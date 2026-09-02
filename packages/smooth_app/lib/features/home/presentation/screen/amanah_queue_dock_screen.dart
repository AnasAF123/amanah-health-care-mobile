import 'dart:async' as async;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/features/home/domain/amanah_queue_data.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_blurry_morph_text.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_confetti_canvas.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_dock_hollow_glow.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_genie_effect.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_paramedic_toolbox.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_racing_chevrons.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';
import 'package:smooth_app/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';

/// Master 3D Queue Dock Screen (Pilih Antrean Pasien)
/// Faithful 1:1 native Flutter replication of QueueDockScreen.tsx from web.
class AmanahQueueDockScreen extends StatefulWidget {
  const AmanahQueueDockScreen({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => const AmanahQueueDockScreen(),
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
  final List<AmanahQueueCardData> _cards = defaultAmanahQueueCards;
  final List<AmanahQueueCardData> _collectedCards = <AmanahQueueCardData>[];

  int _currentIndex = 1;
  double _horizontalDrag = 0.0;
  double _verticalDrag = 0.0;
  bool _isLongPressing = false;
  double _spinOffset = 0.0;

  // Activation & Ejection stages matching web: 'idle', 'plunging', 'activating', 'dock_appear', 'rail_converge', 'atm_peek', 'full_eject'
  String _activationStage = 'idle';
  String _ejectionStage = 'idle';
  bool _showSuccess = false;
  bool _isGenieSettled = false;
  AmanahQueueCardData? _selectedActiveCard;

  // Genie Animation Engine
  AnimationController? _genieController;
  ui.Image? _genieSnapshot;
  AmanahGenieDirection _genieDirection = AmanahGenieDirection.open;
  bool _isGenieRunning = false;

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
    _dotsController =
        AnimationController(
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

  void _disposeGenieController() {
    if (_genieController != null) {
      _genieController!.stop();
      _genieController!.dispose();
      _genieController = null;
    }
  }

  @override
  void dispose() {
    _clearEjectionTimers();
    _entranceController.dispose();
    _dotsController?.dispose();
    _dotsController = null;
    _genieSnapshot?.dispose();
    _genieSnapshot = null;
    _disposeRouletteController();
    _disposeDecelController();
    _disposeGenieController();
    super.dispose();
  }

  void _onIndexChange(int newIndex) {
    if (_cards.isEmpty) {
      return;
    }
    _disposeRouletteController();
    _disposeDecelController();
    setState(() {
      _currentIndex =
          ((newIndex % _cards.length) + _cards.length) % _cards.length;
      _horizontalDrag = 0;
      _verticalDrag = 0;
      _spinOffset = 0;
    });
  }

  void _startRouletteSpin() {
    if (_activationStage != 'idle') {
      return;
    }
    _disposeDecelController();
    _disposeRouletteController();

    setState(() {
      _isLongPressing = true;
      _horizontalDrag = 0;
      _verticalDrag = 0;
    });
    _lastHapticTimeMs = DateTime.now().millisecondsSinceEpoch;
    HapticFeedback.heavyImpact();

    _rouletteVelocity = 18.0 * 230.0; // ~18 cards per second

    _rouletteController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            if (!_isLongPressing || !mounted) {
              return;
            }
            setState(() {
              _spinOffset += _rouletteVelocity * 0.016;
            });
            final int now = DateTime.now().millisecondsSinceEpoch;
            if (now - _lastHapticTimeMs >= 90) {
              _lastHapticTimeMs = now;
              HapticFeedback.selectionClick();
            }
          });
    _rouletteController!.repeat();
  }

  void _stopRouletteSpin() {
    if (!_isLongPressing) {
      return;
    }
    _disposeRouletteController();

    setState(() {
      _isLongPressing = false;
    });

    // Smooth exponential deceleration to snap firmly on selected card
    final double startOffset = _spinOffset;
    final int shiftCards = (startOffset / 230.0).round();
    final double targetOffset = shiftCards * 230.0;
    final int targetIndex =
        (((_currentIndex + shiftCards) % _cards.length) + _cards.length) %
        _cards.length;

    _disposeDecelController();

    _decelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    final Animation<double> decelAnimation =
        Tween<double>(begin: startOffset, end: targetOffset).animate(
          CurvedAnimation(
            parent: _decelController!,
            curve: Curves.easeOutCubic,
          ),
        );

    decelAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _spinOffset = decelAnimation.value;
        });
      }
    });

    decelAnimation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _currentIndex = targetIndex;
            _spinOffset = 0;
          });
          HapticFeedback.mediumImpact();
        }
        _disposeDecelController();
      }
    });

    _decelController!.forward();
  }

  Future<void> _handleActivate() async {
    if (_activationStage != 'idle' || _isGenieRunning) {
      return;
    }
    _disposeRouletteController();
    _disposeDecelController();
    _disposeGenieController();

    final AmanahQueueCardData chosen = _cards[_currentIndex];
    setState(() {
      _selectedActiveCard = chosen;
      _activationStage = 'plunging';
      _ejectionStage = 'atm_plunge';
    });
    HapticFeedback.heavyImpact();

    // 1. Plunge into slot (t = 450ms)
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) {
      return;
    }

    setState(() {
      _activationStage = 'activating';
      _ejectionStage = 'idle';
    });
    _dotsController?.repeat();

    // 2. Complete Activation & Trigger Genie Open Emergence (t = 1800ms)
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) {
      return;
    }

    _dotsController?.stop();

    final Size screenSize = MediaQuery.sizeOf(context);
    final double cardW = math.min(screenSize.width - 64, 320.0);
    final double cardH = cardW / 0.718;

    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: chosen,
      size: Size(cardW, cardH),
    );

    if (!mounted) {
      coverSnapshot.dispose();
      return;
    }

    _genieSnapshot?.dispose();
    _genieSnapshot = coverSnapshot;
    _genieDirection = AmanahGenieDirection.open;
    _isGenieRunning = true;
    _showSuccess = true;
    _isGenieSettled = false;
    _activationStage = 'idle';

    _genieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _genieController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _genieController!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isGenieRunning = false;
          });
          // Deliberate event-based settle pause (300ms) so backface card is seen landed
          // stably in place before starting the smooth 3D flip rotation
          async.Timer(const Duration(milliseconds: 300), () {
            if (mounted && _showSuccess) {
              setState(() {
                _isGenieSettled = true;
              });
            }
          });
        }
        _disposeGenieController();
      }
    });

    _genieController!.forward();
  }

  Future<void> _handleCloseOverlay() async {
    if (_isGenieRunning) {
      return;
    }
    _disposeGenieController();

    setState(() {
      _isGenieSettled = false;
    });

    final AmanahQueueCardData chosen =
        _selectedActiveCard ?? _cards[_currentIndex];
    final Size screenSize = MediaQuery.sizeOf(context);
    final double cardW = math.min(screenSize.width - 64, 320.0);
    final double cardH = cardW / 0.718;

    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: chosen,
      size: Size(cardW, cardH),
    );

    if (!mounted) {
      coverSnapshot.dispose();
      return;
    }

    _genieSnapshot?.dispose();
    _genieSnapshot = coverSnapshot;
    _genieDirection = AmanahGenieDirection.minimize;
    _isGenieRunning = true;

    _genieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _genieController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _genieController!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isGenieRunning = false;
            _showSuccess = false;
            _activationStage = 'idle';
            _ejectionStage = 'dock_appear';
            _verticalDrag = 0;
            _horizontalDrag = 0;
          });
          _startEjectionChoreography();
        }
        _disposeGenieController();
      }
    });

    _genieController!.forward();
  }

  void _startEjectionChoreography() {
    _clearEjectionTimers();

    // Step 2: Friends converge to 3D rail (t = 200ms)
    _ejectionTimers.add(
      async.Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _ejectionStage = 'rail_converge');
        }
      }),
    );

    // Step 3: Center card peeks from slot mouth (t = 850ms)
    _ejectionTimers.add(
      async.Timer(const Duration(milliseconds: 850), () {
        if (mounted) {
          setState(() => _ejectionStage = 'atm_peek');
          HapticFeedback.lightImpact();
        }
      }),
    );

    // Step 4: Center card rises into place (t = 1350ms)
    _ejectionTimers.add(
      async.Timer(const Duration(milliseconds: 1350), () {
        if (mounted) {
          setState(() => _ejectionStage = 'full_eject');
        }
      }),
    );

    // Step 5: Lock firmly into rail (t = 2000ms)
    _ejectionTimers.add(
      async.Timer(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _ejectionStage = 'idle';
            _selectedActiveCard = null;
          });
          HapticFeedback.mediumImpact();
        }
      }),
    );
  }

  Future<void> _handleCollectCard(AmanahQueueCardData card) async {
    if (_isGenieRunning) {
      return;
    }
    _disposeGenieController();

    setState(() {
      _isGenieSettled = false;
    });

    final Size screenSize = MediaQuery.sizeOf(context);
    final double cardW = math.min(screenSize.width - 64, 320.0);
    final double cardH = cardW / 0.718;

    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: card,
      size: Size(cardW, cardH),
    );

    if (!mounted) {
      coverSnapshot.dispose();
      return;
    }

    _genieSnapshot?.dispose();
    _genieSnapshot = coverSnapshot;
    _genieDirection = AmanahGenieDirection.minimize;
    _isGenieRunning = true;

    _genieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _genieController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _genieController!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _collectedCards.removeWhere(
              (AmanahQueueCardData c) => c.id == card.id,
            );
            _collectedCards.insert(0, card);
            _showSuccess = false;
            _isGenieRunning = false;
            _isGenieSettled = false;
            _selectedActiveCard = null;
            _activationStage = 'idle';
            _ejectionStage = 'idle';
            _verticalDrag = 0;
            _horizontalDrag = 0;
            _spinOffset = 0;
            _currentIndex = (_currentIndex + 1) % _cards.length;
          });
          _disposeGenieController();
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
      }
    });

    _genieController!.forward();
  }

  void _openGuide() {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (_) => const _AmanahQueueGuideDrawer(),
    );
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
    final Size screenSize = MediaQuery.sizeOf(context);
    final double dragProgress = (_verticalDrag / 80.0).clamp(0.0, 1.0);
    final bool isNearSlot =
        (_verticalDrag >= 20.0 || dragProgress >= 0.25) &&
        _activationStage == 'idle';
    final bool isMorphingActive = _activationStage == 'activating';

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

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FF),
          body: Stack(
            children: <Widget>[
              // Background Gradient matching web
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.2),
                      radius: 0.95,
                      colors: <Color>[
                        Color(0xFFDBEAFE),
                        Color(0xFFEFF6FF),
                        Color(0xFFF4F7FF),
                      ],
                      stops: <double>[0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: <Widget>[
                    // 1. Unified Master Header Bar (Sequential Entrance 1)
                    Transform.translate(
                      offset: Offset(0, -20.0 * (1.0 - headerProgress)),
                      child: Opacity(
                        opacity: headerProgress,
                        child: RepaintBoundary(
                          child: _QueueHeaderBar(
                            onBack: () => Navigator.of(context).pop(),
                            onOpenGuide: _openGuide,
                            onOpenHistory: _openHistory,
                            historyCount: _collectedCards.length,
                            showSuccess: _showSuccess,
                          ),
                        ),
                      ),
                    ),

                    // 2. 3D Paramedic Toolbox & Morphing Headline (Sequential Entrance 2)
                    Transform.translate(
                      offset: Offset(0, -15.0 * (1.0 - textProgress)),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _showSuccess ? 0.0 : textProgress,
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
                                    scale: (isMorphingActive || isNearSlot)
                                        ? 1.1
                                        : 1.0,
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
                                    dotCount: _dotCount,
                                    style: TextStyle(
                                      color: isNearSlot || isMorphingActive
                                          ? const Color(0xFF0A44FF)
                                          : const Color(0xFF0F172A),
                                      fontFamily: 'PlusJakartaSans',
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

                    // 3. 3D Cylindrical Carousel & Deck (Sequential Entrance 3)
                    Expanded(
                      child: Transform.translate(
                        offset: Offset(0, 40.0 * (1.0 - railProgress)),
                        child: Transform.scale(
                          scale: 0.88 + (0.12 * railProgress),
                          child: Opacity(
                            opacity: railProgress,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onLongPressStart: (_) => _startRouletteSpin(),
                              onLongPressEnd: (_) => _stopRouletteSpin(),
                              onPanDown: (_) {
                                if (_decelController != null &&
                                    _decelController!.isAnimating) {
                                  _disposeDecelController();
                                  setState(() {
                                    _spinOffset = 0;
                                  });
                                }
                              },
                              onPanCancel: () {
                                if (!_isLongPressing &&
                                    _activationStage == 'idle') {
                                  setState(() {
                                    _horizontalDrag = 0;
                                    _verticalDrag = 0;
                                  });
                                }
                              },
                              onPanUpdate: (DragUpdateDetails details) {
                                if (_isLongPressing ||
                                    _activationStage != 'idle') {
                                  return;
                                }
                                final double dx = details.delta.dx;
                                final double dy = details.delta.dy;
                                if (dy > 0 || _verticalDrag > 0) {
                                  setState(() {
                                    _verticalDrag = (_verticalDrag + dy).clamp(
                                      0.0,
                                      110.0,
                                    );
                                  });
                                } else {
                                  setState(() {
                                    _horizontalDrag += dx;
                                  });
                                }
                              },
                              onPanEnd: (DragEndDetails details) {
                                if (_isLongPressing ||
                                    _activationStage != 'idle') {
                                  return;
                                }
                                if (_verticalDrag >= 55) {
                                  _handleActivate();
                                } else {
                                  setState(() => _verticalDrag = 0);
                                  final double vx =
                                      details.velocity.pixelsPerSecond.dx;
                                  if (_horizontalDrag < -45 || vx < -400) {
                                    _onIndexChange(_currentIndex + 1);
                                  } else if (_horizontalDrag > 45 || vx > 400) {
                                    _onIndexChange(_currentIndex - 1);
                                  } else {
                                    setState(() => _horizontalDrag = 0);
                                  }
                                }
                              },
                              child: RepaintBoundary(
                                child: _AmanahQueue3DCarousel(
                                  cards: _cards,
                                  currentIndex: _currentIndex,
                                  horizontalDrag: _horizontalDrag,
                                  verticalDrag: _verticalDrag,
                                  spinOffset: _spinOffset,
                                  isActivating: _activationStage != 'idle',
                                  ejectionStage: _ejectionStage,
                                  showSuccess: _showSuccess,
                                  onCardSelect: _onIndexChange,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 4. SVG Notched Bottom Dock Floor with Glowing Cavity (Sequential Entrance 4)
                    Transform.translate(
                      offset: Offset(0, 70.0 * (1.0 - dockProgress)),
                      child: Opacity(
                        opacity: dockProgress,
                        child: RepaintBoundary(
                          child: _AmanahBottomNotchedDock(
                            isActivating: isMorphingActive || _showSuccess,
                            dragProgress: dragProgress,
                            isLongPressing: _isLongPressing,
                            label: 'Tarik antrean ke bawah untuk proses',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Activation & Success Overlay with 3D Flip Hero Card
              if (_showSuccess && _selectedActiveCard != null)
                _AmanahQueueActivationOverlay(
                  card: _selectedActiveCard!,
                  isGenieSettled: _isGenieSettled,
                  isGenieRunning: _isGenieRunning,
                  onClose: _handleCloseOverlay,
                  onRedraw: _handleCloseOverlay,
                  onActionClick: () => _handleCollectCard(_selectedActiveCard!),
                ),

              // 6. Native Genie Effect Canvas Layer (1:1 macOS-style Suction & Emergence)
              if (_isGenieRunning && _genieSnapshot != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: AmanahGenieCanvasPainter(
                        snapshot: _genieSnapshot!,
                        progress: _genieController?.value ?? 0.0,
                        direction: _genieDirection,
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

// --- App Bar Header ---

class _QueueHeaderBar extends StatelessWidget {
  const _QueueHeaderBar({
    required this.onBack,
    required this.onOpenGuide,
    required this.onOpenHistory,
    required this.historyCount,
    required this.showSuccess,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenHistory;
  final int historyCount;
  final bool showSuccess;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: showSuccess ? 0.0 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              color: const Color(0xFF1E293B),
              iconSize: 24,
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF1E293B),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              onSelected: (String val) {
                if (val == 'guide') {
                  onOpenGuide();
                } else if (val == 'history') {
                  onOpenHistory();
                }
              },
              itemBuilder: (_) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'guide',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF0A44FF),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Panduan antrean',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'history',
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.history_rounded,
                        color: Color(0xFF0A44FF),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Riwayat antrean',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (historyCount > 0) ...<Widget>[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            '$historyCount',
                            style: const TextStyle(
                              color: Color(0xFF0A44FF),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3D Carousel Deck with Target Glow Frame & Directional Chevrons ---

class _AmanahQueue3DCarousel extends StatelessWidget {
  const _AmanahQueue3DCarousel({
    required this.cards,
    required this.currentIndex,
    required this.horizontalDrag,
    required this.verticalDrag,
    required this.spinOffset,
    required this.isActivating,
    required this.ejectionStage,
    required this.showSuccess,
    required this.onCardSelect,
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

    // 1. Target Alignment Glow Frame strictly behind cards (Compact to fit card)
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
                color: const Color(0xFF3B82F6).withValues(alpha: 0.75),
                width: 1.8,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 2. High-Performance Aerodynamic Racing Chevrons (Centered beneath target frame)
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

    // 3. Render 3D Cards with U-Railway Geometry
    for (int index = 0; index < cards.length; index++) {
      double distanceFromCenter = (index - currentIndex) + dragUnits;

      // Handle wrapping for infinite carousel illusion
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

      // U-Railway geometry matching web
      final double x = 660.0 * math.sin(angleRad) * (screen.width / 420.0);
      double y = -660.0 * (1.0 - math.cos(angleRad)) * 0.8;
      final double rotateZ = -distanceFromCenter * 13.0 * math.pi / 180.0;
      final double rotateY = distanceFromCenter * 8.0 * math.pi / 180.0;
      final double scale =
          1.0 - math.min(0.06, distanceFromCenter.abs() * 0.035);
      double opacity =
          (1.0 - (distanceFromCenter.abs() - 0.85).clamp(0.0, 1.0) * 0.95)
              .clamp(0.0, 1.0);

      // Pull down gesture on center card
      if (isCenter && verticalDrag > 0) {
        y += verticalDrag;
      }

      // Ejection animations
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
              alignment: const Alignment(0, -0.6), // center 20%
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
                  child: _AmanahQueueCardCover(card: cards[index]),
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

// --- Card Cover (Back Face on 3D Rail with Watermark & Organic Pixel Texture) ---

class _AmanahQueueCardCover extends StatelessWidget {
  const _AmanahQueueCardCover({required this.card, this.width, this.height});

  final AmanahQueueCardData card;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final double cardW = width ?? 212.0;
    final double cardH = height ?? 335.0;
    final double logoSize = cardW * 0.46;

    return RepaintBoundary(
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.white, Color(0xFFF8FAFF), Color(0xFFEDF2FF)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF0A1E50).withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 14),
              spreadRadius: -6,
            ),
          ],
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // 1. Background Texture with Bottom-to-Top Gradient Masking
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[
                        const Color(0xFFDBEAFE).withValues(alpha: 0.50),
                        const Color(0xFFEFF6FF).withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Organic Cybernetic Pixel Texture (Faded bottom-to-top, 1:1 with Web)
              const AmanahPixelTexture(
                isDark: false,
                opacity: 0.38,
                maskType: AmanahPixelMaskType.fadeTop,
              ),

              // 3. Center Group: Official Vector Watermark (wm.svg) + Queue Number
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Vector Watermark with Theme Gradient Fill (wm.svg 1:1, crisp and clean)
                  AmanahWatermarkLogo(
                    size: logoSize,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Color(0xFF0A44FF),
                        Color(0xFF1A55FF),
                        Color(0xFF3B82F6),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Queue Number (#01, #04, etc.)
                  Text(
                    card.queueNumber,
                    style: TextStyle(
                      color: const Color(0xFF0A44FF),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: cardW > 250 ? 44 : 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      height: 1.0,
                    ),
                  ),
                ],
              ),

              // 4. Glossy Sheen Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                      stops: const <double>[0.0, 0.45],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Bottom Notched Floor Dock with SVG Cavity ---

class _AmanahBottomNotchedDock extends StatelessWidget {
  const _AmanahBottomNotchedDock({
    required this.isActivating,
    required this.dragProgress,
    required this.isLongPressing,
    required this.label,
  });

  final bool isActivating;
  final double dragProgress;
  final bool isLongPressing;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, isActivating ? 180.0 : 0.0, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isActivating ? 0.0 : 1.0,
        child: SizedBox(
          height: 145,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              // 1. Master 6-Layer Volumetric Optical Glow & Notched Dock Painter
              Positioned.fill(
                child: CustomPaint(
                  painter: AmanahDockHollowGlowPainter(
                    dragProgress: dragProgress,
                    isLongPressing: isLongPressing,
                    isActivating: isActivating,
                    isDark: false,
                  ),
                ),
              ),

              // 2. Instruction Text Prompt placed at top: 66px below notch opening (1:1 Web Placement)
              Positioned(
                top: 66,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isActivating ? 0.0 : 1.0,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dragProgress > 0.05
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF334155),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: dragProgress > 0.05
                          ? FontWeight.w800
                          : FontWeight.w600,
                      letterSpacing: 0.2,
                      shadows: dragProgress > 0.05
                          ? const <Shadow>[
                              Shadow(color: Color(0xFF3B82F6), blurRadius: 12),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),

              // 3. Bottom Home Indicator Gesture Bar
              Positioned(
                bottom: 10,
                child: Container(
                  width: 112,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Success & Activation Overlay with 3D Flip Hero Card & Genie Synchronization ---

class _AmanahQueueActivationOverlay extends StatefulWidget {
  const _AmanahQueueActivationOverlay({
    required this.card,
    required this.isGenieSettled,
    required this.isGenieRunning,
    required this.onClose,
    required this.onRedraw,
    required this.onActionClick,
  });

  final AmanahQueueCardData card;
  final bool isGenieSettled;
  final bool isGenieRunning;
  final VoidCallback onClose;
  final VoidCallback onRedraw;
  final VoidCallback onActionClick;

  @override
  State<_AmanahQueueActivationOverlay> createState() =>
      _AmanahQueueActivationOverlayState();
}

class _AmanahQueueActivationOverlayState
    extends State<_AmanahQueueActivationOverlay>
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
  void didUpdateWidget(covariant _AmanahQueueActivationOverlay oldWidget) {
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
    AmanahPatientDetailModal.show(
      context,
      BookedPatient(
        id: widget.card.id,
        patientName: widget.card.patientName,
        patientComplaint: widget.card.complaint,
        queueNumber: widget.card.queueNumber,
        timeSlot: widget.card.timeSlot,
        avatarUrl: widget.card.doctorImage,
        patientAge: '${widget.card.age} Thn',
        patientRm: widget.card.patientRm,
        badge: widget.card.priority,
        badgeVariant: widget.card.priority == 'Prioritas'
            ? AmanahBadgeVariant.warning
            : AmanahBadgeVariant.primary,
      ),
      DoctorSchedule(
        id: 'sch_${widget.card.id}',
        title: 'Praktik Dokter',
        date: 'Hari ini',
        time: widget.card.timeSlot,
        poli: widget.card.poly,
        room: widget.card.room,
        slotCount: '1',
        slotText: 'Antrean',
        badge: widget.card.priority,
        badgeVariant: AmanahBadgeVariant.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double cardW = math.min(size.width - 64, 320.0);
    final double cardH = cardW / 0.718;

    final double flipAngle = _flipAnimation.value;
    final bool isBackface = flipAngle > (math.pi / 2);

    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          // 1. Soft Background Scrim (Fades in softly without wrapping or pulsing the Hero Card)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              opacity: widget.isGenieSettled
                  ? 1.0
                  : (widget.isGenieRunning ? 0.0 : 0.95),
              child: Container(color: const Color(0xF8F8FAFF)),
            ),
          ),

          SafeArea(
            child: Column(
              children: <Widget>[
                // 2. Top Header Bar (Animated Slide & Fade when settled)
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
                            color: const Color(0xFF1E293B),
                          ),
                          const Text(
                            'Antrean terpilih',
                            style: TextStyle(
                              color: Color(0xFF14103B),
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Activated Hero Card: Steady, Solid & Continuous (Zero flash, zero pulse)
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
                                    child: _AmanahQueueCardCover(
                                      card: widget.card,
                                      width: cardW,
                                      height: cardH,
                                    ),
                                  ),
                                )
                              : _AmanahRevealedHeroCard(
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

                // 4. Action Buttons: Panggil Pasien & Pilih Antrean Lain (Animated Slide & Fade when settled)
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
                        vertical: 20,
                      ),
                      child: Column(
                        children: <Widget>[
                          // Primary Action Button: Panggil & Proses Pasien (Triggers Genie suction into dock)
                          AmanahButton.primary(
                            text: 'Panggil & Proses Pasien',
                            size: AmanahButtonSize.hero,
                            isFullWidth: true,
                            borderRadius: BorderRadius.circular(18),
                            onPressed: widget.onActionClick,
                          ),

                          const SizedBox(height: 12),

                          // Secondary Action Button
                          AmanahButton.secondary(
                            text: 'Pilih Antrean Lain',
                            size: AmanahButtonSize.medium,
                            isFullWidth: true,
                            borderRadius: BorderRadius.circular(18),
                            onPressed: widget.onRedraw,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. Native Confetti Streamers Layer (Fired at 3D flip spin apex)
          Positioned.fill(child: AmanahConfettiCanvas(key: _confettiKey)),
        ],
      ),
    );
  }
}

// --- Front Face Revealed Hero Card ---

class _AmanahRevealedHeroCard extends StatelessWidget {
  const _AmanahRevealedHeroCard({
    required this.card,
    required this.width,
    required this.height,
    required this.onDetailTap,
  });

  final AmanahQueueCardData card;
  final double width;
  final double height;
  final VoidCallback onDetailTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.white, Color(0xFFF8FAFF), Color(0xFFEDF2FF)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF0A1E50).withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
            spreadRadius: -12,
          ),
        ],
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: <Widget>[
            // 1. Official Vector Watermark switched to Top-Left (-top-4 -left-6)
            const Positioned(
              top: -16,
              left: -24,
              child: AmanahWatermarkLogo(
                size: 200,
                color: Color(0xFF0A44FF),
                opacity: 0.25,
              ),
            ),

            // 2. Cybernetic Pixel Matrix Texture (bottom-left feathering)
            const AmanahPixelTexture(
              isDark: false,
              opacity: 0.22,
              maskType: AmanahPixelMaskType.bottomLeft,
            ),

            // 3. Top-Left Queue Number
            Positioned(
              top: 16,
              left: 20,
              child: Text(
                card.queueNumber,
                style: const TextStyle(
                  color: Color(0xFF0A44FF),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
            ),

            // 4. Doctor / Patient Silhouette Photo with Smooth Bottom Alpha Fade
            Positioned(
              right: 0,
              top: 36,
              bottom: 74,
              width: width * 0.76,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: <double>[0.0, 0.68, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  card.doctorImage,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),

            // 5. Bottom Section: Patient Name with Clickable Arrow ↗ + Complaint
            Positioned(
              bottom: 48,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.arrow_outward_rounded,
                        color: Color(0xFF0A44FF),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          card.patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.complaint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 6. Polyclinic Tag (Bottom Right)
            Positioned(
              bottom: 16,
              right: 20,
              child: Text(
                card.poly,
                style: const TextStyle(
                  color: Color(0xFF0A44FF),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- History Screen (Riwayat Antrean Diproses) ---

class AmanahQueueHistoryScreen extends StatelessWidget {
  const AmanahQueueHistoryScreen({
    required this.collectedCards,
    required this.onRedraw,
    super.key,
  });

  final List<AmanahQueueCardData> collectedCards;
  final VoidCallback onRedraw;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Riwayat antrean diproses',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: collectedCards.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Center(
                      child: Text(
                        '#',
                        style: TextStyle(
                          color: Color(0xFF0A44FF),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada antrean diproses',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Tarik kartu antrean pasien ke bawah pada rel 3D untuk memproses dan memanggil pasien!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: collectedCards.length,
              itemBuilder: (BuildContext context, int index) {
                final AmanahQueueCardData card = collectedCards[index];
                return GestureDetector(
                  onTap: () {
                    AmanahPatientDetailModal.show(
                      context,
                      BookedPatient(
                        id: card.id,
                        patientName: card.patientName,
                        patientComplaint: card.complaint,
                        queueNumber: card.queueNumber,
                        timeSlot: card.timeSlot,
                        avatarUrl: card.doctorImage,
                        patientAge: '${card.age} Thn',
                        patientRm: card.patientRm,
                        badge: card.priority,
                        badgeVariant: card.priority == 'Prioritas'
                            ? AmanahBadgeVariant.warning
                            : AmanahBadgeVariant.primary,
                      ),
                      DoctorSchedule(
                        id: 'sch_${card.id}',
                        title: 'Praktik Dokter',
                        date: 'Hari ini',
                        time: card.timeSlot,
                        poli: card.poly,
                        room: card.room,
                        slotCount: '1',
                        slotText: 'Antrean',
                        badge: card.priority,
                        badgeVariant: AmanahBadgeVariant.primary,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: <Widget>[
                          // Watermark Silhouette (Left side behind Queue Number area)
                          const Positioned(
                            top: -6,
                            left: -8,
                            child: Opacity(
                              opacity: 0.07,
                              child: AmanahWatermarkLogo(size: 72),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // Top Row: Queue Number + Poly Tag
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      card.queueNumber,
                                      style: const TextStyle(
                                        color: Color(0xFF0A44FF),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFDBEAFE),
                                          ),
                                        ),
                                        child: Text(
                                          card.poly,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF0A44FF),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Bottom Group: User Avatar + Name + Complaint
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.asset(
                                              card.doctorImage,
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    BuildContext context,
                                                    Object error,
                                                    StackTrace? stackTrace,
                                                  ) {
                                                    return Container(
                                                      color: const Color(
                                                        0xFFEFF6FF,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                        Icons.person,
                                                        size: 14,
                                                        color: Color(
                                                          0xFF0A44FF,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            card.patientName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      card.complaint,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: AmanahButton.primary(
            text: 'Panggil Antrean Lain',
            isFullWidth: true,
            size: AmanahButtonSize.large,
            onPressed: () {
              Navigator.of(context).pop();
              onRedraw();
            },
          ),
        ),
      ),
    );
  }
}

// --- Panduan Alur Sistem Antrean Master Drawer ---

class _AmanahQueueGuideDrawer extends StatelessWidget {
  const _AmanahQueueGuideDrawer();

  @override
  Widget build(BuildContext context) {
    final double bottomNavPadding = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 32.0 + bottomNavPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Panduan alur sistem antrean',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            'Sistem rel antrean 3D interaktif Klinik Amanah mempermudah dokter & staf dalam memproses dan memanggil pasien:',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),
          _buildStep(
            '1. Geser Rel 3D',
            'Geser kartu ke kiri/kanan untuk memilih nomor antrean pasien',
            AmanahColorTokens.brandPrimary,
          ),
          _buildStep(
            '2. Tarik ke Bawah',
            'Tarik kartu ke slot bawah hingga kotak paramedis terbuka untuk memproses',
            AmanahColorTokens.brandLight,
          ),
          _buildStep(
            '3. Putar & Cek Kartu',
            'Kartu berputar 3D menampilkan nama pasien, keluhan, dan poli tujuan',
            AmanahColorTokens.success,
          ),
          _buildStep(
            '4. Panggil Pasien',
            'Tekan "Panggil Pasien" untuk aktivasi atau simpan ke riwayat antrean',
            AmanahColorTokens.violet,
          ),

          const SizedBox(height: 20),
          AmanahButton.ghost(
            text: 'Mengerti',
            isFullWidth: true,
            size: AmanahButtonSize.medium,
            customForegroundColor: AmanahColorTokens.neutral700,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String title, String desc, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
