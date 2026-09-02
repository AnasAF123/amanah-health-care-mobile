import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_home_shell.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_qr_code_widget.dart';
import 'package:smooth_app/features/presence/presentation/screen/amanah_qr_scanner_tab_screen.dart';

void main() {
  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'doc-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Andika Perkasa',
    email: 'dokter@amanah.health',
    phone: '081234567890',
    password: 'password123',
  );

  Widget createQrScreen({
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
      home: AmanahQrScannerTabScreen(
        user: testUser,
        animateLaser: false,
        onBack: onBack ?? () {},
      ),
    );
  }

  group('Amanah QR Scanner Tab Screen Tests', () {
    testWidgets(
        'Renders floating controls, reticle, and can open/close drawer modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQrScreen());
      await tester.pumpAndSettle();

      // Top Floating Controls
      expect(find.bySemanticsLabel('Kembali'), findsOneWidget);
      expect(find.bySemanticsLabel('Bantuan Presensi'), findsOneWidget);
      expect(find.bySemanticsLabel('Pilih QR dari Galeri'), findsOneWidget);
      expect(find.bySemanticsLabel('Buka Menu Presensi'), findsOneWidget);
      expect(find.bySemanticsLabel('Senter Flash'), findsOneWidget);

      // Initially drawer is closed
      expect(find.text('Tampilkan QR'), findsNothing);

      // Tap Buka Menu Presensi to open drawer modal overlay
      await tester.tap(find.bySemanticsLabel('Buka Menu Presensi'));
      await tester.pumpAndSettle();

      // Drawer Content is now visible
      expect(find.text('Praktek Poli Anak dimulai 08:00 WIB'), findsOneWidget);
      expect(find.text('Tampilkan QR'), findsOneWidget);
      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('Upload QR'), findsOneWidget);

      // Tap Chevron down to close drawer modal
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();

      // Drawer is closed
      expect(find.text('Tampilkan QR'), findsNothing);
    });

    testWidgets('Tapping Tampilkan QR displays QR Code and 5-digit code',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQrScreen());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.bySemanticsLabel('Buka Menu Presensi'));
      await tester.pumpAndSettle();

      // Tap Tampilkan QR
      await tester.tap(find.text('Tampilkan QR'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahQrCodeWidget), findsOneWidget);
      expect(find.text('84920'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);

      // Tap Salin Kode
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kode 84920 berhasil disalin'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));

      // Tap Kembali
      await tester.tap(find.text('Kembali'));
      await tester.pumpAndSettle();

      expect(find.text('Tampilkan QR'), findsOneWidget);
    });

    testWidgets('Tapping Manual opens PIN input and verifies successfully',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQrScreen());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.bySemanticsLabel('Buka Menu Presensi'));
      await tester.pumpAndSettle();

      // Tap Manual
      await tester.tap(find.text('Manual'));
      await tester.pumpAndSettle();

      expect(find.text('Verifikasi Presensi'), findsOneWidget);

      // Enter 6-digit PIN
      final Finder textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));

      await tester.enterText(textFields.at(0), '8');
      await tester.enterText(textFields.at(1), '4');
      await tester.enterText(textFields.at(2), '9');
      await tester.enterText(textFields.at(3), '2');
      await tester.enterText(textFields.at(4), '0');
      await tester.enterText(textFields.at(5), '1');
      await tester.pumpAndSettle();

      // Tap Verifikasi Presensi button explicitly
      await tester.tap(find.text('Verifikasi Presensi'));
      await tester.pumpAndSettle();

      // Dismiss success sheet
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();

      expect(find.text('Presensi Berhasil!'), findsNothing);
    });

    testWidgets('Tapping Upload QR switches to dropzone and simulates scan',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQrScreen());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.bySemanticsLabel('Buka Menu Presensi'));
      await tester.pumpAndSettle();

      // Tap Upload QR
      await tester.tap(find.text('Upload QR'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih file QR atau seret ke sini'), findsOneWidget);
      expect(find.text('Format PNG, JPG, JPEG (Maks. 5MB)'), findsOneWidget);

      // Tap Dropzone to simulate upload
      await tester.tap(find.text('Pilih file QR atau seret ke sini'));
      await tester.pumpAndSettle();

      expect(find.text('Presensi Berhasil!'), findsOneWidget);
    });

    testWidgets('Tapping Flashlight button toggles flash state',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQrScreen());
      await tester.pumpAndSettle();

      // Tap Flashlight button
      await tester.tap(find.bySemanticsLabel('Senter Flash'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);

      // Tap again to toggle off
      await tester.tap(find.bySemanticsLabel('Senter Flash'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
    });

    testWidgets('Tapping Ubah Kamera button toggles camera switch state',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQrScreen());
      await tester.pumpAndSettle();

      // Find Ubah Kamera button
      expect(find.bySemanticsLabel('Ubah Kamera'), findsOneWidget);
      expect(find.byIcon(Icons.cameraswitch_rounded), findsOneWidget);

      // Tap Ubah Kamera
      await tester.tap(find.bySemanticsLabel('Ubah Kamera'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cameraswitch_rounded), findsOneWidget);
    });

    testWidgets('Tapping Help button opens help dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createQrScreen());
      await tester.pumpAndSettle();

      // Tap Help button
      await tester.tap(find.bySemanticsLabel('Bantuan Presensi'));
      await tester.pumpAndSettle();

      expect(find.text('Panduan Presensi'), findsOneWidget);
      expect(find.text('Mengerti'), findsOneWidget);

      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();

      expect(find.text('Panduan Presensi'), findsNothing);
    });

    testWidgets('Bottom navigation bar center scan button navigates to QR Scanner',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        const MaterialApp(
          home: AmanahHomeShell(user: testUser),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap center scan button
      await tester.tap(find.bySemanticsLabel('Pindai QR Presensi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AmanahQrScannerTabScreen), findsOneWidget);
    });
  });
}
