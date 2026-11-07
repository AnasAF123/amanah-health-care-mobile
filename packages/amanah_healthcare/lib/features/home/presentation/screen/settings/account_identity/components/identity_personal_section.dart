import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/constants/gender_constants.dart';
import 'package:amanah_healthcare/features/home/presentation/components/account/amanah_masked_nik_setting_row.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/identity_display_extensions.dart';
import 'package:amanah_healthcare/features/home/presentation/state/account_identity_controller.dart';

/// Organism section presenting personal demographic and national identity fields.
class IdentityPersonalSection extends StatelessWidget {
  const IdentityPersonalSection({
    required this.controller,
    required this.onEditName,
    required this.onEditNik,
    required this.onEditBirthPlace,
    required this.onEditBirthDate,
    required this.onEditGender,
    super.key,
  });

  final AccountIdentityController controller;
  final VoidCallback onEditName;
  final VoidCallback onEditNik;
  final VoidCallback onEditBirthPlace;
  final VoidCallback onEditBirthDate;
  final VoidCallback onEditGender;

  @override
  Widget build(BuildContext context) {
    return AmanahSettingSection(
      title: 'Data Pribadi & Kependudukan',
      children: <Widget>[
        AmanahSettingEditableRow(
          label: 'Nama Lengkap (sesuai KTP / Gelar)',
          value: controller.name.orFallback(),
          onEdit: onEditName,
        ),
        AmanahMaskedNikSettingRow(
          label: 'NIK (Nomor Induk Kependudukan)',
          nik: controller.nik,
          onEdit: onEditNik,
        ),
        AmanahSettingEditableRow(
          label: 'Tempat Lahir',
          value: controller.birthPlace.orFallback(),
          onEdit: onEditBirthPlace,
        ),
        AmanahSettingEditableRow(
          label: 'Tanggal Lahir',
          value: controller.formatBirthDateDisplay(),
          onEdit: onEditBirthDate,
        ),
        AmanahSettingEditableRow(
          label: 'Jenis Kelamin',
          value: GenderConstants.toLabel(controller.gender),
          onEdit: onEditGender,
        ),
      ],
    );
  }
}
