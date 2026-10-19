import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_painters.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_palette.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/atoms/amanah_drawer_arc_horizon.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/atoms/amanah_drawer_aura_background.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/molecules/amanah_badge_hero_stage.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/molecules/amanah_result_typography_section.dart';

/// Organism: Renders the custom badge drawer layout with sequential choreography:
/// 1. Phase 1: Badge showcased in the dead center with wide concentric ripples expanding full.
/// 2. Phase 2: Half-circle arc horizon rises from bottom, slicing ripple and pushing badge to the top.
/// 3. Phase 3: Badge reaches the top -> celebratory confetti bursts, typography & buttons appear.
class AmanahBadgeDrawerView extends StatelessWidget {
  const AmanahBadgeDrawerView({
    required this.payload,
    required this.palette,
    required this.onClose,
    required this.bottomPadding,
    required this.particles,
    required this.confettiProgress,
    super.key,
    this.progress = 1.0,
    this.buildProgress = 1.0,
    this.rippleProgress = 1.0,
    this.pushProgress = 1.0,
    this.contentProgress = 1.0,
    this.onGoHome,
    this.onViewHistory,
    this.onBadgeTap,
  });

  final PresenceStatusPayload payload;
  final PresenceResultPalette palette;
  final VoidCallback onClose;
  final double bottomPadding;
  final List<ResultConfettiParticle> particles;
  final double confettiProgress;
  final double progress;
  final double buildProgress;
  final double rippleProgress;
  final double pushProgress;
  final double contentProgress;
  final VoidCallback? onGoHome;
  final VoidCallback? onViewHistory;
  final VoidCallback? onBadgeTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final double pushEased = Curves.easeInOutCubic.transform(pushProgress);
    final double contentEased = Curves.easeOutCubic.transform(contentProgress);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double drawerHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 520.0;
        final double drawerWidth = constraints.maxWidth;

        // Initial center spacing: places badge in dead center of drawer
        // Pushed spacing: smoothly shrinks to 10.0 under the drag handle
        final double centerSpacing = math.max(10.0, (drawerHeight * 0.44) - 78.0 - 16.0);
        final double currentSpacing = ui.lerpDouble(centerSpacing, 10.0, pushEased)!;

        // Current ripple center follows the badge center
        final double currentBadgeCenterY = 16.0 + currentSpacing + 78.0;

        // Half-circle arc horizon rises from bottom up to resting position (top: 124)
        final double arcTranslateY = (1.0 - pushEased) * (drawerHeight - 124.0);

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            // 1. Full-Drawer Aura Radial Gradient Header (Underneath everything)
            Positioned.fill(
              child: AmanahDrawerAuraBackground(
                badgeTheme: palette.badgeTheme,
                dark: dark,
                height: drawerHeight,
              ),
            ),

            // 2. Full-Drawer Ambient Ripples (Expanding wide from center around the badge)
            Positioned.fill(
              child: ClipRect(
                child: Transform.scale(
                  scale: Curves.easeOutCubic.transform(rippleProgress),
                  child: CustomPaint(
                    painter: ResultRipplePainter(
                      palette: palette,
                      centerOffset: Offset(drawerWidth / 2, currentBadgeCenterY),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Half-Circle Arc Horizon (Rises from bottom to slice the ripple)
            Positioned(
              top: 124,
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, arcTranslateY),
                child: Stack(
                  children: <Widget>[
                    AmanahDrawerArcHorizon(
                      surfaceColor: palette.surface,
                      height: 140,
                    ),
                    Positioned(
                      top: 139,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ColoredBox(color: palette.surface),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Celebratory Confetti Layer (Bursts from badge once it reaches the top)
            if (palette.showConfetti && confettiProgress > 0.01)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ResultConfettiCanvasPainter(
                      progress: confettiProgress,
                      particles: particles,
                      originOffset: Offset(drawerWidth / 2, 104.0),
                    ),
                  ),
                ),
              ),

            // 5. Foreground Content Flow (Handle, Badge Hero, Staggered Typography & Buttons)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Drag Handle bar
                    Center(
                      child: Container(
                        width: 38,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: palette.handle,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),

                    // Dynamic spacing: starts large (centering the badge), then smoothly shrinks as half-circle pushes it up
                    SizedBox(height: currentSpacing),

                    // 3D Hexagon Hero Badge Stage (Clean, no glow, animated 3D pop & vector stroke draw)
                    AmanahBadgeHeroStage(
                      palette: palette,
                      statusType: payload.type,
                      size: 156.0,
                      entranceProgress: 1.0,
                      buildProgress: buildProgress,
                      onTap: onBadgeTap,
                    ),
                    const SizedBox(height: 16),

                    // Sequential Content: Reveals once the badge arrives at the top
                    Transform.translate(
                      offset: Offset(0, 16.0 * (1.0 - contentEased)),
                      child: Opacity(
                        opacity: contentEased,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Typography Section (Minimalist: Title, Divider, Message)
                            AmanahResultTypographySection(
                              payload: payload,
                              palette: palette,
                              progress: contentProgress,
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons (In-Flow, Design System)
                            if (payload.isSuccess) ...<Widget>[
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
                            ] else ...<Widget>[
                              AmanahButton.primary(
                                text: payload.actionLabel,
                                isFullWidth: true,
                                size: AmanahButtonSize.medium,
                                onPressed: onClose,
                              ),
                            ],
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
    );
  }
}
