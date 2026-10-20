import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/identity_display_extensions.dart';
import 'package:amanah_healthcare/features/home/presentation/state/account_identity_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Organism section presenting operational contact and admin-assigned staff identity.
class IdentityContactSection extends StatelessWidget {
  const IdentityContactSection({
    required this.controller,
    required this.onEditPhone,
    required this.onEditEmail,
    super.key,
  });

  final AccountIdentityController controller;
  final VoidCallback onEditPhone;
  final VoidCallback onEditEmail;

  @override
  Widget build(BuildContext context) {
    final Widget lockTrailing = Icon(
      Icons.lock_rounded,
      size: 16,
      color: AmanahThemeTokens.textTertiary(context),
    );

    return AmanahSettingSection(
      title: 'Kontak & Penugasan Operasional',
      children: <Widget>[
        AmanahSettingEditableRow(
          label: 'Nomor WhatsApp / Handphone',
          value: controller.phone.orFallback(),
          onEdit: onEditPhone,
        ),
        AmanahSettingEditableRow(
          label: 'Email Akun',
          value: controller.email.orFallback(),
          onEdit: onEditEmail,
        ),
        AmanahSettingInfoRow(
          label: 'Kode Staf / NIP (Ditetapkan Admin)',
          value: controller.staffCode ?? '-',
          trailing: lockTrailing,
        ),
        AmanahSettingInfoRow(
          label: 'Profesi / Jabatan (Ditetapkan Admin)',
          value: controller.profession,
          trailing: lockTrailing,
        ),
        AmanahSettingInfoRow(
          label: 'Poliklinik Penugasan (Ditetapkan Admin)',
          value: controller.poliklinikDisplay,
          trailing: lockTrailing,
        ),
      ],
    );
  }
}
