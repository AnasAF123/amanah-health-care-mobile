import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_toaster.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/request_password_reset.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/reset_password.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/verify_otp.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_sheet_container.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_sheet_header.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/social_auth_button.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/change_password_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/forgot_password_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/otp_verification_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/password_changed_success_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/sign_in_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/auth_ui_state.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/password_requirements.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class AuthModalSheet extends StatefulWidget {
  const AuthModalSheet({
    required this.onAuthenticated,
    this.repository = const AmanahAuthRepository(),
    SignInWithEmailUseCase? signInWithEmailUseCase,
    SignInWithGoogleUseCase? signInWithGoogleUseCase,
    RequestPasswordResetUseCase? requestPasswordResetUseCase,
    VerifyOtpUseCase? verifyOtpUseCase,
    ResetPasswordUseCase? resetPasswordUseCase,
    this.initialMode = AuthSheetMode.signIn,
    super.key,
  }) : _signInWithEmailUseCase = signInWithEmailUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _requestPasswordResetUseCase = requestPasswordResetUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       _resetPasswordUseCase = resetPasswordUseCase;

  final AuthRepository repository;
  final ValueChanged<AmanahAuthUser> onAuthenticated;
  final AuthSheetMode initialMode;
  final SignInWithEmailUseCase? _signInWithEmailUseCase;
  final SignInWithGoogleUseCase? _signInWithGoogleUseCase;
  final RequestPasswordResetUseCase? _requestPasswordResetUseCase;
  final VerifyOtpUseCase? _verifyOtpUseCase;
  final ResetPasswordUseCase? _resetPasswordUseCase;

  SignInWithEmailUseCase get signInWithEmailUseCase =>
      _signInWithEmailUseCase ?? SignInWithEmailUseCase(repository);

  SignInWithGoogleUseCase get signInWithGoogleUseCase =>
      _signInWithGoogleUseCase ?? SignInWithGoogleUseCase(repository: repository);

  RequestPasswordResetUseCase get requestPasswordResetUseCase =>
      _requestPasswordResetUseCase ?? RequestPasswordResetUseCase(repository);

  VerifyOtpUseCase get verifyOtpUseCase => _verifyOtpUseCase ?? VerifyOtpUseCase(repository);

  ResetPasswordUseCase get resetPasswordUseCase =>
      _resetPasswordUseCase ?? ResetPasswordUseCase(repository);

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<AmanahAuthUser> onAuthenticated,
    AuthRepository repository = const AmanahAuthRepository(),
    SignInWithEmailUseCase? signInWithEmailUseCase,
    SignInWithGoogleUseCase? signInWithGoogleUseCase,
    RequestPasswordResetUseCase? requestPasswordResetUseCase,
    VerifyOtpUseCase? verifyOtpUseCase,
    ResetPasswordUseCase? resetPasswordUseCase,
    AuthSheetMode initialMode = AuthSheetMode.signIn,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      enableDrag: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.60),
      builder: (_) => AuthModalSheet(
        repository: repository,
        onAuthenticated: onAuthenticated,
        signInWithEmailUseCase: signInWithEmailUseCase,
        signInWithGoogleUseCase: signInWithGoogleUseCase,
        requestPasswordResetUseCase: requestPasswordResetUseCase,
        verifyOtpUseCase: verifyOtpUseCase,
        resetPasswordUseCase: resetPasswordUseCase,
        initialMode: initialMode,
      ),
    );
  }

  @override
  State<AuthModalSheet> createState() => _AuthModalSheetState();
}

class _AuthModalSheetState extends State<AuthModalSheet> {
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _changePasswordFormKey = GlobalKey<FormState>();

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  final TextEditingController _resetPasswordController = TextEditingController();
  final TextEditingController _resetConfirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers = List<TextEditingController>.generate(
    6,
    (_) => TextEditingController(),
  );

  late AuthSheetMode _mode;
  AuthProviderType? _loadingProvider;
  bool _hasCredentialError = false;
  String? _credentialErrorMessage;
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    _resetPasswordController.dispose();
    _resetConfirmPasswordController.dispose();
    for (final TextEditingController c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _switchMode(AuthSheetMode mode) {
    setState(() {
      _mode = mode;
      _loadingProvider = null;
      _hasCredentialError = false;
      _credentialErrorMessage = null;
      _statusMessage = null;
      _statusIsError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showHeader = _mode != AuthSheetMode.passwordChangedSuccess;

    return AuthSheetContainer(
      centerContent: _mode == AuthSheetMode.passwordChangedSuccess,
      child: showHeader
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AuthSheetHeader(
                  titlePrefix: _headerTitle,
                  brand: '',
                  description: _headerDescription,
                  onDismiss: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: VERY_LARGE_SPACE),
                _buildContent(),
              ],
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return switch (_mode) {
      AuthSheetMode.signIn => SignInContent(
        formKey: _signInFormKey,
        identifierController: _identifierController,
        passwordController: _passwordController,
        loadingProvider: _loadingProvider,
        hasCredentialError: _hasCredentialError,
        credentialErrorMessage: _credentialErrorMessage,
        onCredentialChanged: () {
          if (_hasCredentialError) {
            setState(() {
              _hasCredentialError = false;
              _credentialErrorMessage = null;
            });
          }
        },
        onForgotPassword: () {
          final String id = _identifierController.text.trim();
          if (id.contains('@')) _resetEmailController.text = id;
          _switchMode(AuthSheetMode.forgotPassword);
        },
        onEmailAuth: _handleCredentialSignIn,
        onGoogleAuth: () => _handleProviderAuth(AuthProviderType.google),
      ),
      AuthSheetMode.forgotPassword => ForgotPasswordContent(
        formKey: _forgotPasswordFormKey,
        emailController: _resetEmailController,
        loadingProvider: _loadingProvider,
        onSubmit: _handleRequestPasswordOtp,
      ),
      AuthSheetMode.otpVerification => OtpVerificationContent(
        controllers: _otpControllers,
        loadingProvider: _loadingProvider,
        statusMessage: _statusMessage,
        statusIsError: _statusIsError,
        onVerify: _handleVerifyOtp,
      ),
      AuthSheetMode.changePassword => ChangePasswordContent(
        formKey: _changePasswordFormKey,
        passwordController: _resetPasswordController,
        confirmPasswordController: _resetConfirmPasswordController,
        loadingProvider: _loadingProvider,
        statusMessage: _statusMessage,
        statusIsError: _statusIsError,
        onSubmit: _handleChangePassword,
      ),
      AuthSheetMode.passwordChangedSuccess => PasswordChangedSuccessContent(
        onSignIn: () => _switchMode(AuthSheetMode.signIn),
      ),
    };
  }

  String get _headerTitle => switch (_mode) {
    AuthSheetMode.signIn => 'Selamat Datang Kembali',
    AuthSheetMode.forgotPassword => 'Lupa password',
    AuthSheetMode.otpVerification => 'Masukkan kode OTP',
    AuthSheetMode.changePassword => 'Ganti password',
    AuthSheetMode.passwordChangedSuccess => '',
  };

  String get _headerDescription {
    final String target = _resetEmailController.text.trim();
    return switch (_mode) {
      AuthSheetMode.signIn => 'Masuk untuk mengakses portal staf dan tenaga medis',
      AuthSheetMode.forgotPassword => 'Masukkan email Anda untuk menerima OTP verifikasi',
      AuthSheetMode.otpVerification =>
        'Kode OTP telah dikirimkan ke ${target.isEmpty ? 'email Anda' : target}',
      AuthSheetMode.changePassword => 'Silakan masukkan password baru Anda di bawah ini.',
      AuthSheetMode.passwordChangedSuccess => '',
    };
  }

  Future<void> _handleCredentialSignIn() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_signInFormKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loadingProvider = AuthProviderType.email;
      _hasCredentialError = false;
      _credentialErrorMessage = null;
    });

    final String identifier = _identifierController.text.trim();
    AmanahAuthLogger.logLifecycle('Email sign in initiated', details: {'id': identifier});

    try {
      final AmanahAuthUser? user = await widget.signInWithEmailUseCase(
        SignInWithEmailParams(email: identifier, password: _passwordController.text),
      );

      if (!mounted) return;

      setState(() => _loadingProvider = null);
      if (user == null) {
        setState(() {
          _hasCredentialError = true;
          _credentialErrorMessage = 'Email atau password salah.';
        });
      } else {
        widget.onAuthenticated(user);
        Navigator.of(context).pop();
      }
    } on AmanahAuthClientNotAllowedException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProvider = null;
        _hasCredentialError = true;
        _credentialErrorMessage = e.message;
      });
    } on AmanahAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProvider = null;
        _hasCredentialError = true;
        _credentialErrorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProvider = null;
        _hasCredentialError = true;
        _credentialErrorMessage = 'Terjadi kesalahan pada server.';
      });
    }
  }

  Future<void> _handleProviderAuth(AuthProviderType provider) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _loadingProvider = provider);

    if (provider == AuthProviderType.google) {
      try {
        final AmanahAuthUser? user = await widget.signInWithGoogleUseCase();
        if (!mounted) return;
        setState(() => _loadingProvider = null);

        if (user != null) {
          widget.onAuthenticated(user);
          Navigator.of(context).pop();
        }
      } on AuthFailure catch (e) {
        if (!mounted) return;
        setState(() => _loadingProvider = null);
        AmanahToaster.error(context, message: e.message);
      } catch (_) {
        if (!mounted) return;
        setState(() => _loadingProvider = null);
        AmanahToaster.error(context, message: 'Terjadi kendala saat menghubungkan ke akun Google.');
      }
    }
  }

  Future<void> _handleRequestPasswordOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_forgotPasswordFormKey.currentState?.validate() ?? false)) return;

    final String email = _resetEmailController.text.trim();
    setState(() {
      _loadingProvider = AuthProviderType.email;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final bool success = await widget.requestPasswordResetUseCase(
        RequestPasswordResetParams(email: email),
      );
      if (!mounted) return;
      setState(() => _loadingProvider = null);

      if (success) {
        for (final TextEditingController c in _otpControllers) {
          c.clear();
        }
        _switchMode(AuthSheetMode.otpVerification);
      } else {
        setState(() {
          _statusMessage = 'Email tidak terdaftar atau gagal mengirim OTP.';
          _statusIsError = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProvider = null;
        _statusMessage = 'Gagal meminta OTP reset password.';
        _statusIsError = true;
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String code = _otpControllers.map((TextEditingController c) => c.text.trim()).join();
    if (code.length != 6) {
      setState(() {
        _statusMessage = 'Masukkan 6 digit kode OTP.';
        _statusIsError = true;
      });
      return;
    }

    setState(() {
      _loadingProvider = AuthProviderType.email;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final bool valid = await widget.verifyOtpUseCase(
        VerifyOtpParams(email: _resetEmailController.text.trim(), otp: code),
      );
      if (!mounted) return;
      setState(() => _loadingProvider = null);

      if (valid) {
        _resetPasswordController.clear();
        _resetConfirmPasswordController.clear();
        _switchMode(AuthSheetMode.changePassword);
      } else {
        setState(() {
          _statusMessage = 'Kode OTP salah atau telah kedaluwarsa.';
          _statusIsError = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProvider = null;
        _statusMessage = 'Gagal memverifikasi kode OTP.';
        _statusIsError = true;
      });
    }
  }

  Future<void> _handleChangePassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_changePasswordFormKey.currentState?.validate() ?? false)) return;
    if (!AmanahPasswordRequirements.evaluate(_resetPasswordController.text).isComplete) {
      return;
    }

    if (_resetPasswordController.text != _resetConfirmPasswordController.text) {
      setState(() {
        _statusMessage = 'Konfirmasi password tidak cocok.';
        _statusIsError = true;
      });
      return;
    }

    final String code = _otpControllers.map((TextEditingController c) => c.text.trim()).join();
    final String email = _resetEmailController.text.trim();

    setState(() {
      _loadingProvider = AuthProviderType.email;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final bool success = await widget.resetPasswordUseCase(
        ResetPasswordParams(email: email, otp: code, newPassword: _resetPasswordController.text),
      );
      if (!mounted) return;
      setState(() => _loadingProvider = null);

      if (success) {
        _passwordController.text = _resetPasswordController.text;
        _identifierController.text = _resetEmailController.text;
        _switchMode(AuthSheetMode.passwordChangedSuccess);
      } else {
        setState(() {
          _statusMessage = 'Gagal memperbarui password. Silakan coba lagi.';
          _statusIsError = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProvider = null;
        _statusMessage = 'Gagal memperbarui password.';
        _statusIsError = true;
      });
    }
  }
}
