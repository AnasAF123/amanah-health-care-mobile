import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_copywriting.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_blurry_morph_text.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_paramedic_toolbox.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_bottom_notched_dock.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_deck_stack.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_gesture_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_header_bar.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Composition widget for Queue Dock with responsive queue deck stack and reactive headline
class AmanahQueueDockBody extends StatelessWidget {
  const AmanahQueueDockBody({
    required this.cards,
    required this.horizontalDrag,
    required this.verticalDrag,
    required this.dragMode,
    required this.isCancelling,
    required this.cancelProgress,
    required this.isRotating,
    required this.rotateProgress,
    required this.activationStage,
    required this.ejectionStage,
    required this.showSuccess,
    required this.dotCount,
    required this.entranceValue,
    required this.historyCount,
    required this.onBack,
    required this.onOpenGuide,
    required this.onOpenHistory,
    required this.onCardSelect,
    required this.onPanDown,
    required this.onPanCancel,
    required this.onPanUpdate,
    required this.onPanEnd,
    this.sessionLabel,
    this.onSelectSession,
    this.onCardTap,
    this.onResetQueue,
    this.onCallPatient,
    super.key,
  });

  final List<AmanahQueueCardData> cards;
  final double horizontalDrag;
  final double verticalDrag;
  final QueueDragMode dragMode;
  final bool isCancelling;
  final double cancelProgress;
  final bool isRotating;
  final double rotateProgress;
  final String activationStage;
  final String ejectionStage;
  final bool showSuccess;
  final int dotCount;
  final double entranceValue;
  final int historyCount;
  final String? sessionLabel;
  final VoidCallback? onSelectSession;
  final VoidCallback onBack;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenHistory;
  final ValueChanged<int> onCardSelect;
  final ValueChanged<AmanahQueueCardData>? onCardTap;
  final VoidCallback? onResetQueue;
  final ValueChanged<DragDownDetails> onPanDown;
  final VoidCallback onPanCancel;
  final ValueChanged<DragUpdateDetails> onPanUpdate;
  final ValueChanged<DragEndDetails> onPanEnd;
  final VoidCallback? onCallPatient;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double dragProgress = (verticalDrag / 80.0).clamp(0.0, 1.0);
    final bool isNearSlot =
        (verticalDrag >= 20.0 || dragProgress >= 0.25) &&
            activationStage == 'idle';
    final bool isMorphingActive = activationStage == 'activating';

    final double headerProgress = Curves.easeOutCubic.transform(
      (entranceValue / 0.40).clamp(0.0, 1.0),
    );
    final double textProgress = Curves.easeOutCubic.transform(
      ((entranceValue - 0.15) / 0.45).clamp(0.0, 1.0),
    );
    final double railProgress = Curves.easeOutCubic.transform(
      ((entranceValue - 0.25) / 0.50).clamp(0.0, 1.0),
    );
    final double dockProgress = Curves.easeOutCubic.transform(
      ((entranceValue - 0.45) / 0.40).clamp(0.0, 1.0),
    );

    String headlineText = 'Pilih antrean\npasien';
    if (isMorphingActive) {
      headlineText = 'Memproses\nantrean';
    } else if (isNearSlot) {
      headlineText = 'Lepaskan untuk\nproses antrean';
    } else if (dragMode == QueueDragMode.up && verticalDrag <= -20.0) {
      headlineText = 'Lepaskan untuk\nbatalkan antrean';
    } else if (dragMode == QueueDragMode.left && horizontalDrag <= -20.0) {
      headlineText = 'Lepaskan untuk\njadwalkan ulang';
    }

    return SafeArea(
      child: Column(
        children: <Widget>[
          Transform.translate(
            offset: Offset(0, -20.0 * (1.0 - headerProgress)),
            child: Opacity(
              opacity: headerProgress,
              child: RepaintBoundary(
                child: AmanahQueueHeaderBar(
                  onBack: onBack,
                  onOpenGuide: onOpenGuide,
                  onOpenHistory: onOpenHistory,
                  historyCount: historyCount,
                  showSuccess: showSuccess,
                  sessionLabel: sessionLabel,
                  onSelectSession: onSelectSession,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -15.0 * (1.0 - textProgress)),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showSuccess ? 0.0 : textProgress,
              child: RepaintBoundary(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: const Cubic(0.22, 1.0, 0.36, 1.0),
                  transform: Matrix4.translationValues(
                    0,
                    isMorphingActive ? 220.0 : 12.0,
                    0,
                  ),
                  child: AnimatedScale(
                    scale: isMorphingActive ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 700),
                    curve: const Cubic(0.22, 1.0, 0.36, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 6),
                        AnimatedScale(
                          scale: (isMorphingActive || isNearSlot) ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: AmanahParamedicToolbox3D(
                            isOpen: isMorphingActive || isNearSlot,
                            size: 76,
                          ),
                        ),
                        const SizedBox(height: 10),
                        BlurryMorphText(
                          text: headlineText,
                          isProcessing: isMorphingActive,
                          dotCount: dotCount,
                          style: TextStyle(
                            color: isNearSlot || isMorphingActive
                                ? (isDark
                                    ? AmanahColorTokens.tabActiveDark
                                    : AmanahColorTokens.brandPrimary)
                                : (isDark
                                    ? AmanahColorTokens.pureWhite
                                    : AmanahColorTokens.neutral900),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (cards.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AmanahEmptyState.box(
                    title: DoctorQueueCopywriting.emptyQueueTitle,
                    message: DoctorQueueCopywriting.emptyQueueSubtitle,
                  ),
                ),
              ),
            )
          else ...<Widget>[
            Expanded(
              child: Transform.translate(
                offset: Offset(0, 40.0 * (1.0 - railProgress)),
                child: Transform.scale(
                  scale: 0.88 + (0.12 * railProgress),
                  child: Opacity(
                    opacity: railProgress,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanDown: onPanDown,
                      onPanCancel: onPanCancel,
                      onPanUpdate: onPanUpdate,
                      onPanEnd: onPanEnd,
                      child: RepaintBoundary(
                        child: AmanahQueueDeckStack(
                          cards: cards,
                          horizontalDrag: horizontalDrag,
                          verticalDrag: verticalDrag,
                          dragMode: dragMode,
                          isCancelling: isCancelling,
                          cancelProgress: cancelProgress,
                          isRotating: isRotating,
                          rotateProgress: rotateProgress,
                          isActivating: activationStage != 'idle',
                          ejectionStage: ejectionStage,
                          showSuccess: showSuccess,
                          onCardSelect: onCardSelect,
                          onCardTap: onCardTap,
                          onResetQueue: onResetQueue,
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
                    isLongPressing: false,
                    label: DoctorQueueCopywriting.pullCardToCall,
                    onCallPatient: onCallPatient,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
