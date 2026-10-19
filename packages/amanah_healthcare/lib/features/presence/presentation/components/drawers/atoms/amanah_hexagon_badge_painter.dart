import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_palette.dart';

/// Atom: High-precision vector painter rendering the 3D hexagon badge,
/// inner recessed bevel, layered ribbon, and animated status glyph stroke.
class AmanahHexagonBadgePainter extends CustomPainter {
  const AmanahHexagonBadgePainter({
    required this.palette,
    required this.statusType,
    this.scale = 1.0,
    this.buildProgress = 1.0,
    this.glyphProgress = 1.0,
    this.ribbonOffset = 0.0,
    this.tiltAngle = 0.0,
  });

  final PresenceResultPalette palette;
  final PresenceStatusType statusType;
  final double scale;
  final double buildProgress;
  final double glyphProgress;
  final double ribbonOffset;
  final double tiltAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale * (size.width / 200.0));
    if (tiltAngle != 0.0) {
      canvas.rotate(tiltAngle);
    }

    final BadgeStageTheme theme = palette.badgeTheme;

    // Layer 1: Base Outer Hexagon (buildProgress: 0.0 -> 0.32)
    // Self-drawing outer border stroke, followed by gradient fill
    final double baseProgress = (buildProgress / 0.32).clamp(0.0, 1.0);
    if (baseProgress > 0.0) {
      final Path outerHex = _createRoundedHexagon(radius: 82, cornerRadius: 13);
      final double fillOpacity = Curves.easeOutCubic.transform(
        ((baseProgress - 0.20) / 0.80).clamp(0.0, 1.0),
      );

      if (fillOpacity > 0.0) {
        final Paint outerPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              theme.outerTop.withValues(alpha: fillOpacity),
              theme.outerBottom.withValues(alpha: fillOpacity),
            ],
          ).createShader(Rect.fromCenter(center: Offset.zero, width: 164, height: 164))
          ..style = PaintingStyle.fill;
        canvas.drawPath(outerHex, outerPaint);
      }

      final double strokeOpacity = baseProgress < 1.0 ? 0.85 : 0.45;
      final Paint outerStroke = Paint()
        ..color = Colors.white.withValues(alpha: strokeOpacity)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (baseProgress >= 1.0) {
        canvas.drawPath(outerHex, outerStroke);
      } else {
        _renderTrimmedPath(canvas, outerHex, outerStroke, baseProgress);
      }
    }

    // Layer 2: Inner Recessed Shell & Track Bevel / "Cangkang Dalam" (buildProgress: 0.28 -> 0.58)
    final double innerProgress = ((buildProgress - 0.28) / 0.30).clamp(0.0, 1.0);
    if (innerProgress > 0.0) {
      final double innerScale = Curves.easeOutBack.transform(innerProgress);
      canvas.save();
      canvas.scale(innerScale);

      // Inner Recessed Hexagon
      final Path innerHex = _createRoundedHexagon(radius: 66, cornerRadius: 10);
      final Paint innerPaint = Paint()
        ..color = theme.innerRecess
        ..style = PaintingStyle.fill;
      canvas.drawPath(innerHex, innerPaint);

      // Inner Bevel Track (Trimmed stroke drawing)
      final Path trackHex = _createRoundedHexagon(radius: 59, cornerRadius: 8);
      final Paint trackPaint = Paint()
        ..color = theme.innerRim.withValues(alpha: 0.65)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      if (innerProgress >= 1.0) {
        canvas.drawPath(trackHex, trackPaint);
      } else {
        _renderTrimmedPath(canvas, trackHex, trackPaint, innerProgress);
      }

      canvas.restore();
    }

    // Layer 3: Curved Ribbon Banner (buildProgress: 0.52 -> 0.76)
    final double ribbonProg = ((buildProgress - 0.52) / 0.24).clamp(0.0, 1.0);
    if (ribbonProg > 0.0) {
      final double ribbonScale = Curves.easeOutBack.transform(ribbonProg);
      final double dynamicDrop = ribbonOffset + (-14.0 * (1.0 - ribbonProg));

      canvas.save();
      canvas.translate(0, dynamicDrop);
      canvas.scale(ribbonScale);

      final Path ribbon = _createRibbonPath();
      final Paint ribbonPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[theme.ribbonTop, theme.ribbonBottom],
        ).createShader(const Rect.fromLTWH(-34, -64, 68, 86))
        ..style = PaintingStyle.fill;
      canvas.drawPath(ribbon, ribbonPaint);

      final Paint ribbonStroke = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(ribbon, ribbonStroke);

      canvas.restore();
    }

    // Layer 4: Central Status Glyph (buildProgress: 0.70 -> 1.00)
    // Self-drawing vector line / stroke animation
    final double effectiveGlyphProgress = buildProgress < 1.0
        ? ((buildProgress - 0.70) / 0.30).clamp(0.0, 1.0)
        : glyphProgress;

    if (effectiveGlyphProgress > 0.0) {
      _drawAnimatedGlyph(canvas, theme.glyphColor, effectiveGlyphProgress);
    }

    canvas.restore();
  }

  Path _createRoundedHexagon({
    required double radius,
    required double cornerRadius,
  }) {
    const List<double> angles = <double>[
      -90 * math.pi / 180,
      -30 * math.pi / 180,
      30 * math.pi / 180,
      90 * math.pi / 180,
      150 * math.pi / 180,
      210 * math.pi / 180,
    ];

    final List<Offset> pts = angles
        .map((double a) => Offset(radius * math.cos(a), radius * math.sin(a)))
        .toList();

    final Path path = Path();
    final double d = cornerRadius / math.sqrt(3);

    for (int idx = 0; idx < 6; idx++) {
      final Offset curr = pts[idx];
      final Offset prev = pts[(idx + 5) % 6];
      final Offset next = pts[(idx + 1) % 6];

      final Offset vPrev = (prev - curr) / (prev - curr).distance;
      final Offset vNext = (next - curr) / (next - curr).distance;

      final Offset pStart = curr + vPrev * d;
      final Offset pEnd = curr + vNext * d;

      if (idx == 0) {
        path.moveTo(pStart.dx, pStart.dy);
      } else {
        path.lineTo(pStart.dx, pStart.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, pEnd.dx, pEnd.dy);
    }
    path.close();
    return path;
  }

  Path _createRibbonPath() {
    final Path path = Path()
      ..moveTo(0, -64)
      ..cubicTo(4, -64, 30, -48, 34, -44)
      ..lineTo(34, 21)
      ..cubicTo(28, 19, 8, 8, 0, 8)
      ..cubicTo(-8, 8, -28, 19, -34, 21)
      ..lineTo(-34, -44)
      ..cubicTo(-30, -48, -4, -64, 0, -64)
      ..close();
    return path;
  }

  void _drawAnimatedGlyph(Canvas canvas, Color color, double progress) {
    if (progress <= 0.0) return;

    final Paint glyphPaint = Paint()
      ..color = color
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (statusType) {
      case PresenceStatusType.successCheckIn:
      case PresenceStatusType.successCheckOut:
        final Path check = Path()
          ..moveTo(-15, -10)
          ..lineTo(-4, 2)
          ..lineTo(16, -20);
        _renderTrimmedPath(canvas, check, glyphPaint, progress);
        break;

      case PresenceStatusType.invalidOrExpiredToken:
      case PresenceStatusType.genericError:
        final Path line1 = Path()
          ..moveTo(-12, -20)
          ..lineTo(12, 4);
        final Path line2 = Path()
          ..moveTo(12, -20)
          ..lineTo(-12, 4);

        if (progress <= 0.5) {
          _renderTrimmedPath(canvas, line1, glyphPaint, progress / 0.5);
        } else {
          canvas.drawPath(line1, glyphPaint);
          _renderTrimmedPath(canvas, line2, glyphPaint, (progress - 0.5) / 0.5);
        }
        break;

      case PresenceStatusType.conflictAlreadyCheckedIn:
      case PresenceStatusType.conflictAlreadyCheckedOut:
        // Exclamation / Conflict: Bar draws down then dot pops
        final Path bar = Path()
          ..moveTo(0, -24)
          ..lineTo(0, -6);

        if (progress <= 0.70) {
          _renderTrimmedPath(canvas, bar, glyphPaint, progress / 0.70);
        } else {
          canvas.drawPath(bar, glyphPaint);
          final double dotProgress = ((progress - 0.70) / 0.30).clamp(0.0, 1.0);
          final double dotScale = Curves.easeOutBack.transform(dotProgress);
          final Paint dotPaint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;
          canvas.drawCircle(const Offset(0, 7), 4.5 * dotScale, dotPaint);
        }
        break;

      case PresenceStatusType.outOfSchedule:
      case PresenceStatusType.onOfficialLeave:
        // Info 'i': Dot pops, bar draws down
        final Paint dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        final double dotProgress = (progress / 0.35).clamp(0.0, 1.0);
        final double dotScale = Curves.easeOutBack.transform(dotProgress);
        canvas.drawCircle(const Offset(0, -22), 4.5 * dotScale, dotPaint);

        if (progress > 0.30) {
          final double barProgress = ((progress - 0.30) / 0.70).clamp(0.0, 1.0);
          final Path bar = Path()
            ..moveTo(0, -10)
            ..lineTo(0, 8);
          _renderTrimmedPath(canvas, bar, glyphPaint, barProgress);
        }
        break;
    }
  }

  void _renderTrimmedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double progress,
  ) {
    if (progress >= 1.0) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final ui.PathMetric metric in path.computeMetrics()) {
      final Path extracted = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extracted, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AmanahHexagonBadgePainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.statusType != statusType ||
        oldDelegate.scale != scale ||
        oldDelegate.buildProgress != buildProgress ||
        oldDelegate.glyphProgress != glyphProgress ||
        oldDelegate.ribbonOffset != ribbonOffset ||
        oldDelegate.tiltAngle != tiltAngle;
  }
}
