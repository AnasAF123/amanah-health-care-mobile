import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_dock_hollow_glow.dart';
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

      await tester.pumpWidget(
        createQueueDockScreen(brightness: Brightness.light),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check header and title
      expect(find.text('Pilih antrean\npasien'), findsOneWidget);
      expect(find.text('Tarik antrean ke bawah untuk proses'), findsOneWidget);

      // Check default cards on rail
      expect(find.text('#01'), findsWidgets);
      expect(find.text('#02'), findsWidgets);
    });

    testWidgets('Renders Queue Dock screen and respects Dark theme', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        createQueueDockScreen(brightness: Brightness.dark),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check header and title
      expect(find.text('Pilih antrean\npasien'), findsOneWidget);
      expect(find.text('Tarik antrean ke bawah untuk proses'), findsOneWidget);

      // Verify scaffold background matches dark canvas token
      final Scaffold scaffold = tester.widget<Scaffold>(
        find.byType(Scaffold).first,
      );
      expect(scaffold.backgroundColor, const Color(0xFF060B18));

      // Verify custom painter is dark
      final CustomPaint dockPainter = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (Widget w) =>
              w is CustomPaint && w.painter is AmanahDockHollowGlowPainter,
        ),
      );
      final AmanahDockHollowGlowPainter painter =
          dockPainter.painter! as AmanahDockHollowGlowPainter;
      expect(painter.isDark, isTrue);

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

      await tester.pumpWidget(
        createQueueDockScreen(brightness: Brightness.light),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Drag left
      await tester.drag(
        find.byType(GestureDetector).first,
        const Offset(-150, 0),
      );
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

    testWidgets(
      'Rapid multiple long-presses and release do not crash with double dispose',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          createQueueDockScreen(brightness: Brightness.light),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        const Offset center = Offset(200, 350);

        // 1st Long-press
        TestGesture gesture = await tester.startGesture(center);
        await tester.pump(const Duration(milliseconds: 600));
        await gesture.up();
        await tester.pump(
          const Duration(milliseconds: 100),
        ); // Interrupted before deceleration finishes

        // 2nd Rapid Long-press immediately
        gesture = await tester.startGesture(center);
        await tester.pump(const Duration(milliseconds: 800));
        await gesture.up();
        await tester.pump(
          const Duration(milliseconds: 600),
        ); // Complete deceleration

        // 3rd Long-press
        gesture = await tester.startGesture(center);
        await tester.pump(const Duration(milliseconds: 500));
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 600));
      },
    );

    testWidgets('Can drag down to activate queue card', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        createQueueDockScreen(brightness: Brightness.light),
      );
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

    testWidgets('Can close activation overlay with genie minimize suction', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        createQueueDockScreen(brightness: Brightness.light),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Activate card
      await tester.dragFrom(const Offset(200, 400), const Offset(0, 120));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 1000));

      // Tap 'Pilih Antrean Lain'
      await tester.tap(find.text('Pilih Antrean Lain'));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 700),
      ); // Genie minimize runs & completes
      await tester.pump(
        const Duration(milliseconds: 2500),
      ); // ATM rail return choreography completes
      await tester.pump(const Duration(milliseconds: 300));

      // Should be back on main dock screen
      expect(find.text('Pilih antrean\npasien'), findsOneWidget);
    });

    testWidgets(
      'Can tap Panggil & Proses Pasien to collect card into history',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          createQueueDockScreen(brightness: Brightness.light),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Activate card
        await tester.dragFrom(const Offset(200, 400), const Offset(0, 120));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pump(const Duration(milliseconds: 1000));

        // Tap 'Panggil & Proses Pasien'
        await tester.tap(find.text('Panggil & Proses Pasien'));
        await tester.pump();
        await tester.pump(
          const Duration(milliseconds: 900),
        ); // Retreat animation
        await tester.pump(
          const Duration(milliseconds: 600),
        ); // Navigation transition

        // Navigates to history screen
        expect(find.text('Riwayat antrean diproses'), findsOneWidget);
      },
    );
  });
}
