import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/account/amanah_telehealth_artwork.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahAccountHeroBanner extends StatelessWidget {
  const AmanahAccountHeroBanner({
    required this.dark,
    this.onIdCardTap,
    super.key,
  });

  final bool dark;
  final VoidCallback? onIdCardTap;

  @override
  Widget build(BuildContext context) {
    const double bannerHeight = 148.0;

    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) {
          if (dark) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AmanahColorTokens.pureBlack,
                AmanahColorTokens.pureBlack.withValues(alpha: 0.80),
                AmanahColorTokens.pureBlack.withValues(alpha: 0.25),
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.45, 0.75, 1.0],
            ).createShader(bounds);
          } else {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AmanahColorTokens.pureBlack.withValues(alpha: 0.54),
                AmanahColorTokens.pureBlack.withValues(alpha: 0.44),
                AmanahColorTokens.pureBlack.withValues(alpha: 0.12),
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.45, 0.75, 1.0],
            ).createShader(bounds);
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _MedicalHeroIllustrationPainter(dark: dark),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 24,
              child: AmanahTelehealthArtwork(dark: dark, onTap: onIdCardTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalHeroIllustrationPainter extends CustomPainter {
  const _MedicalHeroIllustrationPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? const <Color>[
                AmanahColorTokens.brandNavyDark,
                AmanahColorTokens.brandNavy,
                AmanahColorTokens.navySurface,
              ]
            : const <Color>[
                AmanahColorTokens.skySurface,
                AmanahColorTokens.skyLight,
                AmanahColorTokens.skySubtle,
              ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final Paint gridPaint = Paint()
      ..color = AmanahColorTokens.skySoft.withValues(alpha: dark ? 0.08 : 0.12)
      ..strokeWidth = 0.6;
    const double gridSize = 22.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Path midWave = Path()
      ..moveTo(-20, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.44,
        size.width * 0.52,
        size.height * 0.60,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.76,
        size.width + 20,
        size.height * 0.48,
      )
      ..lineTo(size.width + 20, size.height)
      ..lineTo(-20, size.height)
      ..close();

    final Paint midWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? <Color>[
                AmanahColorTokens.cyanDark.withValues(alpha: 0.6),
                AmanahColorTokens.brandNavy.withValues(alpha: 0.8),
              ]
            : <Color>[
                AmanahColorTokens.skySoft.withValues(alpha: 0.35),
                AmanahColorTokens.skyMedium.withValues(alpha: 0.45),
              ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(midWave, midWavePaint);

    final Path deepWave = Path()
      ..moveTo(-20, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.58,
        size.width * 0.60,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.94,
        size.width + 20,
        size.height * 0.65,
      )
      ..lineTo(size.width + 20, size.height)
      ..lineTo(-20, size.height)
      ..close();

    final Paint deepWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const <Color>[AmanahColorTokens.brandNavy, AmanahColorTokens.brandNavyDark]
            : <Color>[
                AmanahColorTokens.sky.withValues(alpha: 0.30),
                AmanahColorTokens.skyDark.withValues(alpha: 0.38),
              ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(deepWave, deepWavePaint);

    final double ecgY = size.height * 0.56;
    final Path ecgPath = Path()
      ..moveTo(-10, ecgY)
      ..lineTo(size.width * 0.20, ecgY)
      ..lineTo(size.width * 0.23, ecgY)
      ..lineTo(size.width * 0.25, ecgY - 14)
      ..lineTo(size.width * 0.27, ecgY + 16)
      ..lineTo(size.width * 0.29, ecgY - 34)
      ..lineTo(size.width * 0.31, ecgY + 18)
      ..lineTo(size.width * 0.33, ecgY - 6)
      ..lineTo(size.width * 0.35, ecgY)
      ..lineTo(size.width * 0.48, ecgY)
      ..lineTo(size.width * 0.50, ecgY - 13)
      ..lineTo(size.width * 0.52, ecgY + 10)
      ..lineTo(size.width * 0.54, ecgY - 24)
      ..lineTo(size.width * 0.56, ecgY + 11)
      ..lineTo(size.width * 0.58, ecgY - 5)
      ..lineTo(size.width * 0.60, ecgY)
      ..lineTo(size.width + 10, ecgY);

    final Paint ecgGlowPaint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[
          AmanahColorTokens.skySoft.withValues(alpha: 0.20),
          AmanahColorTokens.cyanBright,
          AmanahColorTokens.cyanLight,
          AmanahColorTokens.skySoft.withValues(alpha: 0.20),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(ecgPath, ecgGlowPaint);

    final Paint pulsePaint = Paint()
      ..color = AmanahColorTokens.cyanBright
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.29, ecgY - 34), 3.2, pulsePaint);
    canvas.drawCircle(
      Offset(size.width * 0.54, ecgY - 24),
      2.6,
      Paint()..color = AmanahColorTokens.cyanLight,
    );

    _drawPlusSign(
      canvas,
      Offset(size.width * 0.12, size.height * 0.26),
      7,
      AmanahColorTokens.cyanBright,
    );
    _drawPlusSign(
      canvas,
      Offset(size.width * 0.36, size.height * 0.18),
      6,
      AmanahColorTokens.skySoft,
    );
    _drawPlusSign(
      canvas,
      Offset(size.width * 0.50, size.height * 0.28),
      5,
      AmanahColorTokens.surfaceLight.withValues(alpha: 0.8),
    );
  }

  void _drawPlusSign(Canvas canvas, Offset center, double radius, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MedicalHeroIllustrationPainter oldDelegate) =>
      oldDelegate.dark != dark;
}
