import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/intake_info_row.dart';

/// Clinical presentation view for Maternal & Obstetric Intake Form (ANC / Kehamilan / Persalinan).
class MaternalIntakeView extends StatelessWidget {
  const MaternalIntakeView({
    super.key,
    required this.maternal,
    required this.isDark,
  });

  final MaternalIntakeData maternal;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Riwayat Medis KIA & Kehamilan (ANC)',
              style: TextStyle(
                color: isDark
                    ? AmanahColorTokens.surfaceLight
                    : AmanahColorTokens.neutral900,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (maternal.gpa != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.pink.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  maternal.gpa!,
                  style: TextStyle(
                    color: Colors.pink.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
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
                label: 'HPHT',
                value: maternal.hpht ?? '-',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Taksiran Persalinan (HPL)',
                value: maternal.estimatedDueDate ?? '-',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Usia Kehamilan',
                value: maternal.gestationalAgeFormatted ?? '-',
                isDark: isDark,
              ),
              const Divider(height: 20),
              IntakeInfoRow(
                label: 'TB / BB Awal',
                value:
                    '${maternal.heightCm != null ? "${maternal.heightCm} cm" : "-"} / ${maternal.prePregnancyWeightKg != null ? "${maternal.prePregnancyWeightKg} kg" : "-"}',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'LiLA / IMT Awal',
                value:
                    '${maternal.upperArmCircumferenceCm != null ? "${maternal.upperArmCircumferenceCm} cm" : "-"} / ${maternal.initialBmi ?? "-"}',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Gol. Darah / Status TT',
                value:
                    '${maternal.motherBloodType ?? "-"} / ${maternal.tetanusStatus ?? "-"}',
                isDark: isDark,
              ),
              IntakeInfoRow(
                label: 'Nama Suami / Pasangan',
                value: maternal.partnerName ?? '-',
                isDark: isDark,
              ),
            ],
          ),
        ),
        if (maternal.previousPregnancies.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          Text(
            'Riwayat Persalinan Sebelumnya',
            style: TextStyle(
              color: isDark
                  ? AmanahColorTokens.surfaceLight
                  : AmanahColorTokens.neutral900,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...maternal.previousPregnancies.map((PreviousPregnancyItem p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AmanahColorTokens.surfaceDark
                    : AmanahColorTokens.neutral50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AmanahColorTokens.neutral800
                      : AmanahColorTokens.neutral200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Anak Ke-${p.orderNumber} (${p.birthYear ?? "-"})',
                        style: TextStyle(
                          color: isDark
                              ? AmanahColorTokens.surfaceLight
                              : AmanahColorTokens.neutral900,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${p.childSex ?? "-"} • ${p.birthWeightGrams != null ? "${p.birthWeightGrams} g" : "-"}',
                        style: TextStyle(
                          color: isDark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cara: ${p.deliveryMethod ?? "-"} • Penolong: ${p.birthAttendant ?? "-"} • Tempat: ${p.deliveryPlace ?? "-"}',
                    style: TextStyle(
                      color: isDark
                          ? AmanahColorTokens.neutral400
                          : AmanahColorTokens.neutral600,
                      fontSize: 11,
                    ),
                  ),
                  if (p.complications != null &&
                      p.complications != 'Tidak ada') ...<Widget>[
                    const SizedBox(height: 3),
                    Text(
                      'Komplikasi: ${p.complications}',
                      style: TextStyle(
                        color: AmanahColorTokens.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
        if (maternal.contraceptiveHistories.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          Text(
            'Riwayat Kontrasepsi (KB)',
            style: TextStyle(
              color: isDark
                  ? AmanahColorTokens.surfaceLight
                  : AmanahColorTokens.neutral900,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...maternal.contraceptiveHistories.map((ContraceptiveHistoryItem c) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AmanahColorTokens.surfaceDark
                    : AmanahColorTokens.neutral50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AmanahColorTokens.neutral800
                      : AmanahColorTokens.neutral200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    c.contraceptiveType,
                    style: TextStyle(
                      color: isDark
                          ? AmanahColorTokens.surfaceLight
                          : AmanahColorTokens.neutral900,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    c.durationText ??
                        (c.startDate != null ? 'Mulai: ${c.startDate}' : '-'),
                    style: TextStyle(
                      color: isDark
                          ? AmanahColorTokens.neutral400
                          : AmanahColorTokens.neutral600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
