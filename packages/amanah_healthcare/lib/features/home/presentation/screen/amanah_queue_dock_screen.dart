import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_copywriting.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_status.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_genie_effect.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/queue/data/datasources/doctor_queue_remote_data_source.dart';
import 'package:amanah_healthcare/features/queue/data/repositories/doctor_queue_repository_impl.dart';
import 'package:amanah_healthcare/features/queue/presentation/controllers/doctor_queue_controller.dart';
import 'package:amanah_healthcare/features/queue/presentation/screens/amanah_queue_history_screen.dart';
import 'package:amanah_healthcare/features/queue/presentation/widgets/amanah_queue_active_session_sheet.dart';
import 'package:amanah_healthcare/features/queue/presentation/widgets/amanah_queue_dock_animator.dart';
import 'package:amanah_healthcare/features/queue/presentation/widgets/amanah_queue_dock_body.dart';
import 'package:amanah_healthcare/features/queue/presentation/widgets/amanah_queue_guide_drawer.dart';
import 'package:amanah_healthcare/features/queue/presentation/widgets/amanah_queue_roulette_controller.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class AmanahQueueDockScreen extends StatefulWidget {
  const AmanahQueueDockScreen({
    this.cards,
    this.controller,
    this.poliklinikId,
    this.session,
    super.key,
  });

  final List<AmanahQueueCardData>? cards;
  final DoctorQueueController? controller;
  final String? poliklinikId;
  final String? session;

  static Route<void> route({
    List<AmanahQueueCardData>? cards,
    DoctorQueueController? controller,
    String? poliklinikId,
    String? session,
  }) {
    return PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => AmanahQueueDockScreen(
        cards: cards,
        controller: controller,
        poliklinikId: poliklinikId,
        session: session,
      ),
      transitionsBuilder: (
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
  late final DoctorQueueController _controller;
  late final AmanahQueueRouletteController _roulette;
  late final AmanahQueueDockAnimator _animator;
  late final AnimationController _entranceController;
  AnimationController? _dotsController;

  late List<AmanahQueueCardData> _cards;
  final List<AmanahQueueCardData> _collectedCards = <AmanahQueueCardData>[];

  int _currentIndex = 0;
  double _horizontalDrag = 0.0;
  double _verticalDrag = 0.0;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        DoctorQueueController(
          repository: DoctorQueueRepositoryImpl(
            remoteDataSource: DoctorQueueRemoteDataSourceImpl(dio: Dio()),
            tokenStorage: const AmanahAuthTokenStorage(),
          ),
        );
    _cards = widget.cards != null
        ? List<AmanahQueueCardData>.from(widget.cards!)
        : _loadCardsFromSchedules();
    _currentIndex = _cards.isNotEmpty ? 0 : 0;

    _roulette = AmanahQueueRouletteController(
      vsync: this,
      onUpdate: () => setState(() {}),
      onSnapComplete: (int idx) => setState(() => _currentIndex = idx),
    );

    _animator = AmanahQueueDockAnimator(
      vsync: this,
      onStateChange: () => setState(() {}),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _initDotsTimer();
    _loadQueueFromBackend();
  }

  void _loadQueueFromBackend() {
    if (widget.poliklinikId != null) {
      final String todayStr =
          AmanahScheduleStore.baseToday.toIso8601String().substring(0, 10);
      _controller.loadQueue(
        poliklinikId: widget.poliklinikId!,
        date: todayStr,
        session: widget.session,
      );
    }
  }

  List<AmanahQueueCardData> _loadCardsFromSchedules() {
    final List<DoctorSchedule> todaySchedules = AmanahScheduleStore.instance
        .getSchedulesForDate(AmanahScheduleStore.baseToday);
    final List<AmanahQueueCardData> result = <AmanahQueueCardData>[];
    for (final DoctorSchedule s in todaySchedules) {
      for (final BookedPatient p in s.bookedPatients) {
        if (p.isCancelled) {
          continue;
        }
        result.add(
          AmanahQueueCardData(
            id: p.id.isNotEmpty ? p.id : 'queue-${result.length + 1}',
            queueNumber: p.queueNumber,
            patientName: p.patientName,
            complaint: p.patientComplaint,
            poly: s.poli,
            doctorName: p.sessionTitle ?? s.title,
            doctorImage: 'assets/amanah/id_card/images/woman-doctor-4.png',
            priority: p.badge,
            timeSlot: p.timeSlot,
            age: int.tryParse(p.patientAge) ?? 0,
            gender: p.gender ?? 'L',
            room: p.room ?? s.room,
            status: p.status ?? DoctorQueueCopywriting.statusWaiting,
            guardian: p.patientGuardian,
          ),
        );
      }
    }
    return result;
  }

  void _initDotsTimer() {
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 960),
    )..addListener(() {
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
    _entranceController.dispose();
    _dotsController?.dispose();
    _dotsController = null;
    _roulette.dispose();
    _animator.dispose();
    super.dispose();
  }

  void _onIndexChange(int newIndex) {
    if (_cards.isEmpty) {
      return;
    }
    _roulette.resetDrag();
    setState(() {
      _currentIndex =
          ((newIndex % _cards.length) + _cards.length) % _cards.length;
      _horizontalDrag = 0.0;
      _verticalDrag = 0.0;
    });
  }

  Future<void> _handleActivate() async {
    if (_cards.isEmpty) {
      return;
    }
    final AmanahQueueCardData chosen = _cards[_currentIndex];
    _dotsController?.repeat();

    await _animator.triggerPlunge(
      context: context,
      card: chosen,
      onCallBackend: () => _controller.callPatient(chosen.id),
    );

    _dotsController?.stop();
  }

  Future<void> _handleCompleteAction(AmanahQueueCardData card) async {
    await _controller.completeConsultation(
      card.id,
      poliklinikId: widget.poliklinikId,
      session: widget.session,
    );
    await _dismissCard(card);
  }

  Future<void> _handleSkipAction(AmanahQueueCardData card) async {
    if (widget.poliklinikId != null) {
      await _controller.noShowPatient(
        card.id,
        poliklinikId: widget.poliklinikId!,
        date: AmanahScheduleStore.baseToday.toIso8601String().substring(0, 10),
        session: widget.session,
      );
    }
    await _animator.closeOverlay(
      context: context,
      onDismissComplete: () {
        setState(() {
          _verticalDrag = 0;
          _horizontalDrag = 0;
        });
      },
    );
  }

  Future<void> _dismissCard(AmanahQueueCardData card) async {
    await _animator.closeOverlay(
      context: context,
      onDismissComplete: () {
        setState(() {
          _collectedCards.removeWhere((c) => c.id == card.id);
          _collectedCards.insert(0, card);
          _cards.removeWhere((c) => c.id == card.id);
          if (_cards.isNotEmpty) {
            _currentIndex = _currentIndex.clamp(0, _cards.length - 1);
          } else {
            _currentIndex = 0;
          }
          _verticalDrag = 0;
          _horizontalDrag = 0;
        });
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

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AmanahQueueHistoryScreen(
          collectedCards: _collectedCards,
          onRedraw: () => setState(() {}),
        ),
      ),
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
          backgroundColor: isDark
              ? AmanahColorTokens.canvasDark
              : AmanahColorTokens.canvasLight,
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
                currentIndex: _currentIndex,
                horizontalDrag: _horizontalDrag,
                verticalDrag: _verticalDrag,
                spinOffset: _roulette.spinOffset,
                isLongPressing: _roulette.isLongPressing,
                activationStage: _animator.activationStage,
                ejectionStage: _animator.ejectionStage,
                showSuccess: _animator.showSuccess,
                dotCount: _dotCount,
                entranceValue: _entranceController.value,
                historyCount: _collectedCards.length,
                onBack: () => Navigator.of(context).pop(),
                onOpenGuide: _openGuide,
                onOpenHistory: _openHistory,
                onCardSelect: _onIndexChange,
                onLongPressStart: () => _roulette.startSpin(
                  cardCount: _cards.length,
                  isIdle: _animator.activationStage == 'idle',
                ),
                onLongPressEnd: () => _roulette.stopSpin(
                  currentIndex: _currentIndex,
                  cardCount: _cards.length,
                ),
                onPanDown: () => _roulette.resetDrag(),
                onPanCancel: () {
                  if (!_roulette.isLongPressing &&
                      _animator.activationStage == 'idle') {
                    setState(() {
                      _horizontalDrag = 0;
                      _verticalDrag = 0;
                    });
                  }
                },
                onPanUpdate: (DragUpdateDetails details) {
                  if (_roulette.isLongPressing ||
                      _animator.activationStage != 'idle') {
                    return;
                  }
                  final double dx = details.delta.dx;
                  final double dy = details.delta.dy;
                  if (dy > 0 || _verticalDrag > 0) {
                    setState(() {
                      _verticalDrag = (_verticalDrag + dy).clamp(0.0, 110.0);
                    });
                  } else {
                    setState(() {
                      _horizontalDrag += dx;
                    });
                  }
                },
                onPanEnd: (DragEndDetails details) {
                  if (_roulette.isLongPressing ||
                      _animator.activationStage != 'idle') {
                    return;
                  }
                  if (_verticalDrag >= 55) {
                    _handleActivate();
                  } else {
                    setState(() => _verticalDrag = 0);
                    final double vx = details.velocity.pixelsPerSecond.dx;
                    if (_horizontalDrag < -45 || vx < -400) {
                      _onIndexChange(_currentIndex + 1);
                    } else if (_horizontalDrag > 45 || vx > 400) {
                      _onIndexChange(_currentIndex - 1);
                    } else {
                      setState(() => _horizontalDrag = 0);
                    }
                  }
                },
              ),
              if (_animator.showSuccess &&
                  _animator.selectedActiveCard != null)
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    final activeApp = _controller.activeAppointment;
                    return AmanahQueueActiveSessionSheet(
                      card: _animator.selectedActiveCard!,
                      isGenieSettled: _animator.isGenieSettled,
                      isGenieRunning: _animator.isGenieRunning,
                      callCount: activeApp?.callCount ?? 1,
                      status: activeApp?.status ?? DoctorQueueStatus.called,
                      isLoading: _controller.isActionLoading,
                      onClose: () => _animator.closeOverlay(
                        context: context,
                        onDismissComplete: () {
                          setState(() {
                            _verticalDrag = 0;
                            _horizontalDrag = 0;
                          });
                        },
                      ),
                      onCallAgain: () => _controller
                          .callPatient(_animator.selectedActiveCard!.id),
                      onPatientEntered: () => _controller
                          .patientRespond(_animator.selectedActiveCard!.id),
                      onSkipNoShow: () =>
                          _handleSkipAction(_animator.selectedActiveCard!),
                      onComplete: () =>
                          _handleCompleteAction(_animator.selectedActiveCard!),
                    );
                  },
                ),
              if (_animator.isGenieRunning && _animator.genieSnapshot != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: AmanahGenieCanvasPainter(
                        snapshot: _animator.genieSnapshot!,
                        progress: _animator.genieController?.value ?? 0.0,
                        direction: _animator.genieDirection,
                        dockPoint: Offset(
                          screenSize.width / 2,
                          screenSize.height - 65,
                        ),
                        cardRect: Rect.fromCenter(
                          center: Offset(
                            screenSize.width / 2,
                            (screenSize.height - 145) * 0.44 + 48,
                          ),
                          width: math.min(screenSize.width - 64, 320.0),
                          height:
                              math.min(screenSize.width - 64, 320.0) / 0.718,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
