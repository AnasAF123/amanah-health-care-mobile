import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_bottom_notched_dock.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_3d_carousel.dart';

/// Interactive area containing the 3D queue carousel and bottom notched dock
class AmanahQueueInteractionStage extends StatelessWidget {
  const AmanahQueueInteractionStage({
    super.key,
    required this.cards,
    required this.currentIndex,
    required this.horizontalDrag,
    required this.verticalDrag,
    required this.spinOffset,
    required this.isLongPressing,
    required this.activationStage,
    required this.ejectionStage,
    required this.showSuccess,
    required this.railProgress,
    required this.dockProgress,
    required this.dragProgress,
    required this.isMorphingActive,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onPanDown,
    required this.onPanCancel,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onCardSelect,
  });

  final List<AmanahQueueCardData> cards;
  final int currentIndex;
  final double horizontalDrag;
  final double verticalDrag;
  final double spinOffset;
  final bool isLongPressing;
  final String activationStage;
  final String ejectionStage;
  final bool showSuccess;
  final double railProgress;
  final double dockProgress;
  final double dragProgress;
  final bool isMorphingActive;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final VoidCallback onPanDown;
  final VoidCallback onPanCancel;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final ValueChanged<int> onCardSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Transform.translate(
            offset: Offset(0, 40.0 * (1.0 - railProgress)),
            child: Transform.scale(
              scale: 0.88 + (0.12 * railProgress),
              child: Opacity(
                opacity: railProgress,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPressStart: (_) => onLongPressStart(),
                  onLongPressEnd: (_) => onLongPressEnd(),
                  onPanDown: (_) => onPanDown(),
                  onPanCancel: onPanCancel,
                  onPanUpdate: onPanUpdate,
                  onPanEnd: onPanEnd,
                  child: RepaintBoundary(
                    child: AmanahQueue3DCarousel(
                      cards: cards,
                      currentIndex: currentIndex,
                      horizontalDrag: horizontalDrag,
                      verticalDrag: verticalDrag,
                      spinOffset: spinOffset,
                      isActivating: activationStage != 'idle',
                      ejectionStage: ejectionStage,
                      showSuccess: showSuccess,
                      onCardSelect: onCardSelect,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, 70.0 * (1.0 - dockProgress)),
          child: Opacity(
            opacity: dockProgress,
            child: RepaintBoundary(
              child: AmanahBottomNotchedDock(
                isActivating: isMorphingActive || showSuccess,
                dragProgress: dragProgress,
                isLongPressing: isLongPressing,
                label: 'Tarik antrean ke bawah untuk proses',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
