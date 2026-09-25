import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/card_decoration_layers.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/patient_detail_modal_painters.dart';

/// Patient Detail & Complaint Bottom Sheet Modal
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
        SizedBox(
          width: 98,
          height: 94,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AmanahColorTokens.brandLight.withValues(alpha: 0.20),
                    width: 3,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AmanahColorTokens.pureBlack.withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    patient.avatarUrl ??
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stack,
                        ) => ColoredBox(
                          color: dark
                              ? AmanahColorTokens.neutral700
                              : AmanahColorTokens.neutral300,
                          child: Center(
                            child: Text(
                              patient.patientName.isNotEmpty
                                  ? patient.patientName.substring(0, 1)
                                  : 'P',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: dark
                                    ? AmanahColorTokens.pureWhite
                                    : AmanahColorTokens.neutral800,
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 3,
                child: CustomPaint(
                  size: const Size(38, 45),
                  painter: QueueBadgePainter(patient.queueNumber),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          patient.patientName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? AmanahColorTokens.pureWhite : AmanahColorTokens.neutral950,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
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
          Text('Usia ${patient.patientAge}', style: _style),
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
            value: patient.timeSlot,
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
          if (patient.patientGuardian != null)
            PatientSpecRow(
              label: 'Nama pendamping',
              value: patient.patientGuardian!,
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
