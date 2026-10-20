import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/identity_display_extensions.dart';
import 'package:amanah_healthcare/features/home/presentation/state/account_identity_controller.dart';

/// Organism section presenting cascading administrative domicile address rows.
class IdentityAddressSection extends StatelessWidget {
  const IdentityAddressSection({
    required this.controller,
    required this.onEditProvince,
    required this.onEditRegency,
    required this.onEditDistrict,
    required this.onEditVillage,
    required this.onEditLine1,
    super.key,
  });

  final AccountIdentityController controller;
  final VoidCallback onEditProvince;
  final VoidCallback onEditRegency;
  final VoidCallback onEditDistrict;
  final VoidCallback onEditVillage;
  final VoidCallback onEditLine1;

  @override
  Widget build(BuildContext context) {
    return AmanahSettingSection(
      title: 'Alamat Domisili Kependudukan',
      children: <Widget>[
        AmanahSettingEditableRow(
          label: 'Provinsi',
          value: controller.province?.displayName ?? 'Pilih Provinsi',
          onEdit: onEditProvince,
        ),
        AmanahSettingEditableRow(
          label: 'Kabupaten / Kota',
          value: controller.regency?.displayName ??
              (controller.hasProvince
                  ? 'Pilih Kabupaten / Kota'
                  : 'Pilih provinsi terlebih dahulu'),
          onEdit: onEditRegency,
        ),
        AmanahSettingEditableRow(
          label: 'Kecamatan',
          value: controller.district?.displayName ??
              (controller.hasRegency
                  ? 'Pilih Kecamatan'
                  : 'Pilih kabupaten/kota terlebih dahulu'),
          onEdit: onEditDistrict,
        ),
        AmanahSettingEditableRow(
          label: 'Kelurahan / Desa',
          value: controller.village?.displayName ??
              (controller.hasDistrict
                  ? 'Pilih Kelurahan / Desa'
                  : 'Pilih kecamatan terlebih dahulu'),
          onEdit: onEditVillage,
        ),
        AmanahSettingEditableRow(
          label: 'Alamat Lengkap (Jalan, RT/RW, No. Rumah)',
          value: controller.line1.orFallback(),
          onEdit: onEditLine1,
        ),
      ],
    );
  }
}
