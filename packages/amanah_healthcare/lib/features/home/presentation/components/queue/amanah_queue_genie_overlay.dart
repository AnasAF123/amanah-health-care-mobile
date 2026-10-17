import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_genie_effect.dart';

/// Fullscreen overlay rendering the Apple-like Genie fluid morph effect.
class AmanahQueueGenieOverlay extends StatelessWidget {
  const AmanahQueueGenieOverlay({
    required this.snapshot,
    required this.progress,
    required this.direction,
    required this.screenSize,
    super.key,
  });

  final ui.Image snapshot;
  final double progress;
  final AmanahGenieDirection direction;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: AmanahGenieCanvasPainter(
            snapshot: snapshot,
            progress: progress,
            direction: direction,
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
    );
  }
}
