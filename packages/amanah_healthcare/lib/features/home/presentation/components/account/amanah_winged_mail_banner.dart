import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahWingedMailBanner extends StatelessWidget {
  const AmanahWingedMailBanner({
    required this.email,
    required this.isVerified,
    required this.dark,
    required this.onActionTap,
    this.onVerifyTap,
    super.key,
  });

  final String email;
  final bool isVerified;
  final bool dark;
  final VoidCallback onActionTap;
  final VoidCallback? onVerifyTap;

  @override
  Widget build(BuildContext context) {
    final String titleText = isVerified
        ? 'Email terverifikasi'
        : 'Belum verifikasi email';

    final Color titleColor = isVerified
        ? (dark ? AmanahColorTokens.skySoft : AmanahColorTokens.skyDark)
        : (dark ? AmanahColorTokens.amberLight : AmanahColorTokens.amberDark);

    final IconData statusIcon = isVerified
        ? Icons.verified_rounded
        : Icons.mark_email_unread_outlined;

    final String buttonLabel = isVerified ? 'Perbarui' : 'Verifikasi email';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: dark
            ? (isVerified
                  ? const LinearGradient(
                      colors: <Color>[AmanahColorTokens.navySurface, AmanahColorTokens.surfaceDark],
                    )
                  : const LinearGradient(
                      colors: <Color>[AmanahColorTokens.amberBgDark, AmanahColorTokens.amberBgDarker],
                    ))
            : (isVerified
                  ? const LinearGradient(
                      colors: <Color>[AmanahColorTokens.skySurface, AmanahColorTokens.skyLight],
                    )
                  : const LinearGradient(
                      colors: <Color>[AmanahColorTokens.amberSurfaceLight, AmanahColorTokens.amberSurfaceSoft],
                    )),
        border: Border.all(
          color: dark
              ? (isVerified
                    ? AmanahThemeTokens.outline(context)
                    : AmanahColorTokens.amberBorderDark)
              : (isVerified
                    ? AmanahColorTokens.skySubtle
                    : AmanahColorTokens.amberBorderLight),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dark
                ? AmanahColorTokens.pureBlack.withValues(alpha: 0.25)
                : AmanahColorTokens.sky.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(statusIcon, size: 16, color: titleColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        titleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (email.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: dark
                          ? AmanahColorTokens.neutral400
                          : AmanahColorTokens.neutral600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: isVerified
                        ? AmanahColorTokens.sky
                        : AmanahColorTokens.warningDark,
                    foregroundColor: AmanahColorTokens.surfaceLight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: isVerified
                      ? onActionTap
                      : (onVerifyTap ?? onActionTap),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 105,
            height: 90,
            child: CustomPaint(painter: _PixelPerfectWingedMailPainter()),
          ),
        ],
      ),
    );
  }
}

class _PixelPerfectWingedMailPainter extends CustomPainter {
  const _PixelPerfectWingedMailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final double scale = math.min(size.width / 120.0, size.height / 110.0);
    canvas.scale(scale, scale);
    canvas.translate(
      (size.width / scale - 120.0) / 2.0,
      (size.height / scale - 110.0) / 2.0,
    );

    final Paint glowPaint = Paint()
      ..color = AmanahColorTokens.amberSurfaceSoft.withValues(alpha: 0.60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(const Offset(68, 48), 28, glowPaint);

    final Path leftWing = Path()
      ..moveTo(52, 31)
      ..cubicTo(45, 28, 38, 18, 34, 10)
      ..cubicTo(31, 6, 26, 8, 27, 13)
      ..cubicTo(28, 17, 31, 22, 33, 24)
      ..cubicTo(27, 21, 23, 23, 24, 27)
      ..cubicTo(25, 31, 29, 34, 35, 36)
      ..cubicTo(30, 35, 27, 38, 29, 42)
      ..cubicTo(32, 46, 40, 45, 52, 35)
      ..close();

    final Paint leftWingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          AmanahColorTokens.surfaceLight,
          AmanahColorTokens.featherGrayLight,
          AmanahColorTokens.featherGray,
        ],
      ).createShader(const Rect.fromLTWH(24, 10, 28, 36));
    canvas.drawPath(leftWing, leftWingPaint);

    final Paint wingStroke = Paint()
      ..color = AmanahColorTokens.neutral400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(leftWing, wingStroke);

    final Path rightWing = Path()
      ..moveTo(64, 31)
      ..cubicTo(71, 28, 78, 18, 82, 10)
      ..cubicTo(85, 6, 90, 8, 89, 13)
      ..cubicTo(88, 17, 85, 22, 83, 24)
      ..cubicTo(89, 21, 93, 23, 92, 27)
      ..cubicTo(91, 31, 87, 34, 81, 36)
      ..cubicTo(86, 35, 89, 38, 87, 42)
      ..cubicTo(84, 46, 76, 45, 64, 35)
      ..close();

    final Paint rightWingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          AmanahColorTokens.surfaceLight,
          AmanahColorTokens.featherGrayLight,
          AmanahColorTokens.featherGray,
        ],
      ).createShader(const Rect.fromLTWH(64, 10, 28, 36));
    canvas.drawPath(rightWing, rightWingPaint);
    canvas.drawPath(rightWing, wingStroke);

    final Path antennaPath = Path()
      ..moveTo(58, 52)
      ..cubicTo(57, 46, 62, 44, 62, 40)
      ..cubicTo(62, 36, 53, 38, 54, 34)
      ..cubicTo(55, 30, 59, 31, 58, 27);

    final Paint antennaPaint = Paint()
      ..color = AmanahColorTokens.neutral800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(antennaPath, antennaPaint);

    canvas.save();
    canvas.translate(58, 74);
    canvas.rotate(-3 * math.pi / 180);
    canvas.translate(-58, -74);

    final Path topFlap = Path()
      ..moveTo(26, 47)
      ..lineTo(58, 31)
      ..lineTo(90, 47)
      ..lineTo(58, 63)
      ..close();
    final Paint flapPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[AmanahColorTokens.skyDeep, AmanahColorTokens.sky],
      ).createShader(const Rect.fromLTWH(26, 31, 64, 32));
    canvas.drawPath(topFlap, flapPaint);

    final Path frontBody = Path()
      ..moveTo(24, 48)
      ..lineTo(58, 64)
      ..lineTo(92, 48)
      ..lineTo(92, 84)
      ..cubicTo(92, 88, 88, 91, 84, 91)
      ..lineTo(32, 91)
      ..cubicTo(28, 91, 24, 88, 24, 84)
      ..close();

    final Paint bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[AmanahColorTokens.mailAirLight, AmanahColorTokens.mailAir],
      ).createShader(const Rect.fromLTWH(24, 48, 68, 43));
    canvas.drawPath(frontBody, bodyPaint);

    final Paint bodyStroke = Paint()
      ..color = AmanahColorTokens.mailAirBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(frontBody, bodyStroke);

    final Paint foldPaint = Paint()
      ..color = AmanahColorTokens.skyDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path folds = Path()
      ..moveTo(24, 49)
      ..lineTo(58, 73)
      ..lineTo(92, 49);
    canvas.drawPath(folds, foldPaint);
    canvas.drawLine(const Offset(25, 89), const Offset(46, 72), foldPaint);
    canvas.drawLine(const Offset(91, 89), const Offset(70, 72), foldPaint);

    final Paint sealOuter = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[AmanahColorTokens.amberLight, AmanahColorTokens.warning],
      ).createShader(const Rect.fromLTWH(46, 61, 24, 24));
    canvas.drawCircle(const Offset(58, 73), 12, sealOuter);

    final Paint sealBorder = Paint()
      ..color = AmanahColorTokens.warning
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(const Offset(58, 73), 12, sealBorder);

    final Paint sealInnerRing = Paint()
      ..color = AmanahColorTokens.amberBorderLight.withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(const Offset(58, 73), 10, sealInnerRing);

    const TextSpan span = TextSpan(
      text: '@',
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w900,
        color: AmanahColorTokens.surfaceLight,
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(58 - tp.width / 2, 73 - tp.height / 2));

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
