import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Directional drag mode for queue deck stack interactions
enum QueueDragMode {
  none,
  up,
  down,
  left,
}

/// Controller orchestrating directional gestures, spring physics, and card animations
class AmanahQueueGestureController {
  AmanahQueueGestureController({
    required TickerProvider vsync,
    required this.onUpdate,
    required this.onProcessCard,
    required this.onCancelComplete,
    required this.onRotateComplete,
  }) {
    _initControllers(vsync);
  }

  final VoidCallback onUpdate;
  final VoidCallback onProcessCard;
  final VoidCallback onCancelComplete;
  final VoidCallback onRotateComplete;

  late final AnimationController _springController;
  late final AnimationController _cancelController;
  late final AnimationController _rotateController;

  QueueDragMode _dragMode = QueueDragMode.none;
  double _horizontalDrag = 0.0;
  double _verticalDrag = 0.0;
  double _springStartX = 0.0;
  double _springStartY = 0.0;

  QueueDragMode get dragMode => _dragMode;
  double get horizontalDrag => _horizontalDrag;
  double get verticalDrag => _verticalDrag;

  bool get isCancelling => _cancelController.isAnimating;
  double get cancelProgress => _cancelController.value;

  bool get isRotating => _rotateController.isAnimating;
  double get rotateProgress => _rotateController.value;

  bool get isAnimating =>
      _springController.isAnimating ||
      _cancelController.isAnimating ||
      _rotateController.isAnimating;

  void _initControllers(TickerProvider vsync) {
    _springController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 260),
    )
      ..addListener(() {
        final double t = Curves.easeOutCubic.transform(_springController.value);
        _horizontalDrag = _springStartX * (1.0 - t);
        _verticalDrag = _springStartY * (1.0 - t);
        onUpdate();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _horizontalDrag = 0.0;
          _verticalDrag = 0.0;
          _dragMode = QueueDragMode.none;
          _springController.reset();
          onUpdate();
        }
      });

    _cancelController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 320),
    )
      ..addListener(onUpdate)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _horizontalDrag = 0.0;
          _verticalDrag = 0.0;
          _dragMode = QueueDragMode.none;
          _cancelController.reset();
          onCancelComplete();
          HapticFeedback.mediumImpact();
        }
      });

    _rotateController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 420),
    )
      ..addListener(onUpdate)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _horizontalDrag = 0.0;
          _verticalDrag = 0.0;
          _dragMode = QueueDragMode.none;
          _rotateController.reset();
          onRotateComplete();
          HapticFeedback.mediumImpact();
        }
      });
  }

  void onPanDown(DragDownDetails details, {required bool isIdle}) {
    if (isAnimating || !isIdle) return;
    if (_springController.isAnimating) {
      _springController.stop();
      _springController.reset();
    }
  }

  void onPanCancel({required bool isIdle}) {
    if (isAnimating || !isIdle) return;
    _springStartX = _horizontalDrag;
    _springStartY = _verticalDrag;
    _springController.forward(from: 0.0);
  }

  void onPanUpdate(DragUpdateDetails details, {required bool isIdle}) {
    if (isAnimating || !isIdle) return;
    final double dx = details.delta.dx;
    final double dy = details.delta.dy;

    if (_dragMode == QueueDragMode.none) {
      _horizontalDrag += dx;
      _verticalDrag += dy;

      if (_verticalDrag < -14 && _verticalDrag.abs() > _horizontalDrag.abs()) {
        _dragMode = QueueDragMode.up;
        _horizontalDrag = 0.0;
        HapticFeedback.selectionClick();
      } else if (_verticalDrag > 14 &&
          _verticalDrag.abs() > _horizontalDrag.abs()) {
        _dragMode = QueueDragMode.down;
        _horizontalDrag = 0.0;
        HapticFeedback.selectionClick();
      } else if (_horizontalDrag < -14 &&
          _horizontalDrag.abs() > _verticalDrag.abs()) {
        _dragMode = QueueDragMode.left;
        _verticalDrag = 0.0;
        HapticFeedback.selectionClick();
      }
    } else if (_dragMode == QueueDragMode.up) {
      _verticalDrag = (_verticalDrag + dy).clamp(-180.0, 0.0);
      _horizontalDrag = 0.0;
    } else if (_dragMode == QueueDragMode.down) {
      _verticalDrag = (_verticalDrag + dy).clamp(0.0, 110.0);
      _horizontalDrag = 0.0;
    } else if (_dragMode == QueueDragMode.left) {
      _horizontalDrag = (_horizontalDrag + dx).clamp(-220.0, 0.0);
      _verticalDrag = 0.0;
    }
    onUpdate();
  }

  void onPanEnd(DragEndDetails details, {required bool isIdle}) {
    if (isAnimating || !isIdle) return;

    final double vx = details.velocity.pixelsPerSecond.dx;
    final double vy = details.velocity.pixelsPerSecond.dy;

    if (_dragMode == QueueDragMode.up) {
      if (_verticalDrag <= -65 || vy < -380) {
        _cancelController.forward(from: 0.0);
        return;
      }
    } else if (_dragMode == QueueDragMode.down) {
      if (_verticalDrag >= 55 || vy > 380) {
        onProcessCard();
        return;
      }
    } else if (_dragMode == QueueDragMode.left) {
      if (_horizontalDrag <= -65 || vx < -380) {
        _rotateController.forward(from: 0.0);
        return;
      }
    }

    _springStartX = _horizontalDrag;
    _springStartY = _verticalDrag;
    _springController.forward(from: 0.0);
  }

  void resetPositions() {
    _horizontalDrag = 0.0;
    _verticalDrag = 0.0;
    _dragMode = QueueDragMode.none;
    if (_springController.isAnimating) _springController.reset();
    if (_cancelController.isAnimating) _cancelController.reset();
    if (_rotateController.isAnimating) _rotateController.reset();
    onUpdate();
  }

  void dispose() {
    _springController.dispose();
    _cancelController.dispose();
    _rotateController.dispose();
  }
}
