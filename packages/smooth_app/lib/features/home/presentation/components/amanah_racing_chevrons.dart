import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

/// Premium Automotive / Racing Game-Style Dynamic Directional Chevrons
/// Staggered kinetic impulse wave with aerodynamic neon glow trails
class AmanahRacingPulseChevrons extends StatefulWidget {
  const AmanahRacingPulseChevrons({super.key});

  @override
  State<AmanahRacingPulseChevrons> createState() =>
      _AmanahRacingPulseChevronsState();
}

class _AmanahRacingPulseChevronsState extends State<AmanahRacingPulseChevrons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: const Size(32, 34),
          painter: _RacingChevronPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _RacingChevronPainter extends CustomPainter {
  const _RacingChevronPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const double wingWidth = 26.0;
    const double wingHeight = 6.5;
    const double spacing = 7.5;
    const int count = 3;

    final double centerX = size.width / 2;

    for (int i = 0; i < count; i++) {
      // Staggered wave timing for each chevron tier
      final double tierOffset = i * 0.18;
      final double t = (progress - tierOffset) % 1.0;
      final double normalized = t < 0 ? t + 1.0 : t;

      // Kinetic pulse curve: sharp impulse forward, smooth ease-back
      double waveProgress;
      if (normalized < 0.40) {
        waveProgress = Curves.easeOutCubic.transform(normalized / 0.40);
      } else {
        waveProgress =
            1.0 - Curves.easeInOut.transform((normalized - 0.40) / 0.60);
      }

      final double yOffset = i * spacing + (waveProgress * 3.5);
      final double opacity = (0.28 + waveProgress * 0.72).clamp(0.0, 1.0);
      final double scale = 0.94 + (waveProgress * 0.08);

      final Path chevronPath = Path()
        ..moveTo(centerX - (wingWidth / 2) * scale, yOffset)
        ..lineTo(centerX, yOffset + wingHeight * scale)
        ..lineTo(centerX + (wingWidth / 2) * scale, yOffset);

      // 1. Aerodynamic Neon Aura Blur (Glow Flare on Impulse)
      if (waveProgress > 0.15) {
        final Shader glowShader = ui.Gradient.linear(
          Offset(centerX - wingWidth / 2, yOffset),
          Offset(centerX + wingWidth / 2, yOffset + wingHeight),
          <Color>[
            AmanahColorTokens.brandSoft.withValues(alpha: 0.60 * waveProgress),
            AmanahColorTokens.brandPrimary.withValues(
              alpha: 0.85 * waveProgress,
            ),
            AmanahColorTokens.brandSoft.withValues(alpha: 0.60 * waveProgress),
          ],
          const <double>[0.0, 0.50, 1.0],
        );

        final Paint glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = glowShader
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

        canvas.drawPath(chevronPath, glowPaint);
      }

      // 2. High-Precision Racing Metallic Blade Stroke
      final Shader bladeShader = ui.Gradient.linear(
        Offset(centerX - wingWidth / 2, yOffset),
        Offset(centerX + wingWidth / 2, yOffset + wingHeight),
        <Color>[
          AmanahColorTokens.brandLight.withValues(alpha: opacity * 0.85),
          AmanahColorTokens.brandPrimary.withValues(alpha: opacity),
          AmanahColorTokens.brandLight.withValues(alpha: opacity * 0.85),
        ],
        const <double>[0.0, 0.50, 1.0],
      );

      final Paint bladePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = bladeShader;

      canvas.drawPath(chevronPath, bladePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RacingChevronPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
