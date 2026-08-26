import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_bottom_navigation_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_home_app_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_quick_access_section.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_schedule_card_stack.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_today_activity_section.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_home_shell.dart';

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
    testWidgets('Renders all Home screen components in Light mode',
        (WidgetTester tester) async {
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
      expect(find.text('Jadwal Hari Ini'), findsOneWidget);
      expect(find.text('07:30 - 11:30'), findsOneWidget);
      expect(find.text('Poli Anak'), findsOneWidget);
      expect(find.text('16 / 30'), findsOneWidget);

      // Check Quick Access Section
      expect(find.byType(AmanahQuickAccessSection), findsOneWidget);
      expect(find.text('Presensi'), findsOneWidget);
      expect(find.text('Jadwal Saya'), findsOneWidget);
      expect(find.text('Cari Visit'), findsOneWidget);
      expect(find.text('Kartu ID'), findsOneWidget);

      // Check Today's Activity Section
      expect(find.byType(AmanahTodayActivitySection), findsOneWidget);
      expect(find.text('Aktivitas hari ini'), findsOneWidget);
      expect(find.text('Antrean Aktif'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
      expect(find.text('Total Selesai'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);

      // Check Bottom Navigation Bar
      expect(find.byType(AmanahBottomNavigationBar), findsOneWidget);
    });

    testWidgets('Quick action Cari Visit shows toast feedback',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cari Visit'));
      await tester.pump();

      expect(find.text('Membuka menu Cari Visit Pasien'), findsOneWidget);
    });

    testWidgets('Tapping notification bell navigates to Notification tab',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.notifications_none_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Notifikasi'), findsWidgets);
    });

    testWidgets('Tapping dismiss button on schedule card cycles schedule',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      expect(find.text('Jadwal Hari Ini'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Jadwal Siang'), findsOneWidget);
    });

    testWidgets('Swiping left on schedule card stack switches to next card',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      expect(find.text('Jadwal Hari Ini'), findsOneWidget);

      // Drag horizontally to the left by -120px
      await tester.drag(find.byType(AmanahScheduleCardStack), const Offset(-120, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Jadwal Siang'), findsOneWidget);
    });
  });
}
