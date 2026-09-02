import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

/// AuroraBackground - Dynamic Aurora Ambient Atmosphere master component in Flutter.
/// Implements 1:1 native fluid ambient lighting that seamlessly welds and dissolves
/// into the canvas (#F8FAFF / #0A0E1A) with ZERO hard edges, ZERO oval cutoffs, and ZERO banding.
/// Matching 1:1 with AuroraBackground.tsx & AuroraShaderGradient.tsx (.web)
class AmanahAuroraBackground extends StatelessWidget {
  const AmanahAuroraBackground({
    super.key,
    this.height = 460,
    this.isSoft = false,
  });

  final double height;
  final bool isSoft;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black,
                Colors.black,
                Color(0xCC000000), // 80%
                Color(0x80000000), // 50%
                Color(0x40000000), // 25%
                Color(0x14000000), // 8%
                Color(0x00000000), // 0%
              ],
              stops: <double>[0.0, 0.28, 0.48, 0.66, 0.80, 0.92, 1.0],
            ).createShader(bounds);
          },
          child: CustomPaint(
            size: Size(double.infinity, height),
            painter: _AmanahAuroraPainter(dark: dark, isSoft: isSoft),
          ),
        ),
      ),
    );
  }
}

/// Canvas painter that renders full-bleed multi-lobe ambient fluid radiance without clipping
class _AmanahAuroraPainter extends CustomPainter {
  const _AmanahAuroraPainter({required this.dark, required this.isSoft});

  final bool dark;
  final bool isSoft;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect fullRect = Offset.zero & size;

    // 1. Base Atmospheric Sky Wash (Top horizontal blend)
    final Paint baseWashPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? <Color>[
                AmanahColorTokens.auroraSapphireDark
                    .withValues(alpha: isSoft ? 0.45 : 0.75),
                AmanahColorTokens.auroraBlueDark
                    .withValues(alpha: isSoft ? 0.35 : 0.60),
                Colors.transparent,
              ]
            : <Color>[
                AmanahColorTokens.auroraSapphireLight
                    .withValues(alpha: isSoft ? 0.40 : 0.70),
                AmanahColorTokens.auroraBlueLight
                    .withValues(alpha: isSoft ? 0.35 : 0.60),
                Colors.transparent,
              ],
        stops: const <double>[0.0, 0.45, 1.0],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, baseWashPaint);

    // 2. Primary Lobe (Electric Sapphire Blue at ~20% 10% top-left)
    final Rect primaryLobeRect = Rect.fromCircle(
      center: Offset(size.width * 0.20, size.height * 0.10),
      radius: size.width * 0.85,
    );
    final Paint primaryPaint = Paint()
      ..shader = RadialGradient(
        colors: dark
            ? <Color>[
                AmanahColorTokens.auroraSapphireDark
                    .withValues(alpha: isSoft ? 0.60 : 0.90),
                AmanahColorTokens.auroraSapphireDark
                    .withValues(alpha: isSoft ? 0.38 : 0.60),
                AmanahColorTokens.auroraSapphireDark
                    .withValues(alpha: isSoft ? 0.15 : 0.25),
                const Color(0x0007247A),
              ]
            : <Color>[
                AmanahColorTokens.auroraSapphireLight
                    .withValues(alpha: isSoft ? 0.55 : 0.92),
                AmanahColorTokens.auroraSapphireLight
                    .withValues(alpha: isSoft ? 0.35 : 0.62),
                AmanahColorTokens.auroraSapphireLight
                    .withValues(alpha: isSoft ? 0.12 : 0.22),
                const Color(0x000D66E9),
              ],
        stops: const <double>[0.0, 0.40, 0.72, 1.0],
      ).createShader(primaryLobeRect);
    canvas.drawRect(fullRect, primaryPaint);

    // 3. Secondary Lobe (Radiant Cobalt / Sky Blue at ~82% 18% top-right)
    final Rect blueLobeRect = Rect.fromCircle(
      center: Offset(size.width * 0.82, size.height * 0.18),
      radius: size.width * 0.75,
    );
    final Paint bluePaint = Paint()
      ..shader = RadialGradient(
        colors: dark
            ? <Color>[
                AmanahColorTokens.auroraBlueDark
                    .withValues(alpha: isSoft ? 0.45 : 0.75),
                AmanahColorTokens.auroraBlueDark
                    .withValues(alpha: isSoft ? 0.25 : 0.42),
                AmanahColorTokens.auroraBlueDark
                    .withValues(alpha: isSoft ? 0.08 : 0.15),
                const Color(0x001D4ED8),
              ]
            : <Color>[
                AmanahColorTokens.auroraBlueLight
                    .withValues(alpha: isSoft ? 0.45 : 0.82),
                AmanahColorTokens.auroraBlueLight
                    .withValues(alpha: isSoft ? 0.24 : 0.45),
                AmanahColorTokens.auroraBlueLight
                    .withValues(alpha: isSoft ? 0.08 : 0.15),
                const Color(0x002563EB),
              ],
        stops: const <double>[0.0, 0.38, 0.70, 1.0],
      ).createShader(blueLobeRect);
    canvas.drawRect(fullRect, bluePaint);

    // 4. Subtle Tertiary Fluid Haze (Center-Mid blend at 50% 40%)
    final Rect centerHazeRect = Rect.fromCircle(
      center: Offset(size.width * 0.50, size.height * 0.40),
      radius: size.width * 0.65,
    );
    final Paint centerPaint = Paint()
      ..shader = RadialGradient(
        colors: dark
            ? <Color>[
                const Color(0xFF14103B).withValues(alpha: isSoft ? 0.20 : 0.35),
                const Color(0x0014103B),
              ]
            : <Color>[
                const Color(0xFF70A6FF).withValues(alpha: isSoft ? 0.15 : 0.28),
                const Color(0x0070A6FF),
              ],
        stops: const <double>[0.0, 1.0],
      ).createShader(centerHazeRect);
    canvas.drawRect(fullRect, centerPaint);
  }

  @override
  bool shouldRepaint(_AmanahAuroraPainter oldDelegate) {
    return oldDelegate.dark != dark || oldDelegate.isSoft != isSoft;
  }
}
