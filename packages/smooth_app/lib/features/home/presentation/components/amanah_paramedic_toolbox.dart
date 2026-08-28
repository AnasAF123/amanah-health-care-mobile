import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Paramedic Toolbox Vector Master Component
/// Faithful 1:1 native Flutter translation of ParamedicToolbox3DSvg.tsx from web.
class AmanahParamedicToolbox3D extends StatelessWidget {
  const AmanahParamedicToolbox3D({
    this.isOpen = false,
    this.size = 76.0,
    super.key,
  });

  final bool isOpen;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _AmanahToolbox3DPainter(isOpen: isOpen),
      ),
    );
  }
}

class _AmanahToolbox3DPainter extends CustomPainter {
  const _AmanahToolbox3DPainter({required this.isOpen});

  final bool isOpen;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 100.0;
    canvas.save();
    canvas.scale(s, s);

    // 1. Ambient Drop Shadow under the toolbox
    final Paint shadowPaint1 = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(52, 74), width: 40, height: 14),
      shadowPaint1,
    );

    final Paint shadowPaint2 = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(51, 73.5), width: 30, height: 10),
      shadowPaint2,
    );

    // 2. Deep 3D Extruded Interior Cavity (Visible when isOpen)
    if (isOpen) {
      // Back Interior Walls
      final Path backLeftWall = Path()
        ..moveTo(50, 38)
        ..lineTo(31, 45.5)
        ..lineTo(31, 58)
        ..lineTo(50, 50)
        ..close();
      canvas.drawPath(backLeftWall, Paint()..color = const Color(0xFF111827));

      final Path backRightWall = Path()
        ..moveTo(50, 38)
        ..lineTo(69, 45.5)
        ..lineTo(69, 58)
        ..lineTo(50, 50)
        ..close();
      canvas.drawPath(backRightWall, Paint()..color = const Color(0xFF1F2937));

      // Deep Interior Floor
      final Path interiorFloor = Path()
        ..moveTo(50, 50)
        ..lineTo(69, 58)
        ..lineTo(50, 66)
        ..lineTo(31, 58)
        ..close();
      canvas.drawPath(interiorFloor, Paint()..color = const Color(0xFF0F172A));

      // Front-Facing Interior Walls
      final Path frontInsideLeft = Path()
        ..moveTo(31, 45.5)
        ..lineTo(50, 58)
        ..lineTo(50, 66)
        ..lineTo(31, 58)
        ..close();
      final Paint insideLeftPaint = Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0xFF2A303C), Color(0xFF141822)],
        ).createShader(const Rect.fromLTWH(31, 45.5, 19, 20.5));
      canvas.drawPath(frontInsideLeft, insideLeftPaint);

      final Path frontInsideRight = Path()
        ..moveTo(50, 58)
        ..lineTo(69, 45.5)
        ..lineTo(69, 58)
        ..lineTo(50, 66)
        ..close();
      final Paint insideRightPaint = Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0xFF374151), Color(0xFF1F2937)],
        ).createShader(const Rect.fromLTWH(50, 45.5, 19, 20.5));
      canvas.drawPath(frontInsideRight, insideRightPaint);

      // Rim Lip Thickness
      final Path lipLeft = Path()
        ..moveTo(28.35, 45.5)
        ..lineTo(50, 58)
        ..lineTo(50, 55)
        ..lineTo(31, 45.5)
        ..close();
      canvas.drawPath(lipLeft, Paint()..color = const Color(0xFFE2E8F0));

      final Path lipRight = Path()
        ..moveTo(50, 58)
        ..lineTo(71.65, 45.5)
        ..lineTo(69, 45.5)
        ..lineTo(50, 55)
        ..close();
      canvas.drawPath(lipRight, Paint()..color = const Color(0xFFCBD5E1));

      // Radiant Medical Energy Burst Glow
      final Paint medicalGlow = Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            const Color(0xFF38BDF8),
            const Color(0xFF0EA5E9).withValues(alpha: 0.8),
            const Color(0xFF0284C7).withValues(alpha: 0.0),
          ],
          stops: const <double>[0.0, 0.45, 1.0],
        ).createShader(Rect.fromCenter(center: const Offset(50, 52), width: 32, height: 18));
      canvas.drawOval(Rect.fromCenter(center: const Offset(50, 52), width: 32, height: 18), medicalGlow);
    }

    // 3. Lower Base Body (Fixed Bottom Half)
    // Left Lower Face
    final Path lowerLeftFace = Path()
      ..moveTo(50, 58)
      ..lineTo(28.35, 45.5)
      ..lineTo(28.35, 62.5)
      ..lineTo(50, 75)
      ..close();
    final Paint leftFacePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFB3B3B3), Color(0xFF808080)],
      ).createShader(const Rect.fromLTWH(28.35, 45.5, 21.65, 29.5));
    canvas.drawPath(lowerLeftFace, leftFacePaint);

    // Right Lower Face
    final Path lowerRightFace = Path()
      ..moveTo(50, 58)
      ..lineTo(71.65, 45.5)
      ..lineTo(71.65, 62.5)
      ..lineTo(50, 75)
      ..close();
    final Paint rightFacePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFD9D9D9), Color(0xFFA6A6A6)],
      ).createShader(const Rect.fromLTWH(50, 45.5, 21.65, 29.5));
    canvas.drawPath(lowerRightFace, rightFacePaint);

    // Seam & Edge Lines
    canvas.drawLine(
      const Offset(50, 58),
      const Offset(50, 75),
      Paint()..color = const Color(0xFFE6E6E6)..strokeWidth = 0.75,
    );
    canvas.drawLine(
      const Offset(28.35, 45.5),
      const Offset(28.35, 62.5),
      Paint()..color = const Color(0xFF666666)..strokeWidth = 0.5,
    );
    canvas.drawLine(
      const Offset(71.65, 45.5),
      const Offset(71.65, 62.5),
      Paint()..color = const Color(0xFFCCCCCC)..strokeWidth = 0.5,
    );

    // Red Medical Cross on Left Lower Face (Isometric transformed)
    canvas.save();
    final Matrix4 crossMatrix = Matrix4(
      0.866, 0.5, 0, 0,
      0.0, 1.0, 0, 0,
      0, 0, 1, 0,
      39.175, 60.25, 0, 1,
    );
    canvas.transform(crossMatrix.storage);

    final Path crossPath = Path()
      ..moveTo(-1.5, -5)
      ..lineTo(1.5, -5)
      ..lineTo(1.5, -1.5)
      ..lineTo(5, -1.5)
      ..lineTo(5, 1.5)
      ..lineTo(1.5, 1.5)
      ..lineTo(1.5, 5)
      ..lineTo(-1.5, 5)
      ..lineTo(-1.5, 1.5)
      ..lineTo(-5, 1.5)
      ..lineTo(-5, -1.5)
      ..lineTo(-1.5, -1.5)
      ..close();

    // Shadow
    canvas.save();
    canvas.translate(0, 0.75);
    canvas.drawPath(crossPath, Paint()..color = const Color(0xFF990000).withValues(alpha: 0.8));
    canvas.restore();

    // Main Red Cross
    canvas.drawPath(crossPath, Paint()..color = const Color(0xFFE60000));
    canvas.restore();

    // Latches on Base
    _drawLatchBase(canvas, 55, 55.115);
    _drawLatchBase(canvas, 65, 49.345);

    // 4. Upper Lid (Flips open if isOpen)
    canvas.save();
    if (isOpen) {
      canvas.translate(50, 35);
      canvas.rotate(-18.0 * math.pi / 180.0);
      canvas.translate(-50 - 10, -35 - 24);
    }

    // Upper Left Face
    final Path upperLeftFace = Path()
      ..moveTo(50, 50)
      ..lineTo(28.35, 37.5)
      ..lineTo(28.35, 45.5)
      ..lineTo(50, 58)
      ..close();
    canvas.drawPath(upperLeftFace, leftFacePaint);

    // Upper Right Face
    final Path upperRightFace = Path()
      ..moveTo(50, 50)
      ..lineTo(71.65, 37.5)
      ..lineTo(71.65, 45.5)
      ..lineTo(50, 58)
      ..close();
    canvas.drawPath(upperRightFace, rightFacePaint);

    // Top Face (Brightest)
    final Path topFace = Path()
      ..moveTo(50, 50)
      ..lineTo(71.65, 37.5)
      ..lineTo(50, 25)
      ..lineTo(28.35, 37.5)
      ..close();
    final Paint topFacePaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFFFFFFF), Color(0xFFE8E8E8)],
      ).createShader(const Rect.fromLTWH(28.35, 25, 43.3, 25));
    canvas.drawPath(topFace, topFacePaint);

    // Highlights
    canvas.drawLine(
      const Offset(28.35, 37.5),
      const Offset(50, 50),
      Paint()..color = Colors.white.withValues(alpha: 0.9)..strokeWidth = 0.75,
    );
    canvas.drawLine(
      const Offset(50, 50),
      const Offset(71.65, 37.5),
      Paint()..color = Colors.white..strokeWidth = 0.75,
    );
    canvas.drawLine(
      const Offset(50, 50),
      const Offset(50, 58),
      Paint()..color = const Color(0xFFE6E6E6)..strokeWidth = 0.75,
    );

    // Upper Latches
    _drawLatchUpper(canvas, 55, 55.115);
    _drawLatchUpper(canvas, 65, 49.345);

    // Handle Shadow
    canvas.drawLine(
      const Offset(45, 35.5),
      const Offset(55, 41.5),
      Paint()
        ..color = const Color(0x66646464)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // Handle Base Mounts
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(44.8, 34.5), width: 3.0, height: 1.5),
      Paint()..color = const Color(0xFF1A1A1A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(55.2, 40.5), width: 3.0, height: 1.5),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    // Main 3D Handle
    final Path handlePath = Path()
      ..moveTo(44.8, 34.5)
      ..lineTo(44.8, 25.0)
      ..lineTo(55.2, 31.0)
      ..lineTo(55.2, 40.5);
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Handle Shimmer Highlight
    final Path handleShimmer = Path()
      ..moveTo(44.4, 34.3)
      ..lineTo(44.4, 24.6)
      ..lineTo(54.8, 30.6)
      ..lineTo(54.8, 40.3);
    canvas.drawPath(
      handleShimmer,
      Paint()
        ..color = const Color(0xFF777777)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
    canvas.restore();
  }

  void _drawLatchBase(Canvas canvas, double tx, double ty) {
    canvas.save();
    final Matrix4 latchMatrix = Matrix4(
      0.866, -0.5, 0, 0,
      0.0, 1.0, 0, 0,
      0, 0, 1, 0,
      tx, ty, 0, 1,
    );
    canvas.transform(latchMatrix.storage);
    canvas.drawRect(
      const Rect.fromLTWH(-1.5, 0, 3.0, 3.5),
      Paint()..color = const Color(0xFF888888),
    );
    canvas.restore();
  }

  void _drawLatchUpper(Canvas canvas, double tx, double ty) {
    canvas.save();
    final Matrix4 latchMatrix = Matrix4(
      0.866, -0.5, 0, 0,
      0.0, 1.0, 0, 0,
      0, 0, 1, 0,
      tx, ty, 0, 1,
    );
    canvas.transform(latchMatrix.storage);
    canvas.drawRect(
      const Rect.fromLTWH(-1.5, -3.5, 3.0, 3.5),
      Paint()..color = const Color(0xFFDDDDDD),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AmanahToolbox3DPainter oldDelegate) {
    return oldDelegate.isOpen != isOpen;
  }
}
