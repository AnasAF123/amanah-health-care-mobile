import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_drawer_style.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_palette.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_painters.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/styles/amanah_badge_drawer_view.dart';

export 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_drawer_style.dart';

/// Agnostic, animated result drawer handling all presence outcomes
/// (Success Check-In/Out, Conflicts, Out of Schedule, Leave, Token Expiry, and Errors).
class AmanahPresenceResultDrawer extends StatefulWidget {
  const AmanahPresenceResultDrawer({
    required this.payload,
    required this.onClose,
    super.key,
    this.style = AmanahPresenceResultDrawerStyle.badgeStage,
    this.bottomPadding = 24,
    this.onGoHome,
    this.onViewHistory,
  });

  final PresenceStatusPayload payload;
  final VoidCallback onClose;
  final AmanahPresenceResultDrawerStyle style;
  final double bottomPadding;
  final VoidCallback? onGoHome;
  final VoidCallback? onViewHistory;

  static Future<void> show(
    BuildContext context, {
    required PresenceStatusPayload payload,
    AmanahPresenceResultDrawerStyle style =
        AmanahPresenceResultDrawerStyle.badgeStage,
    double bottomPadding = 24,
    VoidCallback? onGoHome,
    VoidCallback? onViewHistory,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahPresenceResultDrawer(
        payload: payload,
        style: style,
        bottomPadding: bottomPadding,
        onClose: () => Navigator.of(ctx).pop(),
        onGoHome: () {
          Navigator.of(ctx).pop();
          onGoHome?.call();
        },
        onViewHistory: () {
          Navigator.of(ctx).pop();
          onViewHistory?.call();
        },
      ),
    );
  }

  @override
  State<AmanahPresenceResultDrawer> createState() =>
      _AmanahPresenceResultDrawerState();
}

class _AmanahPresenceResultDrawerState
    extends State<AmanahPresenceResultDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<ResultConfettiParticle> _particles = const <ResultConfettiParticle>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();

    if (widget.payload.isSuccess) {
      _particles = _generateConfetti();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<ResultConfettiParticle> _generateConfetti() {
    final math.Random random = math.Random();
    const List<Color> colors = <Color>[
      Color(0xFF0D66E9), // Brand Sapphire Blue
      Color(0xFF38BDF8), // Sky Blue
      Color(0xFF60A5FA), // Brand Soft Blue
      Color(0xFFFBBF24), // Amber Gold
      Color(0xFFF43F5E), // Rose Coral
      Colors.white,
    ];

    return List<ResultConfettiParticle>.generate(60, (int index) {
      final double angle = -math.pi / 2 + (random.nextDouble() - 0.5) * 1.55;
      final double speed = random.nextDouble() * 380 + 320;

      return ResultConfettiParticle(
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        color: colors[random.nextInt(colors.length)],
        size: random.nextDouble() * 6 + 4,
        rotationSpeed: (random.nextDouble() - 0.5) * 16,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final PresenceResultPalette palette = PresenceResultPalette.resolve(
      theme: theme,
      type: widget.payload.type,
    );

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double safeBottom = mediaQuery.viewPadding.bottom;
    final double bottomInset = mediaQuery.viewInsets.bottom;
    final double footerBottomPadding = bottomInset > 0
        ? 16
        : math.max(widget.bottomPadding, 24 + safeBottom);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.88),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AmanahColorTokens.pureBlack.withValues(
                  alpha: dark ? 0.45 : 0.16,
                ),
                blurRadius: 36,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                final double progress = _controller.value;
                final double iconProgress = (progress / 0.40).clamp(0.0, 1.0);

                // Phase 1: Ripple expands full and stays centered with badge (0.0 -> 0.35)
                final double rippleProgress = (progress / 0.35).clamp(0.0, 1.0);

                // Phase 1: Badge builds sequentially layer-by-layer (0.0 -> 0.45)
                final double buildProgress = (progress / 0.45).clamp(0.0, 1.0);

                // Phase 2: Half-circle pushes badge from center up to resting top position (0.48 -> 0.72)
                final double pushProgress =
                    ((progress - 0.48) / 0.24).clamp(0.0, 1.0);

                // Phase 3: Badge reaches the top -> confetti explodes immediately (0.72 -> 1.0)
                final double confettiProgress =
                    ((progress - 0.72) / 0.28).clamp(0.0, 1.0);

                // Phase 3: Content reveals below the badge (0.74 -> 1.0)
                final double contentProgress =
                    ((progress - 0.74) / 0.26).clamp(0.0, 1.0);
                final double contentEased =
                    Curves.easeOutCubic.transform(contentProgress);

                if (widget.style == AmanahPresenceResultDrawerStyle.badgeStage) {
                  return AmanahBadgeDrawerView(
                    payload: widget.payload,
                    palette: palette,
                    onClose: widget.onClose,
                    bottomPadding: footerBottomPadding,
                    particles: _particles,
                    confettiProgress: confettiProgress,
                    progress: progress,
                    buildProgress: buildProgress,
                    rippleProgress: rippleProgress,
                    pushProgress: pushProgress,
                    contentProgress: contentProgress,
                    onGoHome: widget.onGoHome,
                    onViewHistory: widget.onViewHistory,
                    onBadgeTap: () {
                      if (widget.payload.isSuccess) {
                        setState(() {
                          _particles = _generateConfetti();
                        });
                      }
                      _controller.forward(from: 0.0);
                    },
                  );
                }

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: <Widget>[
                    // 1. Ambient Background Ripples (BEHIND EVERYTHING)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 240,
                      child: ClipRect(
                        child: LayoutBuilder(
                          builder: (BuildContext ctx, BoxConstraints constraints) {
                            return Transform.scale(
                              scale: Curves.easeOutCubic.transform(rippleProgress),
                              child: CustomPaint(
                                painter: ResultRipplePainter(
                                  palette: palette,
                                  centerOffset: Offset(constraints.maxWidth / 2, 75.0),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 2. Celebratory Confetti Burst (Success only)
                    if (palette.showConfetti && confettiProgress > 0.01)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: ResultConfettiCanvasPainter(
                              progress: confettiProgress,
                              particles: _particles,
                            ),
                          ),
                        ),
                      ),

                    // 3. Foreground Content & In-Flow Actions (100% IN FRONT OF BACKGROUND)
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 12, 24, footerBottomPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Drag Handle Bar
                            Center(
                              child: Container(
                                width: 44,
                                height: 4.5,
                                decoration: BoxDecoration(
                                  color: palette.handle,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Top Animated Status Emblem
                            _ResultEmblem(
                              palette: palette,
                              iconProgress: iconProgress,
                            ),
                            const SizedBox(height: 20),

                            // Content and Actions
                            Opacity(
                              opacity: contentEased,
                              child: Transform.translate(
                                offset: Offset(0, 14 * (1 - contentEased)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    // Title (No redundant badge pill above it)
                                    Text(
                                      widget.payload.title,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: palette.title,
                                            height: 1.25,
                                          ) ??
                                          TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: palette.title,
                                          ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Subtitle / Narrative
                                    Text(
                                      widget.payload.message,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: palette.subtitle,
                                        height: 1.45,
                                      ),
                                    ),

                                    // Time Detail (if present)
                                    if (widget.payload.timeFormatted != null) ...<Widget>[
                                      const SizedBox(height: 14),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: palette.mutedSurface,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: palette.border,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.access_time_filled_rounded,
                                              size: 15,
                                              color: palette.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              widget.payload.timeFormatted!,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: palette.metaText,
                                              ),
                                            ),
                                            if (widget.payload.durationHours != null &&
                                                widget.payload.durationHours! > 0) ...<Widget>[
                                              const SizedBox(width: 10),
                                              Container(
                                                width: 1,
                                                height: 12,
                                                color: palette.border,
                                              ),
                                              const SizedBox(width: 10),
                                              Icon(
                                                Icons.timelapse_rounded,
                                                size: 15,
                                                color: palette.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${widget.payload.durationHours!.toStringAsFixed(1)} Jam',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: palette.metaText,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 24),

                                    // In-Flow Action Buttons (Never Covering Content)
                                    _ResultActions(
                                      payload: widget.payload,
                                      palette: palette,
                                      onClose: widget.onClose,
                                      onGoHome: widget.onGoHome,
                                      onViewHistory: widget.onViewHistory,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

class _ResultEmblem extends StatelessWidget {
  const _ResultEmblem({
    required this.palette,
    required this.iconProgress,
  });

  final PresenceResultPalette palette;
  final double iconProgress;

  @override
  Widget build(BuildContext context) {
    final double outlineProgress = (iconProgress / 0.50).clamp(0.0, 1.0);
    final double fillProgress = ((iconProgress - 0.35) / 0.50).clamp(0.0, 1.0);
    final double fillScale = Curves.easeOutBack.transform(fillProgress);
    final double iconScale = ((iconProgress - 0.55) / 0.45).clamp(0.0, 1.0);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(
            painter: ResultEmblemPainter(
              palette: palette,
              outlineProgress: outlineProgress,
              fillScale: fillScale,
            ),
          ),
          if (iconScale > 0.05)
            Center(
              child: Transform.scale(
                scale: Curves.easeOutBack.transform(iconScale),
                child: Icon(
                  palette.iconData,
                  size: 38,
                  color: palette.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({
    required this.payload,
    required this.palette,
    required this.onClose,
    this.onGoHome,
    this.onViewHistory,
  });

  final PresenceStatusPayload payload;
  final PresenceResultPalette palette;
  final VoidCallback onClose;
  final VoidCallback? onGoHome;
  final VoidCallback? onViewHistory;

  @override
  Widget build(BuildContext context) {
    if (payload.isSuccess) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AmanahButton.primary(
            text: 'Lihat Riwayat Absensi',
            isFullWidth: true,
            size: AmanahButtonSize.medium,
            onPressed: onViewHistory ?? onClose,
          ),
          const SizedBox(height: 8),
          AmanahButton.text(
            text: 'Selesai',
            customForegroundColor: palette.subtitle,
            onPressed: onGoHome ?? onClose,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AmanahButton.primary(
          text: payload.actionLabel,
          isFullWidth: true,
          size: AmanahButtonSize.medium,
          onPressed: onClose,
        ),
      ],
    );
  }
}
