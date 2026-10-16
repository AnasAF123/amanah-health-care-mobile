import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/authentication.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/components/settings/amanah_change_password_sheet.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahPrivacySecuritySettingsScreen extends StatefulWidget {
  const AmanahPrivacySecuritySettingsScreen({
    this.user,
    this.changePasswordUseCase,
    this.requestPasswordResetUseCase,
    this.verifyOtpUseCase,
    this.resetPasswordUseCase,
    this.onBack,
    super.key,
  });

  final AmanahAuthUser? user;
  final ChangePasswordUseCase? changePasswordUseCase;
  final RequestPasswordResetUseCase? requestPasswordResetUseCase;
  final VerifyOtpUseCase? verifyOtpUseCase;
  final ResetPasswordUseCase? resetPasswordUseCase;
  final VoidCallback? onBack;

  @override
  State<AmanahPrivacySecuritySettingsScreen> createState() =>
      _AmanahPrivacySecuritySettingsScreenState();
}

class _AmanahPrivacySecuritySettingsScreenState
    extends State<AmanahPrivacySecuritySettingsScreen> {
  String _passwordStatus = 'Terakhir diubah 30 hari yang lalu';
  bool _biometricEnabled = true;

  late final AuthRepository _repository = const AmanahAuthRepository();
  late final ChangePasswordUseCase _changePasswordUseCase =
      widget.changePasswordUseCase ?? ChangePasswordUseCase(_repository);
  late final RequestPasswordResetUseCase _requestPasswordResetUseCase =
      widget.requestPasswordResetUseCase ??
          RequestPasswordResetUseCase(_repository);
  late final VerifyOtpUseCase _verifyOtpUseCase =
      widget.verifyOtpUseCase ?? VerifyOtpUseCase(_repository);
  late final ResetPasswordUseCase _resetPasswordUseCase =
      widget.resetPasswordUseCase ?? ResetPasswordUseCase(_repository);

  Future<void> _editPassword() async {
    final String email = widget.user?.email ?? '';
    final bool? result = await AmanahChangePasswordSheet.show(
      context: context,
      changePasswordUseCase: _changePasswordUseCase,
      requestPasswordResetUseCase: _requestPasswordResetUseCase,
      verifyOtpUseCase: _verifyOtpUseCase,
      resetPasswordUseCase: _resetPasswordUseCase,
      userEmail: email,
    );

    if (result == true && mounted) {
      setState(() => _passwordStatus = 'Baru saja diperbarui');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi akun Anda berhasil diperbarui.'),
          backgroundColor: Color(0xFF0284C7),
          behavior: SnackBarBehavior.floating,
        ),
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
              title: 'Privasi & keamanan',
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
                      title: 'Kredensial dan sandi',
                      children: <Widget>[
                        AmanahSettingEditableRow(
                          label: 'Kata sandi akun',
                          value: _passwordStatus,
                          onEdit: _editPassword,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Keamanan perangkat
                    AmanahSettingSection(
                      title: 'Keamanan perangkat',
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
