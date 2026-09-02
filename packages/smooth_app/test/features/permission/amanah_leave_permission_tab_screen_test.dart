import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_home_shell.dart';
import 'package:smooth_app/features/permission/data/amanah_permission_store.dart';
import 'package:smooth_app/features/permission/presentation/components/amanah_permission_detail_drawer.dart';
import 'package:smooth_app/features/permission/presentation/components/amanah_permission_form_drawer.dart';
import 'package:smooth_app/features/permission/presentation/screen/amanah_leave_permission_tab_screen.dart';

void main() {
  setUp(() {
    AmanahPermissionStore.instance.reset();
  });

  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'doc-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Rayhan Pratama, Sp.A',
    email: 'rayhan@amanah.health',
    phone: '081234567890',
    password: 'password123',
  );

  Widget createPermissionScreen({
    VoidCallback? onBack,
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
      home: AmanahLeavePermissionTabScreen(onBack: onBack),
    );
  }

  group('Amanah Leave Permission Tab Screen Tests', () {
    testWidgets(
      'Renders header, filter chips with pending badge, and initial cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createPermissionScreen());
        await tester.pumpAndSettle();

        // 1. Header
        expect(find.text('Perizinan'), findsOneWidget);
        expect(find.byIcon(Icons.add_rounded), findsOneWidget);

        // 2. Filter chips & Status Badges
        expect(find.text('Semua'), findsOneWidget);
        expect(find.text('Menunggu'), findsWidgets);
        expect(find.text('Disetujui'), findsWidgets);
        expect(find.text('Ditolak'), findsWidgets);
        expect(find.text('Dibatalkan'), findsWidgets);

        // Initial pending count badge (2 items: perm_001 and perm_002)
        expect(find.text('2'), findsWidgets);

        // 3. Initial Visible Cards
        expect(find.text('Seminar / Simposium'), findsOneWidget);
        expect(find.text('Urusan Keluarga'), findsOneWidget);
        expect(find.text('Cuti Tahunan'), findsWidgets);
        expect(find.text('Tugas Luar RS'), findsOneWidget);

        // Scroll to reveal remaining items
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(find.text('Izin Sakit'), findsOneWidget);
      },
    );

    testWidgets('Filter by Menunggu displays only pending items', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createPermissionScreen());
      await tester.pumpAndSettle();

      // Tap 'Menunggu' filter chip (first widget with 'Menunggu')
      await tester.tap(find.text('Menunggu').first);
      await tester.pumpAndSettle();

      expect(find.text('Seminar / Simposium'), findsOneWidget);
      expect(find.text('Urusan Keluarga'), findsOneWidget);
      expect(find.text('Tugas Luar RS'), findsNothing);
      expect(find.text('Izin Sakit'), findsNothing);
    });

    testWidgets('Tapping card opens Detail Drawer with full info', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createPermissionScreen());
      await tester.pumpAndSettle();

      // Tap first card (Seminar / Simposium)
      await tester.tap(find.text('Seminar / Simposium').first);
      await tester.pumpAndSettle();

      expect(find.byType(AmanahPermissionDetailDrawer), findsOneWidget);
      expect(find.text('Detail perizinan'), findsOneWidget);
      expect(find.text('Durasi'), findsOneWidget);
      expect(find.text('3 Hari Kerja'), findsOneWidget);
      expect(find.text('Pesan / Alasan Perizinan'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AmanahPermissionDetailDrawer),
          matching: find.text(
            'Menghadiri Kongres Nasional Ilmu Kesehatan Anak (KONIKA) XIX di Bali sebagai pembicara panelis.',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Dokter Pengganti'), findsOneWidget);
      expect(find.text('dr. Budi Santoso, Sp.A'), findsOneWidget);
      expect(find.text('Edit Izin'), findsNothing);
      expect(find.text('Batalkan'), findsNothing);

      await tester.tap(find.byTooltip('Aksi perizinan'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Izin'), findsOneWidget);
      expect(find.text('Batalkan'), findsOneWidget);
    });

    testWidgets('Tapping Plus button opens Form Drawer to create permission', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createPermissionScreen());
      await tester.pumpAndSettle();

      // Tap '+' button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahPermissionFormDrawer), findsOneWidget);
      expect(find.text('Pengajuan izin baru'), findsOneWidget);
      expect(find.text('Subjek Perizinan *'), findsOneWidget);
      expect(find.text('Rentang Tanggal *'), findsOneWidget);
      expect(find.text('Pesan / Alasan Perizinan *'), findsOneWidget);
      expect(find.text('Kirim Pengajuan Izin'), findsOneWidget);

      // Enter reason
      await tester.enterText(
        find.widgetWithText(TextField, 'Tuliskan keterangan keperluan izin...'),
        'Mengikuti pelatihan kegawatdaruratan anak di RS Rujukan.',
      );
      await tester.pumpAndSettle();

      // Tap Kirim Pengajuan Izin
      await tester.tap(find.text('Kirim Pengajuan Izin'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahPermissionFormDrawer), findsNothing);
    });

    testWidgets(
      'Bottom navigation bar navigates to Perizinan tab in HomeShell',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          const MaterialApp(home: AmanahHomeShell(user: testUser)),
        );
        await tester.pumpAndSettle();

        // Bottom bar tab labeled 'Perizinan'
        expect(find.text('Perizinan'), findsOneWidget);

        // Tap 'Perizinan' in bottom navigation bar
        await tester.tap(find.text('Perizinan'));
        await tester.pumpAndSettle();

        expect(find.byType(AmanahLeavePermissionTabScreen), findsOneWidget);
        expect(find.text('Perizinan'), findsWidgets);
      },
    );
  });
}
