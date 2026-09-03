import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_bottom_navigation_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_home_app_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_quick_access_section.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_schedule_card_stack.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_today_activity_section.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_home_shell.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';

void main() {
  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'doc-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Andika Perkasa',
    email: 'dokter@amanah.health',
    phone: '081234567890',
    password: 'password123',
  );

  Widget createHomeScreen({Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A44FF),
          brightness: brightness,
        ),
      ),
      home: const AmanahHomeShell(user: testUser),
    );
  }

  group('Amanah Home Screen Tests', () {
    testWidgets('Renders all Home screen components in Light mode', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createHomeScreen(brightness: Brightness.light));
      await tester.pumpAndSettle();

      // Check App Bar
      expect(find.byType(AmanahHomeAppBar), findsOneWidget);
      expect(find.text('dr. Andika Perkasa'), findsOneWidget);
      expect(find.text('Selamat Pagi'), findsOneWidget);

      // Check Schedule Card Stack
      expect(find.byType(AmanahScheduleCardStack), findsOneWidget);
      expect(find.text('Jadwal Hari Ini'), findsWidgets);
      expect(find.text('Sesi Pagi'), findsOneWidget);
      expect(find.text('07:00 - 11:00 WIB'), findsOneWidget);
      expect(find.text('Poli Gigi & Mulut'), findsOneWidget);
      expect(find.text('2 Pasien'), findsOneWidget);
      expect(find.text('Terdaftar'), findsWidgets);

      // Check Quick Access Section
      expect(find.byType(AmanahQuickAccessSection), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Jadwal Saya'), findsOneWidget);
      expect(find.text('Pilih Antrean'), findsOneWidget);
      expect(find.text('Kartu ID'), findsOneWidget);

      // Check Today's Activity Section (reflects live total booked patients: 4)
      expect(find.byType(AmanahTodayActivitySection), findsOneWidget);
      expect(find.text('Aktivitas hari ini'), findsOneWidget);
      expect(find.text('Antrean Aktif'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Total Selesai'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);

      // Check Bottom Navigation Bar
      expect(find.byType(AmanahBottomNavigationBar), findsOneWidget);
    });

    testWidgets(
      'Tapping History quick action navigates to Riwayat Presensi screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createHomeScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('History'));
        await tester.pumpAndSettle();

        expect(find.text('Riwayat Presensi'), findsOneWidget);
        expect(find.text('Timeline'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Jadwal Saya quick action navigates to Schedule Overview screen with capacity gauge',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createHomeScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Jadwal Saya'));
        await tester.pumpAndSettle();

        expect(find.text('Jadwal Praktik'), findsOneWidget);
        expect(find.text('Lihat jadwal'), findsOneWidget);
        expect(find.text('Kapasitas Hari Ini'), findsWidgets);
      },
    );

    testWidgets('Quick action Pilih Antrean opens queue dock screen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pilih Antrean'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Pilih antrean'), findsWidgets);
      expect(find.text('Tarik antrean ke bawah untuk proses'), findsOneWidget);
    });

    testWidgets('Tapping Kartu ID quick action opens Doctor ID Card screen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'PlusJakartaSans',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0A44FF),
            ),
          ),
          home: const AmanahHomeShell(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kartu ID'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 360));

      expect(find.text('Kartu Identitas'), findsOneWidget);
      expect(find.text('Bagikan'), findsOneWidget);
      expect(find.text('Unduh PDF'), findsOneWidget);
      expect(find.text('RS AMANAH SEHAT'), findsWidgets);
    });

    testWidgets(
      'Tapping notification bell button in app bar navigates to Notification screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createHomeScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.notifications_none_rounded).first);
        await tester.pumpAndSettle();

        expect(find.text('Notifikasi'), findsWidgets);
      },
    );

    testWidgets('Tapping dismiss button on schedule card cycles schedule', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sesi Pagi'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Sesi Siang'), findsOneWidget);
    });

    testWidgets('Swiping left on schedule card stack switches to next card', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sesi Pagi'), findsOneWidget);

      // Drag horizontally to the left by -120px
      await tester.drag(
        find.byType(AmanahScheduleCardStack),
        const Offset(-120, 0),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Sesi Siang'), findsOneWidget);
    });

    testWidgets(
      'Tapping schedule card navigates directly to Doctor Practice Schedule overview',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createHomeScreen());
        await tester.pumpAndSettle();

        // Tap on the front schedule card (not on the dismiss button)
        await tester.tap(find.text('07:00 - 11:00 WIB'));
        await tester.pumpAndSettle();

        // Should have navigated to the Doctor Practice Schedule overview
        expect(find.text('Jadwal Praktik'), findsOneWidget);
        expect(find.text('Kapasitas Hari Ini'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Detail on Aktivitas hari ini navigates to Pilih Antrean queue dock',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createHomeScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Detail'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.textContaining('Pilih antrean'), findsWidgets);
        expect(
          find.text('Tarik antrean ke bawah untuk proses'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Single schedule card in stack maintains exact card height (172.0) and does not stretch',
      (WidgetTester tester) async {
        const DoctorSchedule singleSchedule = DoctorSchedule(
          id: 'test-single',
          title: 'Jadwal Hari Ini',
          sessionType: 'Pagi',
          date: '03 Sep 2026',
          time: '08:00 - 12:00 WIB',
          poli: 'Poli Anak',
          room: 'Ruang 102',
          slotCount: '5 Pasien',
          slotText: '5 Pasien',
          badge: 'Terdaftar',
          badgeVariant: AmanahBadgeVariant.primary,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AmanahScheduleCardStack(
                schedules: <DoctorSchedule>[singleSchedule],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder cardFinder = find.byType(AmanahScheduleCard);
        expect(cardFinder, findsOneWidget);
        final Size cardSize = tester.getSize(cardFinder);
        expect(cardSize.height, 172.0);
      },
    );
  });
}
