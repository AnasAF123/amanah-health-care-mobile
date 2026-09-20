import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_sheet_container.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_sheet_header.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/social_auth_button.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/change_password_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/forgot_password_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/otp_verification_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/password_changed_success_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/sign_in_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/sign_up_content.dart';
import 'package:amanah_healthcare/features/authentication/presentation/screen/staff_onboarding_screen.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/auth_ui_state.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/password_requirements.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/amanah_home_shell.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/data/amanah_permission_store.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

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
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
  bool _hasCredentialError = false;
  String? _credentialErrorMessage;
  String? _statusMessage;
  bool _statusIsError = false;
  bool _sheetOpen = false;
  AmanahAuthUser? _authenticatedUser;
  bool _isSignUpVerification = false;
  String _pendingVerificationPassword = '';
  String _pendingPhone = '';

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    AmanahAuthLogger.logLifecycle('Initiating cold startup session check');
    try {
      final AmanahAuthUser? user = await widget.repository.getSession();
      if (user != null && mounted) {
        AmanahAuthLogger.logLifecycle(
          'Active session restored successfully',
          details: <String, dynamic>{
            'userId': user.id,
            'name': user.fullName,
            'role': user.role.name,
            'needsOnboarding': user.needsOnboarding,
          },
        );
        setState(() {
          _authenticatedUser = user;
        });
        widget.onAuthenticated?.call(user);
      } else {
        AmanahAuthLogger.logLifecycle(
          'No active session found (user remains on login screen)',
        );
      }
    } catch (e) {
      AmanahAuthLogger.logLifecycle('Session restoration check error: $e');
    }
  }

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
    final AmanahAuthUser? user = _authenticatedUser;
    if (user != null) {
      if (user.needsOnboarding) {
        return StaffOnboardingScreen(
          user: user,
          repository: widget.repository,
          onOnboardingComplete: (AmanahAuthUser updatedUser) {
            setState(() => _authenticatedUser = updatedUser);
            widget.onAuthenticated?.call(updatedUser);
          },
          onLogout: () async {
            await widget.repository.signOut();
            try {
              await GoogleSignIn().signOut();
            } catch (_) {}
            AmanahScheduleStore.instance.reset();
            AmanahNotificationStore.instance.reset();
            AmanahPermissionStore.instance.reset();
            if (mounted) {
              setState(() => _authenticatedUser = null);
            }
          },
        );
      }

      return AmanahHomeShell(
        user: user,
        onLogout: () async {
          await widget.repository.signOut();
          try {
            await GoogleSignIn().signOut();
          } catch (_) {}
          AmanahScheduleStore.instance.reset();
          AmanahNotificationStore.instance.reset();
          AmanahPermissionStore.instance.reset();
          if (mounted) {
            setState(() => _authenticatedUser = null);
          }
        },
      );
    }

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
    _hasCredentialError = false;
    _credentialErrorMessage = null;
    _statusMessage = null;
    _statusIsError = false;

    final _AuthSheetResult? result =
        await showModalBottomSheet<_AuthSheetResult>(
          context: context,
          isScrollControlled: true,
          useSafeArea: false,
          enableDrag: true,
          showDragHandle: false,
          backgroundColor: Colors.transparent,
          barrierColor: AmanahThemeTokens.scrim(context),
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
        hasCredentialError: _hasCredentialError,
        credentialErrorMessage: _credentialErrorMessage,
        onCredentialChanged: () {
          if (_hasCredentialError) {
            _hasCredentialError = false;
            _credentialErrorMessage = null;
            _refreshSheet(sheetSetState);
          }
        },
        onForgotPassword: () {
          final String identifier = _identifierController.text.trim();
          if (identifier.contains('@')) {
            _resetEmailController.text = identifier;
          }
          Navigator.of(
            sheetContext,
          ).pop(const _AuthSheetResult(AuthSheetMode.forgotPassword));
        },
        onEmailAuth: () => _handleCredentialSignIn(sheetContext, sheetSetState),
        onGoogleAuth: () =>
            _handleProviderAuth(sheetContext, AuthProviderType.google, sheetSetState),
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
            _handleProviderAuth(sheetContext, AuthProviderType.google, sheetSetState),
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
      AuthSheetMode.signIn => 'Selamat Datang Kembali',
      AuthSheetMode.signUp => 'Buat Akun Barumu',
      AuthSheetMode.forgotPassword => 'Lupa password',
      AuthSheetMode.otpVerification =>
        _isSignUpVerification ? 'Verifikasi Akun' : 'Masukkan kode',
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
    final String target = _isSignUpVerification
        ? _emailController.text.trim()
        : _resetEmailController.text.trim();
    return switch (_mode) {
      AuthSheetMode.signIn => 'Masuk untuk melanjutkan ke akunmu',
      AuthSheetMode.signUp => 'Mulai pengalaman kesehatan yang dipersonalisasi',
      AuthSheetMode.forgotPassword =>
        'Masukkan emailmu, kita akan mengirim OTP ke sana',
      AuthSheetMode.otpVerification =>
        'Kode OTP telah dikirimkan ke ${target.isEmpty ? 'emailmu' : target}',
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

  Future<void> _handleCredentialSignIn(
    BuildContext sheetContext,
    StateSetter sheetSetState,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_signInFormKey.currentState?.validate() ?? false)) {
      return;
    }

    _loadingProvider = AuthProviderType.email;
    _hasCredentialError = false;
    _credentialErrorMessage = null;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    final String identifier = _identifierController.text.trim();
    AmanahAuthLogger.logLifecycle(
      'Email credential sign in initiated',
      details: <String, dynamic>{'identifier': identifier},
    );

    try {
      final AmanahAuthUser? user = await widget.repository.authenticate(
        identifier,
        _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      _loadingProvider = null;
      if (user == null) {
        _hasCredentialError = true;
        _credentialErrorMessage =
            'Email atau password yang Anda masukkan salah. Silakan periksa kembali.';
        AmanahAuthLogger.logLifecycle(
          'Email credential sign in failed: invalid credentials',
          details: <String, dynamic>{'identifier': identifier},
        );
      } else {
        _hasCredentialError = false;
        _credentialErrorMessage = null;
        AmanahAuthLogger.logLifecycle(
          'Email credential sign in succeeded',
          details: <String, dynamic>{
            'userId': user.id,
            'role': user.role.name,
            'needsOnboarding': user.needsOnboarding,
          },
        );
      }
      _refreshSheet(sheetSetState);

      if (user != null) {
        widget.onAuthenticated?.call(user);
        setState(() => _authenticatedUser = user);
        if (sheetContext.mounted) {
          Navigator.of(sheetContext).pop();
        }
      }
    } on AmanahAuthPatientRestrictedException catch (e) {
      if (!mounted) return;
      _loadingProvider = null;
      _hasCredentialError = true;
      _credentialErrorMessage = e.message;
      AmanahAuthLogger.logLifecycle(
        'Email credential sign in restricted',
        details: <String, dynamic>{'error': e.message},
      );
      _refreshSheet(sheetSetState);
    } on AmanahAuthException catch (e) {
      if (!mounted) return;
      _loadingProvider = null;
      _hasCredentialError = true;
      _credentialErrorMessage = e.message;
      AmanahAuthLogger.logLifecycle(
        'Email credential sign in error',
        details: <String, dynamic>{'error': e.message},
      );
      _refreshSheet(sheetSetState);
    } catch (e) {
      if (!mounted) return;
      _loadingProvider = null;
      _hasCredentialError = true;
      _credentialErrorMessage =
          'Terjadi kesalahan pada server. Silakan coba lagi.';
      AmanahAuthLogger.logLifecycle(
        'Email credential sign in unexpected error',
        details: <String, dynamic>{'error': e.toString()},
      );
      _refreshSheet(sheetSetState);
    }
  }

  Future<void> _handleProviderAuth(
    BuildContext sheetContext,
    AuthProviderType provider,
    StateSetter sheetSetState,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _loadingProvider = provider;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    if (provider == AuthProviderType.google) {
      try {
        AmanahAuthLogger.logOAuth('Google auth initiated');
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId:
              '649477011186-augsamgganq024tesomp0c8rvgs9c7ua.apps.googleusercontent.com',
        );
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        if (account == null) {
          AmanahAuthLogger.logOAuth('Google sign-in cancelled by user');
          _loadingProvider = null;
          _refreshSheet(sheetSetState);
          return;
        }

        final GoogleSignInAuthentication auth = await account.authentication;
        final String? idToken = auth.idToken;

        if (idToken == null || idToken.isEmpty) {
          throw const AmanahAuthException(
            'Gagal mendapatkan ID token dari Google.',
          );
        }

        final AmanahAuthUser? user =
            await widget.repository.signInWithGoogle(idToken);
        if (!mounted) return;

        _loadingProvider = null;
        _refreshSheet(sheetSetState);

        if (user != null) {
          AmanahAuthLogger.logOAuth(
            'Google auth succeeded',
            details: <String, dynamic>{
              'userId': user.id,
              'role': user.role.name,
              'needsOnboarding': user.needsOnboarding,
            },
          );
          widget.onAuthenticated?.call(user);
          setState(() => _authenticatedUser = user);
          if (sheetContext.mounted) {
            Navigator.of(sheetContext).pop();
          }
        }
      } on AmanahAuthPatientRestrictedException catch (e) {
        if (!mounted) return;
        _loadingProvider = null;
        _statusMessage = e.message;
        _statusIsError = true;
        AmanahAuthLogger.logOAuth(
          'Google auth restricted for patient role',
          details: <String, dynamic>{'error': e.message},
        );
        _refreshSheet(sheetSetState);
      } on AmanahAuthException catch (e) {
        if (!mounted) return;
        _loadingProvider = null;
        _statusMessage = e.message;
        _statusIsError = true;
        AmanahAuthLogger.logOAuth(
          'Google auth failed',
          details: <String, dynamic>{'error': e.message},
        );
        _refreshSheet(sheetSetState);
      } catch (e) {
        if (!mounted) return;
        _loadingProvider = null;
        _statusMessage = 'Gagal masuk dengan Google: $e';
        _statusIsError = true;
        AmanahAuthLogger.logOAuth(
          'Google auth unexpected error',
          details: <String, dynamic>{'error': e.toString()},
        );
        _refreshSheet(sheetSetState);
      }
    } else {
      _loadingProvider = null;
      _statusMessage = 'Metode masuk ini belum didukung.';
      _statusIsError = true;
      _refreshSheet(sheetSetState);
    }
  }

  Future<void> _handleCreateAccount(
    BuildContext sheetContext,
    StateSetter sheetSetState,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_signUpFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!AmanahPasswordRequirements.evaluate(
      _newPasswordController.text,
    ).isComplete) {
      return;
    }

    _loadingProvider = AuthProviderType.email;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    final String name = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _newPasswordController.text;
    final String phone = _phoneController.text.trim();

    AmanahAuthLogger.logLifecycle(
      'Manual sign up initiated',
      details: <String, dynamic>{'name': name, 'email': email, 'phone': phone},
    );

    try {
      await widget.repository.signUp(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      _loadingProvider = null;
      _isSignUpVerification = true;
      _pendingVerificationPassword = password;
      _pendingPhone = phone;
      for (final TextEditingController controller in _otpControllers) {
        controller.clear();
      }

      AmanahAuthLogger.logLifecycle(
        'Manual sign up account created, transitioning to email OTP verification',
        details: <String, dynamic>{'email': email},
      );

      _refreshSheet(sheetSetState);
      if (sheetContext.mounted) {
        Navigator.of(
          sheetContext,
        ).pop(const _AuthSheetResult(AuthSheetMode.otpVerification));
      }
    } on AmanahAuthException catch (e) {
      if (!mounted) return;
      _loadingProvider = null;
      _statusMessage = e.message;
      _statusIsError = true;
      AmanahAuthLogger.logLifecycle(
        'Manual sign up failed',
        details: <String, dynamic>{'error': e.message},
      );
      _refreshSheet(sheetSetState);
    } catch (e) {
      if (!mounted) return;
      _loadingProvider = null;
      _statusMessage = 'Gagal mendaftar akun. Silakan coba lagi.';
      _statusIsError = true;
      AmanahAuthLogger.logLifecycle(
        'Manual sign up unexpected error',
        details: <String, dynamic>{'error': e.toString()},
      );
      _refreshSheet(sheetSetState);
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

    _isSignUpVerification = false;
    final String email = _resetEmailController.text.trim();
    _loadingProvider = AuthProviderType.email;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    AmanahAuthLogger.logLifecycle(
      'Password reset OTP requested',
      details: <String, dynamic>{'email': email},
    );

    try {
      final bool success = await widget.repository.requestPasswordReset(email);

      if (!mounted) return;
      _loadingProvider = null;

      if (success) {
        AmanahAuthLogger.logLifecycle(
          'Password reset OTP sent successfully',
          details: <String, dynamic>{'email': email},
        );
        for (final TextEditingController controller in _otpControllers) {
          controller.clear();
        }
        _refreshSheet(sheetSetState);
        if (sheetContext.mounted) {
          Navigator.of(
            sheetContext,
          ).pop(const _AuthSheetResult(AuthSheetMode.otpVerification));
        }
      } else {
        AmanahAuthLogger.logLifecycle(
          'Password reset OTP request failed: email not accepted',
          details: <String, dynamic>{'email': email},
        );
        _statusMessage =
            'Gagal mengirim OTP. Pastikan email Anda telah terdaftar.';
        _statusIsError = true;
        _refreshSheet(sheetSetState);
      }
    } on AmanahAuthException catch (e) {
      if (!mounted) return;
      _loadingProvider = null;
      _statusMessage = e.message;
      _statusIsError = true;
      AmanahAuthLogger.logLifecycle(
        'Password reset OTP request failed',
        details: <String, dynamic>{'error': e.message},
      );
      _refreshSheet(sheetSetState);
    } catch (e) {
      if (!mounted) return;
      _loadingProvider = null;
      _statusMessage = 'Terjadi kesalahan saat meminta OTP reset password.';
      _statusIsError = true;
      AmanahAuthLogger.logLifecycle(
        'Password reset OTP request unexpected error',
        details: <String, dynamic>{'error': e.toString()},
      );
      _refreshSheet(sheetSetState);
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

    if (_isSignUpVerification) {
      final String email = _emailController.text.trim();
      AmanahAuthLogger.logLifecycle(
        'Verifying sign up email OTP challenge',
        details: <String, dynamic>{'email': email},
      );

      try {
        AmanahAuthUser? user = await widget.repository.verifyEmailOtp(
          email,
          code,
        );

        // Fallback: If Better Auth does not auto-return session token on verifyEmail, authenticate
        if (user == null && _pendingVerificationPassword.isNotEmpty) {
          user = await widget.repository.authenticate(
            email,
            _pendingVerificationPassword,
          );
        }

        if (!mounted) return;
        _loadingProvider = null;

        if (user != null) {
          // Attach phone from registration if not yet stored on user
          if (user.phone.isEmpty && _pendingPhone.isNotEmpty) {
            user = user.copyWith(phone: _pendingPhone);
          }

          AmanahAuthLogger.logLifecycle(
            'Sign up email OTP verified successfully',
            details: <String, dynamic>{
              'userId': user.id,
              'email': user.email,
              'role': user.role.name,
              'needsOnboarding': user.needsOnboarding,
            },
          );

          _isSignUpVerification = false;
          _pendingVerificationPassword = '';
          _refreshSheet(sheetSetState);

          widget.onAuthenticated?.call(user);
          setState(() => _authenticatedUser = user);
          if (sheetContext.mounted) {
            Navigator.of(sheetContext).pop();
          }
        } else {
          _statusMessage = 'Kode OTP salah atau telah kedaluwarsa.';
          _statusIsError = true;
          _refreshSheet(sheetSetState);
        }
      } on AmanahAuthPatientRestrictedException catch (e) {
        if (!mounted) return;
        _loadingProvider = null;
        _statusMessage = e.message;
        _statusIsError = true;
        _refreshSheet(sheetSetState);
      } on AmanahAuthException catch (e) {
        if (!mounted) return;
        _loadingProvider = null;
        _statusMessage = e.message;
        _statusIsError = true;
        AmanahAuthLogger.logLifecycle(
          'Sign up email OTP verification error',
          details: <String, dynamic>{'error': e.message},
        );
        _refreshSheet(sheetSetState);
      } catch (e) {
        if (!mounted) return;
        _loadingProvider = null;
        _statusMessage = 'Terjadi kesalahan saat memverifikasi kode OTP.';
        _statusIsError = true;
        AmanahAuthLogger.logLifecycle(
          'Sign up email OTP verification unexpected error',
          details: <String, dynamic>{'error': e.toString()},
        );
        _refreshSheet(sheetSetState);
      }
    } else {
      final String email = _resetEmailController.text.trim();
      AmanahAuthLogger.logLifecycle(
        'Verifying password reset OTP challenge',
        details: <String, dynamic>{'email': email},
      );

      try {
        final bool valid = await widget.repository.checkVerificationOtp(
          email,
          code,
        );

        if (!mounted) return;
        _loadingProvider = null;

        if (valid) {
          AmanahAuthLogger.logLifecycle(
            'Password reset OTP verified successfully',
            details: <String, dynamic>{'email': email},
          );
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
        } else {
          AmanahAuthLogger.logLifecycle(
            'Password reset OTP verification rejected',
            details: <String, dynamic>{'email': email},
          );
          _statusMessage = 'Kode OTP salah atau telah kedaluwarsa.';
          _statusIsError = true;
          _refreshSheet(sheetSetState);
        }
      } on AmanahAuthException catch (e) {
        if (!mounted) return;
        _loadingProvider = null;
        _statusMessage = e.message;
        _statusIsError = true;
        AmanahAuthLogger.logLifecycle(
          'Password reset OTP verification error',
          details: <String, dynamic>{'error': e.message},
        );
        _refreshSheet(sheetSetState);
      } catch (e) {
        if (!mounted) return;
        _loadingProvider = null;
        _statusMessage = 'Terjadi kesalahan saat memverifikasi kode OTP.';
        _statusIsError = true;
        AmanahAuthLogger.logLifecycle(
          'Password reset OTP verification unexpected error',
          details: <String, dynamic>{'error': e.toString()},
        );
        _refreshSheet(sheetSetState);
      }
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
    if (!AmanahPasswordRequirements.evaluate(
      _resetPasswordController.text,
    ).isComplete) {
      return;
    }

    if (_resetPasswordController.text != _resetConfirmPasswordController.text) {
      _statusMessage = 'Konfirmasi password tidak cocok.';
      _statusIsError = true;
      _refreshSheet(sheetSetState);
      return;
    }

    final String code = _otpControllers
        .map((TextEditingController controller) => controller.text.trim())
        .join();
    final String email = _resetEmailController.text.trim();

    _loadingProvider = AuthProviderType.email;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);

    AmanahAuthLogger.logLifecycle(
      'Submitting new password with verified OTP',
      details: <String, dynamic>{'email': email},
    );

    try {
      final bool success = await widget.repository.resetPassword(
        email,
        code,
        _resetPasswordController.text,
      );

      if (!mounted) return;
      _loadingProvider = null;

      if (success) {
        AmanahAuthLogger.logLifecycle(
          'Password reset completed successfully',
          details: <String, dynamic>{'email': email},
        );
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
      } else {
        AmanahAuthLogger.logLifecycle(
          'Password reset rejected by server',
          details: <String, dynamic>{'email': email},
        );
        _statusMessage = 'Gagal memperbarui password. Silakan coba lagi.';
        _statusIsError = true;
        _refreshSheet(sheetSetState);
      }
    } on AmanahAuthException catch (e) {
      if (!mounted) return;
      _loadingProvider = null;
      _statusMessage = e.message;
      _statusIsError = true;
      AmanahAuthLogger.logLifecycle(
        'Password reset error',
        details: <String, dynamic>{'error': e.message},
      );
      _refreshSheet(sheetSetState);
    } catch (e) {
      if (!mounted) return;
      _loadingProvider = null;
      _statusMessage = 'Terjadi kesalahan saat memperbarui password.';
      _statusIsError = true;
      AmanahAuthLogger.logLifecycle(
        'Password reset unexpected error',
        details: <String, dynamic>{'error': e.toString()},
      );
      _refreshSheet(sheetSetState);
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
    final Color baseColor = AmanahElevation.sheet(dark: dark).color;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                baseColor.withValues(alpha: dark ? 0.10 : 0.03),
                Colors.transparent,
                baseColor.withValues(alpha: 0.14),
                baseColor.withValues(alpha: 0.36),
                baseColor.withValues(alpha: 0.78),
              ],
              stops: const <double>[0, 0.36, 0.56, 0.76, 1],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.90,
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    baseColor.withValues(alpha: 0.08),
                    baseColor.withValues(alpha: 0.28),
                    baseColor.withValues(alpha: 0.54),
                  ],
                  stops: const <double>[0, 0.30, 0.66, 1],
                ),
              ),
            ),
          ),
        ),
      ],
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(
          children: <Widget>[
            const Spacer(),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Sehat Bersama Amanah',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AmanahColorTokens.surfaceLight,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: MEDIUM_SPACE),
                  Text(
                    'Menemukan layanan kesehatan dan perawatan terbaik yang dirancang khusus untuk kebutuhanmu',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.82),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.42,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            AmanahButton.hero(
              text: 'Mulai',
              onPressed: onSignUp,
              size: AmanahButtonSize.large,
              isFullWidth: true,
            ),
            const SizedBox(height: MEDIUM_SPACE),
            AmanahButton.ghost(
              text: 'Saya sudah punya akun',
              onPressed: onSignIn,
              size: AmanahButtonSize.large,
              isFullWidth: true,
              customForegroundColor: AmanahColorTokens.surfaceLight,
            ),
            const SizedBox(height: 24),
            Text.rich(
              const TextSpan(
                text: 'Dengan melanjutkan, Anda menyetujui ',
                children: <InlineSpan>[
                  TextSpan(
                    text: 'syarat penggunaan',
                    style: TextStyle(
                      color: AmanahColorTokens.surfaceLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' dan memahami '),
                  TextSpan(
                    text: 'kebijakan privasi',
                    style: TextStyle(
                      color: AmanahColorTokens.surfaceLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' Amanah Healthcare.'),
                ],
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.78),
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
