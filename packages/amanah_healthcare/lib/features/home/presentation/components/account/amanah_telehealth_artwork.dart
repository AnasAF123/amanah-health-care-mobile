import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Telehealth Tablet Artwork matching POC's right hero elements
class AmanahTelehealthArtwork extends StatelessWidget {
  const AmanahTelehealthArtwork({required this.dark, this.onTap, super.key});

  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 175,
        height: 125,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Tilted Telehealth Tablet (-12 deg)
            Positioned(
              right: 18,
              top: 8,
              child: Transform.rotate(
                angle: -12 * math.pi / 180,
                child: Container(
                  width: 95,
                  height: 110,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: dark
                          ? const <Color>[AmanahColorTokens.skyDark, AmanahColorTokens.brandNavy]
                          : const <Color>[AmanahColorTokens.skySoft, AmanahColorTokens.sky],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dark
                          ? AmanahColorTokens.sky
                          : AmanahColorTokens.skySubtle,
                      width: 2,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: dark
                            ? AmanahColorTokens.pureBlack.withValues(alpha: 0.30)
                            : AmanahColorTokens.sky.withValues(alpha: 0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AmanahColorTokens.skySoft.withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 80,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: dark
                                ? const <Color>[
                                    AmanahColorTokens.neutral900,
                                    AmanahColorTokens.neutral800,
                                  ]
                                : const <Color>[
                                    AmanahColorTokens.surfaceLight,
                                    AmanahColorTokens.skySurface,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    AmanahColorTokens.sky,
                                    AmanahColorTokens.skySoft,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: AmanahColorTokens.surfaceLight,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                              width: 55,
                              child: CustomPaint(painter: _MiniVitalsPainter()),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: AmanahColorTokens.cyanBright.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AmanahColorTokens.cyanBright.withValues(alpha: 0.60),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'TeleCare Active',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                  color: dark
                                      ? AmanahColorTokens.skySoft
                                      : AmanahColorTokens.skyDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AmanahColorTokens.skySoft.withValues(alpha: 0.50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[AmanahColorTokens.sky, AmanahColorTokens.cyanBright],
                  ),
                  border: Border.all(
                    color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.80),
                    width: 1.2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AmanahColorTokens.pureBlack.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AmanahColorTokens.surfaceLight,
                  size: 20,
                ),
              ),
            ),
            Positioned(
              right: 2,
              top: 36,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: <Color>[AmanahColorTokens.cyanBright, AmanahColorTokens.sky],
                  ),
                  border: Border.all(
                    color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.80),
                    width: 1.2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AmanahColorTokens.pureBlack.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AmanahColorTokens.surfaceLight,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniVitalsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(size.width * 0.30, size.height * 0.5)
      ..lineTo(size.width * 0.40, 0)
      ..lineTo(size.width * 0.50, size.height)
      ..lineTo(size.width * 0.60, size.height * 0.2)
      ..lineTo(size.width * 0.70, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.5);

    final Paint paint = Paint()
      ..color = AmanahColorTokens.sky
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
