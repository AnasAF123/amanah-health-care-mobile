import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_detail_grouped_card.dart';

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
        // Group 1: Status Obstetrik & Kehamilan
        PatientDetailGroupSection(
          title: 'Status Obstetrik & Kehamilan (ANC)',
          isDark: isDark,
          children: <Widget>[
            if (maternal.gpa != null)
              PatientDetailTile(
                icon: Icons.pregnant_woman_rounded,
                label: 'Status Gravida / Paritas / Abortus (GPA)',
                value: maternal.gpa!,
                isDark: isDark,
              ),
            PatientDetailTile(
              icon: Icons.event_note_rounded,
              label: 'Hari Pertama Haid Terakhir (HPHT)',
              value: maternal.hpht ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.event_available_rounded,
              label: 'Taksiran Persalinan (HPL)',
              value: maternal.estimatedDueDate ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.hourglass_bottom_rounded,
              label: 'Usia Kehamilan Saat Ini',
              value: maternal.gestationalAgeFormatted ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.favorite_border_rounded,
              label: 'Nama Suami / Pasangan',
              value: maternal.partnerName ?? '-',
              isDark: isDark,
              showDivider: false,
            ),
          ],
        ),

        // Group 2: Pemeriksaan Fisik & Skrining
        PatientDetailGroupSection(
          title: 'Pemeriksaan Fisik & Skrining Awal',
          isDark: isDark,
          children: <Widget>[
            PatientDetailTile(
              icon: Icons.straighten_rounded,
              label: 'Tinggi Badan',
              value: maternal.heightCm != null ? '${maternal.heightCm} cm' : '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.monitor_weight_outlined,
              label: 'Berat Badan Pra-Kehamilan',
              value: maternal.prePregnancyWeightKg != null
                  ? '${maternal.prePregnancyWeightKg} kg'
                  : '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.fitness_center_rounded,
              label: 'Lingkar Lengan Atas (LiLA)',
              value: maternal.upperArmCircumferenceCm != null
                  ? '${maternal.upperArmCircumferenceCm} cm'
                  : '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.speed_rounded,
              label: 'Indeks Massa Tubuh (IMT)',
              value: maternal.initialBmi != null ? '${maternal.initialBmi}' : '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.bloodtype_outlined,
              label: 'Golongan Darah Ibu',
              value: maternal.motherBloodType ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.vaccines_outlined,
              label: 'Status Imunisasi Tetanus Toksoid (TT)',
              value: maternal.tetanusStatus ?? '-',
              isDark: isDark,
              showDivider: false,
            ),
          ],
        ),

        // Group 3: Riwayat Persalinan Sebelumnya
        if (maternal.previousPregnancies.isNotEmpty)
          PatientDetailGroupSection(
            title: 'Riwayat Persalinan Sebelumnya',
            isDark: isDark,
            children: maternal.previousPregnancies
                .asMap()
                .entries
                .map((MapEntry<int, PreviousPregnancyItem> entry) {
              final int index = entry.key;
              final PreviousPregnancyItem p = entry.value;
              final bool isLast =
                  index == maternal.previousPregnancies.length - 1;
              return PatientDetailTile(
                icon: Icons.child_friendly_rounded,
                label: 'Anak Ke-${p.orderNumber} (Tahun ${p.birthYear ?? "-"})',
                value:
                    '${p.childSex ?? "Anak"}, Persalinan ${p.deliveryMethod ?? "Normal"} di ${p.deliveryPlace ?? "Faskes"}',
                isDark: isDark,
                showDivider: !isLast,
              );
            }).toList(),
          ),

        // Group 4: Riwayat Kontrasepsi (KB)
        if (maternal.contraceptiveHistories.isNotEmpty)
          PatientDetailGroupSection(
            title: 'Riwayat Kontrasepsi (KB)',
            isDark: isDark,
            children: maternal.contraceptiveHistories.asMap().entries.map((MapEntry<int, ContraceptiveHistoryItem> entry) {
              final int index = entry.key;
              final ContraceptiveHistoryItem c = entry.value;
              final bool isLast = index == maternal.contraceptiveHistories.length - 1;
              return PatientDetailTile(
                icon: Icons.medication_outlined,
                label: c.durationText ?? (c.startDate != null ? 'Mulai: ${c.startDate}' : '-'),
                value: c.contraceptiveType,
                isDark: isDark,
                showDivider: !isLast,
              );
            }).toList(),
          ),
      ],
    );
  }
}
