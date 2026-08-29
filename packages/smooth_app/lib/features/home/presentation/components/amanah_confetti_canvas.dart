import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Native Flutter Confetti Particle Streamer System
/// 1:1 Replication of ConfettiCanvas.tsx from web.
class AmanahConfettiCanvas extends StatefulWidget {
  const AmanahConfettiCanvas({super.key});

  @override
  AmanahConfettiCanvasState createState() => AmanahConfettiCanvasState();
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.r,
    required this.dx,
    required this.dy,
    required this.color,
    required this.tilt,
    required this.tiltAngle,
    required this.tiltAngleInc,
  });

  double x;
  double y;
  double r;
  double dx;
  double dy;
  Color color;
  double tilt;
  double tiltAngle;
  double tiltAngleInc;
}

class AmanahConfettiCanvasState extends State<AmanahConfettiCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = <_ConfettiParticle>[];
  final math.Random _random = math.Random();

  static const List<Color> _palette = <Color>[
    Color(0xFFFF9900),
    Color(0xFFFF0055),
    Color(0xFF00E5FF),
    Color(0xFF0A44FF),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFFBBF24),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(_tick);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fire({Offset? origin}) {
    final Size size = MediaQuery.sizeOf(context);
    final double spawnX = origin?.dx ?? (size.width / 2);
    final double spawnY = origin?.dy ?? (size.height / 2 - 80);

    _particles.clear();
    for (int i = 0; i < 110; i++) {
      final double angle = _random.nextDouble() * math.pi * 2;
      final double speed = _random.nextDouble() * 12 + 4;
      final double angleInc = _random.nextDouble() * 0.08 + 0.05;

      _particles.add(
        _ConfettiParticle(
          x: spawnX + math.cos(angle) * 10,
          y: spawnY + math.sin(angle) * 10,
          r: _random.nextDouble() * 5 + 3,
          dx: math.cos(angle) * speed * 0.85,
          dy: -(_random.nextDouble() * 14 + 6),
          color: _palette[_random.nextInt(_palette.length)],
          tilt: _random.nextDouble() * 12 - 6,
          tiltAngle: _random.nextDouble() * math.pi,
          tiltAngleInc: angleInc,
        ),
      );
    }

    _controller.forward(from: 0.0);
  }

  void _tick() {
    if (_particles.isEmpty) {
      return;
    }

    for (final _ConfettiParticle p in _particles) {
      p.tiltAngle += p.tiltAngleInc;
      p.y += (math.cos(p.tiltAngle) + 1 + p.r / 2) / 2;
      p.x += math.sin(p.tiltAngle) * 2;
      p.dy += 0.32; // Gravity
      p.x += p.dx;
      p.y += p.dy;
      p.dx *= 0.985; // Air drag
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isAnimating || _particles.isEmpty) {
      return const SizedBox.shrink();
    }

    final double alpha = _controller.value > 0.70
        ? (1.0 - (_controller.value - 0.70) / 0.30).clamp(0.0, 1.0)
        : 1.0;

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(
          particles: _particles,
          globalAlpha: alpha,
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.particles,
    required this.globalAlpha,
  });

  final List<_ConfettiParticle> particles;
  final double globalAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.stroke;

    for (final _ConfettiParticle p in particles) {
      if (p.y < -50 || p.y > size.height + 50 || p.x < -50 || p.x > size.width + 50) {
        continue;
      }

      paint.color = p.color.withValues(alpha: globalAlpha);
      paint.strokeWidth = p.r;
      paint.strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(p.x + p.tilt + (p.r / 4), p.y),
        Offset(p.x + p.tilt, p.y + p.tilt + (p.r / 4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
