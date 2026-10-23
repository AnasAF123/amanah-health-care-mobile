import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/contracts/time_service.dart';
import 'package:amanah_healthcare/core/time/services/default_time_service.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_detail_grouped_card.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/sub_sheets/contraceptive_history_sheet.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/sub_sheets/disease_history_sheet.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/sub_sheets/maternal_timeline_sheet.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/sub_sheets/previous_pregnancies_sheet.dart';

/// Clinical presentation view for Maternal & Obstetric Intake Form (ANC / Kehamilan / Persalinan).
class MaternalIntakeView extends StatelessWidget {
  MaternalIntakeView({
    super.key,
    required this.maternal,
    required this.isDark,
    this.patientId,
    this.patientName,
    TimeService? timeService,
  }) : timeService = timeService ?? DefaultTimeService();

  final MaternalIntakeData maternal;
  final bool isDark;
  final String? patientId;
  final String? patientName;
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

  List<Widget> _buildHusbandTiles(MaternalHusbandData? husband, String? fallbackPartnerName) {
    final List<Widget> list = <Widget>[];
    list.add(
      PatientDetailTile(
        icon: Icons.favorite_border_rounded,
        label: 'Nama Suami / Pasangan',
        value: husband?.name ?? fallbackPartnerName ?? '-',
        isDark: isDark,
      ),
    );
    if (husband != null) {
      if (husband.nik != null && husband.nik!.trim().isNotEmpty) {
        list.add(
          PatientDetailTile(
            icon: Icons.badge_outlined,
            label: 'NIK Suami (Tersensor)',
            value: PatientDataMasker.maskNik(husband.nik),
            isDark: isDark,
          ),
        );
      }
      if (husband.birthDate != null && husband.birthDate!.trim().isNotEmpty) {
        list.add(
          PatientDetailTile(
            icon: Icons.cake_outlined,
            label: 'Tanggal Lahir Suami',
            value: _formatDate(husband.birthDate),
            isDark: isDark,
          ),
        );
      }
      if (husband.age != null) {
        list.add(
          PatientDetailTile(
            icon: Icons.person_outline_rounded,
            label: 'Usia Suami',
            value: '${husband.age} tahun',
            isDark: isDark,
          ),
        );
      }
      if (husband.job != null && husband.job!.trim().isNotEmpty) {
        list.add(
          PatientDetailTile(
            icon: Icons.work_outline_rounded,
            label: 'Pekerjaan Suami',
            value: husband.job!,
            isDark: isDark,
          ),
        );
      }
      if (husband.education != null && husband.education!.trim().isNotEmpty) {
        list.add(
          PatientDetailTile(
            icon: Icons.school_outlined,
            label: 'Pendidikan Terakhir',
            value: husband.education!,
            isDark: isDark,
          ),
        );
      }
      if (husband.bloodType != null && husband.bloodType!.trim().isNotEmpty) {
        list.add(
          PatientDetailTile(
            icon: Icons.bloodtype_outlined,
            label: 'Golongan Darah Suami',
            value: husband.bloodType!,
            isDark: isDark,
            showDivider: false,
          ),
        );
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final MaternalHusbandData? husband = maternal.husband;
    final bool hasHusband =
        husband != null ||
        (maternal.partnerName != null && maternal.partnerName!.trim().isNotEmpty);

    final List<MaternalDiseaseHistoryItem> positiveDiseases = maternal.diseaseHistoryList
        .where((MaternalDiseaseHistoryItem d) => d.hasDisease)
        .toList();

    final bool hasEnv =
        (maternal.puskesmas != null && maternal.puskesmas!.trim().isNotEmpty) ||
        (maternal.posyandu != null && maternal.posyandu!.trim().isNotEmpty) ||
        (maternal.dasawisma != null && maternal.dasawisma!.trim().isNotEmpty) ||
        (maternal.concerningEnvironmentNotes != null &&
            maternal.concerningEnvironmentNotes!.trim().isNotEmpty) ||
        (maternal.allergyInfo != null && maternal.allergyInfo!.trim().isNotEmpty) ||
        (maternal.otherNotes != null && maternal.otherNotes!.trim().isNotEmpty);

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
              value: _formatDate(maternal.hpht),
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.event_available_rounded,
              label: 'Taksiran Persalinan (HPL)',
              value: _formatDate(maternal.estimatedDueDate),
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.hourglass_bottom_rounded,
              label: 'Usia Kehamilan Saat Ini',
              value: maternal.gestationalAgeFormatted ?? '-',
              isDark: isDark,
              showDivider: false,
            ),
          ],
        ),

        // Group 2: Identitas Suami / Pasangan (Conditional)
        if (hasHusband)
          PatientDetailGroupSection(
            title: 'Identitas Suami / Pasangan',
            isDark: isDark,
            children: _buildHusbandTiles(husband, maternal.partnerName),
          ),

        // Group 3: Pemeriksaan Fisik & Skrining
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

        // Group 4: Riwayat Medis, Persalinan & Kontrasepsi (Interactive Sub-Sheets)
        PatientDetailGroupSection(
          title: 'Riwayat Medis & Obstetri (Detail Lengkap)',
          isDark: isDark,
          children: <Widget>[
            // 4.1: Riwayat Persalinan Sebelumnya
            if (maternal.previousPregnancies.isNotEmpty)
              PatientDetailActionTile(
                icon: Icons.child_friendly_rounded,
                value: 'Anak Ke-${maternal.previousPregnancies.first.orderNumber}',
                label:
                    'Tahun ${maternal.previousPregnancies.first.birthYear ?? "-"} • ${maternal.previousPregnancies.first.deliveryMethod ?? "Normal"}',
                badgeText: '${maternal.previousPregnancies.length} Anak',
                isDark: isDark,
                showDivider:
                    maternal.contraceptiveHistories.isNotEmpty ||
                    maternal.diseaseHistoryList.isNotEmpty ||
                    (patientId != null && patientId!.isNotEmpty),
                onTap: () => PreviousPregnanciesSheet.show(
                  context,
                  pregnancies: maternal.previousPregnancies,
                  isDark: isDark,
                ),
              ),

            // 4.2: Riwayat Kontrasepsi (KB)
            if (maternal.contraceptiveHistories.isNotEmpty)
              PatientDetailActionTile(
                icon: Icons.medication_outlined,
                value: maternal.contraceptiveHistories.first.contraceptiveType,
                label:
                    maternal.contraceptiveHistories.first.durationText ??
                    (maternal.contraceptiveHistories.first.startDate != null
                        ? 'Mulai ${_formatDate(maternal.contraceptiveHistories.first.startDate)}'
                        : 'Riwayat KB Aktif'),
                badgeText: '${maternal.contraceptiveHistories.length} Metode',
                isDark: isDark,
                showDivider:
                    maternal.diseaseHistoryList.isNotEmpty ||
                    (patientId != null && patientId!.isNotEmpty),
                onTap: () => ContraceptiveHistorySheet.show(
                  context,
                  histories: maternal.contraceptiveHistories,
                  isDark: isDark,
                  timeService: timeService,
                ),
              ),

            // 4.3: Skrining Riwayat Penyakit & Operasi
            if (maternal.diseaseHistoryList.isNotEmpty)
              PatientDetailActionTile(
                icon: Icons.health_and_safety_outlined,
                value: 'Skrining Penyakit & Operasi',
                label: positiveDiseases.isNotEmpty
                    ? '${positiveDiseases.length} kondisi terdiagnosis positif'
                    : 'Tidak ada catatan penyakit kronis',
                badgeText: positiveDiseases.isNotEmpty
                    ? '${positiveDiseases.length} Positif'
                    : 'Aman',
                isDark: isDark,
                showDivider: patientId != null && patientId!.isNotEmpty,
                onTap: () => DiseaseHistorySheet.show(
                  context,
                  diseases: maternal.diseaseHistoryList,
                  isDark: isDark,
                ),
              ),

            // 4.4: Timeline Riwayat Asuhan Kehamilan (Live DB Fetching)
            if (patientId != null && patientId!.isNotEmpty)
              PatientDetailActionTile(
                icon: Icons.timeline_rounded,
                value: 'Riwayat Asuhan Kehamilan',
                label: 'Daftar sesi pemeriksaan terdahulu',
                badgeText: 'Arsip DB',
                isDark: isDark,
                showDivider: false,
                onTap: () => MaternalTimelineSheet.show(
                  context,
                  patientId: patientId!,
                  patientName: patientName ?? 'Pasien',
                  isDark: isDark,
                  timeService: timeService,
                ),
              ),
          ],
        ),

        // Group 7: Lingkungan & Fasilitas Kesehatan Binaan (Conditional)
        if (hasEnv)
          PatientDetailGroupSection(
            title: 'Lingkungan & Fasilitas Binaan',
            isDark: isDark,
            children: <Widget>[
              if (maternal.puskesmas != null && maternal.puskesmas!.trim().isNotEmpty)
                PatientDetailTile(
                  icon: Icons.local_hospital_outlined,
                  label: 'Puskesmas Pembina',
                  value: maternal.puskesmas!,
                  isDark: isDark,
                ),
              if (maternal.posyandu != null && maternal.posyandu!.trim().isNotEmpty)
                PatientDetailTile(
                  icon: Icons.store_mall_directory_outlined,
                  label: 'Posyandu',
                  value: maternal.posyandu!,
                  isDark: isDark,
                ),
              if (maternal.dasawisma != null && maternal.dasawisma!.trim().isNotEmpty)
                PatientDetailTile(
                  icon: Icons.groups_outlined,
                  label: 'Kelompok Dasawisma',
                  value: maternal.dasawisma!,
                  isDark: isDark,
                ),
              if (maternal.concerningEnvironmentNotes != null &&
                  maternal.concerningEnvironmentNotes!.trim().isNotEmpty)
                PatientDetailTile(
                  icon: Icons.eco_outlined,
                  label: 'Kondisi Lingkungan Tempat Tinggal',
                  value: maternal.concerningEnvironmentNotes!,
                  isDark: isDark,
                ),
              if (maternal.allergyInfo != null && maternal.allergyInfo!.trim().isNotEmpty)
                PatientDetailTile(
                  icon: Icons.warning_amber_rounded,
                  label: 'Riwayat Alergi',
                  value: maternal.allergyInfo!,
                  isDark: isDark,
                ),
              if (maternal.otherNotes != null && maternal.otherNotes!.trim().isNotEmpty)
                PatientDetailTile(
                  icon: Icons.notes_rounded,
                  label: 'Catatan Tambahan',
                  value: maternal.otherNotes!,
                  isDark: isDark,
                  showDivider: false,
                ),
            ],
          ),
      ],
    );
  }
}
