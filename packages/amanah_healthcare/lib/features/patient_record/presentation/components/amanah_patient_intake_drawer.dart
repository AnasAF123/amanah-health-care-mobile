import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/empty_intake_view.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/immunization_intake_view.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/maternal_intake_view.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_intake_header_card.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/regular_intake_view.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/state/patient_intake_controller.dart';

/// Reusable Master Drawer / Bottom Sheet for Comprehensive Patient Clinical Intake Form.
class AmanahPatientIntakeDrawer extends StatefulWidget {
  const AmanahPatientIntakeDrawer({
    super.key,
    required this.appointmentId,
    this.initialPatientName,
    this.initialQueueNumber,
    this.initialMrn,
    this.initialAge,
    this.initialComplaint,
  });

  final String appointmentId;
  final String? initialPatientName;
  final String? initialQueueNumber;
  final String? initialMrn;
  final String? initialAge;
  final String? initialComplaint;

  static void show(
    BuildContext context, {
    required String appointmentId,
    String? patientName,
    String? queueNumber,
    String? mrn,
    String? age,
    String? complaint,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahPatientIntakeDrawer(
        appointmentId: appointmentId,
        initialPatientName: patientName,
        initialQueueNumber: queueNumber,
        initialMrn: mrn,
        initialAge: age,
        initialComplaint: complaint,
      ),
    );
  }

  @override
  State<AmanahPatientIntakeDrawer> createState() =>
      _AmanahPatientIntakeDrawerState();
}

class _AmanahPatientIntakeDrawerState extends State<AmanahPatientIntakeDrawer> {
  late final PatientIntakeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PatientIntakeController();
    _controller.addListener(_onStateChange);
    _controller.loadIntake(widget.appointmentId);
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final PatientIntakeRecord? intake = _controller.intake;

    String headerTitle = 'Formulir Klinis Pasien';
    if (intake != null) {
      if (intake.isMaternal) {
        headerTitle = 'Formulir KIA & Kehamilan (ANC)';
      } else if (intake.isImmunization) {
        headerTitle = 'Skrining Imunisasi & Tumbuh Kembang';
      } else {
        headerTitle = 'Formulir Pasien & Rekam Medis';
      }
    }

    return AmanahBottomSheetScaffold(
      title: headerTitle,
      fixedHeightFactor: 0.90,
      minHeight: 520,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      body: _buildContent(context, isDark, intake),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    PatientIntakeRecord? intake,
  ) {
    if (_controller.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              color: isDark
                  ? AmanahColorTokens.brandLight
                  : AmanahColorTokens.brandPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat formulir klinis pasien...',
              style: TextStyle(
                color: isDark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_controller.status == IntakeStateStatus.error && intake == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AmanahColorTokens.danger,
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal Memuat Formulir',
                style: TextStyle(
                  color: isDark
                      ? AmanahColorTokens.surfaceLight
                      : AmanahColorTokens.neutral900,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _controller.errorMessage ?? 'Terjadi kesalahan pada server.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AmanahColorTokens.neutral400
                      : AmanahColorTokens.neutral600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              AmanahButton.secondary(
                text: 'Coba Lagi',
                onPressed: () => _controller.loadIntake(widget.appointmentId),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PatientIntakeHeaderCard(
            patientName: intake?.regular?.fullName ??
                intake?.immunization?.childName ??
                widget.initialPatientName ??
                'Pasien Klinik',
            mrn: intake?.regular?.medicalRecordNumber ??
                intake?.immunization?.childNik ??
                widget.initialMrn ??
                '-',
            age: intake?.immunization?.childAgeFormatted ??
                widget.initialAge ??
                '-',
            queueNumber: widget.initialQueueNumber ?? '-',
            flow: intake?.flow ?? 'regular',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          if (_controller.isEmpty)
            EmptyIntakeView(
              complaint: widget.initialComplaint,
              isDark: isDark,
            )
          else if (intake != null && intake.isMaternal && intake.maternal != null)
            MaternalIntakeView(
              maternal: intake.maternal!,
              isDark: isDark,
            )
          else if (intake != null &&
              intake.isImmunization &&
              intake.immunization != null)
            ImmunizationIntakeView(
              immunization: intake.immunization!,
              isDark: isDark,
            )
          else
            RegularIntakeView(
              regular: intake?.regular,
              fallbackComplaint: widget.initialComplaint,
              isDark: isDark,
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
