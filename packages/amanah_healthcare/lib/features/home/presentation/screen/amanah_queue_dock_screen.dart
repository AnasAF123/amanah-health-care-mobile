import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_status.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_bottom_banner.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_active_session_sheet.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_dock_animator.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_dock_body.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_genie_overlay.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_gesture_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_guide_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/modal/amanah_queue_dismiss_modal.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/modal/amanah_queue_session_selector.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/modal/amanah_reschedule_modal.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/amanah_queue_history_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/patient_record.dart';
import 'package:amanah_healthcare/features/queue/domain/failures/queue_failure.dart';
import 'package:amanah_healthcare/features/queue/presentation/state/amanah_queue_store.dart';

/// Master 3D Queue Deck Stack Screen (Pilih Antrean Pasien)
class AmanahQueueDockScreen extends StatefulWidget {
  const AmanahQueueDockScreen({super.key, this.cards = const <AmanahQueueCardData>[]});

  final List<AmanahQueueCardData> cards;

  static Route<void> route({List<AmanahQueueCardData> cards = const <AmanahQueueCardData>[]}) {
    return PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => AmanahQueueDockScreen(cards: cards),
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(opacity: animation, child: child);
          },
    );
  }

  @override
  State<AmanahQueueDockScreen> createState() => _AmanahQueueDockScreenState();
}

class _AmanahQueueDockScreenState extends State<AmanahQueueDockScreen>
    with TickerProviderStateMixin {
  final AmanahQueueStore _queueStore = AmanahQueueStore.instance;
  late final AmanahQueueGestureController _gesture;
  late final AmanahQueueDockAnimator _animator;
  late final AnimationController _entranceController;
  AnimationController? _dotsController;

  late List<AmanahQueueCardData> _cards;
  final List<AmanahQueueCardData> _collectedCards = <AmanahQueueCardData>[];

  int _dotCount = 0;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _cards = List<AmanahQueueCardData>.from(widget.cards);

    _gesture = AmanahQueueGestureController(
      vsync: this,
      onUpdate: () => setState(() {}),
      onProcessCard: _handleActivate,
      onCancelComplete: _handleSwipeUpCancel,
      onRotateComplete: _handleSwipeLeftReschedule,
    );

    _animator = AmanahQueueDockAnimator(vsync: this, onStateChange: () => setState(() {}));

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _initDotsTimer();
    _queueStore.addListener(_onQueueStoreChanged);
    _queueStore.loadTodaySessionsAndQueue();
  }

  void _initDotsTimer() {
    _dotsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 960))
      ..addListener(() {
        if (_animator.activationStage == 'activating') {
          final int next = ((_dotsController!.value * 3).floor() % 3) + 1;
          if (next != _dotCount) {
            setState(() => _dotCount = next);
          }
        }
      });
  }

  @override
  void dispose() {
    _queueStore.removeListener(_onQueueStoreChanged);
    _entranceController.dispose();
    _dotsController?.dispose();
    _dotsController = null;
    _gesture.dispose();
    _animator.dispose();
    super.dispose();
  }

  void _onQueueStoreChanged() {
    if (!mounted) return;
    if (_queueStore.waitingPatients.isNotEmpty || widget.cards.isEmpty) {
      final List<AmanahQueueCardData> newCards = _queueStore.waitingPatients
          .map((p) => p.toUiCard())
          .toList();
      setState(() {
        _cards = newCards;
      });
    }
  }

  void _bringCardToFront(int index) {
    if (index <= 0 || index >= _cards.length) return;
    setState(() {
      final chosen = _cards.removeAt(index);
      _cards.insert(0, chosen);
      _gesture.resetPositions();
    });
  }

  Future<void> _handleSwipeUpCancel() async {
    if (_cards.isEmpty) return;
    final AmanahQueueCardData card = _cards.first;

    final AmanahQueueDismissAction? action = await AmanahQueueDismissModal.show(
      context,
      patientName: card.patientName,
      queueNumber: card.queueNumber,
    );

    if (action == null) {
      if (mounted) {
        setState(() {
          _gesture.resetPositions();
        });
      }
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      if (action == AmanahQueueDismissAction.cancel) {
        await _queueStore.cancelAppointment(card.id, reason: 'Dibatalkan oleh dokter dari antrean');
        if (!mounted) return;
        setState(() {
          _cards.removeWhere((c) => c.id == card.id);
          _gesture.resetPositions();
        });
        _showSnack('Janji temu ${card.queueNumber} (${card.patientName}) berhasil dibatalkan.');
      } else if (action == AmanahQueueDismissAction.noShow) {
        await _queueStore.reportNoShow(card.id, notes: 'Pasien tidak hadir saat giliran antrean');
        if (!mounted) return;
        setState(() {
          _cards.removeWhere((c) => c.id == card.id);
          _gesture.resetPositions();
        });
        _showSnack(
          'Antrean ${card.queueNumber} (${card.patientName}) ditandai tidak hadir (No-Show).',
        );
      }
    } catch (e) {
      if (!mounted) return;
      final String msg = e is QueueFailure
          ? e.message
          : e.toString().replaceFirst('Exception: ', '');
      _showSnack('Gagal memproses aksi antrean: $msg', isError: true);
      setState(() {
        _gesture.resetPositions();
      });
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _handleSwipeLeftReschedule() {
    if (_cards.isEmpty) return;
    final AmanahQueueCardData targetCard = _cards.first;
    _handleRescheduleAction(targetCard);
  }

  Future<void> _handleCallPatientAction() async {
    if (_cards.isEmpty) return;
    final AmanahQueueCardData current = _cards.first;
    setState(() => _isActionLoading = true);
    try {
      await _queueStore.callPatient(current.id);
      if (!mounted) return;
      _showSnack('Nomor antrean ${current.queueNumber} (${current.patientName}) dipanggil.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal memanggil pasien: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    if (isError) {
      AmanahBottomBanner.error(context, message: msg);
    } else {
      AmanahBottomBanner.success(context, message: msg);
    }
  }

  Future<void> _handleActivate() async {
    if (_cards.isEmpty || _animator.activationStage != 'idle') return;
    final AmanahQueueCardData chosen = _cards.first;
    _dotsController?.repeat();

    try {
      await _animator.triggerPlunge(
        context: context,
        card: chosen,
        onCallBackend: () async {
          await _queueStore.startService(chosen.id);
        },
      );
    } catch (e) {
      final String msg = e is QueueFailure
          ? e.message
          : e.toString().replaceFirst('Exception: ', '');
      _showSnack(msg, isError: true);
    } finally {
      _dotsController?.stop();
    }
  }

  Future<void> _handleCompleteAction(AmanahQueueCardData card) async {
    setState(() => _isActionLoading = true);
    try {
      await _queueStore.completeService(card.id);
      if (!mounted) return;
      await _animator.closeOverlay(
        context: context,
        onDismissComplete: () {
          setState(() {
            _collectedCards.removeWhere((c) => c.id == card.id);
            _collectedCards.insert(0, card);
            _cards.removeWhere((c) => c.id == card.id);
            _gesture.resetPositions();
          });
        },
      );
    } catch (e) {
      _showSnack('Gagal menyelesaikan konsultasi: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _handleRescheduleAction(AmanahQueueCardData card) {
    _animator.closeOverlay(context: context, onDismissComplete: _gesture.resetPositions);
    AmanahRescheduleModal.show(
      context,
      appointmentId: card.id,
      patientName: card.patientName,
      queueNumber: card.queueNumber,
      avatarUrl: card.avatarUrl,
      onConfirm:
          ({
            required String targetDate,
            required String session,
            String? targetSessionId,
            String? reason,
          }) async {
            try {
              await _queueStore.rescheduleAppointment(
                card.id,
                targetDate: targetDate,
                session: session,
                targetSessionId: targetSessionId,
                reason: reason,
              );
              if (!mounted) return;
              setState(() {
                _cards.removeWhere((c) => c.id == card.id);
                _gesture.resetPositions();
              });
              _showSnack(
                'Janji temu ${card.queueNumber} (${card.patientName}) dipindahkan ke $targetDate.',
              );
            } catch (err) {
              _showSnack('Gagal menjadwalkan ulang: $err', isError: true);
              rethrow;
            }
          },
    );
  }

  void _openGuide() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AmanahQueueGuideDrawer(),
    );
  }

  Future<void> _openHistory() async {
    final List<AmanahQueueCardData> allHistory = List.from(_collectedCards);
    final processed = await _queueStore.loadDoctorProcessedAppointments();
    final existingIds = allHistory.map((c) => c.id).toSet();
    for (final p in processed) {
      if (!existingIds.contains(p.id)) allHistory.add(p.toUiCard());
    }

    final String? sessionId = _queueStore.activeSession?.sessionId;
    if (allHistory.isEmpty && sessionId != null) {
      final completed = await _queueStore.loadCompletedPatients(sessionId);
      for (final p in completed) {
        if (!existingIds.contains(p.id)) allHistory.add(p.toUiCard());
      }
    }

    if (!mounted) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            AmanahQueueHistoryScreen(collectedCards: allHistory, onRedraw: () => setState(() {})),
      ),
    );
  }

  void _openPatientIntake(AmanahQueueCardData card) {
    AmanahPatientIntakeDrawer.show(
      context,
      appointmentId: card.effectiveAppointmentId,
      patientName: card.patientName,
      queueNumber: card.queueNumber,
      mrn: card.patientRm,
      age: '${card.age} Thn',
      complaint: card.complaint,
    );
  }

  void _openSessionSelector() {
    AmanahQueueSessionSelector.show(
      context,
      sessions: _queueStore.sessions,
      activeSession: _queueStore.activeSession,
      onSelectSession: _queueStore.selectSession,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          backgroundColor: isDark ? AmanahColorTokens.canvasDark : AmanahColorTokens.canvasLight,
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.2),
                      radius: 0.95,
                      colors: isDark
                          ? const <Color>[
                              AmanahColorTokens.surfaceSecondaryDark,
                              AmanahColorTokens.surfaceDark,
                              AmanahColorTokens.canvasDark,
                            ]
                          : const <Color>[
                              AmanahColorTokens.brandMuted,
                              AmanahColorTokens.brandSurface,
                              AmanahColorTokens.canvasLight,
                            ],
                      stops: const <double>[0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
              AmanahQueueDockBody(
                cards: _cards,
                horizontalDrag: _gesture.horizontalDrag,
                verticalDrag: _gesture.verticalDrag,
                dragMode: _gesture.dragMode,
                isCancelling: _gesture.isCancelling,
                cancelProgress: _gesture.cancelProgress,
                isRotating: _gesture.isRotating,
                rotateProgress: _gesture.rotateProgress,
                activationStage: _animator.activationStage,
                ejectionStage: _animator.ejectionStage,
                showSuccess: _animator.showSuccess,
                dotCount: _dotCount,
                entranceValue: _entranceController.value,
                historyCount: _collectedCards.length,
                sessionLabel: _queueStore.activeSession != null
                    ? '${_queueStore.activeSession!.sessionLabel} • ${_queueStore.activeSession!.roomName}'
                    : null,
                onSelectSession: _openSessionSelector,
                onBack: () => Navigator.of(context).pop(),
                onOpenGuide: _openGuide,
                onOpenHistory: _openHistory,
                onCardSelect: _bringCardToFront,
                onCardTap: _openPatientIntake,
                onResetQueue: _queueStore.loadTodaySessionsAndQueue,
                onCallPatient: _cards.isNotEmpty ? _handleCallPatientAction : null,
                onPanDown: (details) =>
                    _gesture.onPanDown(details, isIdle: _animator.activationStage == 'idle'),
                onPanCancel: () =>
                    _gesture.onPanCancel(isIdle: _animator.activationStage == 'idle'),
                onPanUpdate: (details) =>
                    _gesture.onPanUpdate(details, isIdle: _animator.activationStage == 'idle'),
                onPanEnd: (details) =>
                    _gesture.onPanEnd(details, isIdle: _animator.activationStage == 'idle'),
              ),
              if (_animator.showSuccess && _animator.selectedActiveCard != null)
                ListenableBuilder(
                  listenable: _queueStore,
                  builder: (context, _) {
                    final chosen = _animator.selectedActiveCard!;
                    return AmanahQueueActiveSessionSheet(
                      card: chosen,
                      isGenieSettled: _animator.isGenieSettled,
                      isGenieRunning: _animator.isGenieRunning,
                      status: DoctorQueueStatus.inConsultation,
                      isLoading: _isActionLoading,
                      onClose: () => _animator.closeOverlay(
                        context: context,
                        onDismissComplete: _gesture.resetPositions,
                      ),
                      onComplete: () => _handleCompleteAction(chosen),
                    );
                  },
                ),
              if (_animator.isGenieRunning && _animator.genieSnapshot != null)
                AmanahQueueGenieOverlay(
                  snapshot: _animator.genieSnapshot!,
                  progress: _animator.genieController?.value ?? 0.0,
                  direction: _animator.genieDirection,
                  screenSize: screenSize,
                ),
            ],
          ),
        );
      },
    );
  }
}
