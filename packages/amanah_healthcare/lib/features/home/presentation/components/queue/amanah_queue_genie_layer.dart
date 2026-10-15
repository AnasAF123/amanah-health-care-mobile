import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_genie_effect.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_activation_overlay.dart';

/// Layer orchestrating the Genie opening, suction/minimization, and activation modal
class AmanahQueueGenieLayer extends StatefulWidget {
  const AmanahQueueGenieLayer({
    super.key,
    required this.activeCard,
    required this.onClose,
    required this.onCollect,
  });

  final AmanahQueueCardData? activeCard;
  final VoidCallback onClose;
  final ValueChanged<AmanahQueueCardData> onCollect;

  @override
  State<AmanahQueueGenieLayer> createState() => _AmanahQueueGenieLayerState();
}

class _AmanahQueueGenieLayerState extends State<AmanahQueueGenieLayer>
    with TickerProviderStateMixin {
  AnimationController? _genieController;
  ui.Image? _genieSnapshot;
  AmanahGenieDirection _genieDirection = AmanahGenieDirection.open;
  bool _isGenieRunning = false;
  bool _isGenieSettled = false;

  @override
  void initState() {
    super.initState();
    if (widget.activeCard != null) {
      _startGenieOpen(widget.activeCard!);
    }
  }

  @override
  void didUpdateWidget(AmanahQueueGenieLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeCard == null && widget.activeCard != null) {
      _startGenieOpen(widget.activeCard!);
    } else if (oldWidget.activeCard != null && widget.activeCard == null) {
      _genieSnapshot?.dispose();
      _genieSnapshot = null;
      _isGenieRunning = false;
      _isGenieSettled = false;
    }
  }

  Future<void> _startGenieOpen(AmanahQueueCardData card) async {
    _disposeController();
    setState(() {
      _isGenieRunning = true;
      _isGenieSettled = false;
    });
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: card,
      size: const Size(230, 320),
      pixelRatio: 2.0,
      isDark: isDark,
    );
    if (!mounted) {
      coverSnapshot.dispose();
      return;
    }
    _genieSnapshot?.dispose();
    _genieSnapshot = coverSnapshot;

    _genieDirection = AmanahGenieDirection.open;
    _genieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );

    _genieController!.addListener(() {
      if (mounted) setState(() {});
    });

    _genieController!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _isGenieRunning = false;
          _isGenieSettled = true;
        });
      }
    });

    _genieController!.forward();
  }

  Future<void> _startGenieMinimize({required VoidCallback onComplete}) async {
    if (widget.activeCard == null) return;
    _disposeController();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ui.Image coverSnapshot = await generateCardCoverSnapshot(
      card: widget.activeCard!,
      size: const Size(230, 320),
      pixelRatio: 2.0,
      isDark: isDark,
    );
    if (!mounted) {
      coverSnapshot.dispose();
      return;
    }
    _genieSnapshot?.dispose();
    _genieSnapshot = coverSnapshot;

    _genieDirection = AmanahGenieDirection.minimize;
    _genieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    setState(() {
      _isGenieRunning = true;
      _isGenieSettled = false;
    });

    _genieController!.addListener(() {
      if (mounted) setState(() {});
    });

    _genieController!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _isGenieRunning = false;
          _isGenieSettled = false;
        });
        _disposeController();
        onComplete();
      }
    });

    _genieController!.forward();
  }

  void _disposeController() {
    if (_genieController != null) {
      _genieController!.stop();
      _genieController!.dispose();
      _genieController = null;
    }
  }

  @override
  void dispose() {
    _disposeController();
    _genieSnapshot?.dispose();
    _genieSnapshot = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final AmanahQueueCardData? card = widget.activeCard;

    if (card == null && !_isGenieRunning) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: <Widget>[
        if (card != null)
          AmanahQueueActivationOverlay(
            card: card,
            isGenieSettled: _isGenieSettled,
            isGenieRunning: _isGenieRunning,
            onClose: () => _startGenieMinimize(onComplete: widget.onClose),
            onRedraw: () => _startGenieMinimize(onComplete: widget.onClose),
            onActionClick: () => _startGenieMinimize(
              onComplete: () => widget.onCollect(card),
            ),
          ),
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
                    height: math.min(screenSize.width - 64, 320.0) / 0.718,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
