import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahPrivacySecuritySettingsScreen extends StatefulWidget {
  const AmanahPrivacySecuritySettingsScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  State<AmanahPrivacySecuritySettingsScreen> createState() =>
      _AmanahPrivacySecuritySettingsScreenState();
}

class _AmanahPrivacySecuritySettingsScreenState
    extends State<AmanahPrivacySecuritySettingsScreen> {
  String _passwordStatus = 'Terakhir diubah 30 hari yang lalu';
  bool _biometricEnabled = true;

  void _editPassword() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah kata sandi',
      label: 'Masukkan kata sandi baru (minimal 8 karakter)',
      initialValue: '',
      obscureText: true,
      placeholder: 'Kata sandi baru...',
      onSave: (String val) {
        if (val.trim().isNotEmpty) {
          setState(() => _passwordStatus = 'Baru saja diperbarui');
        }
      },
    );
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
