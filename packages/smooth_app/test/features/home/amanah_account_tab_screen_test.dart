import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_edit_profile_drawer.dart';
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
    testWidgets(
        'Renders doctor identity header, bio, 8 settings items, and logout button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createAccountScreen());
      await tester.pumpAndSettle();

      // Doctor Profile Identity
      expect(find.text('dr. Andika Perkasa'), findsOneWidget);
      expect(find.text('Dokter Spesialis Anak'), findsOneWidget);
      expect(find.text('ID: DOC-2026-0819 • RS Amanah Sehat'), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

      // Settings Menu Items (7 items matching web after removing Perangkat Terhubung)
      expect(find.text('Akun & Identitas Dokter'), findsOneWidget);
      expect(find.text('Pengaturan Praktik & Shift'), findsOneWidget);
      expect(find.text('Privasi & Keamanan'), findsOneWidget);
      expect(find.text('Notifikasi & Pengingat'), findsOneWidget);
      expect(find.text('Data & Penyimpanan'), findsOneWidget);
      expect(find.text('Dokumen & Sertifikasi'), findsOneWidget);
      expect(find.text('Perangkat Terhubung'), findsNothing);
      expect(find.text('Bantuan & IT Support'), findsOneWidget);

      // Logout Button
      expect(find.text('Keluar dari Akun Dokter'), findsOneWidget);
    });

    testWidgets('Tapping Edit Profil opens Edit Profile drawer and updates profile',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createAccountScreen());
      await tester.pumpAndSettle();

      // Tap Edit Profil button
      await tester.tap(find.text('Edit Profil'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahEditProfileDrawer), findsOneWidget);
      expect(find.text('Edit Profil Dokter'), findsOneWidget);
      expect(find.text('✓ Terverifikasi Manajemen RS Amanah Sehat'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);

      // Tap Simpan Perubahan
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahEditProfileDrawer), findsNothing);
    });

    testWidgets('Tapping Camera icon button opens Avatar photo sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createAccountScreen());
      await tester.pumpAndSettle();

      // Tap Camera button
      await tester.tap(find.byIcon(Icons.camera_alt_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahAvatarPhotoSheet), findsOneWidget);
      expect(find.text('Ganti Foto Profil Dokter'), findsOneWidget);
      expect(find.text('Pilih dari Galeri Perangkat'), findsOneWidget);
      expect(find.text('Gunakan Foto Default'), findsOneWidget);

      // Tap Gunakan Foto Default
      await tester.tap(find.text('Gunakan Foto Default'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahAvatarPhotoSheet), findsNothing);
    });

    testWidgets('Tapping a settings menu item triggers onMenuItemTap callback',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      String? tappedItem;
      await tester.pumpWidget(createAccountScreen(
        onMenuItemTap: (String id) => tappedItem = id,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pengaturan Praktik & Shift'));
      await tester.pump();

      expect(tappedItem, 'practice');
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
      expect(find.text('Akun & Identitas Dokter'), findsOneWidget);
      expect(find.text('Keluar dari Akun Dokter'), findsOneWidget);
    });
  });
}
