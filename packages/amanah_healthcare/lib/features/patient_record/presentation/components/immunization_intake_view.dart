import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/intake_info_row.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Skrining Imunisasi & Tumbuh Kembang',
          style: TextStyle(
            color: isDark
                ? AmanahColorTokens.surfaceLight
                : AmanahColorTokens.neutral900,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AmanahColorTokens.surfaceSecondaryDark
                : AmanahColorTokens.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AmanahColorTokens.neutral800
                  : AmanahColorTokens.neutral200,
            ),
          ),
          child: Column(
            children: <Widget>[
              IntakeInfoRow(
                label: 'Nama Anak',
                value: immunization.childName,
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'NIK Anak',
                value: immunization.childNik ?? '-',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Tanggal Lahir / Jenis Kelamin',
                value:
                    '${immunization.childBirthDate ?? "-"} / ${immunization.childSex ?? "-"}',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Orang Tua (Ayah / Ibu)',
                value:
                    '${immunization.fatherName ?? "-"} / ${immunization.motherName ?? "-"}',
                isDark: isDark,
              ),
              const Divider(height: 20),
              IntakeInfoRow(
                label: 'Riwayat Vaksinasi Sebelumnya',
                value: immunization.previousVaccineHistory ??
                    'Belum ada catatan vaksinasi sebelumnya.',
                isDark: isDark,
              ),
              if (immunization.childAllergyHistory != null &&
                  immunization.childAllergyHistory != 'Tidak ada alergi') ...<Widget>[
                const SizedBox(height: 8),
                IntakeInfoRow(
                  label: 'Riwayat Alergi Anak',
                  value: immunization.childAllergyHistory!,
                  isAlert: true,
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
