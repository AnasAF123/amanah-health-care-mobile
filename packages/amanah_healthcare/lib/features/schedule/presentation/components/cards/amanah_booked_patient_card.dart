import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_queue_badge.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/card_decoration_layers.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

class AmanahBookedPatientCard extends StatelessWidget {
  const AmanahBookedPatientCard({
    required this.patient,
    required this.schedule,
    required this.imageIndex,
    required this.onTapDetail,
    super.key,
  });

  final BookedPatient patient;
  final DoctorSchedule schedule;
  final int imageIndex;
  final VoidCallback onTapDetail;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String cardBgAsset = dark
        ? 'assets/amanah/images/booking-card-bg-dark.png'
        : 'assets/amanah/images/booking-card-bg-light.png';

    final String rawSlot = patient.timeSlot;
    final String startTime = rawSlot.contains(' - ')
        ? rawSlot.split(' - ').first.trim()
        : (schedule.startTime ?? '');
    final String endTime = rawSlot.contains(' - ')
        ? rawSlot.split(' - ').last.replaceAll(' WIB', '').trim()
        : (schedule.endTime ?? '');

    final bool isSlotExpired = isTemporalSlotPast(
      scheduleDate: schedule.scheduleDate != null && schedule.scheduleDate!.isNotEmpty
          ? DateTime.tryParse(schedule.scheduleDate!)
          : null,
      scheduleDateStr: schedule.scheduleDate ?? schedule.date,
      timeSlotOrEndTime: patient.timeSlot,
    );
    final bool isPatientDisabled =
        patient.isCompleted || patient.isCancelled || isSlotExpired;

    final String displayBadge = patient.isCancelled
        ? ScheduleFormConstants.statusBatal
        : (isPatientDisabled ? ScheduleFormConstants.badgeSelesai : patient.badge);
    final Color badgeToneColor = patient.isCancelled
        ? scheduleBadgeTone(AmanahBadgeVariant.warning, context).primary
        : (isPatientDisabled
            ? scheduleBadgeTone(AmanahBadgeVariant.success, context).primary
            : scheduleBadgeTone(patient.badgeVariant, context).primary);

    return Semantics(
      button: true,
      label: 'Pasien ${patient.patientName}, Antrean ${patient.queueNumber}',
      child: GestureDetector(
        onTap: onTapDetail,
        child: Opacity(
          opacity: isPatientDisabled ? 0.82 : 1.0,
          child: Container(
            height: 335,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: AmanahThemeTokens.surface(context),
              border: Border.all(
                color: AmanahThemeTokens.outline(context),
                width: 1,
              ),
              boxShadow: <BoxShadow>[AmanahElevation.soft(dark: dark)],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Image.asset(
                    cardBgAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: dark
                              ? const <Color>[
                                  AmanahColorTokens.darkNavy,
                                  AmanahColorTokens.canvasDark,
                                ]
                              : const <Color>[
                                  AmanahColorTokens.skyLight,
                                  AmanahColorTokens.canvasLight,
                                ],
                        ),
                      ),
                    ),
                  ),
                ),
                ProfileReadabilityMaskLayer(dark: dark, height: 210),
                AmbientCardGradientLayer(dark: dark),
                Positioned(
                  top: 14,
                  left: 14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: dark
                              ? AmanahColorTokens.canvasDark.withValues(alpha: 0.70)
                              : AmanahColorTokens.surfaceLight.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: dark
                                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                                : AmanahColorTokens.neutral200,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AmanahColorTokens.pureBlack.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: badgeToneColor,
                                shape: BoxShape.circle,
                              ),
                              child: const SizedBox(width: 8, height: 8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              displayBadge,
                              style: TextStyle(
                                color: dark
                                    ? AmanahColorTokens.pureWhite
                                    : AmanahColorTokens.neutral900,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: AmanahQueueBadge(
                    queueNumber: patient.queueNumber,
                    size: 68,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              patient.patientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AmanahThemeTokens.textPrimary(
                                  context,
                                ),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              patient.patientRm,
                              style: TextStyle(
                                color: AmanahThemeTokens.textSecondary(
                                  context,
                                ),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PatientCardSlotSpecsRow(
                          poli: schedule.poli,
                          room: schedule.room,
                          startTime: startTime,
                          endTime: endTime,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: dark
                              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.15)
                              : AmanahColorTokens.neutral200,
                        ),
                        const SizedBox(height: 12),
                        if (isPatientDisabled)
                          AmanahButton.secondary(
                            text: 'Detail Pasien',
                            isFullWidth: true,
                            size: AmanahButtonSize.medium,
                            onPressed: onTapDetail,
                          )
                        else
                          AmanahButton.primary(
                            text: 'Detail Pasien',
                            isFullWidth: true,
                            size: AmanahButtonSize.medium,
                            onPressed: onTapDetail,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
