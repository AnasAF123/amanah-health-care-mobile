import 'package:flutter/material.dart';

/// 3D Game-Style Hex Shield & Ribbon Medal Badge for Patient Queue Number.
/// Matching 1:1 with QueueBadge.tsx in .web
class AmanahQueueBadge extends StatelessWidget {
  const AmanahQueueBadge({
    required this.queueNumber,
    super.key,
    this.size = 68,
    this.onTap,
  });

  final String queueNumber;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String cleanNumber = queueNumber.replaceAll('#', '').trim();
    final String displayValue = cleanNumber.isEmpty
        ? '01'
        : (cleanNumber.length == 1 ? '0$cleanNumber' : cleanNumber);

    return Semantics(
      label: 'Nomor antrean: $displayValue',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            size: Size(size, size),
            painter: _QueueBadgePainter(
              displayValue: displayValue,
              dark: dark,
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueBadgePainter extends CustomPainter {
  const _QueueBadgePainter({required this.displayValue, required this.dark});

  final String displayValue;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. LAYER 1: 3D Hanging Ribbon (Left & Right halves)
    final Path ribbonLeft = Path()
      ..moveTo(34, 46)
      ..lineTo(50, 46)
      ..lineTo(50, 74)
      ..lineTo(34, 85)
      ..close();

    final Paint ribbonLeftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const <Color>[Color(0xFF3B82F6), Color(0xFF2563EB)]
            : const <Color>[Color(0xFF0D66E9), Color(0xFF1D58AC)],
      ).createShader(const Rect.fromLTWH(34, 46, 16, 39));
    canvas.drawPath(ribbonLeft, ribbonLeftPaint);

    final Path ribbonRight = Path()
      ..moveTo(50, 46)
      ..lineTo(66, 46)
      ..lineTo(66, 85)
      ..lineTo(50, 74)
      ..close();

    final Paint ribbonRightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const <Color>[Color(0xFF2563EB), Color(0xFF1D4ED8)]
            : const <Color>[Color(0xFF1D58AC), Color(0xFF0E3A7A)],
      ).createShader(const Rect.fromLTWH(50, 46, 16, 39));
    canvas.drawPath(ribbonRight, ribbonRightPaint);

    // Ribbon bottom V-notch stroke trim
    final Path ribbonTrim = Path()
      ..moveTo(34, 85)
      ..lineTo(50, 74)
      ..lineTo(66, 85);
    final Paint ribbonTrimPaint = Paint()
      ..shader = LinearGradient(
        colors: dark
            ? const <Color>[Color(0xFFDBEAFE), Color(0xFF3B82F6), Color(0xFF1E40AF)]
            : const <Color>[Color(0xFFFFFFFF), Color(0xFF93C5FD), Color(0xFF2563EB)],
      ).createShader(const Rect.fromLTWH(34, 74, 32, 11))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(ribbonTrim, ribbonTrimPaint);

    // 2. LAYER 2: 3D Crystal Mecha Laurel Wings
    // Left Wing
    final Path leftWing = Path()
      ..moveTo(34, 16)
      ..lineTo(3, 8)
      ..lineTo(10, 22)
      ..lineTo(17, 38)
      ..lineTo(24, 38)
      ..lineTo(24, 23)
      ..close();
    final Paint leftWingPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const <Color>[Color(0xFFDBEAFE), Color(0xFF93C5FD), Color(0xFF3B82F6), Color(0xFF2563EB)]
            : const <Color>[Color(0xFFFFFFFF), Color(0xFFBFDBFE), Color(0xFF60A5FA), Color(0xFF0D66E9)],
      ).createShader(const Rect.fromLTWH(3, 8, 31, 30));
    canvas.drawPath(leftWing, leftWingPaint);

    // Left Wing Trim
    final Path leftWingTrim = Path()
      ..moveTo(34, 16)
      ..lineTo(3, 8)
      ..lineTo(10, 22)
      ..lineTo(17, 38)
      ..lineTo(24, 38);
    final Paint wingTrimPaint = Paint()
      ..shader = LinearGradient(
        colors: dark
            ? const <Color>[Color(0xFFDBEAFE), Color(0xFF3B82F6), Color(0xFF1E40AF)]
            : const <Color>[Color(0xFFFFFFFF), Color(0xFF93C5FD), Color(0xFF2563EB)],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 50))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(leftWingTrim, wingTrimPaint);

    // Right Wing
    final Path rightWing = Path()
      ..moveTo(66, 16)
      ..lineTo(97, 8)
      ..lineTo(90, 22)
      ..lineTo(83, 38)
      ..lineTo(76, 38)
      ..lineTo(76, 23)
      ..close();
    final Paint rightWingPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: dark
            ? const <Color>[Color(0xFFDBEAFE), Color(0xFF93C5FD), Color(0xFF3B82F6), Color(0xFF2563EB)]
            : const <Color>[Color(0xFFFFFFFF), Color(0xFFBFDBFE), Color(0xFF60A5FA), Color(0xFF0D66E9)],
      ).createShader(const Rect.fromLTWH(66, 8, 31, 30));
    canvas.drawPath(rightWing, rightWingPaint);

    // Right Wing Trim
    final Path rightWingTrim = Path()
      ..moveTo(66, 16)
      ..lineTo(97, 8)
      ..lineTo(90, 22)
      ..lineTo(83, 38)
      ..lineTo(76, 38);
    canvas.drawPath(rightWingTrim, wingTrimPaint);

    // 3. LAYER 3: 3D Extruded Shield Base
    final Path shieldBase = Path()
      ..moveTo(22, 54)
      ..lineTo(50, 70)
      ..lineTo(78, 54)
      ..lineTo(78, 58)
      ..lineTo(50, 74)
      ..lineTo(22, 58)
      ..close();
    final Paint shieldBasePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? const <Color>[Color(0xFF0369A1), Color(0xFF082F49)]
            : const <Color>[Color(0xFF1D58AC), Color(0xFF0F172A)],
      ).createShader(const Rect.fromLTWH(22, 54, 56, 20));
    canvas.drawPath(shieldBase, shieldBasePaint);

    // 4. LAYER 4: 3D Outer Hexagon Frame
    final Path hexFrame = Path()
      ..moveTo(50, 6)
      ..lineTo(78, 22)
      ..lineTo(78, 54)
      ..lineTo(50, 70)
      ..lineTo(22, 54)
      ..lineTo(22, 22)
      ..close();
    final Paint hexFramePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const <Color>[
                Color(0xFFDBEAFE),
                Color(0xFF3B82F6),
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
                Color(0xFF1E3A8A),
              ]
            : const <Color>[
                Color(0xFFFFFFFF),
                Color(0xFF93C5FD),
                Color(0xFF0D66E9),
                Color(0xFF1D58AC),
                Color(0xFF0E3A7A),
              ],
        stops: const <double>[0.0, 0.15, 0.5, 0.85, 1.0],
      ).createShader(const Rect.fromLTWH(22, 6, 56, 64));
    canvas.drawPath(hexFrame, hexFramePaint);

    // 5. LAYER 5: 3D Inset Chamfer Ring
    final Path hexChamfer = Path()
      ..moveTo(50, 11)
      ..lineTo(73, 24.5)
      ..lineTo(73, 51.5)
      ..lineTo(50, 65)
      ..lineTo(27, 51.5)
      ..lineTo(27, 24.5)
      ..close();
    final Paint hexChamferPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const <Color>[Color(0xFF93C5FD), Color(0xFF3B82F6), Color(0xFF2563EB)]
            : const <Color>[Color(0xFFBFDBFE), Color(0xFF60A5FA), Color(0xFF1D58AC)],
      ).createShader(const Rect.fromLTWH(27, 11, 46, 54));
    canvas.drawPath(hexChamfer, hexChamferPaint);

    // 6. LAYER 6: 3D Crystal Gem Core (Left & Right Facets)
    final Path gemLeft = Path()
      ..moveTo(50, 15)
      ..lineTo(50, 61)
      ..lineTo(32, 49.5)
      ..lineTo(32, 26.5)
      ..close();
    final Paint gemLeftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const <Color>[Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)]
            : const <Color>[Color(0xFF60A5FA), Color(0xFF0D66E9), Color(0xFF1D58AC)],
      ).createShader(const Rect.fromLTWH(32, 15, 18, 46));
    canvas.drawPath(gemLeft, gemLeftPaint);

    final Path gemRight = Path()
      ..moveTo(50, 15)
      ..lineTo(68, 26.5)
      ..lineTo(68, 49.5)
      ..lineTo(50, 61)
      ..close();
    final Paint gemRightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: dark
            ? const <Color>[Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E3A8A)]
            : const <Color>[Color(0xFF1D58AC), Color(0xFF1D58AC), Color(0xFF0E3A7A)],
      ).createShader(const Rect.fromLTWH(50, 15, 18, 46));
    canvas.drawPath(gemRight, gemRightPaint);

    // 7. LAYER 7: Specular Glass Sheen
    final Path specularGloss = Path()
      ..moveTo(32, 26.5)
      ..lineTo(50, 15)
      ..lineTo(68, 26.5)
      ..cubicTo(68, 26.5, 58, 37, 32, 31.5)
      ..close();
    final Paint glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(const Rect.fromLTWH(32, 15, 36, 23));
    canvas.drawPath(specularGloss, glossPaint);

    // 8. LAYER 8: 3D Embossed Number Text
    final double fontSize = displayValue.length > 3
        ? 14.0
        : (displayValue.length > 2 ? 17.0 : 20.0);

    // 3D Shadow Depth Underlayer
    final TextPainter depthPainter = TextPainter(
      text: TextSpan(
        text: displayValue,
        style: TextStyle(
          color: dark ? const Color(0xFF041F3D) : const Color(0xFF0F2B66),
          fontFamily: 'PlusJakartaSans',
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    depthPainter.paint(
      canvas,
      Offset(50 - depthPainter.width / 2, 40.5 - depthPainter.height / 2),
    );

    // Front Bright Face
    final TextPainter frontPainter = TextPainter(
      text: TextSpan(
        text: displayValue,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'PlusJakartaSans',
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          shadows: const <Shadow>[
            Shadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    frontPainter.paint(
      canvas,
      Offset(50 - frontPainter.width / 2, 39.0 - frontPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_QueueBadgePainter oldDelegate) =>
      oldDelegate.displayValue != displayValue || oldDelegate.dark != dark;
}
