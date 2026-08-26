import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_account_tab_screen.dart';
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

  Widget createAccountScreen({
    ValueChanged<String>? onMenuItemTap,
    VoidCallback? onLogout,
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
      home: Scaffold(
        body: AmanahAccountTabScreen(
          user: testUser,
          onMenuItemTap: onMenuItemTap ?? (_) {},
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  group('Amanah Account Tab Screen Tests', () {
    testWidgets('Renders doctor identity header, menu items, and logout button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createAccountScreen());
      await tester.pumpAndSettle();

      // Doctor Profile Identity
      expect(find.text('dr. Andika Perkasa'), findsOneWidget);
      expect(find.text('Dokter Spesialis Anak'), findsOneWidget);
      expect(find.text('ID: DOC-2026-0819'), findsOneWidget);
      expect(find.text('RS Amanah Sehat'), findsOneWidget);

      // Settings Menu Items
      expect(find.text('Surat Izin Praktek (SIP)'), findsOneWidget);
      expect(find.text('SIP: 446/1029/DS/2024'), findsOneWidget);
      expect(find.text('Spesialisasi & Sertifikasi'), findsOneWidget);
      expect(find.text('Ikatan Dokter Anak Indonesia (IDAI)'), findsOneWidget);
      expect(find.text('Keamanan & PIN Presensi'), findsOneWidget);
      expect(find.text('Privasi Data Rekam Medis'), findsOneWidget);
      expect(find.text('Pusat Bantuan & IT Support'), findsOneWidget);

      // Logout Button
      expect(find.text('Keluar dari Akun Dokter'), findsOneWidget);
    });

    testWidgets('Tapping a menu item triggers onMenuItemTap callback',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      String? tappedItem;
      await tester.pumpWidget(createAccountScreen(
        onMenuItemTap: (String id) => tappedItem = id,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Surat Izin Praktek (SIP)'));
      await tester.pump();

      expect(tappedItem, 'sip');
    });

    testWidgets('Tapping logout button triggers onLogout callback',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      bool logoutCalled = false;
      await tester.pumpWidget(createAccountScreen(
        onLogout: () => logoutCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar dari Akun Dokter'));
      await tester.pump();

      expect(logoutCalled, isTrue);
    });

    testWidgets('Bottom navigation bar Akun tab navigates to Account Tab screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        const MaterialApp(
          home: AmanahHomeShell(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Akun in bottom navigation bar
      await tester.tap(find.text('Akun'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahAccountTabScreen), findsOneWidget);
      expect(find.text('Surat Izin Praktek (SIP)'), findsOneWidget);
      expect(find.text('Keluar dari Akun Dokter'), findsOneWidget);
    });
  });
}
