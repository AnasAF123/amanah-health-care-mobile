import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_schedule_card_tokens.dart';

/// Custom Clipper for Ticket Silhouette with smooth corner radii and C-notches.
/// Matching SVG Ticket Path from ScheduleCard.tsx (.web)
class AmanahTicketClipper extends CustomClipper<Path> {
  const AmanahTicketClipper();

  @override
  Path getClip(Size size) {
    const double radius = AmanahScheduleCardTokens.cornerRadius;
    const double notchRadius = AmanahScheduleCardTokens.notchRadius;
    const double notchCenterY = AmanahScheduleCardTokens.notchCenterY;

    final Path path = Path()
      // Top Left Corner
      ..moveTo(radius, 0)
      ..lineTo(size.width - radius, 0)
      // Top Right Corner
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      // Right Edge to Top of Right Notch
      ..lineTo(size.width, notchCenterY - notchRadius)
      // Inward Right "C" Notch
      ..arcToPoint(
        Offset(size.width, notchCenterY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      // Right Edge to Bottom Right Corner
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      // Bottom Edge to Bottom Left Corner
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      // Left Edge to Bottom of Left Notch
      ..lineTo(0, AmanahScheduleCardTokens.notchEndY)
      // Inward Left "C" Notch
      ..arcToPoint(
        const Offset(0, AmanahScheduleCardTokens.notchStartY),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      // Left Edge to Top Left Corner
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant AmanahTicketClipper oldClipper) => false;
}

/// Custom Painter for Solid Base Fill & Ticket Border Stroke
class AmanahCardBasePainter extends CustomPainter {
  const AmanahCardBasePainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = const AmanahTicketClipper().getClip(size);

    // Solid Background Fill
    final Paint fillPaint = Paint()
      ..color = dark
          ? AmanahScheduleCardTokens.cardBgDark
          : AmanahScheduleCardTokens.cardBgLight
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Subtle Outer Stroke
    final Paint strokePaint = Paint()
      ..color = dark
          ? AmanahScheduleCardTokens.borderStrokeDark
          : AmanahScheduleCardTokens.borderStrokeLight
      ..strokeWidth = AmanahScheduleCardTokens.borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant AmanahCardBasePainter oldDelegate) =>
      oldDelegate.dark != dark;
}

/// Custom Painter for the Wall-to-Wall Perforated Dashed Line between C-Notches
class AmanahPerforatedLinePainter extends CustomPainter {
  const AmanahPerforatedLinePainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint dashPaint = Paint()
      ..color = dark
          ? AmanahScheduleCardTokens.dashedLineColorDark
          : AmanahScheduleCardTokens.dashedLineColorLight
      ..strokeWidth = AmanahScheduleCardTokens.dashedLineWidth
      ..style = PaintingStyle.stroke;

    const double startX = 10.0;
    final double endX = size.width - 10.0;
    const double y = AmanahScheduleCardTokens.notchCenterY;

    const double dashWidth = 4.0;
    const double dashGap = 4.0;

    double currentX = startX;
    while (currentX < endX) {
      final double nextX = (currentX + dashWidth).clamp(startX, endX);
      canvas.drawLine(Offset(currentX, y), Offset(nextX, y), dashPaint);
      currentX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant AmanahPerforatedLinePainter oldDelegate) =>
      oldDelegate.dark != dark;
}
