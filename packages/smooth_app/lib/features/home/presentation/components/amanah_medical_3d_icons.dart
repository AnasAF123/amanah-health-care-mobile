import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

/// Atom: 3D Glossy Medical Icons with Depth Extrusions, Specular Gloss, and Gradients.
/// Replicating Medical3DIcons.tsx (.web) 1:1 with 100% Solid Opacity & Vibrant Gradients.
class AmanahMedical3DIcon extends StatelessWidget {
  const AmanahMedical3DIcon({
    required this.name,
    this.size = 130.0,
    this.isDark = false,
    super.key,
  });

  final String name;
  final double size;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _Medical3DIconPainter(name: name, isDark: isDark),
      ),
    );
  }
}

class _Medical3DIconPainter extends CustomPainter {
  const _Medical3DIconPainter({required this.name, required this.isDark});

  final String name;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Scale coordinate system to 100x100 virtual canvas
    canvas.scale(size.width / 100.0, size.height / 100.0);

    // Primary Gradients
    const Rect bounds = Rect.fromLTWH(0, 0, 100, 100);

    final Paint blueMainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const <Color>[
                Color(0xFF38BDF8), // 0%: sky-400
                Color(0xFF0284C7), // 45%: sky-600
                Color(0xFF0369A1), // 100%: sky-700
              ]
            : const <Color>[
                AmanahColorTokens.brandSubtle,
                AmanahColorTokens.brandLight,
                AmanahColorTokens.brand,
              ],
        stops: isDark ? const <double>[0.0, 0.45, 1.0] : null,
      ).createShader(bounds);

    final Paint blueDarkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const <Color>[
                Color(0xFF0284C7), // 0%: sky-600
                Color(0xFF082F49), // 100%: deep shadow extrusion
              ]
            : const <Color>[
                AmanahColorTokens.brand,
                AmanahColorTokens.brandAccent,
              ],
      ).createShader(bounds);

    final Paint highlightGradPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const <Color>[
                Color(0xFFF0FDFA), // 0%: luminous cyan-50
                Color(0xFF67E8F9), // 50%: luminous cyan-300
                Color(0xFF06B6D4), // 100%: cyan-500
              ]
            : const <Color>[Colors.white, AmanahColorTokens.brandMuted],
        stops: isDark ? const <double>[0.0, 0.5, 1.0] : null,
      ).createShader(bounds);

    final Paint glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withValues(alpha: isDark ? 0.40 : 0.85),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(bounds);

    // Render respective icon
    switch (name) {
      case 'syringe':
        _paintSyringe(canvas, blueMainPaint, highlightGradPaint, glossPaint);
      case 'dna':
        _paintDna(canvas, blueMainPaint, blueDarkPaint);
      case 'shield':
        _paintShield(
          canvas,
          blueMainPaint,
          blueDarkPaint,
          highlightGradPaint,
          glossPaint,
        );
      case 'briefcase':
      default:
        _paintBriefcase(
          canvas,
          blueMainPaint,
          blueDarkPaint,
          highlightGradPaint,
          glossPaint,
        );
    }

    canvas.restore();
  }

  void _paintBriefcase(
    Canvas canvas,
    Paint blueMain,
    Paint blueDark,
    Paint highlightGrad,
    Paint gloss,
  ) {
    // 1. Handle Shadow Extrusion
    final Path handleExtrusion = Path()
      ..moveTo(35, 22)
      ..cubicTo(35, 12, 65, 12, 65, 22);
    canvas.drawPath(
      handleExtrusion,
      Paint()
        ..shader = blueDark.shader
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 2. Handle Front
    final Path handle = Path()
      ..moveTo(35, 18)
      ..cubicTo(35, 8, 65, 8, 65, 18);
    canvas.drawPath(
      handle,
      Paint()
        ..color = isDark ? const Color(0xFF38BDF8) : const Color(0xFFBFDBFE)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 3. Extruded Body Shadow (Dark Blue Base)
    final RRect bodyExtrusion = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 32, 80, 60),
      const Radius.circular(14),
    );
    canvas.drawRRect(bodyExtrusion, blueDark);

    // 4. Main Case Body (Vibrant Blue)
    final RRect body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 24, 80, 60),
      const Radius.circular(14),
    );
    canvas.drawRRect(body, blueMain);

    // 5. Gloss Specular on Top Half of Body
    final Path glossPath = Path()
      ..moveTo(10, 36)
      ..quadraticBezierTo(50, 42, 90, 36)
      ..lineTo(90, 24)
      ..lineTo(10, 24)
      ..close();
    canvas.drawPath(glossPath, gloss);

    // 6. White Inset Rim Border
    final RRect bodyStroke = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 26, 76, 56),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      bodyStroke,
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.50 : 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 7. Central Badge Plate with Rounded Corners (Dark: #0C4A6E, Light: #E0F2FE)
    final RRect badgePlate = RRect.fromRectAndRadius(
      const Rect.fromLTWH(32, 38, 36, 36),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      badgePlate,
      Paint()..color = isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE),
    );

    // 8. Medical Cross on Badge Plate (Dark: #38BDF8, Light: blueMain)
    final Path crossPath = Path()
      ..moveTo(45, 43)
      ..lineTo(55, 43)
      ..lineTo(55, 49)
      ..lineTo(61, 49)
      ..lineTo(61, 59)
      ..lineTo(55, 59)
      ..lineTo(55, 65)
      ..lineTo(45, 65)
      ..lineTo(45, 59)
      ..lineTo(39, 59)
      ..lineTo(39, 49)
      ..lineTo(45, 49)
      ..close();
    canvas.drawPath(
      crossPath,
      isDark ? (Paint()..color = const Color(0xFF38BDF8)) : blueMain,
    );
  }

  void _paintSyringe(
    Canvas canvas,
    Paint blueMain,
    Paint highlightGrad,
    Paint gloss,
  ) {
    canvas.save();
    canvas.translate(50, 50);
    canvas.rotate(-45 * math.pi / 180);
    canvas.translate(-50, -50);

    // Plunger
    canvas.drawRect(
      const Rect.fromLTWH(45, 5, 10, 25),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(35, 2, 30, 6),
        const Radius.circular(3),
      ),
      highlightGrad,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(42, 26, 16, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Syringe Barrel Liquid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(38, 25, 24, 45),
        const Radius.circular(4),
      ),
      Paint()
        ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
    );
    canvas.drawPath(
      Path()
        ..moveTo(40, 40)
        ..lineTo(60, 40)
        ..lineTo(60, 66)
        ..quadraticBezierTo(50, 68, 40, 66)
        ..close(),
      blueMain,
    );
    // Top Liquid Meniscus Ellipse
    canvas.drawOval(
      const Rect.fromLTWH(40, 37, 20, 6),
      Paint()..color = isDark ? const Color(0xFF38BDF8) : const Color(0xFF60A5FA),
    );

    // Glass Barrel Outline & Specular
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(38, 25, 24, 45),
        const Radius.circular(4),
      ),
      Paint()
        ..shader = highlightGrad.shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 25, 44, 6),
        const Radius.circular(3),
      ),
      highlightGrad,
    );

    // Graduated Measurement Lines
    final Paint linePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(40, 45), const Offset(48, 45), linePaint);
    canvas.drawLine(const Offset(40, 52), const Offset(45, 52), linePaint);
    canvas.drawLine(const Offset(40, 59), const Offset(48, 59), linePaint);

    // Needle Tip
    canvas.drawPath(
      Path()
        ..moveTo(43, 70)
        ..lineTo(57, 70)
        ..lineTo(54, 78)
        ..lineTo(46, 78)
        ..close(),
      blueMain,
    );
    canvas.drawRect(
      const Rect.fromLTWH(49, 78, 2, 20),
      Paint()..color = const Color(0xFF94A3B8),
    );

    // Droplet (Luminous Cyan Gradient in dark mode)
    canvas.drawPath(
      Path()
        ..moveTo(50, 105)
        ..cubicTo(48, 102, 47, 100, 50, 98)
        ..cubicTo(53, 100, 52, 102, 50, 105)
        ..close(),
      highlightGrad,
    );

    canvas.restore();
  }

  void _paintDna(Canvas canvas, Paint blueMain, Paint blueDark) {
    // 1. Back Strand Shadow / Extrusion (Dark Blue)
    final Path strand1Ext = Path()
      ..moveTo(30, 10)
      ..cubicTo(70, 30, 70, 50, 30, 70);
    final Path strand2Ext = Path()
      ..moveTo(30, 30)
      ..cubicTo(70, 50, 70, 70, 30, 90);

    final Paint strandExtPaint = Paint()
      ..shader = blueDark.shader
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(strand1Ext, strandExtPaint);
    canvas.drawPath(strand2Ext, strandExtPaint);

    // 2. Molecular Cross Links (Back Layer)
    final Paint bondExtPaint = Paint()
      ..shader = blueDark.shader
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(45, 25), const Offset(60, 35), bondExtPaint);
    canvas.drawLine(const Offset(40, 50), const Offset(65, 50), bondExtPaint);
    canvas.drawLine(const Offset(45, 75), const Offset(60, 65), bondExtPaint);

    // 3. Front Strands (Main Vibrant Blue)
    final Path front1 = Path()
      ..moveTo(70, 10)
      ..cubicTo(30, 30, 30, 50, 70, 70);
    final Path front2 = Path()
      ..moveTo(70, 30)
      ..cubicTo(30, 50, 30, 70, 70, 90);

    final Paint frontStrandPaint = Paint()
      ..shader = blueMain.shader
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(front1, frontStrandPaint);
    canvas.drawPath(front2, frontStrandPaint);

    // 4. White Specular Glint Highlight along Front Strands
    final Path glint1 = Path()
      ..moveTo(68.5, 8.5)
      ..cubicTo(28.5, 28.5, 28.5, 48.5, 68.5, 68.5);
    final Path glint2 = Path()
      ..moveTo(68.5, 28.5)
      ..cubicTo(28.5, 48.5, 28.5, 68.5, 68.5, 88.5);

    final Paint glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.60)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(glint1, glintPaint);
    canvas.drawPath(glint2, glintPaint);

    // 5. Front Molecular Cross Links (Luminous Light Blue #38BDF8 / White)
    final Paint bondHighlight = Paint()
      ..color = isDark ? const Color(0xFF38BDF8) : const Color(0xFFDBEAFE)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(40, 22), const Offset(55, 32), bondHighlight);
    canvas.drawLine(const Offset(35, 50), const Offset(60, 50), bondHighlight);
    canvas.drawLine(const Offset(40, 78), const Offset(55, 68), bondHighlight);
  }

  void _paintShield(
    Canvas canvas,
    Paint blueMain,
    Paint blueDark,
    Paint highlightGrad,
    Paint gloss,
  ) {
    // 1. Shield Extrusion (Dark Blue Base)
    final Path shieldExt = Path()
      ..moveTo(50, 21)
      ..quadraticBezierTo(85, 26, 90, 31)
      ..quadraticBezierTo(95, 66, 50, 101)
      ..quadraticBezierTo(5, 66, 10, 31)
      ..quadraticBezierTo(15, 26, 50, 21)
      ..close();
    canvas.drawPath(shieldExt, blueDark);

    // 2. Main Shield Body (Vibrant Blue)
    final Path shield = Path()
      ..moveTo(50, 15)
      ..quadraticBezierTo(85, 20, 90, 25)
      ..quadraticBezierTo(95, 60, 50, 95)
      ..quadraticBezierTo(5, 60, 10, 25)
      ..quadraticBezierTo(15, 20, 50, 15)
      ..close();
    canvas.drawPath(shield, blueMain);

    // 3. Inner cyan highlight / stroke rim
    final Path innerRim = Path()
      ..moveTo(50, 20)
      ..quadraticBezierTo(81, 24.5, 85, 29)
      ..quadraticBezierTo(89.5, 58, 50, 88)
      ..quadraticBezierTo(10.5, 58, 15, 29)
      ..quadraticBezierTo(19, 24.5, 50, 20)
      ..close();
    canvas.drawPath(
      innerRim,
      Paint()
        ..shader = highlightGrad.shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 4. Specular Gloss
    final Path shieldGloss = Path()
      ..moveTo(50, 15)
      ..quadraticBezierTo(70, 17.8, 75, 21.4)
      ..quadraticBezierTo(80, 45, 50, 70)
      ..quadraticBezierTo(20, 45, 25, 21.4)
      ..quadraticBezierTo(30, 17.8, 50, 15)
      ..close();
    canvas.drawPath(shieldGloss, gloss);

    // 5. Medical Cross (cyan gradient in dark, solid white in light)
    final Path cross = Path()
      ..moveTo(42, 36)
      ..lineTo(58, 36)
      ..lineTo(58, 42)
      ..lineTo(64, 42)
      ..lineTo(64, 56)
      ..lineTo(58, 56)
      ..lineTo(58, 62)
      ..lineTo(42, 62)
      ..lineTo(42, 56)
      ..lineTo(36, 56)
      ..lineTo(36, 42)
      ..lineTo(42, 42)
      ..close();
    canvas.drawPath(
      cross,
      isDark ? highlightGrad : (Paint()..color = Colors.white),
    );
  }

  @override
  bool shouldRepaint(covariant _Medical3DIconPainter oldDelegate) =>
      oldDelegate.name != name || oldDelegate.isDark != isDark;
}
