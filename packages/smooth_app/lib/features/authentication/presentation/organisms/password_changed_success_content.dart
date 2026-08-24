import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_primary_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class PasswordChangedSuccessContent extends StatefulWidget {
  const PasswordChangedSuccessContent({required this.onSignIn, super.key});

  final VoidCallback onSignIn;

  @override
  State<PasswordChangedSuccessContent> createState() =>
      _PasswordChangedSuccessContentState();
}

class _PasswordChangedSuccessContentState
    extends State<PasswordChangedSuccessContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final List<_CelebrationParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = _createParticles();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Center(
          child: _SuccessMessage(
            primary: primary,
            theme: theme,
            onSignIn: widget.onSignIn,
            animation: _confettiController,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (BuildContext context, _) {
                return CustomPaint(
                  painter: _CelebrationConfettiPainter(
                    progress: Curves.easeOutCubic.transform(
                      _confettiController.value,
                    ),
                    particles: _particles,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<_CelebrationParticle> _createParticles() {
    final math.Random random = math.Random(42);
    const List<Color> colors = <Color>[
      Color(0xFF0F0A5A),
      Color(0xFF2458E6),
      Color(0xFF2A8CA5),
      Color(0xFF58C4B8),
      Color(0xFFE9D7FF),
      Color(0xFFF2C94C),
    ];

    return List<_CelebrationParticle>.generate(72, (int index) {
      final bool fromLeft = index.isEven;
      final double side = fromLeft ? -1 : 1;
      final double speed = 190 + random.nextDouble() * 165;
      final double angle = fromLeft
          ? (-0.98 + random.nextDouble() * 0.48)
          : (-math.pi + 0.50 - random.nextDouble() * 0.48);
      final double delay = random.nextDouble() * 0.26;

      return _CelebrationParticle(
        fromLeft: fromLeft,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        size: Size(5 + random.nextDouble() * 7, 3 + random.nextDouble() * 5),
        color: colors[index % colors.length],
        rotation: random.nextDouble() * math.pi,
        spin: side * (1.2 + random.nextDouble() * 3.2),
        delay: delay,
      );
    });
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({
    required this.primary,
    required this.theme,
    required this.onSignIn,
    required this.animation,
  });

  final Color primary;
  final ThemeData theme;
  final VoidCallback onSignIn;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: SMALL_SPACE),
        Center(
          child: Semantics(
            label: 'Password berhasil diganti',
            image: true,
            child: AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, _) {
                final double scale =
                    TweenSequence<double>(<TweenSequenceItem<double>>[
                      TweenSequenceItem<double>(
                        tween: Tween<double>(
                          begin: 0.82,
                          end: 1.10,
                        ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        weight: 46,
                      ),
                      TweenSequenceItem<double>(
                        tween: Tween<double>(
                          begin: 1.10,
                          end: 1,
                        ).chain(CurveTween(curve: Curves.elasticOut)),
                        weight: 54,
                      ),
                    ]).transform(animation.value.clamp(0, 0.62) / 0.62);
                final double checkProgress = ((animation.value - 0.16) / 0.42)
                    .clamp(0, 1)
                    .toDouble();

                return Transform.scale(
                  scale: scale,
                  child: _AnimatedSuccessBadge(
                    primary: primary,
                    checkProgress: Curves.easeOutCubic.transform(checkProgress),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: LARGE_SPACE),
        Text(
          'Password berhasil di ganti',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: SMALL_SPACE),
        Text(
          'Silahkan masukkan password baru untuk masuk',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: VERY_LARGE_SPACE),
        AuthPrimaryButton(label: 'Masuk', onPressed: onSignIn),
      ],
    );
  }
}

class _CelebrationParticle {
  const _CelebrationParticle({
    required this.fromLeft,
    required this.velocity,
    required this.size,
    required this.color,
    required this.rotation,
    required this.spin,
    required this.delay,
  });

  final bool fromLeft;
  final Offset velocity;
  final Size size;
  final Color color;
  final double rotation;
  final double spin;
  final double delay;
}

class _AnimatedSuccessBadge extends StatelessWidget {
  const _AnimatedSuccessBadge({
    required this.primary,
    required this.checkProgress,
  });

  final Color primary;
  final double checkProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: 0.10),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size.square(88),
          painter: _SuccessBadgePainter(
            primary: primary,
            checkProgress: checkProgress,
          ),
        ),
      ),
    );
  }
}

class _SuccessBadgePainter extends CustomPainter {
  const _SuccessBadgePainter({
    required this.primary,
    required this.checkProgress,
  });

  final Color primary;
  final double checkProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.shortestSide / 2 - 2;
    final Paint circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = primary;
    canvas.drawCircle(center, radius, circlePaint);

    final Path checkPath = Path()
      ..moveTo(size.width * 0.30, size.height * 0.52)
      ..lineTo(size.width * 0.43, size.height * 0.65)
      ..lineTo(size.width * 0.72, size.height * 0.36);
    final PathMetric metric = checkPath.computeMetrics().first;
    final Path visiblePath = metric.extractPath(
      0,
      metric.length * checkProgress,
    );
    final Paint checkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = primary;
    canvas.drawPath(visiblePath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _SuccessBadgePainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.checkProgress != checkProgress;
  }
}

class _CelebrationConfettiPainter extends CustomPainter {
  const _CelebrationConfettiPainter({
    required this.progress,
    required this.particles,
  });

  final double progress;
  final List<_CelebrationParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }

    final Paint paint = Paint()..style = PaintingStyle.fill;
    final Offset leftOrigin = Offset(size.width * 0.12, size.height * 0.36);
    final Offset rightOrigin = Offset(size.width * 0.88, size.height * 0.36);

    for (final _CelebrationParticle particle in particles) {
      final double localProgress =
          ((progress - particle.delay) / (1 - particle.delay)).clamp(0, 1);
      if (localProgress <= 0) {
        continue;
      }

      final double t = localProgress;
      final Offset origin = particle.fromLeft ? leftOrigin : rightOrigin;
      final Offset gravity = Offset(0, 360 * t * t);
      final Offset position = origin + particle.velocity * t + gravity;
      final double opacity = (1 - math.pow(t, 2.2)).clamp(0, 1).toDouble();

      if (opacity <= 0) {
        continue;
      }

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(particle.rotation + particle.spin * t);
      paint.color = particle.color.withValues(alpha: opacity);
      final RRect shape = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size.width,
          height: particle.size.height,
        ),
        const Radius.circular(1.6),
      );
      canvas.drawRRect(shape, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}
