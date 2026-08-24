import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_input_field.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_primary_button.dart';
import 'package:smooth_app/features/authentication/presentation/components/social_auth_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class ForgotPasswordContent extends StatelessWidget {
  const ForgotPasswordContent({
    required this.formKey,
    required this.emailController,
    required this.onSubmit,
    super.key,
    this.loadingProvider,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final AuthProviderType? loadingProvider;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AuthInputField(
            label: 'Email',
            hintText: 'Masukkan emailmu',
            controller: emailController,
            leadingIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.email],
            validator: _validateEmail,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: MEDIUM_SPACE),
          AuthPrimaryButton(
            label: 'Kirim OTP',
            loading: loadingProvider == AuthProviderType.email,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
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
}
