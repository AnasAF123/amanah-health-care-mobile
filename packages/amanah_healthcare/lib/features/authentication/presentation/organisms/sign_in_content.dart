import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_divider.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_primary_button.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_text_action.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/password_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/social_auth_button.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class SignInContent extends StatelessWidget {
  const SignInContent({
    required this.formKey,
    required this.identifierController,
    required this.passwordController,
    required this.onForgotPassword,
    required this.onEmailAuth,
    required this.onGoogleAuth,
    super.key,
    this.loadingProvider,
    this.hasCredentialError = false,
    this.credentialErrorMessage,
    this.onCredentialChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;
  final VoidCallback onEmailAuth;
  final VoidCallback onGoogleAuth;
  final AuthProviderType? loadingProvider;
  final bool hasCredentialError;
  final String? credentialErrorMessage;
  final VoidCallback? onCredentialChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
            hasError: hasCredentialError,
            onChanged: (_) => onCredentialChanged?.call(),
          ),
          const SizedBox(height: LARGE_SPACE),
          PasswordInputField(
            label: 'Password',
            hintText: 'Masukkan password',
            controller: passwordController,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.password],
            validator: _validatePassword,
            hasError: hasCredentialError,
            onChanged: (_) => onCredentialChanged?.call(),
            onFieldSubmitted: (_) => onEmailAuth(),
          ),
          if (hasCredentialError && credentialErrorMessage != null)
            AuthInlineValidationMessage(message: credentialErrorMessage!),
          const SizedBox(height: SMALL_SPACE),
          AuthTextAction(label: 'Lupa password?', onPressed: onForgotPassword),
          const SizedBox(height: MEDIUM_SPACE),
          AuthPrimaryButton(
            label: 'Masuk',
            loading: loadingProvider == AuthProviderType.email,
            onPressed: onEmailAuth,
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
          const SizedBox(height: MEDIUM_SPACE),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
            child: Center(
              child: Text(
                'Akses portal terbatas untuk staf dan tenaga medis terdaftar Klinik Amanah.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
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
