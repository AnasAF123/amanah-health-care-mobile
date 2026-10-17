import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_copywriting.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_status.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_confetti_canvas.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_card_cover.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_revealed_hero_card.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/amanah_patient_intake_drawer.dart';

class AmanahQueueActiveSessionSheet extends StatefulWidget {
  const AmanahQueueActiveSessionSheet({
    required this.card,
    required this.isGenieSettled,
    required this.isGenieRunning,
    required this.onClose,
    required this.onComplete,
    this.onCallAgain,
    this.onPatientEntered,
    this.onSkipNoShow,
    this.onReschedule,
    this.callCount = 1,
    this.status = DoctorQueueStatus.inConsultation,
    this.isLoading = false,
    super.key,
  });

  final AmanahQueueCardData card;
  final bool isGenieSettled;
  final bool isGenieRunning;
  final VoidCallback onClose;
  final VoidCallback onComplete;
  final VoidCallback? onCallAgain;
  final VoidCallback? onPatientEntered;
  final VoidCallback? onSkipNoShow;
  final VoidCallback? onReschedule;
  final int callCount;
  final DoctorQueueStatus status;
  final bool isLoading;

  @override
  State<AmanahQueueActiveSessionSheet> createState() =>
      _AmanahQueueActiveSessionSheetState();
}

class _AmanahQueueActiveSessionSheetState
    extends State<AmanahQueueActiveSessionSheet>
    with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  final GlobalKey<AmanahConfettiCanvasState> _confettiKey =
      GlobalKey<AmanahConfettiCanvasState>();

  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _hapticFired = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _flipAnimation = Tween<double>(begin: math.pi, end: 0.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeOutCubic),
    );

    _flipController.addListener(() {
      if (_flipController.value >= 0.45 && !_hapticFired) {
        _hapticFired = true;
        HapticFeedback.mediumImpact();
        _confettiKey.currentState?.fire();
      }
      setState(() {});
    });

    if (widget.isGenieSettled) {
      _flipController.value = 1.0;
      _hapticFired = true;
    }
  }

  @override
  void didUpdateWidget(covariant AmanahQueueActiveSessionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGenieSettled && !oldWidget.isGenieSettled) {
      _hapticFired = false;
      _flipController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _openDetailModal() {
    AmanahPatientIntakeDrawer.show(
      context,
      appointmentId: widget.card.effectiveAppointmentId,
      patientName: widget.card.patientName,
      queueNumber: widget.card.queueNumber,
      mrn: widget.card.patientRm,
      age: '${widget.card.age} Thn',
      complaint: widget.card.complaint,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Size size = MediaQuery.sizeOf(context);
    final double cardW = math.min(size.width - 64, 320.0);
    final double cardH = cardW / 0.718;

    final double flipAngle = _flipAnimation.value;
    final bool isBackface = flipAngle > (math.pi / 2);

    final String statusBadgeText = DoctorQueueCopywriting.statusInConsultation;

    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onClose,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: widget.isGenieSettled
                    ? 1.0
                    : (widget.isGenieRunning ? 0.0 : 0.95),
                child: Container(
                  color: isDark
                      ? AmanahColorTokens.canvasDark.withValues(alpha: 0.95)
                      : AmanahColorTokens.canvasLight.withValues(alpha: 0.97),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: widget.isGenieSettled ? 1.0 : 0.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(
                      0,
                      widget.isGenieSettled ? 0.0 : -14.0,
                      0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: isDark
                                ? AmanahColorTokens.pureWhite
                                : AmanahColorTokens.neutral800,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.status ==
                                      DoctorQueueStatus.inConsultation
                                  ? AmanahColorTokens.success
                                      .withValues(alpha: 0.16)
                                  : (isDark
                                      ? AmanahColorTokens.cyanAccent
                                          .withValues(alpha: 0.16)
                                      : AmanahColorTokens.brandMuted),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusBadgeText,
                              style: TextStyle(
                                color: widget.status ==
                                        DoctorQueueStatus.inConsultation
                                    ? AmanahColorTokens.success
                                    : (isDark
                                        ? AmanahColorTokens.cyanAccent
                                        : AmanahColorTokens.brandPrimary),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onPanUpdate: (DragUpdateDetails d) {
                        setState(() {
                          _tiltX = (d.localPosition.dy / cardH - 0.5) * -0.35;
                          _tiltY = (d.localPosition.dx / cardW - 0.5) * 0.35;
                        });
                      },
                      onPanEnd: (_) {
                        setState(() {
                          _tiltX = 0;
                          _tiltY = 0;
                        });
                      },
                      onTap: _openDetailModal,
                      child: Opacity(
                        opacity: widget.isGenieRunning ? 0.0 : 1.0,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(_tiltX)
                            ..rotateY(_tiltY + flipAngle),
                          child: isBackface
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateY(math.pi),
                                  child: SizedBox(
                                    width: cardW,
                                    height: cardH,
                                    child: AmanahQueueCardCover(
                                      card: widget.card,
                                      width: cardW,
                                      height: cardH,
                                    ),
                                  ),
                                )
                              : AmanahRevealedHeroCard(
                                  card: widget.card,
                                  width: cardW,
                                  height: cardH,
                                  onDetailTap: _openDetailModal,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: widget.isGenieSettled ? 1.0 : 0.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(
                      0,
                      widget.isGenieSettled ? 0.0 : 28.0,
                      0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AmanahButton.primary(
                            text: DoctorQueueCopywriting.actionMarkCompleted,
                            size: AmanahButtonSize.hero,
                            isFullWidth: true,
                            borderRadius: BorderRadius.circular(18),
                            onPressed:
                                widget.isLoading ? null : widget.onComplete,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(child: AmanahConfettiCanvas(key: _confettiKey)),
        ],
      ),
    );
  }
}
