import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/presentation/screen/auth_bottom_sheet_screen.dart';
import 'package:amanah_healthcare/features/authentication/presentation/screen/staff_onboarding_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthBottomSheetScreen Conditional Hero Button & Onboarding Tests', () {
    const AmanahAuthUser onboardingUser = AmanahAuthUser(
      id: 'usr-pending-1',
      fullName: 'dr. Budi Santoso',
      email: 'budi@amanah.health',
      phone: '081298765432',
      role: AmanahUserRole.doctor,
      needsOnboarding: true,
    );

    testWidgets(
      'Displays "Mulai" and "Saya sudah punya akun" when user is not authenticated',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AuthBottomSheetScreen(
              repository: _MockEmptyAuthRepo(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sehat Bersama Amanah'), findsOneWidget);
        expect(find.text('Mulai'), findsOneWidget);
        expect(find.text('Saya sudah punya akun'), findsOneWidget);
        expect(find.text('Lanjutkan Pengisian Data'), findsNothing);
      },
    );

    testWidgets(
      'Displays StaffOnboardingScreen when active session has needsOnboarding == true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AuthBottomSheetScreen(
              repository: _MockPendingOnboardingAuthRepo(onboardingUser),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Immediately shows onboarding screen
        expect(find.byType(StaffOnboardingScreen), findsOneWidget);
        expect(find.text('Pilih Peran Staf Klinik'), findsOneWidget);
      },
    );

    testWidgets(
      'Navigating back from onboarding returns to welcome screen with "Lanjutkan Pengisian Data"',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AuthBottomSheetScreen(
              repository: _MockPendingOnboardingAuthRepo(onboardingUser),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initially inside StaffOnboardingScreen
        expect(find.byType(StaffOnboardingScreen), findsOneWidget);

        // 2. Tap back on Step 0 (Semantics 'Kembali')
        expect(find.bySemanticsLabel('Kembali'), findsOneWidget);
        await tester.tap(find.bySemanticsLabel('Kembali'));
        await tester.pumpAndSettle();

        // 3. User is back on the Welcome Screen
        expect(find.byType(StaffOnboardingScreen), findsNothing);
        expect(find.text('Sehat Bersama Amanah'), findsOneWidget);

        // 4. Hero button conditionally renders "Lanjutkan Pengisian Data" instead of "Mulai"
        expect(find.text('Lanjutkan Pengisian Data'), findsOneWidget);
        expect(find.text('Mulai'), findsNothing);
        expect(find.text('Saya sudah punya akun'), findsOneWidget);

        // 5. Tapping "Lanjutkan Pengisian Data" re-opens StaffOnboardingScreen directly
        await tester.tap(find.text('Lanjutkan Pengisian Data'));
        await tester.pumpAndSettle();

        expect(find.byType(StaffOnboardingScreen), findsOneWidget);
        expect(find.text('Pilih Peran Staf Klinik'), findsOneWidget);
      },
    );

    testWidgets(
      'Preserves selected role and entered data when returning to welcome screen and resuming',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AuthBottomSheetScreen(
              repository: _MockPendingOnboardingAuthRepo(onboardingUser),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Select Dokter
        await tester.tap(find.text('Dokter'));
        await tester.pumpAndSettle();

        // 2. Advance to Step 2
        await tester.tap(find.text('Lanjut ke Data Izin'));
        await tester.pumpAndSettle();
        expect(find.text('Kredensial SIP & STR'), findsOneWidget);

        // 3. Enter SIP number
        await tester.enterText(
          find.byType(TextFormField).first,
          'SIP.777/TEST/2026',
        );
        await tester.pumpAndSettle();

        // 4. Tap "Sebelumnya" (ghost button) to return to Step 1
        final Finder sebelumnyaFinder = find.widgetWithText(
          AmanahButton,
          'Sebelumnya',
        );
        expect(sebelumnyaFinder, findsOneWidget);
        await tester.tap(sebelumnyaFinder);
        await tester.pumpAndSettle();
        expect(find.text('Pilih Peran Staf Klinik'), findsOneWidget);

        // 5. Tap header back button to return to Welcome screen
        await tester.tap(find.bySemanticsLabel('Kembali'));
        await tester.pumpAndSettle();

        // 6. Verify "Lanjutkan Pengisian Data" is present
        expect(find.text('Lanjutkan Pengisian Data'), findsOneWidget);

        // 7. Resume onboarding
        await tester.tap(find.text('Lanjutkan Pengisian Data'));
        await tester.pumpAndSettle();

        // 8. Verify Dokter role was preserved and advance to Step 2
        expect(find.text('Pilih Peran Staf Klinik'), findsOneWidget);
        await tester.tap(find.text('Lanjut ke Data Izin'));
        await tester.pumpAndSettle();

        // 9. Verify SIP number entered earlier is still intact!
        expect(find.text('SIP.777/TEST/2026'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping explicit logout icon in onboarding resets session and turns button back to "Mulai"',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AuthBottomSheetScreen(
              repository: _MockPendingOnboardingAuthRepo(onboardingUser),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(StaffOnboardingScreen), findsOneWidget);

        // Tap the explicit logout icon in the header
        expect(find.bySemanticsLabel('Keluar'), findsOneWidget);
        await tester.tap(find.bySemanticsLabel('Keluar'));
        await tester.pumpAndSettle();

        // Verify session cleared and Welcome screen displays "Mulai"
        expect(find.byType(StaffOnboardingScreen), findsNothing);
        expect(find.text('Sehat Bersama Amanah'), findsOneWidget);
        expect(find.text('Mulai'), findsOneWidget);
        expect(find.text('Lanjutkan Pengisian Data'), findsNothing);
      },
    );
  });
}

class _MockEmptyAuthRepo extends AmanahAuthRepository {
  const _MockEmptyAuthRepo();

  @override
  Future<AmanahAuthUser?> getSession() async => null;

  @override
  Future<void> signOut() async {}
}

class _MockPendingOnboardingAuthRepo extends AmanahAuthRepository {
  const _MockPendingOnboardingAuthRepo(this.user);

  final AmanahAuthUser user;

  @override
  Future<AmanahAuthUser?> getSession() async => user;

  @override
  Future<void> signOut() async {}
}
