import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_input_field.dart';
import 'package:smooth_app/features/authentication/presentation/components/password_input_field.dart';
import 'package:smooth_app/features/authentication/presentation/organisms/sign_in_content.dart';

void main() {
  group('Production Authentication Error-Handling Paradigm Tests', () {
    testWidgets(
      'Does not render error and both fields are in normal state initially',
      (WidgetTester tester) async {
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        final TextEditingController identifierController =
            TextEditingController();
        final TextEditingController passwordController =
            TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SignInContent(
                  formKey: formKey,
                  identifierController: identifierController,
                  passwordController: passwordController,
                  onForgotPassword: () {},
                  onEmailAuth: () {},
                  onGoogleAuth: () {},
                  onSwitchToSignUp: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(AuthInlineValidationMessage), findsNothing);
        expect(find.byType(AuthInputField), findsNWidgets(2));
        expect(find.byType(PasswordInputField), findsOneWidget);
        expect(find.text('Masuk'), findsOneWidget);

        // Verify neither field has error
        final Iterable<AuthInputField> inputs = tester
            .widgetList<AuthInputField>(find.byType(AuthInputField));
        for (final AuthInputField input in inputs) {
          expect(input.hasError, isFalse);
        }
      },
    );

    testWidgets(
      'Applies error state to both credential fields simultaneously and renders generic non-revealing inline validation feedback',
      (WidgetTester tester) async {
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        final TextEditingController identifierController =
            TextEditingController(text: 'user@example.com');
        final TextEditingController passwordController = TextEditingController(
          text: 'secret123',
        );
        const String genericErrorMessage =
            'Email atau password yang Anda masukkan salah. Silakan periksa kembali.';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SignInContent(
                  formKey: formKey,
                  identifierController: identifierController,
                  passwordController: passwordController,
                  hasCredentialError: true,
                  credentialErrorMessage: genericErrorMessage,
                  onForgotPassword: () {},
                  onEmailAuth: () {},
                  onGoogleAuth: () {},
                  onSwitchToSignUp: () {},
                ),
              ),
            ),
          ),
        );

        // 1. Contextual inline validation message is rendered
        expect(find.byType(AuthInlineValidationMessage), findsOneWidget);
        expect(find.text(genericErrorMessage), findsOneWidget);
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

        // 2. Security requirement: DOES NOT reveal which specific field failed
        expect(find.textContaining('dokter@amanah.health'), findsNothing);
        expect(find.textContaining('staff@amanah.health'), findsNothing);
        expect(find.textContaining('dokter123'), findsNothing);
        expect(find.textContaining('Coba gunakan'), findsNothing);

        // 3. Both relevant credential fields receive error state simultaneously
        final Iterable<AuthInputField> inputs = tester
            .widgetList<AuthInputField>(find.byType(AuthInputField));
        expect(inputs.length, 2);
        for (final AuthInputField input in inputs) {
          expect(input.hasError, isTrue);
        }

        // 4. Vertical layout check: Password field -> Inline validation feedback -> Lupa password? -> Masuk
        final double passwordY = tester
            .getTopLeft(find.byType(PasswordInputField))
            .dy;
        final double errorMessageY = tester
            .getTopLeft(find.text(genericErrorMessage))
            .dy;
        final double forgotPasswordY = tester
            .getTopLeft(find.text('Lupa password?'))
            .dy;
        final double masukButtonY = tester.getTopLeft(find.text('Masuk')).dy;

        expect(passwordY, lessThan(errorMessageY));
        expect(errorMessageY, lessThan(forgotPasswordY));
        expect(forgotPasswordY, lessThan(masukButtonY));
      },
    );

    testWidgets(
      'Typing in credential fields invokes onCredentialChanged to clear error state',
      (WidgetTester tester) async {
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();
        final TextEditingController identifierController =
            TextEditingController(text: 'wrong@amanah.health');
        final TextEditingController passwordController = TextEditingController(
          text: 'wrong123',
        );
        bool cleared = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SignInContent(
                  formKey: formKey,
                  identifierController: identifierController,
                  passwordController: passwordController,
                  hasCredentialError: true,
                  credentialErrorMessage:
                      'Email atau password yang Anda masukkan salah. Silakan periksa kembali.',
                  onCredentialChanged: () => cleared = true,
                  onForgotPassword: () {},
                  onEmailAuth: () {},
                  onGoogleAuth: () {},
                  onSwitchToSignUp: () {},
                ),
              ),
            ),
          ),
        );

        // Enter text into identifier field
        await tester.enterText(
          find.byType(TextFormField).first,
          'correct@amanah.health',
        );
        expect(cleared, isTrue);
      },
    );
  });
}
