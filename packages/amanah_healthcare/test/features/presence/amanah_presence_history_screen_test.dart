import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_drawers.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/amanah_presence_history_screen.dart';

const List<AttendanceRecord> kTestAttendanceRecords = <AttendanceRecord>[
  AttendanceRecord(
    id: '101',
    date: '25 Ags 2026',
    dayNumber: 25,
    time: '07:30 WIB',
    title: 'Check-in',
    location: 'Poli Penyakit Dalam - Ruang 204',
    status: AttendanceStatus.hadir,
    isLatest: true,
  ),
  AttendanceRecord(
    id: '102',
    date: '24 Ags 2026',
    dayNumber: 24,
    time: '08:18 WIB',
    title: 'Terlambat',
    location: 'Poli Spesialis Anak',
    status: AttendanceStatus.telat,
    lateDuration: 'Terlambat 18 Menit',
  ),
  AttendanceRecord(
    id: '103',
    date: '23 Ags 2026',
    dayNumber: 23,
    time: '20:00 WIB',
    title: 'Missed',
    location: 'Gedung B - IGD Utama',
    status: AttendanceStatus.missed,
  ),
  AttendanceRecord(
    id: '104',
    date: '22 Ags 2026',
    dayNumber: 22,
    time: '08:00 WIB',
    title: 'Cuti',
    location: 'Izin Resmi RS (Approved)',
    status: AttendanceStatus.cuti,
    reason: 'Simposium Kedokteran Spesialis Penyakit Dalam Tahunan di Jakarta.',
  ),
  AttendanceRecord(
    id: '105',
    date: '20 Ags 2026',
    dayNumber: 20,
    time: '07:45 WIB',
    title: 'Check-in',
    location: 'Bangsal Cempaka Lt. 3',
    status: AttendanceStatus.hadir,
  ),
  AttendanceRecord(
    id: '106',
    date: '19 Ags 2026',
    dayNumber: 19,
    time: '08:10 WIB',
    title: 'Terlambat',
    location: 'Klinik Eksekutif Suite 01',
    status: AttendanceStatus.telat,
    lateDuration: 'Terlambat 10 Menit',
  ),
  AttendanceRecord(
    id: '107',
    date: '18 Ags 2026',
    dayNumber: 18,
    time: '08:00 WIB',
    title: 'Cuti',
    location: 'Disetujui HRD Medis',
    status: AttendanceStatus.cuti,
    reason: 'Cuti Tahunan Dokter Terjadwal Semester 2.',
  ),
];

void main() {
  Widget createPresenceHistoryScreen({
    Brightness brightness = Brightness.light,
    List<AttendanceRecord>? records,
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
      home: AmanahPresenceHistoryScreen(
        records: records ?? kTestAttendanceRecords,
      ),
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

    testWidgets('Renders segmented tabs Presensi and Pasien, switches to Pasien tab', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createPresenceHistoryScreen());
      await tester.pumpAndSettle();

      // Verify both tabs exist
      expect(find.text('Presensi'), findsOneWidget);
      expect(find.text('Pasien'), findsOneWidget);

      // Tap on Pasien tab
      await tester.tap(find.text('Pasien'));
      await tester.pumpAndSettle();

      // Verify Pasien tab content is displayed
      expect(find.text('Riwayat Pasien'), findsOneWidget);
      expect(find.textContaining('Pasien Telah Selesai Konsultasi'), findsOneWidget);
      expect(find.text('Detail Pasien'), findsWidgets);
    });

    testWidgets('Opens directly to Pasien tab when initialTab is 1', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        MaterialApp(
          home: AmanahPresenceHistoryScreen(
            records: kTestAttendanceRecords,
            initialTab: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Immediately shows Pasien tab
      expect(find.text('Riwayat Pasien'), findsOneWidget);
      expect(find.text('Timeline'), findsNothing);
    });
  });
}
