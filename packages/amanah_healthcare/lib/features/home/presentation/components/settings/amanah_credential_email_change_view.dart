import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/request_email_change.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/verify_email_change.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/otp_code_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/password_input_field.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/identity_validators.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

enum _CredentialStep { form, verifyOtp }

class AmanahCredentialEmailChangeView extends StatefulWidget {
  const AmanahCredentialEmailChangeView({
    required this.requestEmailChangeUseCase,
    required this.verifyEmailChangeUseCase,
    required this.currentEmail,
    required this.hasPassword,
    required this.onSuccess,
    super.key,
  });

  final RequestEmailChangeUseCase requestEmailChangeUseCase;
  final VerifyEmailChangeUseCase verifyEmailChangeUseCase;
  final String currentEmail;
  final bool hasPassword;
  final VoidCallback onSuccess;

  @override
  State<AmanahCredentialEmailChangeView> createState() =>
      _AmanahCredentialEmailChangeViewState();
}

class _AmanahCredentialEmailChangeViewState
    extends State<AmanahCredentialEmailChangeView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final List<TextEditingController> _otpControllers =
      List<TextEditingController>.generate(6, (_) => TextEditingController());

  _CredentialStep _step = _CredentialStep.form;
  bool _isLoading = false;
  String? _errorMessage;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  bool get _isOtpComplete {
    return _otpControllers.every(
      (TextEditingController c) => c.text.trim().length == 1,
    );
  }

  String get _otpCode {
    return _otpControllers.map((TextEditingController c) => c.text.trim()).join();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _newEmailController.dispose();
    _passwordController.dispose();
    for (final TextEditingController c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds -= 1);
      }
    });
  }

  Future<void> _handleRequestOtp({bool isResend = false}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!isResend && !(_formKey.currentState?.validate() ?? false)) return;

    final String newEmail = _newEmailController.text.trim();
    final String password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool sent = await widget.requestEmailChangeUseCase(
        RequestEmailChangeParams(
          newEmail: newEmail,
          currentPassword: password.isNotEmpty ? password : null,
        ),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (sent) {
        setState(() => _step = _CredentialStep.verifyOtp);
        _startCooldown(60);
      } else {
        setState(() => _errorMessage = 'Gagal mengirim kode verifikasi ke email baru.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e
            .toString()
            .replaceFirst('ServerFailure: ', '')
            .replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String otp = _otpCode;
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Kode OTP harus berupa 6 digit angka.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool success = await widget.verifyEmailChangeUseCase(
        VerifyEmailChangeParams(
          newEmail: _newEmailController.text.trim(),
          otp: otp,
        ),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        widget.onSuccess();
      } else {
        setState(() => _errorMessage = 'Verifikasi kode OTP gagal.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e
            .toString()
            .replaceFirst('ServerFailure: ', '')
            .replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color secondaryTextColor = AmanahThemeTokens.textSecondary(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          _step == _CredentialStep.verifyOtp
              ? 'Verifikasi Email Baru'
              : 'Ubah Email Akun',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _step == _CredentialStep.verifyOtp
              ? 'Masukkan 6 digit kode OTP yang telah dikirim ke: ${_newEmailController.text.trim()}'
              : 'Kode OTP 6-digit verifikasi akan dikirimkan ke alamat email baru Anda.',
          style: TextStyle(fontSize: 13, color: secondaryTextColor),
        ),
        const SizedBox(height: 20),

        // Error Banner
        if (_errorMessage != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB91C1C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],

        if (_step == _CredentialStep.form) ...<Widget>[
          // Current Email Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AmanahThemeTokens.surfaceMuted(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AmanahThemeTokens.outlineStrong(context),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Email Sekarang',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.currentEmail,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Alamat Email Baru',
                    hintText: 'nama@instansi.com',
                    filled: true,
                    fillColor: AmanahThemeTokens.surfaceMuted(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AmanahThemeTokens.divider(context),
                      ),
                    ),
                  ),
                  validator: (String? val) {
                    final String trimmed = val?.trim() ?? '';
                    final String? err = IdentityValidators.email(trimmed);
                    if (err != null) return err;
                    if (trimmed.toLowerCase() == widget.currentEmail.trim().toLowerCase()) {
                      return 'Email baru tidak boleh sama dengan email saat ini.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                PasswordInputField(
                  label: 'Kata Sandi Saat Ini',
                  hintText: 'Masukkan kata sandi akun Anda',
                  controller: _passwordController,
                  validator: (String? val) {
                    if (widget.hasPassword && (val == null || val.isEmpty)) {
                      return 'Kata sandi saat ini wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AmanahButton.primary(
                  text: 'Kirim Kode Verifikasi',
                  isLoading: _isLoading,
                  isFullWidth: true,
                  size: AmanahButtonSize.large,
                  onPressed: _isLoading ? null : () => _handleRequestOtp(),
                ),
              ],
            ),
          ),
        ] else ...<Widget>[
          OtpCodeField(
            controllers: _otpControllers,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 14),
          Center(
            child: _cooldownSeconds > 0
                ? Text.rich(
                    TextSpan(
                      text: 'Kirim ulang kode dalam ',
                      children: <InlineSpan>[
                        TextSpan(
                          text: '00:${_cooldownSeconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AmanahColorTokens.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 13, color: secondaryTextColor),
                  )
                : TextButton(
                    onPressed: _isLoading ? null : () => _handleRequestOtp(isResend: true),
                    child: const Text(
                      'Kirim Ulang Kode OTP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AmanahColorTokens.brand,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          AmanahButton.primary(
            text: 'Verifikasi & Simpan Email',
            isLoading: _isLoading,
            isDisabled: !_isOtpComplete,
            isFullWidth: true,
            size: AmanahButtonSize.large,
            onPressed: (_isLoading || !_isOtpComplete) ? null : _handleVerifyOtp,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _step = _CredentialStep.form;
                      _errorMessage = null;
                    });
                  },
            child: Text(
              'Ubah Alamat Email Baru',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: secondaryTextColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
