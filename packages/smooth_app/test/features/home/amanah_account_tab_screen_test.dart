import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_edit_profile_drawer.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_account_tab_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_home_shell.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_account_identity_settings_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_data_storage_settings_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_it_chat_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_it_faq_detail_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_it_support_settings_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_privacy_security_settings_screen.dart';

void main() {
  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'doc-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Andika Perkasa',
    email: 'dokter@amanah.health',
    phone: '081234567890',
    password: 'password123',
    isEmailVerified: true,
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
      'Renders doctor identity header, bio, 4 master settings items, and logout button',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createAccountScreen());
        await tester.pumpAndSettle();

        // Doctor Profile Identity
        expect(find.text('dr. Andika Perkasa'), findsOneWidget);
        expect(
          find.text('Dokter Spesialis Anak • +62 812-3456-7890'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.edit_rounded), findsOneWidget);

        // Settings Menu Items (4 master items)
        expect(find.text('Keamanan akun & PIN'), findsOneWidget);
        expect(find.text('Akun & identitas dokter'), findsOneWidget);
        expect(find.text('Data & penyimpanan laporan'), findsOneWidget);
        expect(find.text('Bantuan teknisi IT RS'), findsOneWidget);

        // Logout Button
        expect(find.text('Keluar dari Akun Dokter'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Edit Profil opens Edit Profile drawer and updates profile',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createAccountScreen());
        await tester.pumpAndSettle();

        // Tap Edit Profil button
        await tester.tap(find.byIcon(Icons.edit_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(AmanahEditProfileDrawer), findsOneWidget);
        expect(find.text('Edit Profil Dokter'), findsOneWidget);
        expect(find.text('Terverifikasi oleh manajemen'), findsOneWidget);
        expect(find.text('Simpan Perubahan'), findsOneWidget);

        // Tap Simpan Perubahan
        await tester.tap(find.text('Simpan Perubahan'));
        await tester.pumpAndSettle();

        expect(find.byType(AmanahEditProfileDrawer), findsNothing);
      },
    );

    testWidgets('Tapping Camera / Avatar opens Avatar photo sheet', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createAccountScreen());
      await tester.pumpAndSettle();

      // Tap Avatar
      await tester.tap(find.byType(ClipOval));
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

    testWidgets('Tapping Akun & identitas dokter navigates to sub-screen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      String? tappedItem;
      await tester.pumpWidget(
        createAccountScreen(onMenuItemTap: (String id) => tappedItem = id),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Akun & identitas dokter'));
      await tester.pumpAndSettle();

      expect(tappedItem, 'account');
      expect(find.byType(AmanahAccountIdentitySettingsScreen), findsOneWidget);
      expect(find.text('Informasi pribadi dan kontak'), findsOneWidget);
      expect(find.text('Kredensial medis dan legalitas'), findsOneWidget);
      expect(find.text('NPWP'), findsOneWidget);
      expect(find.text('Nomor NIB'), findsOneWidget);
      expect(find.text('Nomor SIP'), findsNothing);
      expect(find.text('Nomor STR'), findsNothing);
      expect(find.text('Nomor KKI'), findsNothing);
      expect(find.text('Status STR/SIP'), findsNothing);
      expect(find.text('NIK'), findsNothing);
      expect(find.text('Penugasan dan fasilitas kesehatan'), findsNothing);

      // Pop back
      await tester.tap(find.bySemanticsLabel('Kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(AmanahAccountIdentitySettingsScreen), findsNothing);
    });

    testWidgets('Tapping Keamanan akun & PIN navigates to sub-screen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createAccountScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keamanan akun & PIN'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahPrivacySecuritySettingsScreen), findsOneWidget);
      expect(find.text('Kredensial dan sandi'), findsOneWidget);
      expect(find.text('Keamanan perangkat'), findsOneWidget);
      expect(find.text('PIN presensi dokter'), findsNothing);
      expect(find.text('Kunci otomatis aplikasi'), findsNothing);
      expect(find.text('Samarkan nama pasien di notifikasi'), findsNothing);

      // Pop back
      await tester.tap(find.bySemanticsLabel('Kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(AmanahPrivacySecuritySettingsScreen), findsNothing);
    });

    testWidgets('Tapping Data & penyimpanan laporan navigates to sub-screen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createAccountScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Data & penyimpanan laporan'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahDataStorageSettingsScreen), findsOneWidget);
      expect(find.text('Ruang penyimpanan'), findsOneWidget);
      expect(find.text('Sinkronisasi data'), findsNothing);
      expect(find.text('Tindakan penyimpanan'), findsOneWidget);

      // Pop back
      await tester.tap(find.bySemanticsLabel('Kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(AmanahDataStorageSettingsScreen), findsNothing);
    });

    testWidgets(
      'Tapping Bantuan teknisi IT RS navigates to IT support and flows',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createAccountScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Bantuan teknisi IT RS'));
        await tester.pumpAndSettle();

        expect(find.byType(AmanahItSupportSettingsScreen), findsOneWidget);
        expect(find.text('Laporan saya'), findsOneWidget);
        expect(find.text('Pertanyaan sering diajukan'), findsOneWidget);
        expect(find.text('Kontak helpdesk IT'), findsNothing);

        // Open FAQ Detail
        await tester.tap(
          find.text('Kamera scanner presensi tidak merespons atau blank hitam'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AmanahItFaqDetailScreen), findsOneWidget);
        expect(find.text('Langkah penyelesaian'), findsOneWidget);

        // Drag scroll to bring chat button into view
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();

        // Open Chat from button
        await tester.tap(find.text('Chat dengan tim IT'));
        await tester.pumpAndSettle();
        expect(find.byType(AmanahItChatScreen), findsOneWidget);
        expect(find.text('Helpdesk SIMRS · online'), findsOneWidget);

        // Enter message and submit
        await tester.enterText(
          find.byType(TextField),
          'Mohon cek printer label obat',
        );
        await tester.tap(find.text('Kirim'));
        await tester.pumpAndSettle();

        expect(find.text('Mohon cek printer label obat'), findsOneWidget);

        // Pop Chat
        await tester.tap(find.bySemanticsLabel('Kembali'));
        await tester.pumpAndSettle();
        expect(find.byType(AmanahItChatScreen), findsNothing);
      },
    );

    testWidgets('Tapping logout button triggers onLogout callback', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      bool logoutCalled = false;
      await tester.pumpWidget(
        createAccountScreen(onLogout: () => logoutCalled = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar dari Akun Dokter'));
      await tester.pump();

      expect(logoutCalled, isTrue);
    });

    testWidgets(
      'Bottom navigation bar Akun tab navigates to Account Tab screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          const MaterialApp(home: AmanahHomeShell(user: testUser)),
        );
        await tester.pumpAndSettle();

        // Tap Akun in bottom navigation bar
        await tester.tap(find.text('Akun'));
        await tester.pumpAndSettle();

        expect(find.byType(AmanahAccountTabScreen), findsOneWidget);
        expect(find.text('Akun & identitas dokter'), findsOneWidget);
        expect(find.text('Keluar dari Akun Dokter'), findsOneWidget);
      },
    );

    testWidgets(
      'Email banner displays "Email terverifikasi" when isEmailVerified is true',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createAccountScreen());
        await tester.pumpAndSettle();

        expect(find.text('Email terverifikasi'), findsOneWidget);
        expect(find.text('Perbarui'), findsOneWidget);
        expect(find.text('Belum verifikasi email'), findsNothing);
      },
    );

    testWidgets(
      'Email banner displays "Belum verifikasi email" when isEmailVerified is false and tapping Verifikasi email verifies it',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        const AmanahAuthUser unverifiedUser = AmanahAuthUser(
          id: 'doc-002',
          role: AmanahUserRole.doctor,
          fullName: 'dr. Andika Perkasa',
          email: 'dokter@amanah.health',
          phone: '081234567890',
          password: 'password123',
          isEmailVerified: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AmanahAccountTabScreen(
                user: unverifiedUser,
                onMenuItemTap: (_) {},
                onLogout: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Belum verifikasi email'), findsOneWidget);
        expect(find.text('Verifikasi email'), findsOneWidget);
        expect(find.text('Email terverifikasi'), findsNothing);

        // Tap Verifikasi email
        await tester.tap(find.text('Verifikasi email'));
        await tester.pumpAndSettle();

        expect(find.text('Email terverifikasi'), findsOneWidget);
        expect(find.text('Perbarui'), findsOneWidget);
        expect(find.text('Belum verifikasi email'), findsNothing);
      },
    );
  });
}
