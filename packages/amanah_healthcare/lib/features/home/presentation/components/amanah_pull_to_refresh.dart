import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_racing_chevrons.dart';

/// Interaction States matching the Blueprint:
/// IDLE -> PULLING -> ARMED / READY -> REFRESHING -> COMPLETE -> IDLE
enum AmanahPullRefreshState {
  idle,
  pulling,
  armed,
  refreshing,
  complete,
  canceling,
}

/// Universal, High-End Pull-To-Refresh Widget for the Amanah Healthcare Mobile App.
///
/// Implements the exact 3-chevron progressive reveal, non-linear resistance function,
/// armed haptic feedback, and sequential kinetic pulse wave from the "Pilih Antrean"
/// aerodynamic racing chevron design system.
class AmanahPullToRefresh extends StatefulWidget {
  const AmanahPullToRefresh({
    required this.child,
    required this.onRefresh,
    super.key,
    this.refreshThreshold = 72.0,
    this.maxVisualDistance = 104.0,
    this.refreshHoldHeight = 56.0,
    this.resistanceFactor = 140.0,
  });

  /// The scrollable child (e.g., ListView, SingleChildScrollView, CustomScrollView).
  final Widget child;

  /// Async refresh callback invoked when the user releases after passing the threshold.
  final Future<void> Function() onRefresh;

  /// Visual distance required to arm the refresh trigger (progress = 1.0).
  final double refreshThreshold;

  /// Maximum visual travel distance of the content (asymptote of resistance curve).
  final double maxVisualDistance;

  /// Resting slot height for the indicator during the async refresh operation.
  final double refreshHoldHeight;

  /// Dampening factor for the non-linear resistance formula:
  /// `visualDistance = maxVisualDistance * (1 - e^(-rawDistance / resistanceFactor))`
  final double resistanceFactor;

  @override
  State<AmanahPullToRefresh> createState() => _AmanahPullToRefreshState();
}

class _AmanahPullToRefreshState extends State<AmanahPullToRefresh>
    with TickerProviderStateMixin {
  AmanahPullRefreshState _state = AmanahPullRefreshState.idle;

  double _rawDragDistance = 0.0;
  double _visualDistance = 0.0;
  double _pullProgress = 0.0;
  bool _isAtTop = true;
  double _lastPointerY = 0.0;
  bool _isPointerDown = false;

  late final AnimationController _pulseController;
  late final AnimationController _settleController;

  double _settleStart = 0.0;
  double _settleEnd = 0.0;
  Curve _settleCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    )..addListener(() {
        setState(() {
          final double t = _settleCurve.transform(_settleController.value);
          _visualDistance = _settleStart + (_settleEnd - _settleStart) * t;
        });
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _settleController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Resistance & Distance Pipeline
  // ---------------------------------------------------------------------------
  double _calculateVisualDistance(double rawDistance) {
    if (rawDistance <= 0.0) {
      return 0.0;
    }
    // Elastic asymptotic resistance: visual = max * (1 - e^(-raw / factor))
    return widget.maxVisualDistance *
        (1.0 - math.exp(-rawDistance / widget.resistanceFactor));
  }

  void _updatePull(double rawDistance) {
    _rawDragDistance = math.max(0.0, rawDistance);
    final double visual = _calculateVisualDistance(_rawDragDistance);
    final double progress = (visual / widget.refreshThreshold).clamp(0.0, 1.0);

    final AmanahPullRefreshState nextState;
    if (progress >= 1.0) {
      nextState = AmanahPullRefreshState.armed;
      if (_state != AmanahPullRefreshState.armed) {
        HapticFeedback.mediumImpact();
      }
    } else if (progress > 0.0) {
      nextState = AmanahPullRefreshState.pulling;
    } else {
      nextState = AmanahPullRefreshState.idle;
    }

    setState(() {
      _visualDistance = visual;
      _pullProgress = progress;
      _state = nextState;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    _lastPointerY = event.position.dy;
    _isPointerDown = true;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isPointerDown) {
      return;
    }
    final double deltaY = event.position.dy - _lastPointerY;
    _lastPointerY = event.position.dy;

    if (_state == AmanahPullRefreshState.refreshing ||
        _state == AmanahPullRefreshState.complete) {
      return;
    }

    if (_isAtTop && (deltaY > 0 || _rawDragDistance > 0)) {
      _updatePull(_rawDragDistance + deltaY);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _isPointerDown = false;
    _handleRelease();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _isPointerDown = false;
    _handleRelease();
  }

  void _handleRelease() {
    if (_state == AmanahPullRefreshState.refreshing ||
        _state == AmanahPullRefreshState.complete) {
      return;
    }

    if (_state == AmanahPullRefreshState.armed) {
      _triggerRefresh();
    } else if (_visualDistance > 0.0) {
      _cancelAndSettle();
    }
  }

  void _triggerRefresh() {
    _settleStart = _visualDistance;
    _settleEnd = widget.refreshHoldHeight;
    _settleCurve = Curves.easeOutCubic;
    _settleController.duration = const Duration(milliseconds: 240);

    setState(() {
      _state = AmanahPullRefreshState.refreshing;
    });

    _pulseController.repeat();
    _settleController.forward(from: 0.0);

    // Execute async refresh operation
    () async {
      try {
        await widget.onRefresh();
      } finally {
        if (mounted) {
          _completeRefresh();
        }
      }
    }();
  }

  void _completeRefresh() {
    setState(() {
      _state = AmanahPullRefreshState.complete;
    });

    // Hold briefly for visual completion confirmation
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) {
        return;
      }
      _pulseController.stop();

      _settleStart = _visualDistance;
      _settleEnd = 0.0;
      _settleCurve = Curves.easeInOutCubic;
      _settleController.duration = const Duration(milliseconds: 280);

      _settleController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _state = AmanahPullRefreshState.idle;
            _visualDistance = 0.0;
            _rawDragDistance = 0.0;
            _pullProgress = 0.0;
          });
        }
      });
    });
  }

  void _cancelAndSettle() {
    setState(() {
      _state = AmanahPullRefreshState.canceling;
    });

    _settleStart = _visualDistance;
    _settleEnd = 0.0;
    _settleCurve = Curves.easeOutCubic;
    _settleController.duration = const Duration(milliseconds: 220);

    _settleController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _state = AmanahPullRefreshState.idle;
          _visualDistance = 0.0;
          _rawDragDistance = 0.0;
          _pullProgress = 0.0;
        });
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    // Detect if scrollable is resting at the top
    _isAtTop = notification.metrics.extentBefore <= 0.0;

    // Handle standard Flutter overscroll notifications (Clamping / Bouncing)
    if (notification is OverscrollNotification && _isPointerDown) {
      if (notification.overscroll < 0) {
        _updatePull(_rawDragDistance + (-notification.overscroll));
      }
    } else if (notification is ScrollUpdateNotification && _isPointerDown) {
      if (_isAtTop && notification.scrollDelta != null && notification.scrollDelta! < 0) {
        _updatePull(_rawDragDistance + (-notification.scrollDelta!));
      }
    } else if (notification is ScrollEndNotification) {
      if (!_isPointerDown && _visualDistance > 0.0) {
        _handleRelease();
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool showIndicator =
        _visualDistance > 0.0 || _state == AmanahPullRefreshState.refreshing;

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // 1. Translated Scrollable Child
            Transform.translate(
              offset: Offset(0, _visualDistance),
              child: widget.child,
            ),

            // 2. Custom Aerodynamic Progressive Racing Chevrons Header
            if (showIndicator)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _visualDistance,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (BuildContext context, Widget? child) {
                        final bool isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return CustomPaint(
                          size: const Size(36, 38),
                          painter: _AmanahPullChevronPainter(
                            state: _state,
                            pullProgress: _pullProgress,
                            pulseProgress: _pulseController.value,
                            visualDistance: _visualDistance,
                            refreshHoldHeight: widget.refreshHoldHeight,
                            isDark: isDark,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter for Progressive Chevrons (Pulling) and Kinetic Wave Pulse (Refreshing).
///
/// Delegates all geometry, theme-adaptive neon shaders, and wing painting directly to
/// the master renderer [AmanahChevronRenderer] from `amanah_racing_chevrons.dart`.
class _AmanahPullChevronPainter extends CustomPainter {
  const _AmanahPullChevronPainter({
    required this.state,
    required this.pullProgress,
    required this.pulseProgress,
    required this.visualDistance,
    required this.refreshHoldHeight,
    required this.isDark,
  });

  final AmanahPullRefreshState state;
  final double pullProgress;
  final double pulseProgress;
  final double visualDistance;
  final double refreshHoldHeight;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    final double topBaseY = centerY -
        ((AmanahChevronRenderer.count * AmanahChevronRenderer.spacing) / 2);

    final bool isRefreshing = state == AmanahPullRefreshState.refreshing;
    final bool isComplete = state == AmanahPullRefreshState.complete;
    final bool isCanceling = state == AmanahPullRefreshState.canceling;

    // Fade out factor during exit settling
    double masterOpacity = 1.0;
    if (isComplete || isCanceling) {
      masterOpacity = (visualDistance / refreshHoldHeight).clamp(0.0, 1.0);
    }

    if (masterOpacity <= 0.0) {
      return;
    }

    if (isRefreshing || isComplete) {
      AmanahChevronRenderer.paintWavePulse(
        canvas: canvas,
        size: size,
        progress: pulseProgress,
        isDark: isDark,
        masterOpacity: masterOpacity,
        topBaseY: topBaseY,
      );
    } else {
      AmanahChevronRenderer.paintPullProgress(
        canvas: canvas,
        size: size,
        pullProgress: pullProgress,
        isDark: isDark,
        masterOpacity: masterOpacity,
        topBaseY: topBaseY,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AmanahPullChevronPainter oldDelegate) {
    return oldDelegate.pullProgress != pullProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.visualDistance != visualDistance ||
        oldDelegate.state != state ||
        oldDelegate.isDark != isDark;
  }
}
