import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Master Shader & Style Tokens for Amanah Directional Chevrons.
///
/// Centralizes the theme-adaptive color palettes and linear shaders.
/// For Dark Theme: Always combines [AmanahColorTokens.tabActiveDark] (#22D3EE • Cyan 400).
/// For Light Theme: Harmonizes with medical brand sapphire/sky tokens.
abstract final class AmanahChevronTheme {
  /// Returns the linear gradient shader for the glowing aerodynamic neon aura.
  static Shader createGlowShader({
    required Rect bounds,
    required double glowIntensity,
    required double opacity,
    required bool isDark,
  }) {
    final List<Color> colors = isDark
        ? <Color>[
            AmanahColorTokens.tabActiveDark.withValues(
              alpha: 0.65 * glowIntensity * opacity,
            ),
            AmanahColorTokens.auroraCyanDark.withValues(
              alpha: 0.90 * glowIntensity * opacity,
            ),
            AmanahColorTokens.tabActiveDark.withValues(
              alpha: 0.65 * glowIntensity * opacity,
            ),
          ]
        : <Color>[
            AmanahColorTokens.brandSoft.withValues(
              alpha: 0.60 * glowIntensity * opacity,
            ),
            AmanahColorTokens.brandPrimary.withValues(
              alpha: 0.85 * glowIntensity * opacity,
            ),
            AmanahColorTokens.brandSoft.withValues(
              alpha: 0.60 * glowIntensity * opacity,
            ),
          ];

    return ui.Gradient.linear(
      bounds.topLeft,
      bounds.bottomRight,
      colors,
      const <double>[0.0, 0.50, 1.0],
    );
  }

  /// Returns the linear gradient shader for the high-precision metallic blade stroke.
  static Shader createBladeShader({
    required Rect bounds,
    required double opacity,
    required bool isDark,
  }) {
    final List<Color> colors = isDark
        ? <Color>[
            AmanahColorTokens.tabActiveDark.withValues(
              alpha: opacity * 0.90,
            ),
            AmanahColorTokens.auroraCyanDark.withValues(
              alpha: opacity,
            ),
            AmanahColorTokens.tabActiveDark.withValues(
              alpha: opacity * 0.90,
            ),
          ]
        : <Color>[
            AmanahColorTokens.brandLight.withValues(
              alpha: opacity * 0.85,
            ),
            AmanahColorTokens.brandPrimary.withValues(
              alpha: opacity,
            ),
            AmanahColorTokens.brandLight.withValues(
              alpha: opacity * 0.85,
            ),
          ];

    return ui.Gradient.linear(
      bounds.topLeft,
      bounds.bottomRight,
      colors,
      const <double>[0.0, 0.50, 1.0],
    );
  }
}

/// Central Master Renderer for Amanah Directional Chevrons.
///
/// Single Source of Truth for chevron geometry, vector path construction,
/// theme-adaptive shaders, and animation rendering across both the Queue screen
/// and Pull-To-Refresh components.
abstract final class AmanahChevronRenderer {
  static const double wingWidth = 26.0;
  static const double wingHeight = 6.5;
  static const double spacing = 7.5;
  static const int count = 3;

  /// Builds the vector path for a single V-shaped chevron wing.
  static Path buildChevronPath({
    required double centerX,
    required double yOffset,
    required double scale,
    double width = wingWidth,
    double height = wingHeight,
  }) {
    return Path()
      ..moveTo(centerX - (width / 2) * scale, yOffset)
      ..lineTo(centerX, yOffset + height * scale)
      ..lineTo(centerX + (width / 2) * scale, yOffset);
  }

  /// Renders a single chevron wing with neon aura glow and metallic blade stroke.
  static void paintWing({
    required Canvas canvas,
    required double centerX,
    required double yOffset,
    required double scale,
    required double opacity,
    required double glowIntensity,
    required bool isDark,
    double width = wingWidth,
    double height = wingHeight,
  }) {
    if (opacity <= 0.01) {
      return;
    }

    final Path chevronPath = buildChevronPath(
      centerX: centerX,
      yOffset: yOffset,
      scale: scale,
      width: width,
      height: height,
    );

    final Rect bounds = Rect.fromLTWH(
      centerX - width / 2,
      yOffset,
      width,
      height,
    );

    // 1. Aerodynamic Neon Aura Blur (Glow Flare on Impulse)
    if (glowIntensity > 0.10) {
      final Shader glowShader = AmanahChevronTheme.createGlowShader(
        bounds: bounds,
        glowIntensity: glowIntensity,
        opacity: opacity,
        isDark: isDark,
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
    final Shader bladeShader = AmanahChevronTheme.createBladeShader(
      bounds: bounds,
      opacity: opacity,
      isDark: isDark,
    );

    final Paint bladePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = bladeShader;

    canvas.drawPath(chevronPath, bladePaint);
  }

  /// Renders the sequential kinetic wave pulse animation across all tiers.
  static void paintWavePulse({
    required Canvas canvas,
    required Size size,
    required double progress,
    required bool isDark,
    double masterOpacity = 1.0,
    double? topBaseY,
  }) {
    final double centerX = size.width / 2;
    final double startY = topBaseY ?? 0.0;

    for (int i = 0; i < count; i++) {
      final double tierOffset = i * 0.18;
      final double t = (progress - tierOffset) % 1.0;
      final double normalized = t < 0 ? t + 1.0 : t;

      double waveProgress;
      if (normalized < 0.40) {
        waveProgress = Curves.easeOutCubic.transform(normalized / 0.40);
      } else {
        waveProgress =
            1.0 - Curves.easeInOut.transform((normalized - 0.40) / 0.60);
      }

      final double yOffset = startY + (i * spacing) + (waveProgress * 3.5);
      final double opacity =
          (0.28 + waveProgress * 0.72).clamp(0.0, 1.0) * masterOpacity;
      final double scale = 0.94 + (waveProgress * 0.08);

      paintWing(
        canvas: canvas,
        centerX: centerX,
        yOffset: yOffset,
        scale: scale,
        opacity: opacity,
        glowIntensity: waveProgress,
        isDark: isDark,
      );
    }
  }

  /// Renders progressive reveal chevrons during pull-down gesture.
  static void paintPullProgress({
    required Canvas canvas,
    required Size size,
    required double pullProgress,
    required bool isDark,
    double masterOpacity = 1.0,
    required double topBaseY,
  }) {
    final double centerX = size.width / 2;

    for (int i = 0; i < count; i++) {
      final double startP = switch (i) {
        0 => 0.15,
        1 => 0.35,
        _ => 0.60,
      };
      final double endP = switch (i) {
        0 => 0.35,
        1 => 0.60,
        _ => 0.90,
      };

      final double t =
          ((pullProgress - startP) / (endP - startP)).clamp(0.0, 1.0);

      if (t <= 0.0) {
        continue;
      }

      final double chevronOpacity =
          Curves.easeOutQuad.transform(t) * masterOpacity;
      final double chevronScale = 0.85 + (0.15 * t);
      final double translateUp = -6.0 * (1.0 - t);
      final double yOffset = topBaseY + (i * spacing) + translateUp;

      double glowIntensity = 0.0;
      if (pullProgress >= 0.95) {
        glowIntensity = 0.85;
      } else if (t > 0.5) {
        glowIntensity = (t - 0.5) * 1.2;
      }

      paintWing(
        canvas: canvas,
        centerX: centerX,
        yOffset: yOffset,
        scale: chevronScale,
        opacity: chevronOpacity,
        glowIntensity: glowIntensity,
        isDark: isDark,
      );
    }
  }
}

/// Custom painter for autonomous kinetic wave pulsing chevrons.
class _RacingChevronPainter extends CustomPainter {
  const _RacingChevronPainter({
    required this.progress,
    required this.isDark,
  });

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    AmanahChevronRenderer.paintWavePulse(
      canvas: canvas,
      size: size,
      progress: progress,
      isDark: isDark,
    );
  }

  @override
  bool shouldRepaint(covariant _RacingChevronPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

/// Premium Automotive / Racing Game-Style Dynamic Directional Chevrons.
///
/// Master widget providing autonomous staggered kinetic impulse wave with
/// aerodynamic neon glow trails, seamlessly adapted for Light & Dark themes.
class AmanahRacingPulseChevrons extends StatefulWidget {
  const AmanahRacingPulseChevrons({super.key, this.isDark});

  /// Optional explicit dark theme override. When omitted, automatically resolves
  /// from [Theme.of(context).brightness].
  final bool? isDark;

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
    final bool effectiveDark =
        widget.isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          size: const Size(32, 34),
          painter: _RacingChevronPainter(
            progress: _controller.value,
            isDark: effectiveDark,
          ),
        );
      },
    );
  }
}
