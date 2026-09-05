import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/presentation/components/account_switch_action.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_divider.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_input_field.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_primary_button.dart';
import 'package:smooth_app/features/authentication/presentation/components/password_input_field.dart';
import 'package:smooth_app/features/authentication/presentation/components/password_strength_meter.dart';
import 'package:smooth_app/features/authentication/presentation/components/social_auth_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class SignUpContent extends StatelessWidget {
  const SignUpContent({
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onGoogleAuth,
    required this.onCreateAccount,
    required this.onSwitchToSignIn,
    super.key,
    this.loadingProvider,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onGoogleAuth;
  final VoidCallback onCreateAccount;
  final VoidCallback onSwitchToSignIn;
  final AuthProviderType? loadingProvider;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AuthInputField(
            label: 'Nama lengkap',
            hintText: 'Masukkan nama lengkap',
            controller: fullNameController,
            leadingIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.name],
            validator: _required('Nama lengkap wajib diisi.'),
          ),
          const SizedBox(height: MEDIUM_SPACE),
          AuthInputField(
            label: 'Email',
            hintText: 'Masukkan email',
            controller: emailController,
            leadingIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.email],
            validator: _validateEmail,
          ),
          const SizedBox(height: MEDIUM_SPACE),
          AuthInputField(
            label: 'Nomor telepon',
            hintText: 'Masukkan nomor telepon',
            controller: phoneController,
            leadingIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.telephoneNumber],
            validator: _validatePhone,
          ),
          const SizedBox(height: MEDIUM_SPACE),
          PasswordInputField(
            label: 'Password',
            hintText: 'Buat password',
            controller: passwordController,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.newPassword],
            validator: _validatePassword,
          ),
          PasswordStrengthMeter(controller: passwordController),
          const SizedBox(height: MEDIUM_SPACE),
          PasswordInputField(
            label: 'Konfirmasi password',
            hintText: 'Konfirmasi password',
            controller: confirmPasswordController,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.newPassword],
            validator: (String? value) {
              final String input = value ?? '';
              if (input.isEmpty) {
                return 'Konfirmasi password wajib diisi.';
              }
              if (input != passwordController.text) {
                return 'Konfirmasi password belum sama.';
              }
              return null;
            },
            onFieldSubmitted: (_) => onCreateAccount(),
          ),
          const SizedBox(height: LARGE_SPACE),
          AuthPrimaryButton(
            label: 'Daftar',
            loading: loadingProvider == AuthProviderType.email,
            onPressed: onCreateAccount,
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
            message: 'Sudah punya akun? ',
            actionLabel: 'Masuk',
            onTap: onSwitchToSignIn,
          ),
        ],
      ),
    );
  }

  String? Function(String?) _required(String message) {
    return (String? value) {
      if ((value ?? '').trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  String? _validateEmail(String? value) {
    final String input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Email wajib diisi.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input)) {
      return 'Masukkan email yang valid.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final String input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Nomor telepon wajib diisi.';
    }
    if (!RegExp(r'^[0-9+\-\s]{8,}$').hasMatch(input)) {
      return 'Masukkan nomor telepon yang valid.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final String input = value ?? '';
    if (input.isEmpty) {
      return 'Password wajib diisi.';
    }
    return null;
  }
}
