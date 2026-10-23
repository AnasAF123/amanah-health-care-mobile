import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/contracts/time_service.dart';
import 'package:amanah_healthcare/core/time/services/default_time_service.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_detail_grouped_card.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/sub_sheets/vaccine_history_sheet.dart';

/// Clinical presentation view for Child Immunization & Development Intake Form.
class ImmunizationIntakeView extends StatelessWidget {
  ImmunizationIntakeView({
    super.key,
    required this.immunization,
    required this.isDark,
    TimeService? timeService,
  }) : timeService = timeService ?? DefaultTimeService();

  final ImmunizationIntakeData immunization;
  final bool isDark;
  final TimeService timeService;

  String _formatDate(String? dateStr, {String style = 'human_medium'}) {
    if (dateStr == null || dateStr.trim().isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr.trim()).toLocal();
      return timeService.formatDate(dt, style: style);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAllergy =
        immunization.childAllergyHistory != null &&
        immunization.childAllergyHistory!.trim().isNotEmpty &&
        immunization.childAllergyHistory != 'Tidak ada alergi';

    final bool hasEntries = immunization.vaccineEntries.isNotEmpty;

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
              value: _formatDate(immunization.childBirthDate),
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
              value:
                  immunization.previousVaccineHistory ?? 'Belum ada catatan vaksinasi sebelumnya.',
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

        // Group 3: Rekam Vaksinasi Terjadwal (Interactive Sub-Sheet)
        if (hasEntries)
          PatientDetailGroupSection(
            title: 'Jadwal & Rekam Vaksinasi Anak',
            isDark: isDark,
            children: <Widget>[
              PatientDetailActionTile(
                icon: Icons.vaccines_rounded,
                value: 'Jadwal & Rekam Vaksinasi',
                label:
                    '${immunization.vaccineEntries.where((VaccineEntryItem e) => e.status.toUpperCase() == "GIVEN" || e.status == "Sudah").length} dari ${immunization.vaccineEntries.length} vaksin sudah diberikan',
                badgeText: '${immunization.vaccineEntries.length} Vaksin',
                isDark: isDark,
                showDivider: false,
                onTap: () => VaccineHistorySheet.show(
                  context,
                  entries: immunization.vaccineEntries,
                  isDark: isDark,
                  timeService: timeService,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
