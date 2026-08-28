import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_queue_dock_screen.dart';

void main() {
  Widget createQueueDockScreen({Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A44FF),
          brightness: brightness,
        ),
      ),
      home: const AmanahQueueDockScreen(),
    );
  }

  group('Amanah Queue Dock 3D Screen Tests', () {
    testWidgets('Renders Queue Dock screen and all cards in Light mode', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQueueDockScreen(brightness: Brightness.light));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check header and title
      expect(find.text('Pilih antrean\npasien'), findsOneWidget);
      expect(find.text('Tarik antrean ke bawah untuk proses'), findsOneWidget);

      // Check default cards on rail
      expect(find.text('#01'), findsWidgets);
      expect(find.text('#02'), findsWidgets);
    });

    testWidgets('Can drag horizontally and long press to roulette spin', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQueueDockScreen(brightness: Brightness.light));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Drag left
      await tester.drag(find.byType(GestureDetector).first, const Offset(-150, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Long press test
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(GestureDetector).first),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('Can drag down to activate queue card', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQueueDockScreen(brightness: Brightness.light));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Drag downwards past activation threshold
      await tester.dragFrom(const Offset(200, 400), const Offset(0, 120));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 500));

      // Check overlay appears
      expect(find.text('Antrean terpilih'), findsOneWidget);
      expect(find.text('Panggil & Proses Pasien'), findsOneWidget);
      expect(find.text('Pilih Antrean Lain'), findsOneWidget);
    });
  });
}
