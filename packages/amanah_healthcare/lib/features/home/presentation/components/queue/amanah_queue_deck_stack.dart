import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_copywriting.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_racing_chevrons.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_card_cover.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_gesture_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Responsive Queue Deck Stack rendering active front card and layered background queue
class AmanahQueueDeckStack extends StatelessWidget {
  const AmanahQueueDeckStack({
    super.key,
    required this.cards,
    required this.horizontalDrag,
    required this.verticalDrag,
    required this.dragMode,
    required this.isCancelling,
    required this.cancelProgress,
    required this.isRotating,
    required this.rotateProgress,
    required this.isActivating,
    required this.ejectionStage,
    required this.showSuccess,
    required this.onCardSelect,
    this.onCardTap,
    this.onResetQueue,
  });

  final List<AmanahQueueCardData> cards;
  final double horizontalDrag;
  final double verticalDrag;
  final QueueDragMode dragMode;
  final bool isCancelling;
  final double cancelProgress;
  final bool isRotating;
  final double rotateProgress;
  final bool isActivating;
  final String ejectionStage;
  final bool showSuccess;
  final ValueChanged<int> onCardSelect;
  final ValueChanged<AmanahQueueCardData>? onCardTap;
  final VoidCallback? onResetQueue;

  static const double cardW = 212.0;
  static const double cardH = 335.0;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AmanahEmptyState.box(
            title: DoctorQueueCopywriting.emptyQueueTitle,
            message: DoctorQueueCopywriting.emptyQueueSubtitle,
          ),
        ),
      );
    }

    final Size screen = MediaQuery.sizeOf(context);
    final double baseTop = math.max(16.0, screen.height * 0.05);
    final double baseLeft = (screen.width - cardW) / 2;

    double card0X = 0.0;
    double card0Y = 0.0;
    double card0Scale = 1.0;
    double card0Rot = 0.0;
    double card0Opacity = 1.0;
    bool card0IsBehind = false;
    double queueAdvanceFactor = 0.0;

    if (dragMode == QueueDragMode.up) {
      card0Y = verticalDrag;
      card0Scale = 1.0 - (verticalDrag.abs() / 240.0).clamp(0.0, 0.12);
      card0Opacity = 1.0 - (verticalDrag.abs() / 180.0).clamp(0.0, 0.40);
      queueAdvanceFactor = (verticalDrag.abs() / 90.0).clamp(0.0, 1.0);
    } else if (dragMode == QueueDragMode.down) {
      card0Y = verticalDrag;
    } else if (dragMode == QueueDragMode.left) {
      card0X = horizontalDrag;
      card0Y = horizontalDrag.abs() * 0.06;
      card0Rot =
          (horizontalDrag * 0.035).clamp(-8.0, 0.0) * (math.pi / 180.0);
      card0Scale = 1.0 - (horizontalDrag.abs() / 320.0).clamp(0.0, 0.08);
      queueAdvanceFactor = (horizontalDrag.abs() / 90.0).clamp(0.0, 1.0);
    }

    if (isCancelling) {
      final double curve = Curves.easeInCubic.transform(cancelProgress);
      card0Y = verticalDrag + (-screen.height * 0.50 - verticalDrag) * curve;
      card0Scale = 1.0 - 0.20 * curve;
      card0Opacity = (1.0 - curve).clamp(0.0, 1.0);
      queueAdvanceFactor = curve;
    } else if (isRotating) {
      final double peakX = -screen.width * 0.72;
      if (rotateProgress < 0.45) {
        final double p1 = (rotateProgress / 0.45).clamp(0.0, 1.0);
        final double c1 = Curves.easeOutQuad.transform(p1);
        card0X = horizontalDrag + (peakX - horizontalDrag) * c1;
        card0Y = 10.0 * c1;
        card0Rot = (horizontalDrag * 0.035 - 7.0 * c1) * (math.pi / 180.0);
        card0Scale = 1.0 - 0.06 * c1;
        card0Opacity = 1.0 - 0.10 * c1;
        card0IsBehind = false;
        queueAdvanceFactor = c1;
      } else {
        final double p2 = ((rotateProgress - 0.45) / 0.55).clamp(0.0, 1.0);
        final double c2 = Curves.easeOutCubic.transform(p2);
        final double targetBackX = math.min((cards.length - 1) * 24.0, 70.0);
        final double targetBackY = -math.min((cards.length - 1) * 3.0, 9.0);
        final double targetBackScale =
            math.max(1.0 - (cards.length - 1) * 0.06, 0.82);
        final double targetBackOpacity =
            math.max(1.0 - (cards.length - 1) * 0.16, 0.50);

        card0X = peakX * (1.0 - c2) + targetBackX * c2;
        card0Y = 10.0 * (1.0 - c2) + targetBackY * c2;
        card0Rot = (-7.0 * (1.0 - c2)) * (math.pi / 180.0);
        card0Scale = 0.94 - (0.94 - targetBackScale) * c2;
        card0Opacity = 0.90 - (0.90 - targetBackOpacity) * c2;
        card0IsBehind = true;
        queueAdvanceFactor = 1.0;
      }
    }

    if (isActivating || showSuccess || ejectionStage == 'dock_appear') {
      card0Y = 650.0;
      card0Opacity = showSuccess ? 0.0 : 1.0;
    } else if (ejectionStage == 'rail_converge') {
      card0Y = 650.0;
      card0Opacity = 0.0;
    } else if (ejectionStage == 'atm_peek') {
      card0Y = 165.0;
      card0Opacity = 1.0;
    } else if (ejectionStage == 'full_eject') {
      card0Y = 0.0;
      card0Opacity = 1.0;
    }

    final List<Widget> stackChildren = <Widget>[];

    // 1. Target Frame Outline behind active front card
    stackChildren.add(
      Positioned(
        left: baseLeft - 3,
        top: baseTop - 3,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          opacity: isActivating || showSuccess ? 0.0 : 1.0,
          child: Container(
            width: cardW + 6,
            height: cardH + 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AmanahColorTokens.brandLight.withValues(alpha: 0.75),
                width: 1.8,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AmanahColorTokens.brandLight.withValues(alpha: 0.22),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Widget buildCardWidget(
      int index,
      double x,
      double y,
      double scale,
      double rot,
      double opacity,
      bool isInteractive,
    ) {
      return Positioned(
        key: ValueKey<String>(cards[index].id),
        left: baseLeft + x,
        top: baseTop + y,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(rot)
              ..scaleByDouble(scale, scale, 1.0, 1.0),
            child: GestureDetector(
              onTap: isInteractive
                  ? () => onCardSelect(index)
                  : () => onCardTap?.call(cards[index]),
              child: RepaintBoundary(
                child: AmanahQueueCardCover(card: cards[index]),
              ),
            ),
          ),
        ),
      );
    }

    // 2. Queued Background Cards (rendered from back to front)
    final List<Widget> backgroundCardWidgets = <Widget>[];
    final int maxQueued = math.min(cards.length - 1, 3);

    for (int i = maxQueued; i >= 1; i--) {
      final double baseX = i * 24.0;
      final double baseY = -i * 3.0;
      final double baseScale = 1.0 - (i * 0.06);
      final double baseOpacity = 1.0 - (i * 0.12);

      final double targetX = (i - 1) * 24.0;
      final double targetY = -(i - 1) * 3.0;
      final double targetScale = 1.0 - ((i - 1) * 0.06);
      final double targetOpacity = 1.0 - ((i - 1) * 0.12);

      final double x = baseX + (targetX - baseX) * queueAdvanceFactor;
      final double y = baseY + (targetY - baseY) * queueAdvanceFactor;
      final double scale =
          baseScale + (targetScale - baseScale) * queueAdvanceFactor;
      double opacity =
          baseOpacity + (targetOpacity - baseOpacity) * queueAdvanceFactor;

      if (isActivating || showSuccess || ejectionStage == 'dock_appear') {
        opacity = 0.0;
      }

      backgroundCardWidgets.add(
        buildCardWidget(i, x, y, scale, 0.0, opacity, true),
      );
    }

    // 3. Front Card 0
    final Widget card0Widget = buildCardWidget(
      0,
      card0X,
      card0Y,
      card0Scale,
      card0Rot,
      card0Opacity,
      false,
    );

    if (card0IsBehind) {
      stackChildren.add(card0Widget);
      stackChildren.addAll(backgroundCardWidgets);
    } else {
      stackChildren.addAll(backgroundCardWidgets);
      stackChildren.add(card0Widget);
    }

    // 4. On-Demand UP Chevron Indicator (Batalkan)
    double upIndicatorOpacity = 0.0;
    if (dragMode == QueueDragMode.up) {
      upIndicatorOpacity = (verticalDrag.abs() / 50.0).clamp(0.0, 1.0);
    } else if (isCancelling) {
      upIndicatorOpacity = (1.0 - cancelProgress).clamp(0.0, 1.0);
    }

    if (!isActivating && !showSuccess) {
      stackChildren.add(
        Positioned(
          left: 0,
          right: 0,
          top: baseTop - 40,
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: upIndicatorOpacity,
              child: const RotatedBox(
                quarterTurns: 2,
                child: AmanahRacingPulseChevrons(),
              ),
            ),
          ),
        ),
      );
    }

    // 5. On-Demand LEFT Chevron Indicator (Antre ke Belakang)
    double leftIndicatorOpacity = 0.0;
    if (dragMode == QueueDragMode.left) {
      leftIndicatorOpacity = (horizontalDrag.abs() / 50.0).clamp(0.0, 1.0);
    } else if (isRotating) {
      leftIndicatorOpacity = (1.0 - rotateProgress).clamp(0.0, 1.0);
    }

    if (!isActivating && !showSuccess) {
      stackChildren.add(
        Positioned(
          left: 18,
          top: baseTop + (cardH - 34) / 2,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: leftIndicatorOpacity,
            child: const RotatedBox(
              quarterTurns: 1,
              child: AmanahRacingPulseChevrons(),
            ),
          ),
        ),
      );
    }

    // 6. DOWN Chevron Indicator
    final double downChevronOpacity =
        (isActivating || showSuccess || ejectionStage != 'idle')
            ? 0.0
            : (dragMode == QueueDragMode.down
                ? (verticalDrag / 40.0).clamp(0.0, 1.0)
                : (dragMode == QueueDragMode.none ? 0.40 : 0.0));

    stackChildren.add(
      Positioned(
        left: 0,
        right: 0,
        top: baseTop + cardH + 13,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: downChevronOpacity,
            child: const AmanahRacingPulseChevrons(),
          ),
        ),
      ),
    );

    return Stack(clipBehavior: Clip.none, children: stackChildren);
  }
}
