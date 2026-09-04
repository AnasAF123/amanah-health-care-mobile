import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_settings_components.dart';

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
  String _phone = '+62 812-3456-7890';
  String _email = 'rayhan.pratama@rsamanah.co.id';

  @override
  void initState() {
    super.initState();
    _name = widget.user.fullName;
    _phone = '+62 812-3456-7890';
    _email = widget.user.email.isNotEmpty
        ? widget.user.email
        : 'rayhan.pratama@rsamanah.co.id';
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
                        const AmanahSettingInfoRow(
                          label: 'Spesialisasi medis',
                          value: 'Dokter Spesialis Anak',
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
                        const AmanahSettingInfoRow(
                          label: 'NIK',
                          value: '3171015508920003',
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
                          value: '09.254.382.1-013.000',
                        ),
                        AmanahSettingInfoRow(
                          label: 'Nomor NIB',
                          value: '9120001234567',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. Penugasan dan fasilitas kesehatan
                    const AmanahSettingSection(
                      title: 'Penugasan dan fasilitas kesehatan',
                      children: <Widget>[
                        AmanahSettingInfoRow(
                          label: 'Fasilitas kesehatan',
                          value: 'RS Amanah Sehat',
                        ),
                        AmanahSettingInfoRow(
                          label: 'Departemen',
                          value: 'Departemen ilmu kesehatan anak',
                        ),
                        AmanahSettingInfoRow(
                          label: 'Status kepegawaian',
                          value: 'Dokter spesialis tetap',
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
