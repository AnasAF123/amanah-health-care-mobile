import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_palette.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/atoms/amanah_hexagon_badge_painter.dart';

/// Molecule: 156x156 Clean Hero Badge Stage featuring choreographed 3D entrance pop,
/// rocking tilt, ribbon drop, vector stroke draw-on, and interactive tap bounce.
/// Clean design: absolutely zero circular neon glow or fuzzy drop shadow.
class AmanahBadgeHeroStage extends StatefulWidget {
  const AmanahBadgeHeroStage({
    required this.palette,
    required this.statusType,
    super.key,
    this.size = 156.0,
    this.entranceProgress = 1.0,
    this.buildProgress = 1.0,
    this.onTap,
  });

  final PresenceResultPalette palette;
  final PresenceStatusType statusType;
  final double size;
  final double entranceProgress;
  final double buildProgress;
  final VoidCallback? onTap;

  @override
  State<AmanahBadgeHeroStage> createState() => _AmanahBadgeHeroStageState();
}

class _AmanahBadgeHeroStageState extends State<AmanahBadgeHeroStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _tapScaleAnimation;
  late final Animation<double> _tapTiltAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _tapScaleAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.08, end: 0.96)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.96, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_bounceController);

    _tapTiltAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 0.05)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.05, end: -0.03)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -0.03, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final double b = widget.buildProgress.clamp(0.0, 1.0);
    final double p = widget.entranceProgress.clamp(0.0, 1.0);

    double scale = 1.0;
    double tilt = 0.0;
    double ribbonOffset = 0.0;
    double glyphProgress = 1.0;

    if (widget.buildProgress < 1.0) {
      // Phase 1 Building Choreography
      // 1. Base scale: emerges smoothly 0.90 -> 1.00 as outer border draws
      if (b <= 0.25) {
        final double t = (b / 0.25).clamp(0.0, 1.0);
        scale = 0.90 + Curves.easeOutCubic.transform(t) * 0.10;
      } else if (b >= 0.92) {
        // Celebratory Badge Bounce when the SVG glyph completes self-drawing!
        final double t = ((b - 0.92) / 0.08).clamp(0.0, 1.0);
        if (t <= 0.50) {
          scale = 1.0 + (t / 0.50) * 0.08;
          tilt = (t / 0.50) * 0.035;
        } else {
          final double t2 = (t - 0.50) / 0.50;
          scale = 1.08 - Curves.easeOutBack.transform(t2) * 0.08;
          tilt = 0.035 * (1.0 - Curves.easeOutBack.transform(t2));
        }
      } else {
        scale = 1.0;
        tilt = 0.0;
      }

      glyphProgress = ((b - 0.70) / 0.24).clamp(0.0, 1.0);
    } else {
      // Snappy fallback to entranceProgress
      if (p <= 0.35) {
        final double t = (p / 0.35).clamp(0.0, 1.0);
        scale = Curves.easeOutCubic.transform(t) * 1.10;
      } else if (p <= 0.55) {
        final double t = ((p - 0.35) / 0.20).clamp(0.0, 1.0);
        scale = 1.10 - Curves.easeInOutCubic.transform(t) * 0.14;
      } else if (p < 1.0) {
        final double t = ((p - 0.55) / 0.25).clamp(0.0, 1.0);
        scale = 0.96 + Curves.easeOutBack.transform(t) * 0.04;
      } else {
        scale = 1.0;
      }

      if (p <= 0.35) {
        final double t = (p / 0.35).clamp(0.0, 1.0);
        tilt = -0.174 + Curves.easeOutCubic.transform(t) * (0.174 + 0.052);
      } else if (p <= 0.60) {
        final double t = ((p - 0.35) / 0.25).clamp(0.0, 1.0);
        tilt = 0.052 - Curves.easeInOutCubic.transform(t) * (0.052 + 0.017);
      } else if (p < 1.0) {
        final double t = ((p - 0.60) / 0.20).clamp(0.0, 1.0);
        tilt = -0.017 + Curves.easeOutBack.transform(t) * 0.017;
      } else {
        tilt = 0.0;
      }

      if (p <= 0.40) {
        final double t = (p / 0.40).clamp(0.0, 1.0);
        ribbonOffset = -14.0 * (1.0 - Curves.easeOutCubic.transform(t));
      } else if (p < 1.0) {
        final double t = ((p - 0.40) / 0.35).clamp(0.0, 1.0);
        ribbonOffset = 2.0 * (1.0 - Curves.easeOutBack.transform(t));
      } else {
        ribbonOffset = 0.0;
      }

      glyphProgress = ((p - 0.10) / 0.40).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (BuildContext context, _) {
          final double totalScale = scale * _tapScaleAnimation.value;
          final double totalTilt = tilt + _tapTiltAnimation.value;

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: AmanahHexagonBadgePainter(
                palette: widget.palette,
                statusType: widget.statusType,
                scale: totalScale,
                buildProgress: widget.buildProgress,
                glyphProgress: glyphProgress,
                ribbonOffset: ribbonOffset,
                tiltAngle: totalTilt,
              ),
            ),
          );
        },
      ),
    );
  }
}
