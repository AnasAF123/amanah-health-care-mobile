import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_presence_drawers.dart';
import 'package:smooth_app/features/presence/presentation/screen/amanah_presence_history_screen.dart';

void main() {
  Widget createPresenceHistoryScreen({
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A44FF),
          brightness: brightness,
        ),
      ),
      home: const AmanahPresenceHistoryScreen(),
    );
  }

  group('Amanah Presence History Screen Tests', () {
    testWidgets(
      'Renders header, timeline, distribution bar, metrics, and records',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createPresenceHistoryScreen());
        await tester.pumpAndSettle();

        // Check Header
        expect(find.text('Riwayat Presensi'), findsOneWidget);

        // Check Timeline Title & Info Icon
        expect(find.text('Timeline'), findsOneWidget);

        // Check Date Ticks
        expect(find.text('01 Ags'), findsOneWidget);
        expect(find.text('08 Ags'), findsOneWidget);
        expect(find.text('15 Ags'), findsOneWidget);
        expect(find.text('22 Ags'), findsOneWidget);
        expect(find.text('31 Ags'), findsOneWidget);

        // Check Metrics
        expect(find.text('Total jam kerja · Bulan ini'), findsOneWidget);
        expect(find.text('168 hr'), findsOneWidget);
        expect(find.text('(21 hari)'), findsOneWidget);

        // Check Legends
        expect(find.text('Hadir'), findsWidgets);
        expect(find.text('Telat'), findsWidgets);
        expect(find.text('Missed'), findsWidgets);
        expect(find.text('Cuti'), findsWidgets);

        // Check Attendance Records
        expect(find.text('25 Ags 2026'), findsOneWidget);
        expect(find.text('07:30 WIB'), findsOneWidget);
        expect(find.text('Check-in'), findsWidgets);
        expect(find.text('Poli Penyakit Dalam - Ruang 204'), findsOneWidget);
      },
    );

    testWidgets('Tapping info icon opens Keterangan Timeline Presensi drawer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createPresenceHistoryScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahPresenceInfoDrawer), findsOneWidget);
      expect(find.text('Keterangan Timeline Presensi'), findsOneWidget);
      expect(find.text('Tutup Informasi'), findsNothing);
    });

    testWidgets(
      'Tapping Lihat Alasan on cuti record opens Leave Reason drawer',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createPresenceHistoryScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lihat Alasan').first);
        await tester.pumpAndSettle();

        expect(find.byType(AmanahPresenceLeaveReasonDrawer), findsOneWidget);
        expect(find.text('Alasan Cuti Dokter'), findsOneWidget);
        expect(find.text('Disetujui'), findsOneWidget);
        expect(find.text('Tutup'), findsNothing);
      },
    );

    testWidgets(
      'Tapping filter button opens Filter drawer and applying filter updates list',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createPresenceHistoryScreen());
        await tester.pumpAndSettle();

        // Tap filter button
        await tester.tap(find.byIcon(Icons.tune_rounded).first);
        await tester.pumpAndSettle();

        expect(find.byType(AmanahPresenceFilterDrawer), findsOneWidget);
        expect(find.text('Filter Presensi'), findsOneWidget);
        expect(find.text('Poli Anak'), findsOneWidget);

        // Select Poli Anak
        await tester.tap(find.text('Poli Anak'));
        await tester.pumpAndSettle();

        // Apply Filter
        await tester.tap(find.text('Terapkan Filter'));
        await tester.pumpAndSettle();

        // Expect Filter banner
        expect(find.text('Filter: '), findsOneWidget);
        expect(find.text('Anak'), findsOneWidget);
      },
    );

    testWidgets('Empty state displays when no records match filter, and allows reset', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createPresenceHistoryScreen());
      await tester.pumpAndSettle();

      // Open filter
      await tester.tap(find.byIcon(Icons.tune_rounded).first);
      await tester.pumpAndSettle();

      // Select 'Poli Anak' and 'Missed' (0 matches)
      await tester.tap(find.text('Poli Anak'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AmanahPresenceFilterDrawer),
          matching: find.text('Missed'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      expect(find.text('Tidak Ada Data Presensi'), findsOneWidget);
      expect(find.text('Ubah Filter'), findsOneWidget);
      expect(find.text('Reset Filter'), findsOneWidget);

      // Tap Reset Filter
      await tester.tap(find.text('Reset Filter'));
      await tester.pumpAndSettle();

      // Records should reappear
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('Tidak Ada Data Presensi'), findsNothing);
    });
  });
}
