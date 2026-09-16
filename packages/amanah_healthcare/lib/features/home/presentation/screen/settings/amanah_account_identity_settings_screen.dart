import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahAccountIdentitySettingsScreen extends StatefulWidget {
  const AmanahAccountIdentitySettingsScreen({
    required this.user,
    this.onBack,
    super.key,
  });

  final AmanahAuthUser user;
  final VoidCallback? onBack;

  @override
  State<AmanahAccountIdentitySettingsScreen> createState() =>
      _AmanahAccountIdentitySettingsScreenState();
}

class _AmanahAccountIdentitySettingsScreenState
    extends State<AmanahAccountIdentitySettingsScreen> {
  String _name = '';
  String _phone = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _name = widget.user.fullName;
    _phone = widget.user.phone;
    _email = widget.user.email;
  }

  void _editName() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah nama lengkap',
      label: 'Nama lengkap beserta gelar dokter',
      initialValue: _name,
      placeholder: 'dr. Nama dokter, Sp.A',
      onSave: (String val) {
        if (val.trim().isNotEmpty) {
          setState(() => _name = val.trim());
        }
      },
    );
  }

  void _editPhone() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah nomor telepon',
      label: 'Nomor aktif untuk verifikasi dan kontak darurat',
      initialValue: _phone,
      keyboardType: TextInputType.phone,
      placeholder: '+62 812-xxxx-xxxx',
      onSave: (String val) {
        if (val.trim().isNotEmpty) {
          setState(() => _phone = val.trim());
        }
      },
    );
  }

  void _editEmail() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah email resmi',
      label: 'Alamat email institusi atau resmi dokter',
      initialValue: _email,
      keyboardType: TextInputType.emailAddress,
      placeholder: 'dokter@rsamanah.co.id',
      onSave: (String val) {
        if (val.trim().isNotEmpty) {
          setState(() => _email = val.trim());
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
              title: 'Akun & identitas dokter',
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
                    // 1. Informasi pribadi dan kontak
                    AmanahSettingSection(
                      title: 'Informasi pribadi dan kontak',
                      children: <Widget>[
                        AmanahSettingEditableRow(
                          label: 'Nama lengkap',
                          value: _name,
                          onEdit: _editName,
                        ),
                        AmanahSettingInfoRow(
                          label: 'Spesialisasi medis',
                          value: widget.user.roleLabel,
                        ),
                        AmanahSettingEditableRow(
                          label: 'Nomor telepon / WhatsApp',
                          value: _phone,
                          onEdit: _editPhone,
                        ),
                        AmanahSettingEditableRow(
                          label: 'Email resmi',
                          value: _email,
                          onEdit: _editEmail,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Kredensial medis dan legalitas
                    const AmanahSettingSection(
                      title: 'Kredensial medis dan legalitas',
                      children: <Widget>[
                        AmanahSettingInfoRow(
                          label: 'NPWP',
                          value: '-',
                        ),
                        AmanahSettingInfoRow(
                          label: 'Nomor NIB',
                          value: '-',
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
