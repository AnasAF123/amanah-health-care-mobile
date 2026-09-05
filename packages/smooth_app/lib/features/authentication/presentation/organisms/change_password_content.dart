import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_primary_button.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_status_message.dart';
import 'package:smooth_app/features/authentication/presentation/components/password_input_field.dart';
import 'package:smooth_app/features/authentication/presentation/components/password_strength_meter.dart';
import 'package:smooth_app/features/authentication/presentation/components/social_auth_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class ChangePasswordContent extends StatelessWidget {
  const ChangePasswordContent({
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    super.key,
    this.loadingProvider,
    this.statusMessage,
    this.statusIsError = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final AuthProviderType? loadingProvider;
  final String? statusMessage;
  final bool statusIsError;
  final VoidCallback onSubmit;

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
          PasswordInputField(
            label: 'Password baru',
            hintText: 'password baru',
            controller: passwordController,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.newPassword],
            validator: _validatePassword,
          ),
          PasswordStrengthMeter(controller: passwordController),
          const SizedBox(height: MEDIUM_SPACE),
          PasswordInputField(
            label: 'Konfirmasi password',
            hintText: 'confirm password',
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
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: LARGE_SPACE),
          AuthPrimaryButton(
            label: 'Ganti Password',
            loading: loadingProvider == AuthProviderType.email,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }

  String? _validatePassword(String? value) {
    final String input = value ?? '';
    if (input.isEmpty) {
      return 'Password baru wajib diisi.';
    }
    return null;
  }
}
