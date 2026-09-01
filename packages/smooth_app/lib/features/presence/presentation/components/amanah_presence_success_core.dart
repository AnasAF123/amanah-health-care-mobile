import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahPresenceSuccessCore extends StatefulWidget {
  const AmanahPresenceSuccessCore({
    required this.onClose,
    required this.onGoHome,
    required this.onViewHistory,
    super.key,
    this.timeString = '07:55 WIB',
    this.bottomPadding = 24,
  });

  final String timeString;
  final double bottomPadding;
  final VoidCallback onClose;
  final VoidCallback onGoHome;
  final VoidCallback onViewHistory;

  @override
  State<AmanahPresenceSuccessCore> createState() =>
      _AmanahPresenceSuccessCoreState();
}

class _AmanahPresenceSuccessCoreState extends State<AmanahPresenceSuccessCore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_SuccessConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _particles = _generateParticles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_SuccessConfettiParticle> _generateParticles() {
    final math.Random random = math.Random(42);
    const List<Color> colors = <Color>[
      AmanahColorTokens.brand,
      AmanahColorTokens.brandAccent,
      AmanahColorTokens.brandLight,
      AmanahColorTokens.brandSoft,
      AmanahColorTokens.brandSubtle,
      AmanahColorTokens.brandMuted,
    ];

    return List<_SuccessConfettiParticle>.generate(72, (int index) {
      final double angle = -math.pi / 2 + (random.nextDouble() - 0.5) * 1.35;
      final double speed = random.nextDouble() * 280 + 150;

      return _SuccessConfettiParticle(
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        color: colors[random.nextInt(colors.length)],
        size: random.nextDouble() * 5 + 3,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final _SuccessPalette palette = _SuccessPalette.resolve(theme);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double topSafe = mediaQuery.padding.top;
    final double safeBottom = mediaQuery.viewPadding.bottom;
    final double bottomInset = mediaQuery.viewInsets.bottom;
    final double maxSheetHeight = math.max(320, screenHeight - topSafe - 12);
    final double targetSheetHeight = screenHeight < 700
        ? screenHeight * 0.82
        : screenHeight * 0.70;
    final double sheetHeight = math.min(targetSheetHeight, maxSheetHeight);
    final double footerBottomPadding = bottomInset > 0
        ? 16
        : math.max(widget.bottomPadding, 28 + safeBottom);
    final double headerExtent = (sheetHeight.clamp(320, 720) * 0.34)
        .clamp(136, 206)
        .toDouble();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: sheetHeight,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.46 : 0.18),
                blurRadius: 40,
                offset: const Offset(0, -14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                final double progress = _controller.value;
                final double iconProgress = (progress / 0.36).clamp(0.0, 1.0);
                final double rippleProgress = (progress / 0.50).clamp(0.0, 1.0);
                final double settleProgress = ((progress - 0.46) / 0.34).clamp(
                  0.0,
                  1.0,
                );
                final double headerSettle = Curves.easeInOutCubic.transform(
                  settleProgress,
                );
                final double contentProgress = ((progress - 0.62) / 0.28).clamp(
                  0.0,
                  1.0,
                );
                final double contentEased = Curves.easeOutCubic.transform(
                  contentProgress,
                );
                final double confettiProgress = ((progress - 0.54) / 0.42)
                    .clamp(0.0, 1.0);
                final double graphicHeight =
                    headerExtent +
                    (sheetHeight - headerExtent) * (1 - headerSettle);

                return Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(height: headerExtent, width: double.infinity),
                        Expanded(
                          child: IgnorePointer(
                            ignoring: contentEased < 0.98,
                            child: Opacity(
                              opacity: contentEased,
                              child: Transform.translate(
                                offset: Offset(0, 18 * (1 - contentEased)),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    14,
                                    24,
                                    12,
                                  ),
                                  child: _SuccessContent(
                                    palette: palette,
                                    timeString: widget.timeString,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IgnorePointer(
                          ignoring: contentEased < 0.98,
                          child: Opacity(
                            opacity: contentEased,
                            child: _SuccessFooter(
                              palette: palette,
                              bottomPadding: footerBottomPadding,
                              onGoHome: widget.onGoHome,
                              onViewHistory: widget.onViewHistory,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: graphicHeight,
                      child: _SuccessHeader(
                        palette: palette,
                        rippleProgress: rippleProgress,
                        iconProgress: iconProgress,
                        bottomRadius: 24 * headerSettle,
                      ),
                    ),
                    if (confettiProgress > 0.01)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _ConfettiCanvasPainter(
                              progress: confettiProgress,
                              particles: _particles,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: palette.handle,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({
    required this.palette,
    required this.rippleProgress,
    required this.iconProgress,
    required this.bottomRadius,
  });

  final _SuccessPalette palette;
  final double rippleProgress;
  final double iconProgress;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(bottomRadius),
      ),
      child: ColoredBox(
        color: palette.surface,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Transform.scale(
                scale: Curves.easeOutCubic.transform(rippleProgress),
                child: CustomPaint(
                  painter: _SoftRipplePainter(palette: palette),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.92,
                    colors: <Color>[
                      palette.surface.withValues(alpha: 0),
                      palette.surface.withValues(alpha: 0.42),
                      palette.surface,
                    ],
                    stops: const <double>[0.0, 0.70, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      palette.surface.withValues(alpha: 0),
                      palette.surface.withValues(alpha: 0.76),
                      palette.surface,
                    ],
                    stops: const <double>[0.48, 0.82, 1],
                  ),
                ),
              ),
            ),
            Center(
              child: Semantics(
                label: 'Presensi berhasil',
                image: true,
                child: _SuccessEmblem(progress: iconProgress, palette: palette),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.palette, required this.timeString});

  final _SuccessPalette palette;
  final String timeString;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Presensi Berhasil!',
          textAlign: TextAlign.center,
          style:
              theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: palette.title,
              ) ??
              TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: palette.title,
              ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: 'Anda telah berhasil melakukan rekam presensi\npada pukul ',
            children: <InlineSpan>[
              TextSpan(
                text: timeString,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '. Selamat bekerja!'),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.42,
            color: palette.subtitle,
          ),
        ),
      ],
    );
  }
}

class _SuccessFooter extends StatelessWidget {
  const _SuccessFooter({
    required this.palette,
    required this.bottomPadding,
    required this.onGoHome,
    required this.onViewHistory,
  });

  final _SuccessPalette palette;
  final double bottomPadding;
  final VoidCallback onGoHome;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final double actionBottomPadding = math.max(18, safeBottom + 14);
    final double actionTopPadding =
        12 + math.max(0, bottomPadding - actionBottomPadding);

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.surface),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          actionTopPadding,
          24,
          actionBottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AmanahButton.primary(
              text: 'Lihat Riwayat Absensi',
              isFullWidth: true,
              size: AmanahButtonSize.medium,
              onPressed: onViewHistory,
            ),
            const SizedBox(height: 12),
            AmanahButton.text(
              text: 'Beranda',
              customForegroundColor: palette.subtitle,
              onPressed: onGoHome,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessEmblem extends StatelessWidget {
  const _SuccessEmblem({required this.progress, required this.palette});

  final double progress;
  final _SuccessPalette palette;

  @override
  Widget build(BuildContext context) {
    final double outlineProgress = (progress / 0.42).clamp(0.0, 1.0);
    final double fillProgress = ((progress - 0.34) / 0.44).clamp(0.0, 1.0);
    final double fillScale = Curves.easeOutBack
        .transform(fillProgress)
        .clamp(0.0, 1.0);
    final double pathProgress = ((progress - 0.58) / 0.42).clamp(0.0, 1.0);

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SuccessEmblemPainter(
          palette: palette,
          outlineProgress: outlineProgress,
          fillScale: fillScale,
          pathProgress: Curves.easeOutCubic.transform(pathProgress),
        ),
      ),
    );
  }
}

class _SuccessEmblemPainter extends CustomPainter {
  const _SuccessEmblemPainter({
    required this.palette,
    required this.outlineProgress,
    required this.fillScale,
    required this.pathProgress,
  });

  final _SuccessPalette palette;
  final double outlineProgress;
  final double fillScale;
  final double pathProgress;

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
          ..strokeWidth = 7
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

    if (pathProgress > 0) {
      final Path path = Path()
        ..moveTo(size.width * 0.30, size.height * 0.52)
        ..lineTo(size.width * 0.44, size.height * 0.65)
        ..lineTo(size.width * 0.70, size.height * 0.38);
      final PathMetric metric = path.computeMetrics().first;

      canvas.drawPath(
        metric.extractPath(0, metric.length * pathProgress),
        Paint()
          ..color = palette.onPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessEmblemPainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.outlineProgress != outlineProgress ||
        oldDelegate.fillScale != fillScale ||
        oldDelegate.pathProgress != pathProgress;
  }
}

class _SoftRipplePainter extends CustomPainter {
  const _SoftRipplePainter({required this.palette});

  final _SuccessPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.54);
    final double maxRadius = math.max(size.width, size.height) * 0.86;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 6; i >= 0; i--) {
      final double t = i / 6;
      final double radius = maxRadius * (0.18 + t * 0.82);
      paint.color = Color.lerp(
        palette.primary,
        palette.surface,
        0.32 + t * 0.62,
      )!.withValues(alpha: 0.16 + (1 - t) * 0.16);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SoftRipplePainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}

class _SuccessConfettiParticle {
  const _SuccessConfettiParticle({
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

class _ConfettiCanvasPainter extends CustomPainter {
  const _ConfettiCanvasPainter({
    required this.progress,
    required this.particles,
  });

  final double progress;
  final List<_SuccessConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset origin = Offset(size.width / 2, size.height * 0.28);
    const double gravity = 430;

    for (final _SuccessConfettiParticle particle in particles) {
      final double x = origin.dx + particle.vx * progress;
      final double y =
          origin.dy +
          particle.vy * progress +
          0.5 * gravity * progress * progress;
      final double opacity = (1 - progress).clamp(0.0, 1.0);

      if (opacity <= 0) {
        continue;
      }

      canvas
        ..save()
        ..translate(x, y)
        ..rotate(particle.rotationSpeed * progress);

      final Paint paint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.72)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.58,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiCanvasPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}

class _SuccessPalette {
  const _SuccessPalette({
    required this.surface,
    required this.mutedSurface,
    required this.title,
    required this.subtitle,
    required this.metaText,
    required this.border,
    required this.handle,
    required this.primary,
    required this.primaryText,
    required this.primarySoft,
    required this.onPrimary,
  });

  final Color surface;
  final Color mutedSurface;
  final Color title;
  final Color subtitle;
  final Color metaText;
  final Color border;
  final Color handle;
  final Color primary;
  final Color primaryText;
  final Color primarySoft;
  final Color onPrimary;

  static _SuccessPalette resolve(ThemeData theme) {
    final bool dark = theme.brightness == Brightness.dark;
    final Color surface = dark ? theme.colorScheme.surface : Colors.white;
    final Color primary = dark
        ? AmanahColorTokens.brandSoft
        : AmanahColorTokens.brand;
    final Color primarySoft = dark
        ? primary.withValues(alpha: 0.16)
        : AmanahColorTokens.brandSurface;

    return _SuccessPalette(
      surface: surface,
      mutedSurface: dark
          ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
      title: dark ? theme.colorScheme.onSurface : AmanahColorTokens.heading,
      subtitle: dark
          ? theme.colorScheme.onSurfaceVariant
          : AmanahColorTokens.muted,
      metaText: dark
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurfaceVariant,
      border: dark
          ? theme.colorScheme.outlineVariant.withValues(alpha: 0.34)
          : AmanahColorTokens.brandMuted,
      handle: dark
          ? theme.colorScheme.onSurface.withValues(alpha: 0.20)
          : theme.colorScheme.outlineVariant,
      primary: primary,
      primaryText: dark
          ? AmanahColorTokens.brandSubtle
          : AmanahColorTokens.brand,
      primarySoft: primarySoft,
      onPrimary: Colors.white,
    );
  }
}
