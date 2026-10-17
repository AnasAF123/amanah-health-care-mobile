import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/intake_info_row.dart';

/// Clinical presentation view for General / Regular Consultation Intake Form.
class RegularIntakeView extends StatelessWidget {
  const RegularIntakeView({
    super.key,
    required this.regular,
    required this.fallbackComplaint,
    required this.isDark,
  });

  final RegularIntakeData? regular;
  final String? fallbackComplaint;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final String complaint = regular?.complaint ??
        fallbackComplaint ??
        'Tidak ada catatan keluhan khusus.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Data Rekam Pasien & Kunjungan',
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
                label: 'Layanan Poli',
                value: regular?.serviceName ?? 'Pemeriksaan Umum',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Jadwal Booking',
                value:
                    '${regular?.scheduledDate ?? "-"} • ${regular?.scheduledStartTime ?? "-"}',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Nomor NIK Pasien',
                value: regular?.nik ?? '-',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Golongan Darah / Gender',
                value:
                    '${regular?.bloodType ?? "-"} / ${regular?.gender ?? "-"}',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Nomor Telepon',
                value: regular?.phone ?? '-',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Alamat Tinggal',
                value: regular?.address ?? '-',
                isDark: isDark,
              ),
              if (regular?.emergencyContactName != null) ...<Widget>[
                const Divider(height: 20),
                IntakeInfoRow(
                  label: 'Kontak Darurat',
                  value:
                      '${regular!.emergencyContactName!} (${regular!.emergencyContactRelationship ?? "-"}) • ${regular!.emergencyContactPhone ?? "-"}',
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Keluhan & Catatan Medis',
          style: TextStyle(
            color: isDark
                ? AmanahColorTokens.surfaceLight
                : AmanahColorTokens.neutral900,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? AmanahColorTokens.surfaceDark
                : AmanahColorTokens.neutral50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AmanahColorTokens.neutral800
                  : AmanahColorTokens.neutral200,
            ),
          ),
          child: Text(
            complaint,
            style: TextStyle(
              color: isDark
                  ? AmanahColorTokens.neutral200
                  : AmanahColorTokens.neutral800,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
