import 'dart:async' as async;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_dock_hero_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_genie_layer.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_guide_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_header_bar.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_interaction_stage.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/amanah_queue_history_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Master 3D Queue Dock Screen (Pilih Antrean Pasien)
class AmanahQueueDockScreen extends StatefulWidget {
  const AmanahQueueDockScreen({
    super.key,
    this.cards = const <AmanahQueueCardData>[],
  });

  final List<AmanahQueueCardData> cards;

  static Route<void> route({
    List<AmanahQueueCardData> cards = const <AmanahQueueCardData>[],
  }) {
    return PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => AmanahQueueDockScreen(cards: cards),
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
  late List<AmanahQueueCardData> _cards;
  final List<AmanahQueueCardData> _collectedCards = <AmanahQueueCardData>[];

  int _currentIndex = 0;
  double _horizontalDrag = 0.0;
  double _verticalDrag = 0.0;
  bool _isLongPressing = false;
  double _spinOffset = 0.0;

  String _activationStage = 'idle';
  String _ejectionStage = 'idle';
  AmanahQueueCardData? _selectedActiveCard;

  final List<async.Timer> _ejectionTimers = <async.Timer>[];

  int _dotCount = 0;
  AnimationController? _dotsController;
  AnimationController? _rouletteController;
  AnimationController? _decelController;
  late final AnimationController _entranceController;
  double _rouletteVelocity = 0.0;
  int _lastHapticTimeMs = 0;

  @override
  void initState() {
    super.initState();
    _cards = List<AmanahQueueCardData>.from(widget.cards);
    if (_cards.isNotEmpty && _currentIndex >= _cards.length) {
      _currentIndex = 0;
    }
    _initDotsTimer();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  void _clearEjectionTimers() {
    for (final async.Timer t in _ejectionTimers) {
      t.cancel();
    }
    _ejectionTimers.clear();
  }

  void _initDotsTimer() {
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 960),
    )..addListener(() {
        if (_activationStage == 'activating') {
          final int next = ((_dotsController!.value * 3).floor() % 3) + 1;
          if (next != _dotCount) {
            setState(() => _dotCount = next);
          }
        }
      });
  }

  void _disposeRouletteController() {
    if (_rouletteController != null) {
      _rouletteController!.stop();
      _rouletteController!.dispose();
      _rouletteController = null;
    }
  }

  void _disposeDecelController() {
    if (_decelController != null) {
      _decelController!.stop();
      _decelController!.dispose();
      _decelController = null;
    }
  }

  @override
  void dispose() {
    _clearEjectionTimers();
    _entranceController.dispose();
    _dotsController?.dispose();
    _dotsController = null;
    _disposeRouletteController();
    _disposeDecelController();
    super.dispose();
  }

  void _onIndexChange(int newIndex) {
    if (_isLongPressing || _activationStage != 'idle' || _cards.isEmpty) {
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = (newIndex % _cards.length + _cards.length) % _cards.length;
      _horizontalDrag = 0;
      _verticalDrag = 0;
      _spinOffset = 0;
    });
  }

  void _startRouletteSpin() {
    if (_cards.isEmpty || _activationStage != 'idle') {
      return;
    }
    HapticFeedback.heavyImpact();
    _disposeRouletteController();
    _disposeDecelController();
    setState(() {
      _isLongPressing = true;
      _rouletteVelocity = 18.0;
    });
    _rouletteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        final double delta = _rouletteVelocity;
        setState(() {
          _spinOffset += delta;
        });
        final int now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastHapticTimeMs > 45) {
          _lastHapticTimeMs = now;
          HapticFeedback.selectionClick();
        }
      });
    _rouletteController!.repeat();
  }

  void _stopRouletteSpin() {
    if (!_isLongPressing || _cards.isEmpty) {
      return;
    }
    _disposeRouletteController();
    setState(() => _isLongPressing = false);
    _decelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    final Animation<double> decelCurve = CurvedAnimation(
      parent: _decelController!,
      curve: Curves.decelerate,
    );
    final double initialV = _rouletteVelocity;
    _decelController!.addListener(() {
      final double progress = decelCurve.value;
      final double currentV = initialV * (1.0 - progress);
      setState(() {
        _spinOffset += currentV;
      });
    });
    _decelController!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _disposeDecelController();
        final double totalShift = _spinOffset;
        final int steps = (totalShift / 230.0).round();
        setState(() {
          _currentIndex =
              ((_currentIndex - steps) % _cards.length + _cards.length) %
              _cards.length;
          _spinOffset = 0;
          _horizontalDrag = 0;
        });
      }
    });
    _decelController!.forward();
  }

  void _scheduleStep(int ms, VoidCallback fn) {
    _ejectionTimers.add(async.Timer(Duration(milliseconds: ms), () {
      if (mounted) setState(fn);
    }));
  }

  void _handleActivate() {
    if (_cards.isEmpty || _activationStage != 'idle') {
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _activationStage = 'plunging';
      _verticalDrag = 110.0;
      _horizontalDrag = 0;
    });

    _scheduleStep(140, () {
      _activationStage = 'activating';
      _verticalDrag = 125.0;
    });
    _scheduleStep(620, () {
      HapticFeedback.mediumImpact();
      _ejectionStage = 'dock_appear';
    });
    _scheduleStep(950, () => _ejectionStage = 'rail_converge');
    _scheduleStep(1280, () {
      HapticFeedback.mediumImpact();
      _ejectionStage = 'atm_peek';
    });
    _scheduleStep(1540, () {
      HapticFeedback.heavyImpact();
      _ejectionStage = 'full_eject';
      _activationStage = 'idle';
    });
    _scheduleStep(1720, () {
      _selectedActiveCard = _cards[_currentIndex];
    });
  }

  void _onPanDown() {
    if (_decelController != null && _decelController!.isAnimating) {
      _disposeDecelController();
      setState(() => _spinOffset = 0);
    }
  }

  void _onPanCancel() {
    if (!_isLongPressing && _activationStage == 'idle') {
      setState(() {
        _horizontalDrag = 0;
        _verticalDrag = 0;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isLongPressing || _activationStage != 'idle') return;
    final double dx = details.delta.dx;
    final double dy = details.delta.dy;
    if (dy > 0 || _verticalDrag > 0) {
      setState(() {
        _verticalDrag = (_verticalDrag + dy).clamp(0.0, 110.0);
      });
    } else {
      setState(() => _horizontalDrag += dx);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isLongPressing || _activationStage != 'idle') return;
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
  }

  void _handleCloseOverlay() {
    setState(() {
      _selectedActiveCard = null;
      _activationStage = 'idle';
      _ejectionStage = 'idle';
      _verticalDrag = 0;
      _horizontalDrag = 0;
      _spinOffset = 0;
    });
    _clearEjectionTimers();
  }

  void _handleCollectCard(AmanahQueueCardData card) {
    setState(() {
      _collectedCards.removeWhere((AmanahQueueCardData c) => c.id == card.id);
      _collectedCards.insert(0, card);
      _selectedActiveCard = null;
      _activationStage = 'idle';
      _ejectionStage = 'idle';
      _verticalDrag = 0;
      _horizontalDrag = 0;
      _spinOffset = 0;
      if (_cards.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % _cards.length;
      }
    });
    _clearEjectionTimers();

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AmanahQueueHistoryScreen(
          collectedCards: _collectedCards,
          onRedraw: () {},
        ),
      ),
    );
  }

  void _openGuide() {
    AmanahQueueGuideDrawer.show(context);
  }

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AmanahQueueHistoryScreen(
          collectedCards: _collectedCards,
          onRedraw: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double dragProgress = (_verticalDrag / 80.0).clamp(0.0, 1.0);
    final bool isNearSlot =
        (_verticalDrag >= 20.0 || dragProgress >= 0.25) &&
        _activationStage == 'idle';
    final bool isMorphingActive = _activationStage == 'activating';
    final bool showSuccess = _selectedActiveCard != null;

    String headlineText = 'Pilih antrean\npasien';
    if (isMorphingActive) {
      headlineText = 'Memproses\nantrean';
    } else if (isNearSlot) {
      headlineText = 'Lepaskan untuk\nproses antrean';
    }

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (BuildContext context, Widget? child) {
        final double entranceT = _entranceController.value;
        final double headerProgress = Curves.easeOutCubic.transform(
          (entranceT / 0.40).clamp(0.0, 1.0),
        );
        final double textProgress = Curves.easeOutCubic.transform(
          ((entranceT - 0.15) / 0.45).clamp(0.0, 1.0),
        );
        final double railProgress = Curves.easeOutCubic.transform(
          ((entranceT - 0.25) / 0.50).clamp(0.0, 1.0),
        );
        final double dockProgress = Curves.easeOutCubic.transform(
          ((entranceT - 0.45) / 0.40).clamp(0.0, 1.0),
        );

        final bool isDark = Theme.of(context).brightness == Brightness.dark;

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

              SafeArea(
                child: Column(
                  children: <Widget>[
                    Transform.translate(
                      offset: Offset(0, -20.0 * (1.0 - headerProgress)),
                      child: Opacity(
                        opacity: headerProgress,
                        child: RepaintBoundary(
                          child: AmanahQueueHeaderBar(
                            onBack: () => Navigator.of(context).pop(),
                            onOpenGuide: _openGuide,
                            onOpenHistory: _openHistory,
                            historyCount: _collectedCards.length,
                            showSuccess: showSuccess,
                          ),
                        ),
                      ),
                    ),

                    if (_cards.isNotEmpty) ...<Widget>[
                      AmanahQueueDockHeroHeader(
                        textProgress: textProgress,
                        showSuccess: showSuccess,
                        isMorphingActive: isMorphingActive,
                        isNearSlot: isNearSlot,
                        dotCount: _dotCount,
                        headlineText: headlineText,
                      ),

                      Expanded(
                        child: AmanahQueueInteractionStage(
                          cards: _cards,
                          currentIndex: _currentIndex,
                          horizontalDrag: _horizontalDrag,
                          verticalDrag: _verticalDrag,
                          spinOffset: _spinOffset,
                          isLongPressing: _isLongPressing,
                          activationStage: _activationStage,
                          ejectionStage: _ejectionStage,
                          showSuccess: showSuccess,
                          railProgress: railProgress,
                          dockProgress: dockProgress,
                          dragProgress: dragProgress,
                          isMorphingActive: isMorphingActive,
                          onLongPressStart: _startRouletteSpin,
                          onLongPressEnd: _stopRouletteSpin,
                          onPanDown: _onPanDown,
                          onPanCancel: _onPanCancel,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          onCardSelect: _onIndexChange,
                        ),
                      ),
                    ] else ...<Widget>[
                      Expanded(
                        child: Center(
                          child: AmanahEmptyState.box(
                            title: 'Belum Ada Antrean Pasien',
                            message:
                                'Saat ini belum ada pasien dalam antrean periksa klinik.',
                            actionText: 'Kembali',
                            actionLeadingIcon: Icons.arrow_back_rounded,
                            onAction: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              AmanahQueueGenieLayer(
                activeCard: _selectedActiveCard,
                onClose: _handleCloseOverlay,
                onCollect: _handleCollectCard,
              ),
            ],
          ),
        );
      },
    );
  }
}
