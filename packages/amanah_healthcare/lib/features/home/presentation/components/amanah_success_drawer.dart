import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

enum AmanahDrawerVariant { success, error }

class AmanahSuccessDrawer extends StatefulWidget {
  const AmanahSuccessDrawer({
    required this.title,
    required this.subtitle,
    required this.onClose,
    super.key,
    this.variant = AmanahDrawerVariant.success,
    this.infoTitle,
    this.infoSubtitle,
    this.infoIcon = Icons.shield_rounded,
    this.primaryButtonText = 'Selesai',
    this.primaryIcon,
    this.secondaryButtonText,
    this.secondaryIcon,
    this.sideBySideActions = false,
    this.showCloseButton = true,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.bottomPadding = 24,
  });

  final AmanahDrawerVariant variant;
  final String title;
  final String subtitle;
  final String? infoTitle;
  final String? infoSubtitle;
  final IconData infoIcon;
  final String primaryButtonText;
  final IconData? primaryIcon;
  final String? secondaryButtonText;
  final IconData? secondaryIcon;
  final bool sideBySideActions;
  final bool showCloseButton;
  final VoidCallback onClose;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final double bottomPadding;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    AmanahDrawerVariant variant = AmanahDrawerVariant.success,
    String? infoTitle,
    String? infoSubtitle,
    IconData infoIcon = Icons.shield_rounded,
    String primaryButtonText = 'Selesai',
    IconData? primaryIcon,
    String? secondaryButtonText,
    IconData? secondaryIcon,
    bool sideBySideActions = false,
    bool showCloseButton = true,
    VoidCallback? onPrimaryAction,
    VoidCallback? onSecondaryAction,
    double bottomPadding = 24,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahSuccessDrawer(
        variant: variant,
        title: title,
        subtitle: subtitle,
        infoTitle: infoTitle,
        infoSubtitle: infoSubtitle,
        infoIcon: infoIcon,
        primaryButtonText: primaryButtonText,
        primaryIcon: primaryIcon,
        secondaryButtonText: secondaryButtonText,
        secondaryIcon: secondaryIcon,
        sideBySideActions: sideBySideActions,
        showCloseButton: showCloseButton,
        onClose: () => Navigator.of(ctx).pop(),
        onPrimaryAction: () {
          Navigator.of(ctx).pop();
          onPrimaryAction?.call();
        },
        onSecondaryAction: () {
          Navigator.of(ctx).pop();
          onSecondaryAction?.call();
        },
        bottomPadding: bottomPadding,
      ),
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? infoTitle,
    String? infoSubtitle,
    IconData infoIcon = Icons.error_outline_rounded,
    String primaryButtonText = 'Tutup',
    VoidCallback? onPrimaryAction,
    double bottomPadding = 24,
  }) {
    return show(
      context,
      variant: AmanahDrawerVariant.error,
      title: title,
      subtitle: subtitle,
      infoTitle: infoTitle,
      infoSubtitle: infoSubtitle,
      infoIcon: infoIcon,
      primaryButtonText: primaryButtonText,
      onPrimaryAction: onPrimaryAction,
      bottomPadding: bottomPadding,
    );
  }

  @override
  State<AmanahSuccessDrawer> createState() => _AmanahSuccessDrawerState();
}

class _AmanahSuccessDrawerState extends State<AmanahSuccessDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_SuccessConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..forward();
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
    final _SuccessPalette palette = _SuccessPalette.resolve(theme, variant: widget.variant);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double topSafe = mediaQuery.padding.top;
    final double safeBottom = mediaQuery.viewPadding.bottom;
    final double bottomInset = mediaQuery.viewInsets.bottom;
    final double maxSheetHeight = math.max(320, screenHeight - topSafe - 12);
    final double targetSheetHeight = screenHeight < 700 ? screenHeight * 0.82 : screenHeight * 0.70;
    final double sheetHeight = math.min(targetSheetHeight, maxSheetHeight);
    final double footerBottomPadding = bottomInset > 0
        ? 16
        : math.max(widget.bottomPadding, 28 + safeBottom);
    final double headerExtent = (sheetHeight.clamp(320, 720) * 0.34).clamp(136, 206).toDouble();

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
                color: AmanahColorTokens.pureBlack.withValues(alpha: dark ? 0.46 : 0.18),
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
                final double settleProgress = ((progress - 0.46) / 0.34).clamp(0.0, 1.0);
                final double headerSettle = Curves.easeInOutCubic.transform(settleProgress);
                final double contentProgress = ((progress - 0.62) / 0.28).clamp(0.0, 1.0);
                final double contentEased = Curves.easeOutCubic.transform(contentProgress);
                final double confettiProgress = ((progress - 0.54) / 0.42).clamp(0.0, 1.0);
                final double graphicHeight =
                    headerExtent + (sheetHeight - headerExtent) * (1 - headerSettle);

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
                                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
                                  child: _SuccessBodyContent(
                                    palette: palette,
                                    title: widget.title,
                                    subtitle: widget.subtitle,
                                    infoTitle: widget.infoTitle,
                                    infoSubtitle: widget.infoSubtitle,
                                    infoIcon: widget.infoIcon,
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
                            child: _SuccessDrawerFooter(
                              palette: palette,
                              bottomPadding: footerBottomPadding,
                              primaryButtonText: widget.primaryButtonText,
                              primaryIcon: widget.primaryIcon,
                              secondaryButtonText: widget.secondaryButtonText,
                              secondaryIcon: widget.secondaryIcon,
                              sideBySideActions: widget.sideBySideActions,
                              onPrimaryAction: widget.onPrimaryAction ?? widget.onClose,
                              onSecondaryAction: widget.onSecondaryAction,
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
                      child: _SuccessGraphicHeader(
                        palette: palette,
                        variant: widget.variant,
                        rippleProgress: rippleProgress,
                        iconProgress: iconProgress,
                        bottomRadius: 24 * headerSettle,
                      ),
                    ),
                    if (widget.variant == AmanahDrawerVariant.success && confettiProgress > 0.01)
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
                    if (widget.showCloseButton)
                      Positioned(
                        top: 10,
                        right: 14,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          color: palette.subtitle,
                          tooltip: 'Tutup',
                          onPressed: widget.onClose,
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

class _SuccessGraphicHeader extends StatelessWidget {
  const _SuccessGraphicHeader({
    required this.palette,
    required this.variant,
    required this.rippleProgress,
    required this.iconProgress,
    required this.bottomRadius,
  });

  final _SuccessPalette palette;
  final AmanahDrawerVariant variant;
  final double rippleProgress;
  final double iconProgress;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(bottomRadius)),
      child: ColoredBox(
        color: palette.surface,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Transform.scale(
                scale: Curves.easeOutCubic.transform(rippleProgress),
                child: CustomPaint(painter: _SoftRipplePainter(palette: palette)),
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
                label: variant == AmanahDrawerVariant.error ? 'Aksi Gagal' : 'Aksi Berhasil',
                image: true,
                child: _SuccessBadgeEmblem(
                  progress: iconProgress,
                  palette: palette,
                  variant: variant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBodyContent extends StatelessWidget {
  const _SuccessBodyContent({
    required this.palette,
    required this.title,
    required this.subtitle,
    this.infoTitle,
    this.infoSubtitle,
    this.infoIcon = Icons.shield_rounded,
  });

  final _SuccessPalette palette;
  final String title;
  final String subtitle;
  final String? infoTitle;
  final String? infoSubtitle;
  final IconData infoIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style:
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: palette.title,
              ) ??
              TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: palette.title,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            height: 1.45,
            color: palette.subtitle,
          ),
        ),
        if (infoTitle != null && infoSubtitle != null) ...<Widget>[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: palette.mutedSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: palette.primarySoft, shape: BoxShape.circle),
                  child: Icon(infoIcon, size: 18, color: palette.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        infoTitle!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: palette.subtitle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        infoSubtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: palette.title,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SuccessDrawerFooter extends StatelessWidget {
  const _SuccessDrawerFooter({
    required this.palette,
    required this.bottomPadding,
    required this.primaryButtonText,
    required this.onPrimaryAction,
    this.primaryIcon,
    this.secondaryButtonText,
    this.secondaryIcon,
    this.sideBySideActions = false,
    this.onSecondaryAction,
  });

  final _SuccessPalette palette;
  final double bottomPadding;
  final String primaryButtonText;
  final IconData? primaryIcon;
  final VoidCallback onPrimaryAction;
  final String? secondaryButtonText;
  final IconData? secondaryIcon;
  final bool sideBySideActions;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final double actionBottomPadding = math.max(18, safeBottom + 14);
    final double actionTopPadding = 12 + math.max(0, bottomPadding - actionBottomPadding);

    Widget content;
    if (sideBySideActions && secondaryButtonText != null && onSecondaryAction != null) {
      content = Row(
        children: <Widget>[
          Expanded(
            child: AmanahButton.primary(
              text: primaryButtonText,
              leadingIcon: primaryIcon,
              size: AmanahButtonSize.medium,
              onPressed: onPrimaryAction,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AmanahButton.secondary(
              text: secondaryButtonText!,
              leadingIcon: secondaryIcon,
              size: AmanahButtonSize.medium,
              onPressed: onSecondaryAction,
            ),
          ),
        ],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AmanahButton.primary(
            text: primaryButtonText,
            leadingIcon: primaryIcon,
            isFullWidth: true,
            size: AmanahButtonSize.medium,
            onPressed: onPrimaryAction,
          ),
          if (secondaryButtonText != null && onSecondaryAction != null) ...<Widget>[
            const SizedBox(height: 12),
            AmanahButton.text(
              text: secondaryButtonText!,
              leadingIcon: secondaryIcon,
              customForegroundColor: palette.subtitle,
              onPressed: onSecondaryAction,
            ),
          ],
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.surface),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, actionTopPadding, 24, actionBottomPadding),
        child: content,
      ),
    );
  }
}

class _SuccessBadgeEmblem extends StatelessWidget {
  const _SuccessBadgeEmblem({required this.progress, required this.palette, required this.variant});

  final double progress;
  final _SuccessPalette palette;
  final AmanahDrawerVariant variant;

  @override
  Widget build(BuildContext context) {
    final double outlineProgress = (progress / 0.42).clamp(0.0, 1.0);
    final double fillProgress = ((progress - 0.34) / 0.44).clamp(0.0, 1.0);
    final double fillScale = Curves.easeOutBack.transform(fillProgress).clamp(0.0, 1.0);
    final double pathProgress = ((progress - 0.58) / 0.42).clamp(0.0, 1.0);

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          palette.primaryShadow,
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SuccessBadgeEmblemPainter(
          palette: palette,
          variant: variant,
          outlineProgress: outlineProgress,
          fillScale: fillScale,
          pathProgress: Curves.easeOutCubic.transform(pathProgress),
        ),
      ),
    );
  }
}

class _SuccessBadgeEmblemPainter extends CustomPainter {
  const _SuccessBadgeEmblemPainter({
    required this.palette,
    required this.variant,
    required this.outlineProgress,
    required this.fillScale,
    required this.pathProgress,
  });

  final _SuccessPalette palette;
  final AmanahDrawerVariant variant;
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
          ..color = palette.primaryBorder
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
          ..shader = palette.primaryGradient.createShader(
            Rect.fromCircle(center: center, radius: radius * fillScale),
          )
          ..style = PaintingStyle.fill,
      );
    }

    if (pathProgress > 0) {
      final Paint strokePaint = Paint()
        ..color = palette.onPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (variant == AmanahDrawerVariant.error) {
        final double left = size.width * 0.35;
        final double right = size.width * 0.65;
        final double top = size.height * 0.35;
        final double bottom = size.height * 0.65;

        final Path path1 = Path()
          ..moveTo(left, top)
          ..lineTo(right, bottom);
        final Path path2 = Path()
          ..moveTo(right, top)
          ..lineTo(left, bottom);

        final PathMetric m1 = path1.computeMetrics().first;
        final PathMetric m2 = path2.computeMetrics().first;

        canvas.drawPath(m1.extractPath(0, m1.length * pathProgress), strokePaint);
        canvas.drawPath(m2.extractPath(0, m2.length * pathProgress), strokePaint);
      } else {
        final Path path = Path()
          ..moveTo(size.width * 0.30, size.height * 0.52)
          ..lineTo(size.width * 0.44, size.height * 0.65)
          ..lineTo(size.width * 0.70, size.height * 0.38);
        final PathMetric metric = path.computeMetrics().first;

        canvas.drawPath(metric.extractPath(0, metric.length * pathProgress), strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessBadgeEmblemPainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.variant != variant ||
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
  const _ConfettiCanvasPainter({required this.progress, required this.particles});

  final double progress;
  final List<_SuccessConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset origin = Offset(size.width / 2, size.height * 0.28);
    const double gravity = 430;

    for (final _SuccessConfettiParticle particle in particles) {
      final double x = origin.dx + particle.vx * progress;
      final double y = origin.dy + particle.vy * progress + 0.5 * gravity * progress * progress;
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
          Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.58),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiCanvasPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particles != particles;
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
    required this.primaryGradient,
    required this.primaryBorder,
    required this.primaryShadow,
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
  final LinearGradient primaryGradient;
  final Color primaryBorder;
  final BoxShadow primaryShadow;
  final Color primaryText;
  final Color primarySoft;
  final Color onPrimary;

  static _SuccessPalette resolve(
    ThemeData theme, {
    AmanahDrawerVariant variant = AmanahDrawerVariant.success,
  }) {
    final bool dark = theme.brightness == Brightness.dark;
    final bool isError = variant == AmanahDrawerVariant.error;
    final Color surface = dark ? theme.colorScheme.surface : AmanahColorTokens.surfaceLight;

    final LinearGradient primaryGradient = isError
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AmanahColorTokens.danger, AmanahColorTokens.dangerDark],
          )
        : (dark
              ? AmanahColorTokens.btnCrispBlueDarkGradient
              : AmanahColorTokens.btnCrispBlueGradient);

    final Color primary = isError
        ? (dark ? AmanahColorTokens.dangerStrong : AmanahColorTokens.danger)
        : (dark ? AmanahColorTokens.skyMedium : AmanahColorTokens.brand);

    final Color primaryBorder = isError
        ? (dark ? AmanahColorTokens.dangerDark : AmanahColorTokens.dangerBorder)
        : (dark ? AmanahColorTokens.btnCrispBlueDarkBorder : AmanahColorTokens.btnCrispBlueBorder);

    final BoxShadow primaryShadow = isError
        ? BoxShadow(
            color: AmanahColorTokens.danger.withValues(alpha: dark ? 0.35 : 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          )
        : (dark ? AmanahColorTokens.btnCrispBlueDarkShadow : AmanahColorTokens.btnCrispBlueShadow);

    final Color primarySoft = isError
        ? (dark
              ? AmanahColorTokens.danger.withValues(alpha: 0.16)
              : AmanahColorTokens.dangerSurface)
        : (dark ? AmanahColorTokens.brand.withValues(alpha: 0.16) : AmanahColorTokens.brandSurface);

    return _SuccessPalette(
      surface: surface,
      mutedSurface: dark
          ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
      title: dark ? theme.colorScheme.onSurface : AmanahColorTokens.heading,
      subtitle: dark ? theme.colorScheme.onSurfaceVariant : AmanahColorTokens.muted,
      metaText: dark ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
      border: dark
          ? theme.colorScheme.outlineVariant.withValues(alpha: 0.34)
          : AmanahColorTokens.brandMuted,
      handle: dark
          ? theme.colorScheme.onSurface.withValues(alpha: 0.20)
          : theme.colorScheme.outlineVariant,
      primary: primary,
      primaryGradient: primaryGradient,
      primaryBorder: primaryBorder,
      primaryShadow: primaryShadow,
      primaryText: dark ? AmanahColorTokens.btnCrispSoftDarkText : AmanahColorTokens.brand,
      primarySoft: primarySoft,
      onPrimary: AmanahColorTokens.pureWhite,
    );
  }
}
