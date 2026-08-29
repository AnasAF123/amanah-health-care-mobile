import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_dock_hollow_glow.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Amanah Dock Hollow Glow Painter Tests', () {
    test('AmanahDockHollowGlowPainter repaints on dragProgress and isLongPressing changes', () {
      const AmanahDockHollowGlowPainter painterIdle = AmanahDockHollowGlowPainter(
        dragProgress: 0.0,
        isLongPressing: false,
        isActivating: false,
      );

      const AmanahDockHollowGlowPainter painterDragging = AmanahDockHollowGlowPainter(
        dragProgress: 0.6,
        isLongPressing: false,
        isActivating: false,
      );

      const AmanahDockHollowGlowPainter painterLongPress = AmanahDockHollowGlowPainter(
        dragProgress: 0.0,
        isLongPressing: true,
        isActivating: false,
      );

      expect(painterDragging.shouldRepaint(painterIdle), isTrue);
      expect(painterLongPress.shouldRepaint(painterIdle), isTrue);
      expect(painterIdle.shouldRepaint(painterIdle), isFalse);
    });

    test('AmanahDockHollowGlowPainter paints all 6 layers without exceptions', () {
      const Size size = Size(390, 145);
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Paint idle state
      const AmanahDockHollowGlowPainter idlePainter = AmanahDockHollowGlowPainter(
        dragProgress: 0.0,
        isLongPressing: false,
        isActivating: false,
      );
      idlePainter.paint(canvas, size);

      // Paint dragging state (molten core + rising aura active)
      const AmanahDockHollowGlowPainter dragPainter = AmanahDockHollowGlowPainter(
        dragProgress: 0.75,
        isLongPressing: false,
        isActivating: false,
      );
      dragPainter.paint(canvas, size);

      // Paint long-press state (full volcanic blue beam + laser core)
      const AmanahDockHollowGlowPainter longPressPainter = AmanahDockHollowGlowPainter(
        dragProgress: 0.0,
        isLongPressing: true,
        isActivating: false,
        isDark: true,
      );
      longPressPainter.paint(canvas, size);

      final ui.Picture picture = recorder.endRecording();
      picture.dispose();
    });
  });
}
