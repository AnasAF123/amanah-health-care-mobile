import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/account_switch_action.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_divider.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_primary_button.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_stepper_progress.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/password_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/password_strength_meter.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/social_auth_button.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

/// 3-Step Stepper Sign-Up Content
/// Divides registration into bite-sized chunks:
/// - Step 1: Identitas Diri (Nama & Email) + Opsi Google
/// - Step 2: Kontak Telepon
/// - Step 3: Keamanan Sandi
class SignUpContent extends StatefulWidget {
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
    this.initialStep = 0,
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
  final int initialStep;

  @override
  State<SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<SignUpContent> {
  late int _currentStep;
  bool _isGoogleAuth = false;
  bool _isNavigatingForward = true;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, 2);
  }

  void _goToStep(int step, {required bool forward}) {
    FocusScope.of(context).unfocus();
    setState(() {
      _isNavigatingForward = forward;
      _currentStep = step;
    });
  }

  void _nextFromStep1() {
    final FormState? form = widget.formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    _goToStep(1, forward: true);
  }

  void _handleGoogleSignUp() {
    // Respect existing credentials and do NOT inject any initial dummy values.
    // Fields remain empty for user input.
    setState(() {
      _isGoogleAuth = true;
    });
    widget.onGoogleAuth();
    _goToStep(1, forward: true);
  }

  void _nextFromStep2() {
    final FormState? form = widget.formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    _goToStep(2, forward: true);
  }

  void _submitStep3() {
    final FormState? form = widget.formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    widget.onCreateAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Minimalist Step Progress Indicator
          AuthStepperProgress(currentStep: _currentStep),
          const SizedBox(height: LARGE_SPACE),

          // Animated Step View
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final Offset offset = _isNavigatingForward
                  ? const Offset(0.12, 0.0)
                  : const Offset(-0.12, 0.0);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: offset,
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentStep),
              child: _buildStepContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(context);
      case 1:
        return _buildStep2(context);
      case 2:
      default:
        return _buildStep3(context);
    }
  }

  Widget _buildStep1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Form Fields Wrapper
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AuthInputField(
              label: 'Nama lengkap',
              hintText: 'Masukkan nama lengkap',
              controller: widget.fullNameController,
              leadingIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.name],
              validator: _required('Nama lengkap wajib diisi.'),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            AuthInputField(
              label: 'Email',
              hintText: 'Masukkan email',
              controller: widget.emailController,
              leadingIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.email],
              validator: _validateEmail,
              onFieldSubmitted: (_) => _nextFromStep1(),
            ),
          ],
        ),

        // Distinct generous spacing between Form and Action wrappers
        const SizedBox(height: VERY_LARGE_SPACE),

        // Action Buttons Wrapper
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AuthPrimaryButton(
              label: 'Lanjutkan',
              onPressed: _nextFromStep1,
            ),
            const SizedBox(height: LARGE_SPACE),
            const AuthDivider(),
            const SizedBox(height: LARGE_SPACE),
            SocialAuthButton(
              provider: AuthProviderType.google,
              label: 'Lanjutkan dengan Google',
              loading: widget.loadingProvider == AuthProviderType.google,
              onPressed: _handleGoogleSignUp,
            ),
            const SizedBox(height: LARGE_SPACE),
            AccountSwitchAction(
              message: 'Sudah punya akun? ',
              actionLabel: 'Masuk',
              onTap: widget.onSwitchToSignIn,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Form Fields Wrapper
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_isGoogleAuth) ...<Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.neutral900
                      : AmanahColorTokens.neutral50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: dark
                        ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.35)
                        : AmanahColorTokens.brand.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.verified_user_rounded,
                      size: 18,
                      color: dark
                          ? AmanahColorTokens.tabActiveDark
                          : AmanahColorTokens.brand,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.emailController.text.trim().isNotEmpty
                            ? 'Akun Google: ${widget.emailController.text.trim()}'
                            : 'Mendaftar menggunakan akun Google',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: dark
                              ? AmanahColorTokens.neutral200
                              : AmanahColorTokens.neutral700,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LARGE_SPACE),
            ],
            AuthInputField(
              label: 'Nomor telepon',
              hintText: 'Contoh: 081234567890',
              controller: widget.phoneController,
              leadingIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.telephoneNumber],
              validator: _validatePhone,
              onFieldSubmitted: (_) => _nextFromStep2(),
            ),
          ],
        ),

        // Distinct generous spacing between Form and Action wrappers
        const SizedBox(height: VERY_LARGE_SPACE),

        // Action Buttons Wrapper
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AuthPrimaryButton(
              label: 'Lanjutkan',
              onPressed: _nextFromStep2,
            ),
            const SizedBox(height: MEDIUM_SPACE),
            Center(
              child: TextButton.icon(
                onPressed: () => _goToStep(0, forward: false),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Kembali ke Data Diri'),
                style: TextButton.styleFrom(
                  foregroundColor: dark
                      ? AmanahColorTokens.neutral300
                      : AmanahColorTokens.neutral600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Form Fields Wrapper
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PasswordInputField(
              label: 'Password',
              hintText: 'Buat password',
              controller: widget.passwordController,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.newPassword],
              validator: _validatePassword,
            ),
            PasswordStrengthMeter(controller: widget.passwordController),
            const SizedBox(height: MEDIUM_SPACE),
            PasswordInputField(
              label: 'Konfirmasi password',
              hintText: 'Konfirmasi password',
              controller: widget.confirmPasswordController,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.newPassword],
              validator: (String? value) {
                final String input = value ?? '';
                if (input.isEmpty) {
                  return 'Konfirmasi password wajib diisi.';
                }
                if (input != widget.passwordController.text) {
                  return 'Konfirmasi password belum sama.';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submitStep3(),
            ),
          ],
        ),

        // Distinct generous spacing between Form and Action wrappers
        const SizedBox(height: VERY_LARGE_SPACE),

        // Action Buttons Wrapper
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AuthPrimaryButton(
              label: 'Daftar',
              loading: widget.loadingProvider == AuthProviderType.email,
              onPressed: _submitStep3,
            ),
            const SizedBox(height: MEDIUM_SPACE),
            Center(
              child: TextButton.icon(
                onPressed: () => _goToStep(1, forward: false),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Kembali ke Nomor Telepon'),
                style: TextButton.styleFrom(
                  foregroundColor: dark
                      ? AmanahColorTokens.neutral300
                      : AmanahColorTokens.neutral600,
                ),
              ),
            ),
          ],
        ),
      ],
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
