import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_settings_components.dart';

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
  String _pinValue = '******';
  bool _biometricEnabled = true;
  bool _autoLockEnabled = true;
  bool _maskPatientNotif = true;

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

  void _editPin() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah PIN presensi',
      label: 'Masukkan 6-digit PIN baru',
      initialValue: '',
      keyboardType: TextInputType.number,
      obscureText: true,
      placeholder: '6 digit angka...',
      onSave: (String val) {
        if (val.trim().isNotEmpty) {
          setState(() => _pinValue = '******');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor = dark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFFF8FAFF);

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
                        AmanahSettingEditableRow(
                          label: 'PIN presensi dokter',
                          value: _pinValue,
                          helperText: 'PIN 6-digit untuk presensi manual',
                          onEdit: _editPin,
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
                        AmanahSettingToggleRow(
                          title: 'Kunci otomatis aplikasi',
                          subtitle:
                              'Kunci saat aplikasi tidak aktif selama 5 menit',
                          checked: _autoLockEnabled,
                          onToggle: () {
                            setState(
                              () => _autoLockEnabled = !_autoLockEnabled,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. Privasi data pasien
                    AmanahSettingSection(
                      title: 'Privasi data pasien',
                      children: <Widget>[
                        AmanahSettingToggleRow(
                          title: 'Samarkan nama pasien di notifikasi',
                          subtitle:
                              'Tampilkan inisial saja pada layar terkunci',
                          checked: _maskPatientNotif,
                          onToggle: () {
                            setState(
                              () => _maskPatientNotif = !_maskPatientNotif,
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
