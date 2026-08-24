import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/data/amanah_auth_repository.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_sheet_container.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_sheet_header.dart';
import 'package:smooth_app/features/authentication/presentation/components/social_auth_button.dart';
import 'package:smooth_app/features/authentication/presentation/organisms/change_password_content.dart';
import 'package:smooth_app/features/authentication/presentation/organisms/forgot_password_content.dart';
import 'package:smooth_app/features/authentication/presentation/organisms/otp_verification_content.dart';
import 'package:smooth_app/features/authentication/presentation/organisms/password_changed_success_content.dart';
import 'package:smooth_app/features/authentication/presentation/organisms/sign_in_content.dart';
import 'package:smooth_app/features/authentication/presentation/organisms/sign_up_content.dart';
import 'package:smooth_app/features/authentication/presentation/state/auth_ui_state.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AuthBottomSheetScreen extends StatefulWidget {
  const AuthBottomSheetScreen({
    super.key,
    this.backgroundAsset = 'assets/amanah/auth/auth_background.png',
    this.repository = const AmanahAuthRepository(),
    this.onAuthenticated,
  });

  final String backgroundAsset;
  final AmanahAuthRepository repository;
  final ValueChanged<AmanahAuthUser>? onAuthenticated;

  @override
  State<AuthBottomSheetScreen> createState() => _AuthBottomSheetScreenState();
}

class _AuthBottomSheetScreenState extends State<AuthBottomSheetScreen> {
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _changePasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController(
    text: 'dokter@amanah.health',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'dokter123',
  );
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  final TextEditingController _resetPasswordController =
      TextEditingController();
  final TextEditingController _resetConfirmPasswordController =
      TextEditingController();
  final List<TextEditingController> _otpControllers =
      List<TextEditingController>.generate(6, (_) => TextEditingController());

  AuthSheetMode _mode = AuthSheetMode.signIn;
  AuthProviderType? _loadingProvider;
  String? _statusMessage;
  bool _statusIsError = false;
  bool _sheetOpen = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resetEmailController.dispose();
    _resetPasswordController.dispose();
    _resetConfirmPasswordController.dispose();
    for (final TextEditingController controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _AuthBackground(assetPath: widget.backgroundAsset),
          const _AuthBackgroundScrim(),
          _AuthClosedActions(
            onSignIn: () => _showAuthSheet(AuthSheetMode.signIn),
            onSignUp: () => _showAuthSheet(AuthSheetMode.signUp),
          ),
        ],
      ),
    );
  }

  Future<void> _showAuthSheet(AuthSheetMode mode) async {
    if (_sheetOpen || !mounted) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    _sheetOpen = true;
    _mode = mode;
    _loadingProvider = null;
    _statusMessage = null;
    _statusIsError = false;

    final _AuthSheetResult? result =
        await showModalBottomSheet<_AuthSheetResult>(
          context: context,
          isScrollControlled: true,
          useSafeArea: false,
          enableDrag: true,
          showDragHandle: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: 0.18),
          builder: (BuildContext sheetContext) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter sheetSetState) {
                final bool showHeader =
                    _mode != AuthSheetMode.passwordChangedSuccess;
                return AuthSheetContainer(
                  centerContent: _mode == AuthSheetMode.passwordChangedSuccess,
                  child: showHeader
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AuthSheetHeader(
                              titlePrefix: _headerTitlePrefix,
                              brand: _headerBrand,
                              description: _headerDescription,
                              onDismiss: () => Navigator.of(sheetContext).pop(),
                            ),
                            const SizedBox(height: VERY_LARGE_SPACE),
                            _buildContent(sheetContext, sheetSetState),
                          ],
                        )
                      : _buildContent(sheetContext, sheetSetState),
                );
              },
            );
          },
        );

    _sheetOpen = false;

    if (!mounted || result?.nextMode == null) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      await _showAuthSheet(result!.nextMode!);
    }
  }

  Widget _buildContent(BuildContext sheetContext, StateSetter sheetSetState) {
    return switch (_mode) {
      AuthSheetMode.signIn => SignInContent(
        formKey: _signInFormKey,
        identifierController: _identifierController,
        passwordController: _passwordController,
        loadingProvider: _loadingProvider,
        statusMessage: _statusMessage,
        statusIsError: _statusIsError,
        onForgotPassword: () {
          final String identifier = _identifierController.text.trim();
          if (identifier.contains('@')) {
            _resetEmailController.text = identifier;
          }
          Navigator.of(
            sheetContext,
          ).pop(const _AuthSheetResult(AuthSheetMode.forgotPassword));
        },
        onEmailAuth: () => _handleCredentialSignIn(sheetSetState),
        onGoogleAuth: () =>
            _handleProviderAuth(AuthProviderType.google, sheetSetState),
        onSwitchToSignUp: () => Navigator.of(
          sheetContext,
        ).pop(const _AuthSheetResult(AuthSheetMode.signUp)),
      ),
      AuthSheetMode.signUp => SignUpContent(
        formKey: _signUpFormKey,
        fullNameController: _fullNameController,
        emailController: _emailController,
        phoneController: _phoneController,
        passwordController: _newPasswordController,
        confirmPasswordController: _confirmPasswordController,
        loadingProvider: _loadingProvider,
        onGoogleAuth: () =>
            _handleProviderAuth(AuthProviderType.google, sheetSetState),
        onCreateAccount: () =>
            _handleCreateAccount(sheetContext, sheetSetState),
        onSwitchToSignIn: () => Navigator.of(
          sheetContext,
        ).pop(const _AuthSheetResult(AuthSheetMode.signIn)),
      ),
      AuthSheetMode.forgotPassword => ForgotPasswordContent(
        formKey: _forgotPasswordFormKey,
        emailController: _resetEmailController,
        loadingProvider: _loadingProvider,
        onSubmit: () => _handleRequestPasswordOtp(sheetContext, sheetSetState),
      ),
      AuthSheetMode.otpVerification => OtpVerificationContent(
        controllers: _otpControllers,
        loadingProvider: _loadingProvider,
        statusMessage: _statusMessage,
        statusIsError: _statusIsError,
        onVerify: () => _handleVerifyOtp(sheetContext, sheetSetState),
      ),
      AuthSheetMode.changePassword => ChangePasswordContent(
        formKey: _changePasswordFormKey,
        passwordController: _resetPasswordController,
        confirmPasswordController: _resetConfirmPasswordController,
        loadingProvider: _loadingProvider,
        statusMessage: _statusMessage,
        statusIsError: _statusIsError,
        onSubmit: () => _handleChangePassword(sheetContext, sheetSetState),
      ),
      AuthSheetMode.passwordChangedSuccess => PasswordChangedSuccessContent(
        onSignIn: () => Navigator.of(
          sheetContext,
        ).pop(const _AuthSheetResult(AuthSheetMode.signIn)),
      ),
    };
  }

  String get _headerTitlePrefix {
    return switch (_mode) {
      AuthSheetMode.signIn => 'Halo, selamat datang',
      AuthSheetMode.signUp => 'Buat akun Kamu',
      AuthSheetMode.forgotPassword => 'Lupa password',
      AuthSheetMode.otpVerification => 'Masukkan kode',
      AuthSheetMode.changePassword => 'Ganti password',
      AuthSheetMode.passwordChangedSuccess => '',
    };
  }

  String get _headerBrand {
    return switch (_mode) {
      AuthSheetMode.signIn => '',
      AuthSheetMode.signUp => '',
      AuthSheetMode.forgotPassword => '',
      AuthSheetMode.otpVerification => '',
      AuthSheetMode.changePassword => '',
      AuthSheetMode.passwordChangedSuccess => '',
    };
  }

  String get _headerDescription {
    final String resetTarget = _resetEmailController.text.trim();
    return switch (_mode) {
      AuthSheetMode.signIn => 'Yuk, masuk untuk mengakses layanan klinik Anda.',
      AuthSheetMode.signUp => 'Lengkapi data dibawah ini untuk melanjutkan',
      AuthSheetMode.forgotPassword =>
        'Masukkan emailmu, kita akan mengirim OTP ke sana',
      AuthSheetMode.otpVerification =>
        'Kode OTP telah dikirimkan ke ${resetTarget.isEmpty ? 'emailmu' : resetTarget}',
      AuthSheetMode.changePassword =>
        'Silakan masukkan password baru kamu di bawah ini.',
      AuthSheetMode.passwordChangedSuccess => '',
    };
  }

  void _refreshSheet(StateSetter sheetSetState) {
    if (mounted) {
      sheetSetState(() {});
    }
  }

  Future<void> _handleCredentialSignIn(StateSetter sheetSetState) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_signInFormKey.currentState?.validate() ?? false)) {
      return;
    }

    _loadingProvider = AuthProviderType.email;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    final AmanahAuthUser? user = await widget.repository.signIn(
      identifier: _identifierController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    _loadingProvider = null;
    if (user == null) {
      _statusMessage =
          'Credential tidak cocok. Coba gunakan dokter@amanah.health / dokter123 atau staff@amanah.health / staff123.';
      _statusIsError = true;
    } else {
      _statusMessage = 'Masuk sebagai ${user.fullName} (${user.roleLabel}).';
      _statusIsError = false;
    }
    _refreshSheet(sheetSetState);

    if (user != null) {
      widget.onAuthenticated?.call(user);
    }
  }

  Future<void> _handleProviderAuth(
    AuthProviderType provider,
    StateSetter sheetSetState,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _loadingProvider = provider;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    final String providerName = switch (provider) {
      AuthProviderType.google => 'Google',
      AuthProviderType.email => 'email',
    };

    _loadingProvider = null;
    _statusMessage =
        'Demo autentikasi $providerName berhasil. Integrasi backend belum diaktifkan.';
    _statusIsError = false;
    _refreshSheet(sheetSetState);
  }

  Future<void> _handleCreateAccount(
    BuildContext sheetContext,
    StateSetter sheetSetState,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_signUpFormKey.currentState?.validate() ?? false)) {
      return;
    }

    _loadingProvider = AuthProviderType.email;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    _loadingProvider = null;
    _identifierController.text = _emailController.text;
    _statusMessage =
        'Akun demo ${_fullNameController.text.trim()} dibuat. Silakan masuk.';
    _statusIsError = false;
    if (sheetContext.mounted) {
      Navigator.of(
        sheetContext,
      ).pop(const _AuthSheetResult(AuthSheetMode.signIn));
    }
  }

  Future<void> _handleRequestPasswordOtp(
    BuildContext sheetContext,
    StateSetter sheetSetState,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_forgotPasswordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    _loadingProvider = AuthProviderType.email;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) {
      return;
    }

    for (final TextEditingController controller in _otpControllers) {
      controller.clear();
    }
    _loadingProvider = null;
    if (sheetContext.mounted) {
      Navigator.of(
        sheetContext,
      ).pop(const _AuthSheetResult(AuthSheetMode.otpVerification));
    }
  }

  Future<void> _handleVerifyOtp(
    BuildContext sheetContext,
    StateSetter sheetSetState,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String code = _otpControllers
        .map((TextEditingController controller) => controller.text.trim())
        .join();
    if (code.length != 6) {
      _statusMessage = 'Masukkan 6 digit kode OTP.';
      _statusIsError = true;
      _refreshSheet(sheetSetState);
      return;
    }

    _loadingProvider = AuthProviderType.email;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    _loadingProvider = null;
    _resetPasswordController.clear();
    _resetConfirmPasswordController.clear();
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);
    if (sheetContext.mounted) {
      Navigator.of(
        sheetContext,
      ).pop(const _AuthSheetResult(AuthSheetMode.changePassword));
    }
  }

  Future<void> _handleChangePassword(
    BuildContext sheetContext,
    StateSetter sheetSetState,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_changePasswordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    _loadingProvider = AuthProviderType.email;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    _loadingProvider = null;
    _passwordController.text = _resetPasswordController.text;
    _identifierController.text = _resetEmailController.text;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);
    if (sheetContext.mounted) {
      Navigator.of(
        sheetContext,
      ).pop(const _AuthSheetResult(AuthSheetMode.passwordChangedSuccess));
    }
  }
}

class _AuthSheetResult {
  const _AuthSheetResult(this.nextMode);

  final AuthSheetMode? nextMode;
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      filterQuality: FilterQuality.high,
    );
  }
}

class _AuthBackgroundScrim extends StatelessWidget {
  const _AuthBackgroundScrim();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: dark ? 0.10 : 0.02),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.72),
          ],
          stops: const <double>[0, 0.46, 0.70, 1],
        ),
      ),
    );
  }
}

class _AuthClosedActions extends StatelessWidget {
  const _AuthClosedActions({required this.onSignIn, required this.onSignUp});

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(
          children: <Widget>[
            const Spacer(),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Layanan Klinik\nAmanah Healthcare',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onSignUp,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: primary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: CIRCULAR_BORDER_RADIUS,
                  ),
                ),
                child: Text(
                  'Mulai',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: onSignIn,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
                  shape: const RoundedRectangleBorder(
                    borderRadius: CIRCULAR_BORDER_RADIUS,
                  ),
                ),
                child: Text(
                  'Saya sudah punya akun',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text.rich(
              const TextSpan(
                text: 'Dengan melanjutkan, Anda menyetujui ',
                children: <InlineSpan>[
                  TextSpan(
                    text: 'syarat penggunaan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' dan memahami '),
                  TextSpan(
                    text: 'kebijakan privasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' Amanah Healthcare.'),
                ],
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
