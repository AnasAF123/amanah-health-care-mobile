import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_detail_grouped_card.dart';

/// Minimalist presentation view for General / Regular Consultation Intake Form.
/// Built with grouped inset card design matching modern minimalist styling.
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

  String _formatIsoTime(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(isoString).toLocal();
      final String hour = dt.hour.toString().padLeft(2, '0');
      final String minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute WIB';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String complaint = regular?.complaint ??
        fallbackComplaint ??
        'Tidak ada catatan keluhan khusus.';

    final bool hasEmergency = regular?.emergencyContactName != null &&
        regular!.emergencyContactName!.trim().isNotEmpty;

    final bool hasVillage = regular?.villageName != null &&
        regular!.villageName!.trim().isNotEmpty;
    final bool hasDistrict = regular?.districtName != null &&
        regular!.districtName!.trim().isNotEmpty;
    final bool hasRegency = regular?.regencyName != null &&
        regular!.regencyName!.trim().isNotEmpty;
    final bool hasProvince = regular?.provinceName != null &&
        regular!.provinceName!.trim().isNotEmpty;

    final bool hasActualStarted = regular?.actualStartedAt != null &&
        regular!.actualStartedAt!.trim().isNotEmpty;
    final bool hasActualCompleted = regular?.actualCompletedAt != null &&
        regular!.actualCompletedAt!.trim().isNotEmpty;
    final bool hasDuration = regular?.consultationDurationFormatted != null &&
        regular!.consultationDurationFormatted!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Group 1: Identitas Pasien
        PatientDetailGroupSection(
          title: 'Identitas Pasien',
          isDark: isDark,
          children: <Widget>[
            PatientDetailTile(
              icon: Icons.assignment_ind_outlined,
              label: 'Nomor Rekam Medis (No. RM)',
              value: regular?.medicalRecordNumber ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.badge_outlined,
              label: 'Nomor Induk Kependudukan (NIK)',
              value: PatientDataMasker.maskNik(regular?.nik),
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.location_city_outlined,
              label: 'Tempat Lahir',
              value: regular?.birthPlace ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.cake_outlined,
              label: 'Tanggal Lahir',
              value: regular?.birthDate ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.wc_outlined,
              label: 'Jenis Kelamin',
              value: regular?.genderDisplay ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.bloodtype_outlined,
              label: 'Golongan Darah',
              value: regular?.bloodType ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.work_outline_rounded,
              label: 'Pekerjaan',
              value: regular?.occupation ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.escalator_warning_outlined,
              label: 'Nama Ibu Kandung',
              value: regular?.motherName ?? '-',
              isDark: isDark,
              showDivider: false,
            ),
          ],
        ),

        // Group 2: Hubungan & Kontak Akun
        PatientDetailGroupSection(
          title: 'Hubungan & Kontak Akun',
          isDark: isDark,
          children: <Widget>[
            PatientDetailTile(
              icon: Icons.people_outline_rounded,
              label: 'Hubungan Kepemilikan Akun',
              value: regular?.relationshipDisplay ?? '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.phone_outlined,
              label: 'Nomor Telepon',
              value: (regular?.phone != null && regular!.phone!.trim().isNotEmpty)
                  ? regular!.phone!
                  : '-',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.mail_outline_rounded,
              label: 'Alamat Email',
              value: regular?.email ?? '-',
              isDark: isDark,
              showDivider: false,
            ),
          ],
        ),

        // Group 3: Domisili Tempat Tinggal
        PatientDetailGroupSection(
          title: 'Domisili Tempat Tinggal',
          isDark: isDark,
          children: <Widget>[
            PatientDetailTile(
              icon: Icons.home_outlined,
              label: 'Alamat Tempat Tinggal',
              value: regular?.address ?? '-',
              isDark: isDark,
              showDivider: hasVillage || hasDistrict || hasRegency || hasProvince,
            ),
            if (hasVillage)
              PatientDetailTile(
                icon: Icons.holiday_village_outlined,
                label: 'Kelurahan / Desa',
                value: regular!.villageName!,
                isDark: isDark,
                showDivider: hasDistrict || hasRegency || hasProvince,
              ),
            if (hasDistrict)
              PatientDetailTile(
                icon: Icons.map_outlined,
                label: 'Kecamatan',
                value: regular!.districtName!,
                isDark: isDark,
                showDivider: hasRegency || hasProvince,
              ),
            if (hasRegency)
              PatientDetailTile(
                icon: Icons.location_on_outlined,
                label: 'Kabupaten / Kota',
                value: regular!.regencyName!,
                isDark: isDark,
                showDivider: hasProvince,
              ),
            if (hasProvince)
              PatientDetailTile(
                icon: Icons.public_outlined,
                label: 'Provinsi',
                value: regular!.provinceName!,
                isDark: isDark,
                showDivider: false,
              ),
          ],
        ),

        // Group 4: Kunjungan & Layanan
        PatientDetailGroupSection(
          title: 'Kunjungan & Layanan',
          isDark: isDark,
          children: <Widget>[
            if (regular?.queueNumber != null &&
                regular!.queueNumber!.trim().isNotEmpty)
              PatientDetailTile(
                icon: Icons.confirmation_number_outlined,
                label: 'Nomor Antrean',
                value: regular!.queueNumber!,
                isDark: isDark,
              ),
            PatientDetailTile(
              icon: Icons.qr_code_rounded,
              label: 'Kode Booking Antrean',
              value: regular?.bookingCode ?? '-',
              isDark: isDark,
            ),
            if (regular?.poliklinikName != null &&
                regular!.poliklinikName!.trim().isNotEmpty)
              PatientDetailTile(
                icon: Icons.local_hospital_outlined,
                label: 'Poliklinik',
                value: regular!.poliklinikName!,
                isDark: isDark,
              ),
            PatientDetailTile(
              icon: Icons.medical_services_outlined,
              label: 'Layanan Medis',
              value: regular?.serviceName ?? 'Pemeriksaan Umum',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.person_pin_outlined,
              label: 'Dokter Penanggung Jawab',
              value: (regular?.doctorName != null &&
                      regular!.doctorName!.trim().isNotEmpty)
                  ? regular!.doctorName!
                  : 'Belum di-assign',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.meeting_room_outlined,
              label: 'Ruangan Praktik',
              value: (regular?.roomName != null &&
                      regular!.roomName!.trim().isNotEmpty)
                  ? regular!.roomName!
                  : 'Belum di-assign',
              isDark: isDark,
            ),
            PatientDetailTile(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal Kunjungan',
              value: regular?.scheduledDate ?? '-',
              isDark: isDark,
            ),
            if (regular?.sessionName != null &&
                regular!.sessionName!.trim().isNotEmpty)
              PatientDetailTile(
                icon: Icons.timelapse_rounded,
                label: 'Sesi Praktik',
                value: regular!.sessionName!,
                isDark: isDark,
              ),
            PatientDetailTile(
              icon: Icons.schedule_outlined,
              label: 'Estimasi Jam Layanan',
              value: regular?.practiceTimeFormatted ?? '-',
              isDark: isDark,
              showDivider:
                  hasActualStarted || hasActualCompleted || hasDuration,
            ),
            if (hasActualStarted)
              PatientDetailTile(
                icon: Icons.play_circle_outline_rounded,
                label: 'Waktu Mulai Pelayanan',
                value: _formatIsoTime(regular!.actualStartedAt),
                isDark: isDark,
                showDivider: hasActualCompleted || hasDuration,
              ),
            if (hasActualCompleted)
              PatientDetailTile(
                icon: Icons.check_circle_outline_rounded,
                label: 'Waktu Selesai Pelayanan',
                value: _formatIsoTime(regular!.actualCompletedAt),
                isDark: isDark,
                showDivider: hasDuration,
              ),
            if (hasDuration)
              PatientDetailTile(
                icon: Icons.hourglass_bottom_rounded,
                label: 'Durasi Pelayanan',
                value: regular!.consultationDurationFormatted!,
                isDark: isDark,
                showDivider: false,
              ),
          ],
        ),

        // Group 5: Keluhan Medis
        PatientDetailGroupSection(
          title: 'Keluhan Medis',
          isDark: isDark,
          children: <Widget>[
            PatientDetailTile(
              icon: Icons.notes_rounded,
              label: 'Catatan Keluhan Saat Pendaftaran',
              value: complaint,
              isDark: isDark,
              maxLines: 8,
              showDivider: false,
            ),
          ],
        ),

        // Group 6: Kontak Darurat (Conditional)
        if (hasEmergency)
          PatientDetailGroupSection(
            title: 'Kontak Darurat',
            isDark: isDark,
            children: <Widget>[
              PatientDetailTile(
                icon: Icons.contact_phone_outlined,
                label: 'Nama Kontak Darurat',
                value: regular!.emergencyContactName!,
                isDark: isDark,
              ),
              PatientDetailTile(
                icon: Icons.family_restroom_outlined,
                label: 'Hubungan Kontak Darurat',
                value: regular!.emergencyContactRelationship ?? '-',
                isDark: isDark,
              ),
              PatientDetailTile(
                icon: Icons.phone_in_talk_outlined,
                label: 'Nomor Telepon Darurat',
                value: regular!.emergencyContactPhone ?? '-',
                isDark: isDark,
                showDivider: false,
              ),
            ],
          ),
      ],
    );
  }
}
