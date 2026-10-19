import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_palette.dart';

/// Animated painter for the status emblem circular frame.
class ResultEmblemPainter extends CustomPainter {
  const ResultEmblemPainter({
    required this.palette,
    required this.outlineProgress,
    required this.fillScale,
  });

  final PresenceResultPalette palette;
  final double outlineProgress;
  final double fillScale;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 4;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = palette.primarySoft
        ..style = PaintingStyle.fill,
    );

    if (outlineProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * outlineProgress,
        false,
        Paint()
          ..color = palette.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..strokeCap = StrokeCap.round,
      );
    }

    if (fillScale > 0) {
      canvas.drawCircle(
        center,
        radius * fillScale,
        Paint()
          ..color = palette.primary
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ResultEmblemPainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.outlineProgress != outlineProgress ||
        oldDelegate.fillScale != fillScale;
  }
}

/// Soft ambient ripples emanating from behind the emblem.
class ResultRipplePainter extends CustomPainter {
  const ResultRipplePainter({required this.palette, this.centerOffset});

  final PresenceResultPalette palette;
  final Offset? centerOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = centerOffset ?? Offset(size.width / 2, size.height * 0.52);
    final double maxRadius = math.max(size.width, size.height) * 0.85;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 5; i >= 0; i--) {
      final double t = i / 5;
      final double radius = maxRadius * (0.20 + t * 0.80);
      paint.color = Color.lerp(
        palette.primary,
        palette.surface,
        0.35 + t * 0.60,
      )!.withValues(alpha: 0.14 + (1 - t) * 0.14);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ResultRipplePainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.centerOffset != centerOffset;
  }
}

/// Dynamic confetti particle for success celebrations.
class ResultConfettiParticle {
  const ResultConfettiParticle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotationSpeed,
  });

  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double rotationSpeed;
}

/// Canvas painter for the celebratory confetti burst.
class ResultConfettiCanvasPainter extends CustomPainter {
  const ResultConfettiCanvasPainter({
    required this.progress,
    required this.particles,
    this.originOffset,
  });

  final double progress;
  final List<ResultConfettiParticle> particles;
  final Offset? originOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset origin = originOffset ?? Offset(size.width / 2, 104.0);
    const double gravity = 750;

    for (final ResultConfettiParticle particle in particles) {
      final double x = origin.dx + particle.vx * progress;
      final double y =
          origin.dy +
          particle.vy * progress +
          0.5 * gravity * progress * progress;
      final double opacity = (1 - progress).clamp(0.0, 1.0);

      if (opacity <= 0) continue;

      canvas
        ..save()
        ..translate(x, y)
        ..rotate(particle.rotationSpeed * progress);

      final Paint paint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.75)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.60,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ResultConfettiCanvasPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}
