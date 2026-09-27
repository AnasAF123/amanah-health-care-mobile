import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/card_decoration_layers.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/patient_detail_modal_painters.dart';

class AmanahPatientDetailModal extends StatelessWidget {
  const AmanahPatientDetailModal({
    required this.patient,
    required this.schedule,
    super.key,
  });

  final BookedPatient patient;
  final DoctorSchedule schedule;

  static void show(
    BuildContext context,
    BookedPatient patient,
    DoctorSchedule schedule,
  ) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) =>
          AmanahPatientDetailModal(patient: patient, schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return AmanahBottomSheetScaffold(
      title: 'Detail rekam pasien',
      fixedHeightFactor: 0.92,
      minHeight: 540,
      bodyPadding: EdgeInsets.zero,
      extendBodyBehindHeader: true,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: CustomPaint(
              painter: PatientDetailAuroraPainter(dark: dark),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AmanahSpacing.xxl,
              AmanahSpacing.md,
              AmanahSpacing.xxl,
              AmanahSpacing.xxl,
            ),
            child: Column(
              children: <Widget>[
                _PatientProfileHeader(patient: patient, dark: dark),
                const SizedBox(height: AmanahSpacing.lg),
                _PatientSpecificationTable(
                  patient: patient,
                  schedule: schedule,
                  dark: dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientProfileHeader extends StatelessWidget {
  const _PatientProfileHeader({required this.patient, required this.dark});

  final BookedPatient patient;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomPaint(
          size: const Size(64, 76),
          painter: QueueBadgePainter(patient.queueNumber),
        ),
        const SizedBox(height: 12),
        Text(
          patient.patientName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? AmanahColorTokens.pureWhite : AmanahColorTokens.neutral950,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        _PatientMetaInline(patient: patient, dark: dark),
      ],
    );
  }
}

class _PatientMetaInline extends StatelessWidget {
  const _PatientMetaInline({required this.patient, required this.dark});

  final BookedPatient patient;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(patient.patientRm, style: _style),
          _PatientMetaDivider(dark: dark),
          Text(
            patient.patientAge.isNotEmpty
                ? 'Usia ${patient.patientAge}'
                : (patient.birthDate != null && patient.birthDate!.isNotEmpty
                    ? patient.birthDate!
                    : '-'),
            style: _style,
          ),
          _PatientMetaDivider(dark: dark),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: patient.badgeVariant == AmanahBadgeVariant.success
                  ? (dark
                        ? AmanahColorTokens.success.withValues(alpha: 0.20)
                        : AmanahColorTokens.successSurface)
                  : (dark
                        ? AmanahColorTokens.cyanAccent.withValues(alpha: 0.20)
                        : AmanahColorTokens.brandSurface),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              patient.badge,
              style: TextStyle(
                color: patient.badgeVariant == AmanahBadgeVariant.success
                    ? (dark ? AmanahColorTokens.emerald : AmanahColorTokens.successDark)
                    : (dark
                          ? AmanahColorTokens.cyanAccent
                          : AmanahColorTokens.auroraAccentDark),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _style => TextStyle(
    color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}

class _PatientMetaDivider extends StatelessWidget {
  const _PatientMetaDivider({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: dark
          ? AmanahColorTokens.pureWhite.withValues(alpha: 0.20)
          : AmanahColorTokens.neutral300,
    );
  }
}

class _PatientSpecificationTable extends StatelessWidget {
  const _PatientSpecificationTable({
    required this.patient,
    required this.schedule,
    required this.dark,
  });

  final BookedPatient patient;
  final DoctorSchedule schedule;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _dividerColor),
          bottom: BorderSide(color: _dividerColor),
        ),
      ),
      child: Column(
        children: <Widget>[
          PatientSpecRow(
            label: 'Waktu / jam booking',
            value: patient.timeSlot.isNotEmpty ? patient.timeSlot : '-',
            dark: dark,
          ),
          PatientSpecRow(
            label: 'Sesi praktik',
            value: '${schedule.title} (${schedule.poli})',
            dark: dark,
          ),
          PatientSpecRow(
            label: 'Ruang praktik',
            value: schedule.room,
            dark: dark,
          ),
          PatientSpecRow(
            label: 'Nomor NIK KTP',
            value: patient.nik != null && patient.nik!.isNotEmpty ? patient.nik! : '-',
            dark: dark,
          ),
          PatientSpecRow(
            label: 'Jenis Kelamin',
            value: patient.gender != null && patient.gender!.isNotEmpty ? patient.gender! : '-',
            dark: dark,
          ),
          PatientSpecRow(
            label: 'Golongan Darah',
            value: patient.bloodType != null && patient.bloodType!.isNotEmpty ? patient.bloodType! : '-',
            dark: dark,
          ),
          PatientSpecRow(
            label: 'Nama Ibu Kandung',
            value: patient.motherName != null && patient.motherName!.isNotEmpty ? patient.motherName! : '-',
            dark: dark,
          ),
          PatientSpecRow(
            label: 'Pekerjaan',
            value: patient.occupation != null && patient.occupation!.isNotEmpty ? patient.occupation! : '-',
            dark: dark,
          ),
          if (patient.phoneNumber != null && patient.phoneNumber!.isNotEmpty)
            PatientSpecRow(
              label: 'No. Telepon / WhatsApp',
              value: patient.phoneNumber!,
              dark: dark,
            ),
          if (patient.address != null && patient.address!.isNotEmpty)
            PatientSpecRow(
              label: 'Alamat Domisili',
              value: patient.address!,
              dark: dark,
            ),
          if (patient.patientGuardian != null && patient.patientGuardian!.isNotEmpty)
            PatientSpecRow(
              label: 'Nama Pendamping / Darurat',
              value: patient.patientGuardian!,
              dark: dark,
            ),
          if (patient.visitType != null && patient.visitType!.isNotEmpty)
            PatientSpecRow(
              label: 'Jenis Kunjungan',
              value: patient.visitType!,
              dark: dark,
            ),
          _PatientComplaintBlock(
            complaint: patient.patientComplaint.isEmpty
                ? 'Tidak ada catatan keluhan khusus.'
                : patient.patientComplaint,
            dark: dark,
          ),
        ],
      ),
    );
  }

  Color get _dividerColor =>
      dark ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10) : AmanahColorTokens.neutral100;
}

class _PatientComplaintBlock extends StatelessWidget {
  const _PatientComplaintBlock({required this.complaint, required this.dark});

  final String complaint;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Keluhan & catatan medis pasien',
            style: TextStyle(
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                  : AmanahColorTokens.neutral50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                    : AmanahColorTokens.neutral200,
              ),
            ),
            child: Text(
              complaint,
              style: TextStyle(
                color: dark ? AmanahColorTokens.neutral200 : AmanahColorTokens.neutral800,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
