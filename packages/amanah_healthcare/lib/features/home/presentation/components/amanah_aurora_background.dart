import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AmanahColorTokens.pureBlack,
                AmanahColorTokens.pureBlack,
                AmanahColorTokens.pureBlack.withValues(alpha: 0.80),
                AmanahColorTokens.pureBlack.withValues(alpha: 0.50),
                AmanahColorTokens.pureBlack.withValues(alpha: 0.25),
                AmanahColorTokens.pureBlack.withValues(alpha: 0.08),
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.28, 0.48, 0.66, 0.80, 0.92, 1.0],
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

class _AmanahAuroraPainter extends CustomPainter {
  const _AmanahAuroraPainter({required this.dark, required this.isSoft});

  final bool dark;
  final bool isSoft;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect fullRect = Offset.zero & size;

    final Paint baseWashPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? <Color>[
                AmanahColorTokens.auroraSapphireDark.withValues(
                  alpha: isSoft ? 0.40 : 0.65,
                ),
                AmanahColorTokens.auroraBlueDark.withValues(
                  alpha: isSoft ? 0.30 : 0.50,
                ),
                AmanahColorTokens.auroraCyanDark.withValues(
                  alpha: isSoft ? 0.25 : 0.40,
                ),
                Colors.transparent,
              ]
            : <Color>[
                AmanahColorTokens.auroraSapphireLight.withValues(
                  alpha: isSoft ? 0.40 : 0.70,
                ),
                AmanahColorTokens.auroraBlueLight.withValues(
                  alpha: isSoft ? 0.35 : 0.60,
                ),
                AmanahColorTokens.skySubtle.withValues(
                  alpha: isSoft ? 0.05 : 0.10,
                ),
                Colors.transparent,
              ],
        stops: dark
            ? const <double>[0.0, 0.32, 0.65, 1.0]
            : const <double>[0.0, 0.42, 0.72, 1.0],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, baseWashPaint);

    final Rect primaryLobeRect = Rect.fromCircle(
      center: Offset(size.width * 0.20, size.height * 0.10),
      radius: size.width * 0.85,
    );
    final Paint primaryPaint = Paint()
      ..shader = RadialGradient(
        colors: dark
            ? <Color>[
                AmanahColorTokens.auroraSapphireDark.withValues(
                  alpha: isSoft ? 0.50 : 0.75,
                ),
                AmanahColorTokens.auroraSapphireDark.withValues(
                  alpha: isSoft ? 0.28 : 0.45,
                ),
                AmanahColorTokens.auroraSapphireDark.withValues(
                  alpha: isSoft ? 0.10 : 0.18,
                ),
                AmanahColorTokens.auroraSapphireDark.withValues(alpha: 0.0),
              ]
            : <Color>[
                AmanahColorTokens.auroraSapphireLight.withValues(
                  alpha: isSoft ? 0.55 : 0.90,
                ),
                AmanahColorTokens.auroraSapphireLight.withValues(
                  alpha: isSoft ? 0.35 : 0.60,
                ),
                AmanahColorTokens.auroraSapphireLight.withValues(
                  alpha: isSoft ? 0.12 : 0.20,
                ),
                AmanahColorTokens.auroraSapphireLight.withValues(alpha: 0.0),
              ],
        stops: const <double>[0.0, 0.40, 0.72, 1.0],
      ).createShader(primaryLobeRect);
    canvas.drawRect(fullRect, primaryPaint);

    final Rect blueLobeRect = Rect.fromCircle(
      center: Offset(size.width * 0.82, size.height * 0.18),
      radius: size.width * 0.75,
    );
    final Paint bluePaint = Paint()
      ..shader = RadialGradient(
        colors: dark
            ? <Color>[
                AmanahColorTokens.auroraBlueDark.withValues(
                  alpha: isSoft ? 0.35 : 0.55,
                ),
                AmanahColorTokens.auroraBlueDark.withValues(
                  alpha: isSoft ? 0.18 : 0.30,
                ),
                AmanahColorTokens.auroraBlueDark.withValues(
                  alpha: isSoft ? 0.05 : 0.10,
                ),
                AmanahColorTokens.auroraBlueDark.withValues(alpha: 0.0),
              ]
            : <Color>[
                AmanahColorTokens.auroraBlueLight.withValues(
                  alpha: isSoft ? 0.45 : 0.80,
                ),
                AmanahColorTokens.auroraBlueLight.withValues(
                  alpha: isSoft ? 0.24 : 0.42,
                ),
                AmanahColorTokens.auroraBlueLight.withValues(
                  alpha: isSoft ? 0.08 : 0.14,
                ),
                AmanahColorTokens.auroraBlueLight.withValues(alpha: 0.0),
              ],
        stops: const <double>[0.0, 0.38, 0.70, 1.0],
      ).createShader(blueLobeRect);
    canvas.drawRect(fullRect, bluePaint);

    final Rect cyanLobeRect = Rect.fromCircle(
      center: Offset(size.width * (dark ? 0.64 : 0.70), size.height * 0.16),
      radius: size.width * (dark ? 0.72 : 0.60),
    );
    final Paint cyanPaint = Paint()
      ..shader = RadialGradient(
        colors: dark
            ? <Color>[
                AmanahColorTokens.auroraCyanLuminousDark.withValues(
                  alpha: isSoft ? 0.32 : 0.48,
                ),
                AmanahColorTokens.auroraCyanDark.withValues(
                  alpha: isSoft ? 0.20 : 0.32,
                ),
                AmanahColorTokens.auroraCyanDark.withValues(
                  alpha: isSoft ? 0.06 : 0.12,
                ),
                AmanahColorTokens.auroraCyanDark.withValues(alpha: 0.0),
              ]
            : <Color>[
                AmanahColorTokens.skySoft.withValues(
                  alpha: isSoft ? 0.08 : 0.14,
                ),
                AmanahColorTokens.skySoft.withValues(
                  alpha: isSoft ? 0.03 : 0.06,
                ),
                AmanahColorTokens.skySoft.withValues(alpha: 0.0),
              ],
        stops: dark
            ? const <double>[0.0, 0.38, 0.72, 1.0]
            : const <double>[0.0, 0.48, 1.0],
      ).createShader(cyanLobeRect);
    canvas.drawRect(fullRect, cyanPaint);

    final Rect centerHazeRect = Rect.fromCircle(
      center: Offset(size.width * 0.50, size.height * 0.40),
      radius: size.width * 0.65,
    );
    final Paint centerPaint = Paint()
      ..shader = RadialGradient(
        colors: dark
            ? <Color>[
                AmanahColorTokens.darkNavy.withValues(
                  alpha: isSoft ? 0.18 : 0.30,
                ),
                AmanahColorTokens.darkNavy.withValues(alpha: 0.0),
              ]
            : <Color>[
                AmanahColorTokens.auroraFluidHazeLight.withValues(
                  alpha: isSoft ? 0.15 : 0.28,
                ),
                AmanahColorTokens.auroraFluidHazeLight.withValues(alpha: 0.0),
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
