import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_stepper_progress.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/social_auth_button.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/sign_up_content.dart';

void main() {
  group('SignUpContent 3-Step Stepper Tests', () {
    late GlobalKey<FormState> formKey;
    late TextEditingController fullNameController;
    late TextEditingController emailController;
    late TextEditingController phoneController;
    late TextEditingController passwordController;
    late TextEditingController confirmPasswordController;

    setUp(() {
      formKey = GlobalKey<FormState>();
      fullNameController = TextEditingController();
      emailController = TextEditingController();
      phoneController = TextEditingController();
      passwordController = TextEditingController();
      confirmPasswordController = TextEditingController();
    });

    tearDown(() {
      fullNameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    });

    Widget buildTestHarness({
      VoidCallback? onGoogleAuth,
      VoidCallback? onCreateAccount,
      VoidCallback? onSwitchToSignIn,
      int initialStep = 0,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SignUpContent(
              formKey: formKey,
              fullNameController: fullNameController,
              emailController: emailController,
              phoneController: phoneController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              onGoogleAuth: onGoogleAuth ?? () {},
              onCreateAccount: onCreateAccount ?? () {},
              onSwitchToSignIn: onSwitchToSignIn ?? () {},
              initialStep: initialStep,
            ),
          ),
        ),
      );
    }

    testWidgets('Initial render is on Step 1 with Google Auth button visible and ultra-minimalist progress bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestHarness());
      await tester.pumpAndSettle();

      expect(find.byType(AuthStepperProgress), findsOneWidget);
      expect(find.bySemanticsLabel('Langkah 1 dari 3'), findsOneWidget);
      // No text percentage or title labels
      expect(find.text('33%'), findsNothing);
      expect(find.bySemanticsLabel('Nama lengkap'), findsOneWidget);
      expect(find.bySemanticsLabel('Email'), findsOneWidget);
      expect(find.text('Lanjutkan'), findsOneWidget);
      expect(find.byType(SocialAuthButton), findsOneWidget);
      expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
    });

    testWidgets('Step 1 validation blocks transition if name/email are empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestHarness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();

      // Still on step 1 due to validation failure
      expect(find.bySemanticsLabel('Langkah 1 dari 3'), findsOneWidget);
      expect(find.text('Nama lengkap wajib diisi.'), findsOneWidget);
    });

    testWidgets(
      'Manual flow: entering valid name and email transitions to Step 2 where Google button is hidden',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestHarness());
        await tester.pumpAndSettle();

        fullNameController.text = 'Budi Santoso';
        emailController.text = 'budi@amanah.id';
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lanjutkan'));
        await tester.pumpAndSettle();

        // Should now be on Step 2
        expect(find.bySemanticsLabel('Langkah 2 dari 3'), findsOneWidget);
        expect(find.bySemanticsLabel('Nomor telepon'), findsOneWidget);
        expect(find.text('Kembali ke Data Diri'), findsOneWidget);
        // Social Google button must NOT be present on step 2
        expect(find.byType(SocialAuthButton), findsNothing);
      },
    );

    testWidgets(
      'Step 2 validation blocks transition if phone number is empty',
      (WidgetTester tester) async {
        fullNameController.text = 'Budi Santoso';
        emailController.text = 'budi@amanah.id';

        await tester.pumpWidget(buildTestHarness(initialStep: 1));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lanjutkan'));
        await tester.pumpAndSettle();

        // Still on step 2
        expect(find.bySemanticsLabel('Langkah 2 dari 3'), findsOneWidget);
        expect(find.text('Nomor telepon wajib diisi.'), findsOneWidget);
      },
    );

    testWidgets(
      'Back button on Step 2 preserves user data and returns to Step 1',
      (WidgetTester tester) async {
        fullNameController.text = 'Budi Santoso';
        emailController.text = 'budi@amanah.id';
        phoneController.text = '08123456789';

        await tester.pumpWidget(buildTestHarness(initialStep: 1));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kembali ke Data Diri'));
        await tester.pumpAndSettle();

        // Now back on Step 1
        expect(find.bySemanticsLabel('Langkah 1 dari 3'), findsOneWidget);
        expect(fullNameController.text, equals('Budi Santoso'));
        expect(emailController.text, equals('budi@amanah.id'));
      },
    );

    testWidgets(
      'Step 3 displays password fields and invokes onCreateAccount when valid',
      (WidgetTester tester) async {
        fullNameController.text = 'Budi Santoso';
        emailController.text = 'budi@amanah.id';
        phoneController.text = '08123456789';
        passwordController.text = 'Amanah123!';
        confirmPasswordController.text = 'Amanah123!';

        bool accountCreated = false;
        await tester.pumpWidget(
          buildTestHarness(
            initialStep: 2,
            onCreateAccount: () {
              accountCreated = true;
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Langkah 3 dari 3'), findsOneWidget);
        expect(find.bySemanticsLabel('Password'), findsOneWidget);
        expect(find.bySemanticsLabel('Konfirmasi password'), findsOneWidget);
        expect(find.text('Daftar'), findsOneWidget);
        expect(find.text('Kembali ke Nomor Telepon'), findsOneWidget);

        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle();

        expect(accountCreated, isTrue);
      },
    );

    testWidgets(
      'Google sign-up intercept: does not inject hardcoded credentials, leaves fields empty, hides Google button, and advances directly to Step 2',
      (WidgetTester tester) async {
        bool googleAuthInvoked = false;
        await tester.pumpWidget(
          buildTestHarness(
            onGoogleAuth: () {
              googleAuthInvoked = true;
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lanjutkan dengan Google'));
        await tester.pumpAndSettle();

        expect(googleAuthInvoked, isTrue);
        // Controllers remain empty without arbitrary hardcoded values
        expect(fullNameController.text, isEmpty);
        expect(emailController.text, isEmpty);

        // Transitions directly to Step 2
        expect(find.bySemanticsLabel('Langkah 2 dari 3'), findsOneWidget);
        expect(find.text('Mendaftar menggunakan akun Google'), findsOneWidget);
        expect(find.byType(SocialAuthButton), findsNothing);
      },
    );
  });
}
