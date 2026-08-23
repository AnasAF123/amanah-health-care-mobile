import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/presentation/components/account_switch_action.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_divider.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_input_field.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_primary_button.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_status_message.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_text_action.dart';
import 'package:smooth_app/features/authentication/presentation/components/password_input_field.dart';
import 'package:smooth_app/features/authentication/presentation/components/social_auth_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class SignInContent extends StatelessWidget {
  const SignInContent({
    required this.formKey,
    required this.identifierController,
    required this.passwordController,
    required this.onForgotPassword,
    required this.onAppleAuth,
    required this.onEmailAuth,
    required this.onGoogleAuth,
    required this.onSwitchToSignUp,
    super.key,
    this.loadingProvider,
    this.statusMessage,
    this.statusIsError = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;
  final VoidCallback onAppleAuth;
  final VoidCallback onEmailAuth;
  final VoidCallback onGoogleAuth;
  final VoidCallback onSwitchToSignUp;
  final AuthProviderType? loadingProvider;
  final String? statusMessage;
  final bool statusIsError;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (statusMessage != null) ...<Widget>[
            AuthStatusMessage(message: statusMessage!, isError: statusIsError),
            const SizedBox(height: LARGE_SPACE),
          ],
          AuthInputField(
            label: 'Email atau nomor telepon',
            hintText: 'Masukkan email atau nomor telepon',
            controller: identifierController,
            leadingIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[
              AutofillHints.email,
              AutofillHints.telephoneNumber,
            ],
            validator: _validateIdentifier,
          ),
          const SizedBox(height: LARGE_SPACE),
          PasswordInputField(
            label: 'Password',
            hintText: 'Masukkan password',
            controller: passwordController,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.password],
            validator: _validatePassword,
            onFieldSubmitted: (_) => onEmailAuth(),
          ),
          const SizedBox(height: SMALL_SPACE),
          AuthTextAction(label: 'Lupa password?', onPressed: onForgotPassword),
          const SizedBox(height: MEDIUM_SPACE),
          AuthPrimaryButton(
            label: 'Masuk',
            loading: loadingProvider == AuthProviderType.email,
            onPressed: onEmailAuth,
          ),
          const SizedBox(height: MEDIUM_SPACE),
          SocialAuthButton(
            provider: AuthProviderType.apple,
            label: 'Lanjutkan dengan Apple',
            loading: loadingProvider == AuthProviderType.apple,
            onPressed: onAppleAuth,
          ),
          const SizedBox(height: LARGE_SPACE),
          const AuthDivider(),
          const SizedBox(height: LARGE_SPACE),
          SocialAuthButton(
            provider: AuthProviderType.google,
            label: 'Lanjutkan dengan Google',
            loading: loadingProvider == AuthProviderType.google,
            onPressed: onGoogleAuth,
          ),
          const SizedBox(height: LARGE_SPACE),
          AccountSwitchAction(
            message: 'Belum punya akun? ',
            actionLabel: 'Daftar',
            onTap: onSwitchToSignUp,
          ),
        ],
      ),
    );
  }

  String? _validateIdentifier(String? value) {
    final String input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Email atau nomor telepon wajib diisi.';
    }
    final bool looksLikeEmail = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(input);
    final bool looksLikePhone = RegExp(r'^[0-9+\-\s]{8,}$').hasMatch(input);
    if (!looksLikeEmail && !looksLikePhone) {
      return 'Masukkan email atau nomor telepon yang valid.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final String input = value ?? '';
    if (input.isEmpty) {
      return 'Password wajib diisi.';
    }
    if (input.length < 6) {
      return 'Password minimal 6 karakter.';
    }
    return null;
  }
}
