import 'dart:async' as async;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_blurry_morph_text.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_confetti_canvas.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_dock_hollow_glow.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_genie_effect.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_paramedic_toolbox.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_racing_chevrons.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';

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

enum _QueueDragMode { none, up, down, left }

class _AmanahQueueDockScreenState extends State<AmanahQueueDockScreen>
    with TickerProviderStateMixin {
  late final List<AmanahQueueCardData> _cards =
      List<AmanahQueueCardData>.from(defaultAmanahQueueCards);
  final List<AmanahQueueCardData> _collectedCards = <AmanahQueueCardData>[];

  _QueueDragMode _dragMode = _QueueDragMode.none;
  double _horizontalDrag = 0.0;
  double _verticalDrag = 0.0;
  double _springStartX = 0.0;
  double _springStartY = 0.0;

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
  late final AnimationController _entranceController;
  late final AnimationController _springController;
  late final AnimationController _cancelController;
  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _initDotsTimer();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )
      ..addListener(() {
        if (mounted) {
          final double t =
              Curves.easeOutCubic.transform(_springController.value);
          setState(() {
            _horizontalDrag = _springStartX * (1.0 - t);
            _verticalDrag = _springStartY * (1.0 - t);
          });
        }
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _horizontalDrag = 0.0;
            _verticalDrag = 0.0;
            _dragMode = _QueueDragMode.none;
            _springController.reset();
          });
        }
      });

    _cancelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            if (_cards.isNotEmpty) {
              _cards.removeAt(0);
            }
            _horizontalDrag = 0.0;
            _verticalDrag = 0.0;
            _dragMode = _QueueDragMode.none;
            _cancelController.reset();
          });
          HapticFeedback.mediumImpact();
        }
      });

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            if (_cards.isNotEmpty) {
              final AmanahQueueCardData skipped = _cards.removeAt(0);
              _cards.add(skipped);
            }
            _horizontalDrag = 0.0;
            _verticalDrag = 0.0;
            _dragMode = _QueueDragMode.none;
            _rotateController.reset();
          });
          HapticFeedback.lightImpact();
        }
      });
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
    _springController.dispose();
    _cancelController.dispose();
    _rotateController.dispose();
    _dotsController?.dispose();
    _dotsController = null;
    _genieSnapshot?.dispose();
    _genieSnapshot = null;
    _disposeGenieController();
    super.dispose();
  }

  bool get _isAnimating =>
      _cancelController.isAnimating ||
      _rotateController.isAnimating ||
      _isGenieRunning;

  void _onPanDown(DragDownDetails details) {
    if (_isAnimating || _activationStage != 'idle') {
      return;
    }
    if (_springController.isAnimating) {
      _springController.stop();
      _springController.reset();
    }
  }

  void _onPanCancel() {
    if (_isAnimating || _activationStage != 'idle') {
      return;
    }
    _springStartX = _horizontalDrag;
    _springStartY = _verticalDrag;
    _springController.forward(from: 0.0);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating || _activationStage != 'idle') {
      return;
    }
    final double dx = details.delta.dx;
    final double dy = details.delta.dy;

    if (_dragMode == _QueueDragMode.none) {
      _horizontalDrag += dx;
      _verticalDrag += dy;

      if (_verticalDrag < -14 && _verticalDrag.abs() > _horizontalDrag.abs()) {
        _dragMode = _QueueDragMode.up;
        _horizontalDrag = 0.0;
        HapticFeedback.selectionClick();
      } else if (_verticalDrag > 14 &&
          _verticalDrag.abs() > _horizontalDrag.abs()) {
        _dragMode = _QueueDragMode.down;
        _horizontalDrag = 0.0;
        HapticFeedback.selectionClick();
      } else if (_horizontalDrag < -14 &&
          _horizontalDrag.abs() > _verticalDrag.abs()) {
        _dragMode = _QueueDragMode.left;
        _verticalDrag = 0.0;
        HapticFeedback.selectionClick();
      }
    } else if (_dragMode == _QueueDragMode.up) {
      _verticalDrag = (_verticalDrag + dy).clamp(-180.0, 0.0);
      _horizontalDrag = 0.0;
    } else if (_dragMode == _QueueDragMode.down) {
      _verticalDrag = (_verticalDrag + dy).clamp(0.0, 110.0);
      _horizontalDrag = 0.0;
    } else if (_dragMode == _QueueDragMode.left) {
      _horizontalDrag = (_horizontalDrag + dx).clamp(-220.0, 0.0);
      _verticalDrag = 0.0;
    }
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating || _activationStage != 'idle') {
      return;
    }

    final double vx = details.velocity.pixelsPerSecond.dx;
    final double vy = details.velocity.pixelsPerSecond.dy;

    if (_dragMode == _QueueDragMode.up) {
      if (_verticalDrag <= -65 || vy < -380) {
        _cancelController.forward(from: 0.0);
        return;
      }
    } else if (_dragMode == _QueueDragMode.down) {
      if (_verticalDrag >= 55 || vy > 380) {
        _handleActivate();
        return;
      }
    } else if (_dragMode == _QueueDragMode.left) {
      if (_horizontalDrag <= -65 || vx < -380) {
        _rotateController.forward(from: 0.0);
        return;
      }
    }

    _springStartX = _horizontalDrag;
    _springStartY = _verticalDrag;
    _springController.forward(from: 0.0);
  }

  void _bringCardToFront(int targetIndex) {
    if (_isAnimating || targetIndex <= 0 || targetIndex >= _cards.length) {
      return;
    }
    setState(() {
      for (int i = 0; i < targetIndex; i++) {
        final AmanahQueueCardData skipped = _cards.removeAt(0);
        _cards.add(skipped);
      }
      _horizontalDrag = 0.0;
      _verticalDrag = 0.0;
      _dragMode = _QueueDragMode.none;
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _handleActivate() async {
    if (_activationStage != 'idle' || _isGenieRunning || _cards.isEmpty) {
      return;
    }
    _disposeGenieController();

    final AmanahQueueCardData chosen = _cards.first;
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

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: chosen,
      size: Size(cardW, cardH),
      isDark: isDark,
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
        _selectedActiveCard ?? (_cards.isNotEmpty ? _cards.first : defaultAmanahQueueCards.first);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double cardW = math.min(screenSize.width - 64, 320.0);
    final double cardH = cardW / 0.718;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: chosen,
      size: Size(cardW, cardH),
      isDark: isDark,
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

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: card,
      size: Size(cardW, cardH),
      isDark: isDark,
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
            _cards.removeWhere(
              (AmanahQueueCardData c) => c.id == card.id,
            );
            _showSuccess = false;
            _isGenieRunning = false;
            _isGenieSettled = false;
            _selectedActiveCard = null;
            _activationStage = 'idle';
            _ejectionStage = 'idle';
            _verticalDrag = 0;
            _horizontalDrag = 0;
            _dragMode = _QueueDragMode.none;
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
    } else if (_dragMode == _QueueDragMode.up && _verticalDrag <= -20.0) {
      headlineText = 'Lepaskan untuk\nbatalkan antrean';
    } else if (_dragMode == _QueueDragMode.left && _horizontalDrag <= -20.0) {
      headlineText = 'Pindahkan ke\nurutan belakang';
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
                                          ? (isDark
                                              ? AmanahColorTokens.tabActiveDark
                                              : AmanahColorTokens.brandPrimary)
                                          : (isDark
                                              ? AmanahColorTokens.surfaceLight
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

                    // 3. Queue Card Rail Stack (Sequential Entrance 3)
                    Expanded(
                      child: Transform.translate(
                        offset: Offset(0, 40.0 * (1.0 - railProgress)),
                        child: Transform.scale(
                          scale: 0.88 + (0.12 * railProgress),
                          child: Opacity(
                            opacity: railProgress,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanDown: _onPanDown,
                              onPanCancel: _onPanCancel,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: RepaintBoundary(
                                child: _AmanahQueueRailStack(
                                  cards: _cards,
                                  horizontalDrag: _horizontalDrag,
                                  verticalDrag: _verticalDrag,
                                  dragMode: _dragMode,
                                  isCancelling: _cancelController.isAnimating,
                                  cancelProgress: _cancelController.value,
                                  isRotating: _rotateController.isAnimating,
                                  rotateProgress: _rotateController.value,
                                  isActivating: _activationStage != 'idle',
                                  ejectionStage: _ejectionStage,
                                  showSuccess: _showSuccess,
                                  onCardSelect: _bringCardToFront,
                                  onResetQueue: () {
                                    setState(() {
                                      _cards.clear();
                                      _cards.addAll(defaultAmanahQueueCards);
                                      _horizontalDrag = 0;
                                      _verticalDrag = 0;
                                      _dragMode = _QueueDragMode.none;
                                    });
                                  },
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
                            isLongPressing: false,
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: showSuccess ? 0.0 : 1.0,
      child: AmanahScreenHeader.actionOnly(
        onBack: onBack,
        backgroundColor: Colors.transparent,
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: isDark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isDark
                ? BorderSide(color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.12))
                : BorderSide.none,
          ),
          color: isDark ? AmanahColorTokens.surfaceElevatedDark : AmanahColorTokens.surfaceLight,
          onSelected: (String val) {
            if (val == 'guide') {
              onOpenGuide();
            } else if (val == 'history') {
              onOpenHistory();
            }
          },
          itemBuilder: (_) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'guide',
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    color: isDark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brandPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Panduan antrean',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'history',
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.history_rounded,
                    color: isDark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brandPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Riwayat antrean',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                    ),
                  ),
                  if (historyCount > 0) ...<Widget>[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AmanahColorTokens.auroraSapphireDark
                            : AmanahColorTokens.brandMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$historyCount',
                        style: TextStyle(
                          color: isDark
                              ? AmanahColorTokens.brandSubtle
                              : AmanahColorTokens.brandPrimary,
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
      ),
    );
  }
}

class _AmanahQueueRailStack extends StatelessWidget {
  const _AmanahQueueRailStack({
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
    required this.onResetQueue,
  });

  final List<AmanahQueueCardData> cards;
  final double horizontalDrag;
  final double verticalDrag;
  final _QueueDragMode dragMode;
  final bool isCancelling;
  final double cancelProgress;
  final bool isRotating;
  final double rotateProgress;
  final bool isActivating;
  final String ejectionStage;
  final bool showSuccess;
  final ValueChanged<int> onCardSelect;
  final VoidCallback onResetQueue;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Center(
        child: AmanahEmptyState.viewport(
          tone: AmanahEmptyStateTone.brand,
          title: 'Antrean Selesai',
          message:
              'Semua antrean pasien pada daftar ini telah selesai diproses atau dibatalkan.',
          actionText: 'Muat Ulang Antrean',
          onAction: onResetQueue,
        ),
      );
    }

    final Size screen = MediaQuery.sizeOf(context);
    const double cardW = 212.0;
    const double cardH = 335.0;
    final double baseTop = math.max(16.0, screen.height * 0.05);
    final double baseLeft = (screen.width - cardW) / 2;

    double card0X = 0.0;
    double card0Y = 0.0;
    double card0Scale = 1.0;
    double card0Rot = 0.0;
    double card0Opacity = 1.0;
    bool card0IsBehind = false;
    double queueAdvanceFactor = 0.0;

    if (dragMode == _QueueDragMode.up) {
      card0Y = verticalDrag;
      card0Scale = 1.0 - (verticalDrag.abs() / 240.0).clamp(0.0, 0.12);
      card0Opacity = 1.0 - (verticalDrag.abs() / 180.0).clamp(0.0, 0.40);
      queueAdvanceFactor = (verticalDrag.abs() / 90.0).clamp(0.0, 1.0);
    } else if (dragMode == _QueueDragMode.down) {
      card0Y = verticalDrag;
    } else if (dragMode == _QueueDragMode.left) {
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
        card0Rot =
            (horizontalDrag * 0.035 - 7.0 * c1) * (math.pi / 180.0);
        card0Scale = 1.0 - 0.06 * c1;
        card0Opacity = 1.0 - 0.10 * c1;
        card0IsBehind = false;
        queueAdvanceFactor = c1;
      } else {
        final double p2 = ((rotateProgress - 0.45) / 0.55).clamp(0.0, 1.0);
        final double c2 = Curves.easeOutCubic.transform(p2);
        final double targetBackX =
            math.min((cards.length - 1) * 24.0, 70.0);
        final double targetBackY =
            -math.min((cards.length - 1) * 3.0, 9.0);
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

    // Downward activation & ejection stages matching existing processing animation
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
              onTap: isInteractive && index != 0
                  ? () => onCardSelect(index)
                  : null,
              child: RepaintBoundary(
                child: _AmanahQueueCardCover(card: cards[index]),
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

    // 4. On-Demand UP Chevron Indicator (Batalkan - Single Chevron above card)
    double upIndicatorOpacity = 0.0;
    if (dragMode == _QueueDragMode.up) {
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

    // 5. On-Demand LEFT Chevron Indicator (Antre ke Belakang - Single Chevron to the left)
    double leftIndicatorOpacity = 0.0;
    if (dragMode == _QueueDragMode.left) {
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
            : (dragMode == _QueueDragMode.down
                ? (verticalDrag / 40.0).clamp(0.0, 1.0)
                : (dragMode == _QueueDragMode.none ? 0.40 : 0.0));

    stackChildren.add(
      Positioned(
        left: 0,
        right: 0,
        top: baseTop + 348,
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

// --- Card Cover (Back Face on 3D Rail with Watermark & Organic Pixel Texture) ---

class _AmanahQueueCardCover extends StatelessWidget {
  const _AmanahQueueCardCover({required this.card, this.width, this.height});

  final AmanahQueueCardData card;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double cardW = width ?? 212.0;
    final double cardH = height ?? 335.0;
    final double logoSize = cardW * 0.46;

    return RepaintBoundary(
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const <Color>[
                    AmanahColorTokens.surfaceElevatedDark,
                    AmanahColorTokens.neutral900,
                    AmanahColorTokens.canvasDark,
                  ]
                : const <Color>[
                    AmanahColorTokens.surfaceLight,
                    AmanahColorTokens.canvasLight,
                    AmanahColorTokens.brandSurface,
                  ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDark
                  ? AmanahColorTokens.pureBlack.withValues(alpha: 0.65)
                  : AmanahColorTokens.navy.withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 14),
              spreadRadius: isDark ? -2 : -6,
            ),
          ],
          border: Border.all(
            color: isDark
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.14)
                : AmanahColorTokens.surfaceLight,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isDark
                          ? <Color>[
                              AmanahColorTokens.auroraSapphireDark.withValues(alpha: 0.35),
                              AmanahColorTokens.neutral800.withValues(alpha: 0.15),
                              Colors.transparent,
                            ]
                          : <Color>[
                              AmanahColorTokens.brandMuted.withValues(alpha: 0.50),
                              AmanahColorTokens.brandSurface.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                    ),
                  ),
                ),
              ),

              AmanahPixelTexture(
                isDark: isDark,
                opacity: isDark ? 0.45 : 0.38,
                maskType: AmanahPixelMaskType.fadeTop,
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AmanahWatermarkLogo(
                    size: logoSize,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const <Color>[
                              AmanahColorTokens.brandLight,
                              AmanahColorTokens.brandSoft,
                              AmanahColorTokens.brandSubtle,
                            ]
                          : const <Color>[
                              AmanahColorTokens.brandPrimary,
                              AmanahColorTokens.brandAccent,
                              AmanahColorTokens.brandLight,
                            ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    card.queueNumber,
                    style: TextStyle(
                      color: isDark
                          ? AmanahColorTokens.brandSoft
                          : AmanahColorTokens.brandPrimary,
                      fontSize: cardW > 250 ? 44 : 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      height: 1.0,
                    ),
                  ),
                ],
              ),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: <Color>[
                        AmanahColorTokens.surfaceLight.withValues(alpha: isDark ? 0.05 : 0.10),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
              Positioned.fill(
                child: CustomPaint(
                  painter: AmanahDockHollowGlowPainter(
                    dragProgress: dragProgress,
                    isLongPressing: isLongPressing,
                    isActivating: isActivating,
                    isDark: isDark,
                  ),
                ),
              ),

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
                          ? AmanahColorTokens.brandLight
                          : (isDark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral700),
                      fontSize: 12,
                      fontWeight: dragProgress > 0.05
                          ? FontWeight.w800
                          : FontWeight.w600,
                      letterSpacing: 0.2,
                      shadows: dragProgress > 0.05
                          ? const <Shadow>[
                              Shadow(color: AmanahColorTokens.brandLight, blurRadius: 12),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 10,
                child: Container(
                  width: 112,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.25)
                        : AmanahColorTokens.pureBlack.withValues(alpha: 0.35),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
              child: Container(
                color: isDark
                    ? AmanahColorTokens.canvasDark.withValues(alpha: 0.95)
                    : AmanahColorTokens.canvasLight.withValues(alpha: 0.97),
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
                                ? AmanahColorTokens.surfaceLight
                                : AmanahColorTokens.neutral800,
                          ),
                          Text(
                            'Antrean terpilih',
                            style: TextStyle(
                              color: isDark
                                  ? AmanahColorTokens.surfaceLight
                                  : AmanahColorTokens.darkNavy,
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
                          AmanahButton.primary(
                            text: 'Panggil & Proses Pasien',
                            size: AmanahButtonSize.hero,
                            isFullWidth: true,
                            borderRadius: BorderRadius.circular(18),
                            onPressed: widget.onActionClick,
                          ),

                          const SizedBox(height: 12),

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

          Positioned.fill(child: AmanahConfettiCanvas(key: _confettiKey)),
        ],
      ),
    );
  }
}

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const <Color>[
                  AmanahColorTokens.surfaceElevatedDark,
                  AmanahColorTokens.neutral900,
                  AmanahColorTokens.canvasDark,
                ]
              : const <Color>[
                  AmanahColorTokens.surfaceLight,
                  AmanahColorTokens.canvasLight,
                  AmanahColorTokens.brandSurface,
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isDark
                ? AmanahColorTokens.pureBlack.withValues(alpha: 0.70)
                : AmanahColorTokens.navy.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
            spreadRadius: isDark ? -4 : -12,
          ),
        ],
        border: Border.all(
          color: isDark
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.14)
              : AmanahColorTokens.surfaceLight,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -16,
              left: -24,
              child: AmanahWatermarkLogo(
                size: 200,
                color: isDark
                    ? AmanahColorTokens.brandSoft
                    : AmanahColorTokens.brandPrimary,
                opacity: isDark ? 0.18 : 0.25,
              ),
            ),

            AmanahPixelTexture(
              isDark: isDark,
              opacity: isDark ? 0.30 : 0.22,
              maskType: AmanahPixelMaskType.bottomLeft,
            ),

            Positioned(
              top: 16,
              left: 20,
              child: Text(
                card.queueNumber,
                style: TextStyle(
                  color: isDark
                      ? AmanahColorTokens.brandSoft
                      : AmanahColorTokens.brandPrimary,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
            ),

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
                      AmanahColorTokens.pureBlack,
                      AmanahColorTokens.pureBlack,
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
                      Icon(
                        Icons.arrow_outward_rounded,
                        color: isDark
                            ? AmanahColorTokens.brandSoft
                            : AmanahColorTokens.brandPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          card.patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? AmanahColorTokens.surfaceLight
                                : AmanahColorTokens.neutral900,
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
                    style: TextStyle(
                      color: isDark
                          ? AmanahColorTokens.neutral400
                          : AmanahColorTokens.neutral500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 16,
              right: 20,
              child: Text(
                card.poly,
                style: TextStyle(
                  color: isDark
                      ? AmanahColorTokens.brandSoft
                      : AmanahColorTokens.brandPrimary,
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
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color bgColor = AmanahThemeTokens.canvas(context);
    final Color cardBg = AmanahThemeTokens.surface(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);
    final Color borderColor = AmanahThemeTokens.outline(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // 1. Master Screen Header (Respects Top Bar & Safe Area)
            AmanahScreenHeader.standard(
              title: 'Riwayat antrean diproses',
              onBack: () => Navigator.of(context).pop(),
              showDivider: true,
            ),

            // 2. Body Viewport
            Expanded(
              child: collectedCards.isEmpty
                  ? AmanahEmptyState.viewport(
                      tone: AmanahEmptyStateTone.brand,
                      iconShape: AmanahEmptyStateIconShape.squircle,
                      customIcon: Text(
                        '#',
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.brandAccent
                              : AmanahColorTokens.brandPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      title: 'Belum ada antrean diproses',
                      message:
                          'Tarik kartu antrean pasien ke bawah pada rel 3D untuk memproses dan memanggil pasien!',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(AmanahSpacing.lg),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AmanahColorTokens.pureBlack.withValues(
                                    alpha: dark ? 0.30 : 0.04,
                                  ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        // Top Row: Queue Number + Poly Tag
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              card.queueNumber,
                                              style: TextStyle(
                                                color: dark
                                                    ? AmanahColorTokens
                                                          .brandAccent
                                                    : AmanahColorTokens
                                                          .brandPrimary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: dark
                                                      ? AmanahColorTokens.brand
                                                            .withValues(
                                                              alpha: 0.15,
                                                            )
                                                      : AmanahColorTokens
                                                            .brandSurface,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: dark
                                                        ? AmanahColorTokens
                                                              .brand
                                                              .withValues(
                                                                alpha: 0.30,
                                                              )
                                                        : AmanahColorTokens
                                                              .brandMuted,
                                                  ),
                                                ),
                                                child: Text(
                                                  card.poly,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: dark
                                                        ? AmanahColorTokens
                                                              .brandAccent
                                                        : AmanahColorTokens
                                                              .brandPrimary,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: Image.asset(
                                                      card.doctorImage,
                                                      width: 24,
                                                      height: 24,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            BuildContext
                                                            context,
                                                            Object error,
                                                            StackTrace?
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color: dark
                                                                  ? AmanahColorTokens
                                                                        .brand
                                                                        .withValues(
                                                                          alpha:
                                                                              0.20,
                                                                        )
                                                                  : AmanahColorTokens
                                                                        .brandSurface,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 14,
                                                                color: dark
                                                                    ? AmanahColorTokens
                                                                          .brandAccent
                                                                    : AmanahColorTokens
                                                                          .brandPrimary,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
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
                                              style: TextStyle(
                                                color: subtextColor,
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AmanahSpacing.lg,
            8,
            AmanahSpacing.lg,
            16,
          ),
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
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return AmanahBottomSheetScaffold(
      title: 'Panduan alur sistem antrean',
      subtitle: 'Sistem rel antrean 3D interaktif Klinik Amanah',
      fixedHeightFactor: 0.65,
      minHeight: 400,
      footer: AmanahButton.primary(
        text: 'Mengerti',
        isFullWidth: true,
        size: AmanahButtonSize.medium,
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sistem rel antrean 3D interaktif Klinik Amanah mempermudah dokter & staf dalam memproses dan memanggil pasien:',
            style: TextStyle(
              color: dark
                  ? AmanahColorTokens.neutral400
                  : AmanahColorTokens.neutral500,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _buildStep(
            '1. Geser Rel 3D',
            'Geser kartu ke kiri/kanan untuk memilih nomor antrean pasien',
            AmanahColorTokens.brandPrimary,
            dark: dark,
          ),
          _buildStep(
            '2. Tarik ke Bawah',
            'Tarik kartu ke slot bawah hingga kotak paramedis terbuka untuk memproses',
            dark ? AmanahColorTokens.brandSoft : AmanahColorTokens.brandLight,
            dark: dark,
          ),
          _buildStep(
            '3. Putar & Cek Kartu',
            'Kartu berputar 3D menampilkan nama pasien, keluhan, dan poli tujuan',
            AmanahColorTokens.success,
            dark: dark,
          ),
          _buildStep(
            '4. Panggil Pasien',
            'Tekan "Panggil Pasien" untuk aktivasi atau simpan ke riwayat antrean',
            AmanahColorTokens.violet,
            dark: dark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String title, String desc, Color dotColor, {required bool dark}) {
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
                  style: TextStyle(
                    color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.neutral400
                        : AmanahColorTokens.neutral500,
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
