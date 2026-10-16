import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/change_password.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/request_password_reset.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/reset_password.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/verify_otp.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/password_input_field.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

enum ChangePasswordViewMode { standard, otpReset }

class AmanahChangePasswordSheet extends StatefulWidget {
  const AmanahChangePasswordSheet({
    required this.changePasswordUseCase,
    required this.requestPasswordResetUseCase,
    required this.verifyOtpUseCase,
    required this.resetPasswordUseCase,
    required this.userEmail,
    super.key,
  });

  final ChangePasswordUseCase changePasswordUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final String userEmail;

  static Future<bool?> show({
    required BuildContext context,
    required ChangePasswordUseCase changePasswordUseCase,
    required RequestPasswordResetUseCase requestPasswordResetUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required String userEmail,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => AmanahChangePasswordSheet(
        changePasswordUseCase: changePasswordUseCase,
        requestPasswordResetUseCase: requestPasswordResetUseCase,
        verifyOtpUseCase: verifyOtpUseCase,
        resetPasswordUseCase: resetPasswordUseCase,
        userEmail: userEmail,
      ),
    );
  }

  @override
  State<AmanahChangePasswordSheet> createState() =>
      _AmanahChangePasswordSheetState();
}

class _AmanahChangePasswordSheetState extends State<AmanahChangePasswordSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  ChangePasswordViewMode _mode = ChangePasswordViewMode.standard;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitStandard() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool success = await widget.changePasswordUseCase(
        ChangePasswordParams(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = 'Gagal memperbarui kata sandi akun.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('ServerFailure: ', '').replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handleRequestOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.userEmail.isEmpty) {
      setState(() => _errorMessage = 'Alamat email tidak ditemukan.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool sent = await widget.requestPasswordResetUseCase(
        RequestPasswordResetParams(email: widget.userEmail),
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (sent) {
          _mode = ChangePasswordViewMode.otpReset;
        } else {
          _errorMessage = 'Gagal mengirim kode OTP ke email.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('ServerFailure: ', '');
      });
    }
  }

  Future<void> _handleSubmitOtpReset() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Kode OTP harus berupa 6 digit angka.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool valid = await widget.verifyOtpUseCase(
        VerifyOtpParams(email: widget.userEmail, otp: otp),
      );

      if (!valid) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Kode OTP salah atau telah kedaluwarsa.';
        });
        return;
      }

      final bool success = await widget.resetPasswordUseCase(
        ResetPasswordParams(
          email: widget.userEmail,
          otp: otp,
          newPassword: _newPasswordController.text,
        ),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = 'Gagal mereset kata sandi via OTP.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('ServerFailure: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AmanahThemeTokens.surface(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color secondaryTextColor = AmanahThemeTokens.textSecondary(context);
    final Color primaryColor = AmanahThemeTokens.accent(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AmanahThemeTokens.divider(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                _mode == ChangePasswordViewMode.standard
                    ? 'Ubah Kata Sandi'
                    : 'Pemulihan Kata Sandi via OTP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _mode == ChangePasswordViewMode.standard
                    ? 'Masukkan kata sandi saat ini (atau sandi sementara dari email) dan tentukan kata sandi baru.'
                    : 'Kode OTP 6-digit dikirimkan ke email terdaftar: ${widget.userEmail}',
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),
              const SizedBox(height: 20),
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
              if (_mode == ChangePasswordViewMode.standard) ...<Widget>[
                PasswordInputField(
                  label: 'Kata Sandi Saat Ini / Sementara',
                  hintText: 'Masukkan kata sandi saat ini',
                  controller: _oldPasswordController,
                  validator: (String? val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Kata sandi saat ini wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ] else ...<Widget>[
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Kode OTP 6-Digit',
                    hintText: '123456',
                    counterText: '',
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
                    if (val == null || val.trim().length != 6) {
                      return 'Masukkan 6 digit kode OTP.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ],
              PasswordInputField(
                label: 'Kata Sandi Baru',
                hintText: 'Minimal 8 karakter',
                controller: _newPasswordController,
                validator: (String? val) {
                  if (val == null || val.length < 8) {
                    return 'Kata sandi minimal 8 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              PasswordInputField(
                label: 'Konfirmasi Kata Sandi Baru',
                hintText: 'Ulangi kata sandi baru',
                controller: _confirmPasswordController,
                validator: (String? val) {
                  if (val != _newPasswordController.text) {
                    return 'Konfirmasi kata sandi tidak cocok.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading
                    ? null
                    : (_mode == ChangePasswordViewMode.standard
                        ? _handleSubmitStandard
                        : _handleSubmitOtpReset),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _mode == ChangePasswordViewMode.standard
                            ? 'Simpan Kata Sandi'
                            : 'Verifikasi & Simpan Sandi',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              if (_mode == ChangePasswordViewMode.standard)
                TextButton(
                  onPressed: _isLoading ? null : _handleRequestOtp,
                  child: Text(
                    'Lupa kata sandi saat ini? Kirim kode OTP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() {
                            _mode = ChangePasswordViewMode.standard;
                            _errorMessage = null;
                          }),
                  child: Text(
                    'Kembali ke Ubah Kata Sandi Biasa',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
