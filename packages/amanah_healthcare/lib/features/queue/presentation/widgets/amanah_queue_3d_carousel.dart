import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_racing_chevrons.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/queue/presentation/widgets/amanah_queue_card_cover.dart';

class AmanahQueue3DCarousel extends StatelessWidget {
  const AmanahQueue3DCarousel({
    required this.cards,
    required this.currentIndex,
    required this.horizontalDrag,
    required this.verticalDrag,
    required this.spinOffset,
    required this.isActivating,
    required this.ejectionStage,
    required this.showSuccess,
    required this.onCardSelect,
    super.key,
  });

  final List<AmanahQueueCardData> cards;
  final int currentIndex;
  final double horizontalDrag;
  final double verticalDrag;
  final double spinOffset;
  final bool isActivating;
  final String ejectionStage;
  final bool showSuccess;
  final ValueChanged<int> onCardSelect;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final double totalDragOffset = horizontalDrag - spinOffset;
    final double dragUnits = totalDragOffset / 230.0;
    final double baseTop = math.max(16.0, screen.height * 0.05);

    final List<Widget> cardWidgets = <Widget>[];

    cardWidgets.add(
      Positioned(
        left: (screen.width - 218) / 2,
        top: baseTop - 3,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          opacity: isActivating || showSuccess ? 0.0 : 1.0,
          child: Container(
            width: 218,
            height: 341,
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

    cardWidgets.add(
      Positioned(
        left: 0,
        right: 0,
        top: baseTop + 348,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (isActivating || showSuccess || ejectionStage != 'idle')
                ? 0.0
                : (1.0 - (verticalDrag / 40.0)).clamp(0.0, 1.0),
            child: const AmanahRacingPulseChevrons(),
          ),
        ),
      ),
    );

    for (int index = 0; index < cards.length; index++) {
      double distanceFromCenter = (index - currentIndex) + dragUnits;

      while (distanceFromCenter > cards.length / 2) {
        distanceFromCenter -= cards.length;
      }
      while (distanceFromCenter < -cards.length / 2) {
        distanceFromCenter += cards.length;
      }

      if (distanceFromCenter.abs() > 2.8) {
        continue;
      }

      final bool isCenter = index == currentIndex && totalDragOffset.abs() < 24;
      final double angleDeg = distanceFromCenter * 19.5;
      final double angleRad = angleDeg * math.pi / 180.0;

      final double x = 660.0 * math.sin(angleRad) * (screen.width / 420.0);
      double y = -660.0 * (1.0 - math.cos(angleRad)) * 0.8;
      final double rotateZ = -distanceFromCenter * 13.0 * math.pi / 180.0;
      final double rotateY = distanceFromCenter * 8.0 * math.pi / 180.0;
      final double scale =
          1.0 - math.min(0.06, distanceFromCenter.abs() * 0.035);
      double opacity =
          (1.0 - (distanceFromCenter.abs() - 0.85).clamp(0.0, 1.0) * 0.95)
              .clamp(0.0, 1.0);

      if (isCenter && verticalDrag > 0) {
        y += verticalDrag;
      }

      if (isActivating || showSuccess || ejectionStage == 'dock_appear') {
        if (index != currentIndex) {
          opacity = 0.0;
        } else {
          y = 650.0;
          opacity = showSuccess ? 0.0 : 1.0;
        }
      } else if (ejectionStage == 'rail_converge') {
        if (index == currentIndex) {
          y = 650.0;
          opacity = 0.0;
        } else {
          opacity = 1.0;
        }
      } else if (ejectionStage == 'atm_peek') {
        if (index == currentIndex) {
          y = 165.0;
          opacity = 1.0;
        }
      } else if (ejectionStage == 'full_eject') {
        if (index == currentIndex) {
          y = 0.0;
          opacity = 1.0;
        }
      }

      cardWidgets.add(
        Positioned(
          key: ValueKey<String>(cards[index].id),
          left: (screen.width - 212) / 2 + x,
          top: baseTop + y,
          child: Opacity(
            opacity: opacity,
            child: Transform(
              alignment: const Alignment(0, -0.6),
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotateY)
                ..rotateZ(rotateZ)
                ..scaleByDouble(scale, scale, 1, 1),
              child: GestureDetector(
                onTap: () {
                  if (index != currentIndex) {
                    onCardSelect(index);
                  }
                },
                child: RepaintBoundary(
                  child: AmanahQueueCardCover(card: cards[index]),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: cardWidgets);
  }
}
