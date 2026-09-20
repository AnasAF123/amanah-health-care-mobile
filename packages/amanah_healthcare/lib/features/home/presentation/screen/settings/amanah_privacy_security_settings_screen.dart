import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/otp_code_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/password_requirements.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_success_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahPrivacySecuritySettingsScreen extends StatefulWidget {
  const AmanahPrivacySecuritySettingsScreen({
    this.user,
    this.repository = const AmanahAuthRepository(),
    this.onBack,
    super.key,
  });

  final AmanahAuthUser? user;
  final AmanahAuthRepository repository;
  final VoidCallback? onBack;

  @override
  State<AmanahPrivacySecuritySettingsScreen> createState() =>
      _AmanahPrivacySecuritySettingsScreenState();
}

class _AmanahPrivacySecuritySettingsScreenState
    extends State<AmanahPrivacySecuritySettingsScreen> {
  String _passwordStatus = 'Terakhir diubah 30 hari yang lalu';
  bool _biometricEnabled = true;

  Future<void> _openPasswordSheet() async {
    final bool? success = await showAmanahBottomSheet<bool>(
      context: context,
      builder: (BuildContext sheetContext) {
        return _PasswordManagementSheet(
          user: widget.user,
          repository: widget.repository,
        );
      },
    );

    if (success == true && mounted) {
      setState(() => _passwordStatus = 'Baru saja diperbarui');
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      await AmanahSuccessDrawer.show(
        context,
        title: 'Kata Sandi Berhasil Diperbarui!',
        subtitle:
            'Kata sandi akun Anda telah berhasil diperbarui dan disinkronkan. Gunakan kata sandi baru untuk sesi masuk berikutnya.',
        infoTitle: 'Keamanan Kredensial',
        infoSubtitle: 'Tersinkronisasi & Terlindungi',
        infoIcon: Icons.verified_user_rounded,
        primaryButtonText: 'Selesai',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AmanahThemeTokens.canvas(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: 'Privasi & Keamanan',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  130 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Kredensial dan sandi
                    AmanahSettingSection(
                      title: 'Kredensial dan Sandi',
                      children: <Widget>[
                        AmanahSettingEditableRow(
                          label: 'Kata sandi akun',
                          value: _passwordStatus,
                          helperText:
                              'Ganti kata sandi secara berkala untuk menjaga keamanan akun',
                          onEdit: _openPasswordSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Keamanan perangkat
                    AmanahSettingSection(
                      title: 'Keamanan Perangkat',
                      children: <Widget>[
                        AmanahSettingToggleRow(
                          title: 'Login biometrik',
                          subtitle: 'Gunakan sidik jari atau pemindai wajah',
                          checked: _biometricEnabled,
                          onToggle: () {
                            setState(
                              () => _biometricEnabled = !_biometricEnabled,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PasswordSheetMode {
  change,
  forgotOtp,
  forgotNewPassword,
}

class _PasswordManagementSheet extends StatefulWidget {
  const _PasswordManagementSheet({
    required this.user,
    required this.repository,
  });

  final AmanahAuthUser? user;
  final AmanahAuthRepository repository;

  @override
  State<_PasswordManagementSheet> createState() =>
      _PasswordManagementSheetState();
}

class _PasswordManagementSheetState extends State<_PasswordManagementSheet> {
  final GlobalKey<FormState> _changeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _newPasswordFormKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _resetPasswordController =
      TextEditingController();
  final TextEditingController _resetConfirmPasswordController =
      TextEditingController();

  final List<TextEditingController> _otpControllers =
      List<TextEditingController>.generate(6, (_) => TextEditingController());

  _PasswordSheetMode _mode = _PasswordSheetMode.change;
  bool _isLoading = false;
  String? _errorMessage;
  String _savedOtp = '';

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resetPasswordController.dispose();
    _resetConfirmPasswordController.dispose();
    for (final TextEditingController c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _email => widget.user?.email.trim() ?? '';

  Future<void> _submitChangePassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_changeFormKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!AmanahPasswordRequirements.evaluate(
      _newPasswordController.text,
    ).isComplete) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Konfirmasi kata sandi baru tidak cocok.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AmanahAuthLogger.logLifecycle(
      'Profile change password initiated',
      details: <String, dynamic>{'email': _email},
    );

    try {
      final bool success = await widget.repository.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        AmanahAuthLogger.logLifecycle(
          'Profile change password succeeded',
          details: <String, dynamic>{'email': _email},
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage =
              'Gagal mengubah kata sandi. Periksa kata sandi saat ini.';
        });
      }
    } on AmanahAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat mengubah kata sandi.';
      });
    }
  }

  Future<void> _requestForgotOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_email.isEmpty) {
      setState(() {
        _errorMessage =
            'Email akun tidak ditemukan. Silakan masuk kembali terlebih dahulu.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AmanahAuthLogger.logLifecycle(
      'Profile forgot password OTP requested',
      details: <String, dynamic>{'email': _email},
    );

    try {
      final bool sent = await widget.repository.requestPasswordReset(_email);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (sent) {
        for (final TextEditingController c in _otpControllers) {
          c.clear();
        }
        setState(() {
          _mode = _PasswordSheetMode.forgotOtp;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage =
              'Gagal mengirim kode OTP. Pastikan email akun valid.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat meminta kode OTP.';
      });
    }
  }

  Future<void> _verifyForgotOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final String code =
        _otpControllers.map((TextEditingController c) => c.text.trim()).join();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Masukkan 6 digit kode OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AmanahAuthLogger.logLifecycle(
      'Profile forgot password OTP challenge verification',
      details: <String, dynamic>{'email': _email},
    );

    try {
      final bool valid =
          await widget.repository.checkVerificationOtp(_email, code);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (valid) {
        _savedOtp = code;
        _resetPasswordController.clear();
        _resetConfirmPasswordController.clear();
        setState(() {
          _mode = _PasswordSheetMode.forgotNewPassword;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Kode OTP salah atau telah kedaluwarsa.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat memverifikasi kode OTP.';
      });
    }
  }

  Future<void> _submitForgotNewPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_newPasswordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!AmanahPasswordRequirements.evaluate(
      _resetPasswordController.text,
    ).isComplete) {
      return;
    }

    if (_resetPasswordController.text !=
        _resetConfirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Konfirmasi kata sandi baru tidak cocok.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AmanahAuthLogger.logLifecycle(
      'Profile forgot password reset submission',
      details: <String, dynamic>{'email': _email},
    );

    try {
      final bool success = await widget.repository.resetPassword(
        _email,
        _savedOtp,
        _resetPasswordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        AmanahAuthLogger.logLifecycle(
          'Profile forgot password reset completed successfully',
          details: <String, dynamic>{'email': _email},
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage =
              'Gagal memperbarui kata sandi. Silakan coba kembali.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat memperbarui kata sandi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = AmanahThemeTokens.isDark(context);

    final String title = switch (_mode) {
      _PasswordSheetMode.change => 'Ubah Kata Sandi Akun',
      _PasswordSheetMode.forgotOtp => 'Verifikasi Kode OTP',
      _PasswordSheetMode.forgotNewPassword => 'Buat Kata Sandi Baru',
    };

    final String subtitle = switch (_mode) {
      _PasswordSheetMode.change =>
        'Perbarui kata sandi secara berkala untuk menjaga keamanan akun',
      _PasswordSheetMode.forgotOtp =>
        'Kode OTP 6 digit telah dikirimkan ke email akun',
      _PasswordSheetMode.forgotNewPassword =>
        'Tentukan kata sandi baru untuk akun Anda',
    };

    final Widget body = switch (_mode) {
      _PasswordSheetMode.change => _buildChangePasswordBody(theme, dark),
      _PasswordSheetMode.forgotOtp => _buildForgotOtpBody(theme, dark),
      _PasswordSheetMode.forgotNewPassword =>
        _buildForgotNewPasswordBody(theme, dark),
    };

    final Widget footer = switch (_mode) {
      _PasswordSheetMode.change => _buildChangePasswordFooter(dark),
      _PasswordSheetMode.forgotOtp => _buildForgotOtpFooter(dark),
      _PasswordSheetMode.forgotNewPassword =>
        _buildForgotNewPasswordFooter(dark),
    };

    return AmanahBottomSheetScaffold(
      title: title,
      subtitle: subtitle,
      fixedHeightFactor: 0.86,
      minHeight: 360,
      trailing: IconButton(
        icon: const Icon(Icons.close_rounded, size: 20),
        color: AmanahThemeTokens.textSecondary(context),
        tooltip: 'Tutup',
        onPressed: () => Navigator.of(context).pop(),
      ),
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: footer,
      body: body,
    );
  }

  Widget _buildChangePasswordBody(ThemeData theme, bool dark) {
    final Color textColor = AmanahThemeTokens.textPrimary(context);

    return Form(
      key: _changeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Kata Sandi Saat Ini *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          AuthInputField(
            label: 'Kata Sandi Saat Ini',
            hintText: 'Masukkan kata sandi lama Anda',
            controller: _currentPasswordController,
            leadingIcon: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (String? val) {
              if ((val ?? '').isEmpty) {
                return 'Kata sandi saat ini wajib diisi.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Kata Sandi Baru *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          AuthInputField(
            label: 'Kata Sandi Baru',
            hintText: 'Minimal 8 karakter (huruf, angka, simbol)',
            controller: _newPasswordController,
            leadingIcon: Icons.lock_reset_rounded,
            obscureText: true,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            validator: (String? val) {
              return AmanahPasswordRequirements.validate(
                val,
                requiredMessage: 'Kata sandi baru wajib diisi.',
              );
            },
          ),
          _buildPasswordRequirementsChecklist(
            _newPasswordController.text,
            theme,
            dark,
          ),
          const SizedBox(height: 16),
          Text(
            'Konfirmasi Kata Sandi Baru *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          AuthInputField(
            label: 'Konfirmasi Kata Sandi Baru',
            hintText: 'Ketik ulang kata sandi baru Anda',
            controller: _confirmPasswordController,
            leadingIcon: Icons.lock_reset_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitChangePassword(),
            validator: (String? val) {
              if ((val ?? '').isEmpty) {
                return 'Konfirmasi kata sandi wajib diisi.';
              }
              if (val != _newPasswordController.text) {
                return 'Konfirmasi kata sandi tidak cocok.';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...<Widget>[
            const SizedBox(height: 16),
            AuthInlineValidationMessage(message: _errorMessage!),
          ],
          const SizedBox(height: AmanahSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildChangePasswordFooter(bool dark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AmanahButton.primary(
          text: 'Simpan Kata Sandi Baru',
          isLoading: _isLoading,
          isFullWidth: true,
          size: AmanahButtonSize.medium,
          onPressed: _submitChangePassword,
        ),
        const SizedBox(height: AmanahSpacing.xs),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isLoading ? null : _requestForgotOtp,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Lupa kata sandi saat ini? Reset dengan kode OTP',
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.cyanAccent
                    : AmanahColorTokens.brand,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotOtpBody(ThemeData theme, bool dark) {
    final Color textColor = AmanahThemeTokens.textPrimary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                : AmanahColorTokens.canvasLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AmanahThemeTokens.outline(context)),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.mail_outline_rounded,
                size: 20,
                color: dark
                    ? AmanahColorTokens.cyanAccent
                    : AmanahColorTokens.brand,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Email Penerima',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AmanahThemeTokens.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email.isNotEmpty ? _email : 'Email tidak ditemukan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Masukkan 6 Digit Kode OTP *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: OtpCodeField(
            controllers: _otpControllers,
            onChanged: () => setState(() {}),
          ),
        ),
        if (_errorMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          AuthInlineValidationMessage(message: _errorMessage!),
        ],
        const SizedBox(height: AmanahSpacing.lg),
      ],
    );
  }

  Widget _buildForgotOtpFooter(bool dark) {
    final bool canVerify = _otpControllers.every(
      (TextEditingController c) => c.text.trim().length == 1,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AmanahButton.primary(
          text: 'Verifikasi Kode OTP',
          isLoading: _isLoading,
          isFullWidth: true,
          size: AmanahButtonSize.medium,
          onPressed: canVerify ? _verifyForgotOtp : null,
        ),
        const SizedBox(height: AmanahSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _mode = _PasswordSheetMode.change;
                  _errorMessage = null;
                });
              },
              child: Text(
                'Kembali',
                style: TextStyle(
                  color: AmanahThemeTokens.textSecondary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _requestForgotOtp,
              child: Text(
                'Kirim Ulang OTP',
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.cyanAccent
                      : AmanahColorTokens.brand,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForgotNewPasswordBody(ThemeData theme, bool dark) {
    final Color textColor = AmanahThemeTokens.textPrimary(context);

    return Form(
      key: _newPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Kata Sandi Baru *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          AuthInputField(
            label: 'Kata Sandi Baru',
            hintText: 'Minimal 8 karakter (huruf, angka, simbol)',
            controller: _resetPasswordController,
            leadingIcon: Icons.lock_reset_rounded,
            obscureText: true,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            validator: (String? val) {
              return AmanahPasswordRequirements.validate(
                val,
                requiredMessage: 'Kata sandi baru wajib diisi.',
              );
            },
          ),
          _buildPasswordRequirementsChecklist(
            _resetPasswordController.text,
            theme,
            dark,
          ),
          const SizedBox(height: 16),
          Text(
            'Konfirmasi Kata Sandi Baru *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          AuthInputField(
            label: 'Konfirmasi Kata Sandi Baru',
            hintText: 'Ketik ulang kata sandi baru Anda',
            controller: _resetConfirmPasswordController,
            leadingIcon: Icons.lock_reset_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitForgotNewPassword(),
            validator: (String? val) {
              if ((val ?? '').isEmpty) {
                return 'Konfirmasi kata sandi wajib diisi.';
              }
              if (val != _resetPasswordController.text) {
                return 'Konfirmasi kata sandi tidak cocok.';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...<Widget>[
            const SizedBox(height: 16),
            AuthInlineValidationMessage(message: _errorMessage!),
          ],
          const SizedBox(height: AmanahSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildForgotNewPasswordFooter(bool dark) {
    return AmanahButton.primary(
      text: 'Perbarui Kata Sandi',
      isLoading: _isLoading,
      isFullWidth: true,
      size: AmanahButtonSize.medium,
      onPressed: _submitForgotNewPassword,
    );
  }

  Widget _buildPasswordRequirementsChecklist(
    String password,
    ThemeData theme,
    bool dark,
  ) {
    if (password.isEmpty) return const SizedBox.shrink();

    final Color textColor = AmanahThemeTokens.textSecondary(context);
    final Color successColor = dark
        ? const Color(0xFF34D399)
        : AmanahColorTokens.successDark;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AmanahPasswordRequirements.rules.map((rule) {
          final bool met = rule.isMet(password);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: <Widget>[
                Icon(
                  met
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 14,
                  color: met
                      ? successColor
                      : textColor.withValues(alpha: 0.50),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rule.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: met ? FontWeight.w600 : FontWeight.w500,
                      color: met ? successColor : textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
