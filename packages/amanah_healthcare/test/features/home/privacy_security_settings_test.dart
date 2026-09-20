import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_success_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_privacy_security_settings_screen.dart';

void main() {
  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'user-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Zikri Ahmad',
    email: 'zikri@amanah.co.id',
    phone: '08123456789',
    needsOnboarding: false,
  );

  testWidgets(
    'Opens password management drawer with AmanahBottomSheetScaffold and renders without overflow',
    (WidgetTester tester) async {
      // Set a standard mobile screen size
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: AmanahPrivacySecuritySettingsScreen(
            user: testUser,
            repository: AmanahAuthRepository(),
          ),
        ),
      );

      // Verify screen header
      expect(find.text('Privasi & Keamanan'), findsOneWidget);
      expect(find.text('Kata sandi akun'), findsOneWidget);

      // Tap to open password management drawer
      await tester.tap(find.text('Kata sandi akun'));
      await tester.pumpAndSettle();

      // Verify AmanahBottomSheetScaffold is present
      expect(find.byType(AmanahBottomSheetScaffold), findsOneWidget);

      // Verify drawer title and subtitle
      expect(find.text('Ubah Kata Sandi Akun'), findsOneWidget);
      expect(
        find.text(
          'Perbarui kata sandi secara berkala untuk menjaga keamanan akun',
        ),
        findsOneWidget,
      );

      // Verify field labels
      expect(find.text('Kata Sandi Saat Ini *'), findsOneWidget);
      expect(find.text('Kata Sandi Baru *'), findsOneWidget);
      expect(find.text('Konfirmasi Kata Sandi Baru *'), findsOneWidget);

      // Verify primary and forgot password buttons
      expect(find.text('Simpan Kata Sandi Baru'), findsOneWidget);
      expect(
        find.text('Lupa kata sandi saat ini? Reset dengan kode OTP'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Renders safely without overflow when keyboard is open (viewInsets = 340)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(411.4, 891.4);
      tester.view.devicePixelRatio = 1.0;
      // Simulate Android keyboard height
      tester.view.viewInsets = const FakeViewPadding(bottom: 340);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(
        const MaterialApp(
          home: AmanahPrivacySecuritySettingsScreen(
            user: testUser,
            repository: AmanahAuthRepository(),
          ),
        ),
      );

      await tester.tap(find.text('Kata sandi akun'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahBottomSheetScaffold), findsOneWidget);
      expect(find.text('Ubah Kata Sandi Akun'), findsOneWidget);
    },
  );

  testWidgets(
    'AmanahBottomSheetScaffold handles extreme constraint h=156.7 without RenderFlex overflow',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 411.4,
                height: 156.7,
                child: AmanahBottomSheetScaffold(
                  title: 'Ubah Kata Sandi Akun',
                  subtitle: 'Perbarui kata sandi akun',
                  footer: const Text('Footer'),
                  body: const Text('Body Content'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify that no RenderFlex error was thrown and content rendered cleanly
      expect(tester.takeException(), isNull);
      expect(find.text('Ubah Kata Sandi Akun'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
    },
  );

  testWidgets('AmanahSuccessDrawer renders presence-style success components', (
    WidgetTester tester,
  ) async {
    bool closed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  AmanahSuccessDrawer.show(
                    context,
                    title: 'Kata Sandi Berhasil Diperbarui!',
                    subtitle:
                        'Kata sandi akun Anda telah berhasil diperbarui dan disinkronkan.',
                    infoTitle: 'Keamanan Kredensial',
                    infoSubtitle: 'Tersinkronisasi & Terlindungi',
                    onPrimaryAction: () => closed = true,
                  );
                },
                child: const Text('Open Success'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Success'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000));

    expect(find.text('Kata Sandi Berhasil Diperbarui!'), findsOneWidget);
    expect(
      find.text('Kata sandi akun Anda telah berhasil diperbarui dan disinkronkan.'),
      findsOneWidget,
    );
    expect(find.text('Keamanan Kredensial'), findsOneWidget);
    expect(find.text('Tersinkronisasi & Terlindungi'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });
}
