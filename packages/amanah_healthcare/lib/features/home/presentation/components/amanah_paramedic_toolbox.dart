import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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
      ..color = AmanahColorTokens.pureBlack.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(52, 74), width: 40, height: 14),
      shadowPaint1,
    );

    final Paint shadowPaint2 = Paint()
      ..color = AmanahColorTokens.pureBlack.withValues(alpha: 0.25)
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
      canvas.drawPath(backLeftWall, Paint()..color = AmanahColorTokens.toolboxCavityBackLeft);

      final Path backRightWall = Path()
        ..moveTo(50, 38)
        ..lineTo(69, 45.5)
        ..lineTo(69, 58)
        ..lineTo(50, 50)
        ..close();
      canvas.drawPath(backRightWall, Paint()..color = AmanahColorTokens.toolboxCavityBackRight);

      // Deep Interior Floor
      final Path interiorFloor = Path()
        ..moveTo(50, 50)
        ..lineTo(69, 58)
        ..lineTo(50, 66)
        ..lineTo(31, 58)
        ..close();
      canvas.drawPath(interiorFloor, Paint()..color = AmanahColorTokens.neutral900);

      // Front-Facing Interior Walls
      final Path frontInsideLeft = Path()
        ..moveTo(31, 45.5)
        ..lineTo(50, 58)
        ..lineTo(50, 66)
        ..lineTo(31, 58)
        ..close();
      final Paint insideLeftPaint = Paint()
        ..shader = const LinearGradient(
          colors: <Color>[AmanahColorTokens.toolboxCavityLeftTop, AmanahColorTokens.toolboxCavityLeftBottom],
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
          colors: <Color>[AmanahColorTokens.toolboxCavityRightTop, AmanahColorTokens.toolboxCavityBackRight],
        ).createShader(const Rect.fromLTWH(50, 45.5, 19, 20.5));
      canvas.drawPath(frontInsideRight, insideRightPaint);

      // Rim Lip Thickness
      final Path lipLeft = Path()
        ..moveTo(28.35, 45.5)
        ..lineTo(50, 58)
        ..lineTo(50, 55)
        ..lineTo(31, 45.5)
        ..close();
      canvas.drawPath(lipLeft, Paint()..color = AmanahColorTokens.neutral200);

      final Path lipRight = Path()
        ..moveTo(50, 58)
        ..lineTo(71.65, 45.5)
        ..lineTo(69, 45.5)
        ..lineTo(50, 55)
        ..close();
      canvas.drawPath(lipRight, Paint()..color = AmanahColorTokens.neutral300);

      // Radiant Medical Energy Burst Glow
      final Paint medicalGlow = Paint()
        ..shader =
            RadialGradient(
              colors: <Color>[
                AmanahColorTokens.brandSoft,
                AmanahColorTokens.brandAccent.withValues(alpha: 0.8),
                AmanahColorTokens.auroraAccentDark.withValues(alpha: 0.0),
              ],
              stops: const <double>[0.0, 0.45, 1.0],
            ).createShader(
              Rect.fromCenter(
                center: const Offset(50, 52),
                width: 32,
                height: 18,
              ),
            );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(50, 52), width: 32, height: 18),
        medicalGlow,
      );
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
        colors: <Color>[AmanahColorTokens.toolboxFaceLeftTop, AmanahColorTokens.toolboxFaceLeftBottom],
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
        colors: <Color>[AmanahColorTokens.toolboxFaceRightTop, AmanahColorTokens.toolboxFaceRightBottom],
      ).createShader(const Rect.fromLTWH(50, 45.5, 21.65, 29.5));
    canvas.drawPath(lowerRightFace, rightFacePaint);

    // Seam & Edge Lines
    canvas.drawLine(
      const Offset(50, 58),
      const Offset(50, 75),
      Paint()
        ..color = AmanahColorTokens.toolboxSeamLight
        ..strokeWidth = 0.75,
    );
    canvas.drawLine(
      const Offset(28.35, 45.5),
      const Offset(28.35, 62.5),
      Paint()
        ..color = AmanahColorTokens.toolboxSeamDark
        ..strokeWidth = 0.5,
    );
    canvas.drawLine(
      const Offset(71.65, 45.5),
      const Offset(71.65, 62.5),
      Paint()
        ..color = AmanahColorTokens.toolboxSeamMid
        ..strokeWidth = 0.5,
    );

    // Red Medical Cross on Left Lower Face (Isometric transformed)
    canvas.save();
    final Matrix4 crossMatrix = Matrix4(
      0.866,
      0.5,
      0,
      0,
      0.0,
      1.0,
      0,
      0,
      0,
      0,
      1,
      0,
      39.175,
      60.25,
      0,
      1,
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
    canvas.drawPath(
      crossPath,
      Paint()..color = AmanahColorTokens.toolboxCrossShadow.withValues(alpha: 0.8),
    );
    canvas.restore();

    // Main Red Cross
    canvas.drawPath(crossPath, Paint()..color = AmanahColorTokens.toolboxCrossRed);
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
        colors: <Color>[AmanahColorTokens.pureWhite, AmanahColorTokens.toolboxFaceTopEnd],
      ).createShader(const Rect.fromLTWH(28.35, 25, 43.3, 25));
    canvas.drawPath(topFace, topFacePaint);

    // Highlights
    canvas.drawLine(
      const Offset(28.35, 37.5),
      const Offset(50, 50),
      Paint()
        ..color = AmanahColorTokens.pureWhite.withValues(alpha: 0.9)
        ..strokeWidth = 0.75,
    );
    canvas.drawLine(
      const Offset(50, 50),
      const Offset(71.65, 37.5),
      Paint()
        ..color = AmanahColorTokens.pureWhite
        ..strokeWidth = 0.75,
    );
    canvas.drawLine(
      const Offset(50, 50),
      const Offset(50, 58),
      Paint()
        ..color = AmanahColorTokens.toolboxSeamLight
        ..strokeWidth = 0.75,
    );

    // Upper Latches
    _drawLatchUpper(canvas, 55, 55.115);
    _drawLatchUpper(canvas, 65, 49.345);

    // Handle Shadow
    canvas.drawLine(
      const Offset(45, 35.5),
      const Offset(55, 41.5),
      Paint()
        ..color = AmanahColorTokens.toolboxHandleShadow
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // Handle Base Mounts
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(44.8, 34.5),
        width: 3.0,
        height: 1.5,
      ),
      Paint()..color = AmanahColorTokens.toolboxHandleMount,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(55.2, 40.5),
        width: 3.0,
        height: 1.5,
      ),
      Paint()..color = AmanahColorTokens.toolboxHandleMount,
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
        ..color = AmanahColorTokens.toolboxHandle
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
        ..color = AmanahColorTokens.toolboxHandleShimmer
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
      0.866,
      -0.5,
      0,
      0,
      0.0,
      1.0,
      0,
      0,
      0,
      0,
      1,
      0,
      tx,
      ty,
      0,
      1,
    );
    canvas.transform(latchMatrix.storage);
    canvas.drawRect(
      const Rect.fromLTWH(-1.5, 0, 3.0, 3.5),
      Paint()..color = AmanahColorTokens.toolboxLatchBase,
    );
    canvas.restore();
  }

  void _drawLatchUpper(Canvas canvas, double tx, double ty) {
    canvas.save();
    final Matrix4 latchMatrix = Matrix4(
      0.866,
      -0.5,
      0,
      0,
      0.0,
      1.0,
      0,
      0,
      0,
      0,
      1,
      0,
      tx,
      ty,
      0,
      1,
    );
    canvas.transform(latchMatrix.storage);
    canvas.drawRect(
      const Rect.fromLTWH(-1.5, -3.5, 3.0, 3.5),
      Paint()..color = AmanahColorTokens.toolboxLatchUpper,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AmanahToolbox3DPainter oldDelegate) {
    return oldDelegate.isOpen != isOpen;
  }
}
