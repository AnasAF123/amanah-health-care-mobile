import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/domain/amanah_queue_data.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_genie_effect.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Amanah Genie Effect Unit & Rendering Tests', () {
    test(
      'generateCardCoverSnapshot creates a sharp ui.Image with correct pixelRatio',
      () async {
        const Size cardSize = Size(320, 445);
        final AmanahQueueCardData card = defaultAmanahQueueCards[0];

        final ui.Image snapshot = await generateCardCoverSnapshot(
          card: card,
          size: cardSize,
          pixelRatio: 2.0,
        );

        expect(snapshot.width, 640);
        expect(snapshot.height, 890);
        snapshot.dispose();
      },
    );

    test('AmanahGenieCanvasPainter repaints when progress changes', () async {
      const Size cardSize = Size(320, 445);
      final AmanahQueueCardData card = defaultAmanahQueueCards[0];
      final ui.Image snapshot = await generateCardCoverSnapshot(
        card: card,
        size: cardSize,
        pixelRatio: 1.0,
      );

      final AmanahGenieCanvasPainter painter1 = AmanahGenieCanvasPainter(
        snapshot: snapshot,
        progress: 0.2,
        direction: AmanahGenieDirection.open,
        dockPoint: const Offset(195, 800),
        cardRect: const Rect.fromLTWH(35, 100, 320, 445),
      );

      final AmanahGenieCanvasPainter painter2 = AmanahGenieCanvasPainter(
        snapshot: snapshot,
        progress: 0.5,
        direction: AmanahGenieDirection.open,
        dockPoint: const Offset(195, 800),
        cardRect: const Rect.fromLTWH(35, 100, 320, 445),
      );

      expect(painter2.shouldRepaint(painter1), isTrue);

      // Test paint call on both open and minimize
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      painter1.paint(canvas, const Size(390, 844));

      final AmanahGenieCanvasPainter minimizePainter = AmanahGenieCanvasPainter(
        snapshot: snapshot,
        progress: 0.85,
        direction: AmanahGenieDirection.minimize,
        dockPoint: const Offset(195, 800),
        cardRect: const Rect.fromLTWH(35, 100, 320, 445),
      );

      minimizePainter.paint(canvas, const Size(390, 844));

      final ui.Picture pic = recorder.endRecording();
      pic.dispose();
      snapshot.dispose();
    });
  });
}
