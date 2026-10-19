import 'package:flutter/material.dart';

/// Atom: Elegant spherical horizon arc dividing the colored aura header
/// from the solid drawer body.
class AmanahDrawerArcHorizon extends StatelessWidget {
  const AmanahDrawerArcHorizon({
    required this.surfaceColor,
    super.key,
    this.height = 120.0,
  });

  final Color surfaceColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _AmanahDrawerArcHorizonPainter(surfaceColor: surfaceColor),
      ),
    );
  }
}

class _AmanahDrawerArcHorizonPainter extends CustomPainter {
  const _AmanahDrawerArcHorizonPainter({required this.surfaceColor});

  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, 26.0)
      ..quadraticBezierTo(size.width / 2, -16.0, size.width, 26.0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint paint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AmanahDrawerArcHorizonPainter oldDelegate) {
    return oldDelegate.surfaceColor != surfaceColor;
  }
}
