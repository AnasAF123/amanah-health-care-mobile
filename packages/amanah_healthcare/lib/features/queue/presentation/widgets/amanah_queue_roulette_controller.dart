import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmanahQueueRouletteController {
  final TickerProvider vsync;
  final VoidCallback onUpdate;
  final ValueChanged<int> onSnapComplete;

  AmanahQueueRouletteController({
    required this.vsync,
    required this.onUpdate,
    required this.onSnapComplete,
  });

  AnimationController? _rouletteController;
  AnimationController? _decelController;
  double _spinOffset = 0.0;
  bool _isLongPressing = false;
  double _rouletteVelocity = 0.0;
  int _lastHapticTimeMs = 0;

  double get spinOffset => _spinOffset;
  bool get isLongPressing => _isLongPressing;

  void startSpin({required int cardCount, required bool isIdle}) {
    if (cardCount == 0 || !isIdle) {
      return;
    }
    disposeDecel();
    disposeRoulette();

    _isLongPressing = true;
    _spinOffset = 0.0;
    _lastHapticTimeMs = DateTime.now().millisecondsSinceEpoch;
    HapticFeedback.heavyImpact();

    _rouletteVelocity = 18.0 * 230.0;

    _rouletteController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        if (!_isLongPressing) {
          return;
        }
        _spinOffset += _rouletteVelocity * 0.016;
        final int now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastHapticTimeMs >= 90) {
          _lastHapticTimeMs = now;
          HapticFeedback.selectionClick();
        }
        onUpdate();
      });

    _rouletteController!.repeat();
  }

  void stopSpin({required int currentIndex, required int cardCount}) {
    if (!_isLongPressing) {
      return;
    }
    disposeRoulette();
    _isLongPressing = false;

    final double startOffset = _spinOffset;
    final int shiftCards = (startOffset / 230.0).round();
    final double targetOffset = shiftCards * 230.0;
    final int targetIndex =
        (((currentIndex + shiftCards) % cardCount) + cardCount) % cardCount;

    disposeDecel();

    _decelController = AnimationController(
      vsync: vsync,
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
      _spinOffset = decelAnimation.value;
      onUpdate();
    });

    decelAnimation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _spinOffset = 0.0;
        HapticFeedback.mediumImpact();
        onSnapComplete(targetIndex);
        disposeDecel();
      }
    });

    _decelController!.forward();
  }

  void resetDrag() {
    if (_decelController != null && _decelController!.isAnimating) {
      disposeDecel();
      _spinOffset = 0.0;
      onUpdate();
    }
  }

  void disposeRoulette() {
    if (_rouletteController != null) {
      _rouletteController!.stop();
      _rouletteController!.dispose();
      _rouletteController = null;
    }
  }

  void disposeDecel() {
    if (_decelController != null) {
      _decelController!.stop();
      _decelController!.dispose();
      _decelController = null;
    }
  }

  void dispose() {
    disposeRoulette();
    disposeDecel();
  }
}
