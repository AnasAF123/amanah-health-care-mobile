import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_detail_grouped_card.dart';

/// Clinical presentation view for Child Immunization & Development Intake Form.
class ImmunizationIntakeView extends StatelessWidget {
  const ImmunizationIntakeView({
    super.key,
    required this.immunization,
    required this.isDark,
  });

  final ImmunizationIntakeData immunization;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool hasAllergy = immunization.childAllergyHistory != null &&
        immunization.childAllergyHistory!.trim().isNotEmpty &&
        immunization.childAllergyHistory != 'Tidak ada alergi';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Group 1: Profil Anak & Orang Tua
        PatientDetailGroupSection(
          title: 'Identitas Anak & Keluarga',
          isDark: isDark,
          children: <Widget>[
            PatientDetailTile(
              icon: Icons.child_care_rounded,
              label: 'Nama Lengkap Anak',
              value: immunization.childName,
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.badge_outlined,
              label: 'NIK Anak (Tersensor)',
              value: PatientDataMasker.maskNik(immunization.childNik),
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.cake_outlined,
              label: 'Tanggal Lahir Anak',
              value: immunization.childBirthDate ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.wc_outlined,
              label: 'Jenis Kelamin Anak',
              value: immunization.childSex ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.person_outline_rounded,
              label: 'Nama Ayah',
              value: immunization.fatherName ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.escalator_warning_outlined,
              label: 'Nama Ibu',
              value: immunization.motherName ?? '-',
              isDark: isDark,
              showDivider: false,
            ),
          ],
        ),

        // Group 2: Riwayat Imunisasi & Kesehatan
        PatientDetailGroupSection(
          title: 'Riwayat Imunisasi & Alergi',
          isDark: isDark,
          children: <Widget>[
            PatientDetailTile(
              icon: Icons.vaccines_outlined,
              label: 'Riwayat Vaksinasi Sebelumnya',
              value: immunization.previousVaccineHistory ??
                  'Belum ada catatan vaksinasi sebelumnya.',
              isDark: isDark,
              showDivider: hasAllergy,
            ),
            if (hasAllergy)
              PatientDetailTile(
                icon: Icons.warning_amber_rounded,
                label: 'Catatan Riwayat Alergi',
                value: immunization.childAllergyHistory!,
                isDark: isDark,
                showDivider: false,
              ),
          ],
        ),
      ],
    );
  }
}
