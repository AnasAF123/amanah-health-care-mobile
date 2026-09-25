import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class PatientDetailAuroraPainter extends CustomPainter {
  const PatientDetailAuroraPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());

    final Paint baseGlow = Paint()
      ..color = (dark ? AmanahColorTokens.auroraCyanDark : AmanahColorTokens.brandPrimary)
          .withValues(alpha: dark ? 0.60 : 0.50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 62);
    final Paint secondaryGlow = Paint()
      ..color = (dark ? AmanahColorTokens.auroraCyanLuminousDark : AmanahColorTokens.brandLight)
          .withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 56);

    final double baseHeight = dark ? 200 : 180;
    final double secondaryHeight = dark ? 140 : 130;
    final double baseTop = dark ? -size.height * 0.15 : -size.height * 0.10;
    final Rect baseOval = Rect.fromLTWH(
      -size.width * 0.20,
      baseTop,
      size.width * 1.40,
      baseHeight,
    );
    final Rect secondaryOval = Rect.fromLTWH(
      size.width * 0.20,
      size.height * 0.05,
      size.width,
      secondaryHeight,
    );

    canvas.drawOval(baseOval, baseGlow);
    canvas.drawOval(secondaryOval, secondaryGlow);

    final Paint fadeMask = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[AmanahColorTokens.pureBlack, AmanahColorTokens.pureBlack, Colors.transparent],
        stops: <double>[0, 0.25, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, fadeMask);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PatientDetailAuroraPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

class QueueBadgePainter extends CustomPainter {
  QueueBadgePainter(this.queueNumber);

  final String queueNumber;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 48;
    canvas.save();
    canvas.scale(scale, scale);

    final Paint ribbon = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          AmanahColorTokens.brandSubtle,
          AmanahColorTokens.brandLight,
          AmanahColorTokens.auroraAccentDark,
        ],
      ).createShader(const Rect.fromLTWH(12, 20, 24, 32));
    canvas.drawPath(
      Path()
        ..moveTo(13.5, 22)
        ..lineTo(12.5, 50)
        ..lineTo(24, 43.5)
        ..lineTo(35.5, 50)
        ..lineTo(34.5, 22)
        ..close(),
      ribbon,
    );

    const Offset center = Offset(24, 21.5);
    final Paint outer = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.30, -0.40),
        radius: 0.80,
        colors: <Color>[
          AmanahColorTokens.brandSoft,
          AmanahColorTokens.brandAccent,
          AmanahColorTokens.auroraAccentDark,
          AmanahColorTokens.brandMidnight,
        ],
        stops: <double>[0, 0.45, 0.85, 1],
      ).createShader(Rect.fromCircle(center: center, radius: 19));
    canvas.drawCircle(center, 19, outer);
    canvas.drawCircle(
      center,
      19,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AmanahColorTokens.brandSubtle,
    );
    canvas.drawArc(
      const Rect.fromLTWH(7.5, 4.5, 33, 33),
      math.pi * 1.08,
      math.pi * 0.84,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = AmanahColorTokens.pureWhite.withValues(alpha: 0.55),
    );

    final Path rosette = Path();
    for (int i = 0; i < 20; i++) {
      final double angle = -math.pi / 2 + (math.pi * 2 / 20) * i;
      final double radius = i.isEven ? 15.3 : 12.2;
      final Offset p =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        rosette.moveTo(p.dx, p.dy);
      } else {
        rosette.lineTo(p.dx, p.dy);
      }
    }
    rosette.close();
    canvas.drawPath(rosette, Paint()..color = AmanahColorTokens.skySurface);
    canvas.drawPath(
      rosette,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AmanahColorTokens.brandLight,
    );
    canvas.drawCircle(center, 10.5, Paint()..color = AmanahColorTokens.pureWhite);
    canvas.drawCircle(
      center,
      10.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75
        ..color = AmanahColorTokens.brandSubtle,
    );

    final String raw = queueNumber.replaceFirst('#', '');
    final String display = raw.isEmpty
        ? '01'
        : raw.length == 1
        ? '0$raw'
        : raw;
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: display,
        style: TextStyle(
          color: AmanahColorTokens.auroraAccentDark,
          fontSize: display.length > 2 ? 11 : 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(24 - painter.width / 2, 21.5 - painter.height / 2 + 1.8),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant QueueBadgePainter oldDelegate) {
    return oldDelegate.queueNumber != queueNumber;
  }
}
