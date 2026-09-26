import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/card_decoration_layers.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_detail_drawer_components.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

/// Schedule Session Detail Drawer (Detail Sesi Praktik - Read Only)
class AmanahScheduleDetailDrawer extends StatelessWidget {
  const AmanahScheduleDetailDrawer({
    required this.schedule,
    required this.isDayCuti,
    required this.onViewPatients,
    required this.onTapEdit,
    required this.onTapDelete,
    this.onTapReschedule,
    super.key,
  });

  final DoctorSchedule schedule;
  final bool isDayCuti;
  final VoidCallback onViewPatients;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;
  final VoidCallback? onTapReschedule;

  static void show(
    BuildContext context, {
    required DoctorSchedule schedule,
    required bool isDayCuti,
    required VoidCallback onViewPatients,
    required VoidCallback onTapEdit,
    required VoidCallback onTapDelete,
    VoidCallback? onTapReschedule,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahScheduleDetailDrawer(
        schedule: schedule,
        isDayCuti: isDayCuti,
        onViewPatients: onViewPatients,
        onTapEdit: onTapEdit,
        onTapDelete: onTapDelete,
        onTapReschedule: onTapReschedule,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final bool isSessionExpired = isTemporalSlotPast(
      scheduleDate: schedule.scheduleDate != null && schedule.scheduleDate!.isNotEmpty
          ? DateTime.tryParse(schedule.scheduleDate!)
          : null,
      scheduleDateStr: schedule.scheduleDate ?? schedule.date,
      timeSlotOrEndTime: schedule.endTime ?? schedule.time,
    );

    return AmanahBottomSheetScaffold(
      title: 'Detail Sesi Praktik',
      fixedHeightFactor: 0.85,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.xl,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (onTapReschedule != null) ...<Widget>[
            AmanahButton.secondary(
              text: 'Reschedule Sesi',
              leadingIcon: Icons.schedule_send_rounded,
              isFullWidth: true,
              size: AmanahButtonSize.medium,
              onPressed: () {
                Navigator.of(context).pop();
                onTapReschedule!();
              },
            ),
            const SizedBox(height: 10),
          ],
          AmanahButton.primary(
            text: 'Edit Jadwal',
            isFullWidth: true,
            size: AmanahButtonSize.medium,
            isDisabled: isSessionExpired,
            onPressed: isSessionExpired
                ? null
                : () {
                    Navigator.of(context).pop();
                    onTapEdit();
                  },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isSessionExpired) ...<Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.06)
                    : AmanahColorTokens.neutral100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.12)
                      : AmanahColorTokens.neutral300,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: dark ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sesi praktik telah berakhir (Selesai). Perubahan jadwal dinonaktifkan.',
                      style: TextStyle(
                        color: dark ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral700,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Title & Date Heading + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      schedule.title,
                      style: TextStyle(
                        color: dark ? AmanahColorTokens.pureWhite : AmanahColorTokens.neutral950,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.date,
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SessionDetailStatusBadge(
                isDayCuti: isDayCuti,
                isSessionExpired: isSessionExpired,
                schedule: schedule,
                dark: dark,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Specification Records List
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                      : AmanahColorTokens.neutral100,
                ),
                bottom: BorderSide(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                      : AmanahColorTokens.neutral100,
                ),
              ),
            ),
            child: Column(
              children: <Widget>[
                PatientSpecRow(
                  label: 'Sesi Praktik',
                  value: schedule.sessionType.isNotEmpty
                      ? 'Sesi ${schedule.sessionType}'
                      : schedule.title,
                  dark: dark,
                ),
                PatientSpecRow(
                  label: 'Jam Praktik',
                  value: schedule.time,
                  dark: dark,
                ),
                PatientSpecRow(
                  label: 'Ruang Praktik',
                  value: schedule.room,
                  dark: dark,
                ),
                PatientSpecRow(
                  label: 'Poli / Spesialisasi',
                  value: schedule.poli,
                  dark: dark,
                ),
                SessionSpecTotalPatientsRow(
                  bookedCount: schedule.bookedPatients.length,
                  dark: dark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stacked Avatars Trigger Bar (Lihat Pasien Booking)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                      : AmanahColorTokens.pureBlack.withValues(alpha: 0.06),
                ),
                bottom: BorderSide(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                      : AmanahColorTokens.pureBlack.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                onViewPatients();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        StackedPatientAvatars(
                          patients: schedule.bookedPatients,
                          dark: dark,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Lihat Pasien Booking (${schedule.bookedPatients.length} Pasien)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: dark
                                  ? AmanahColorTokens.tabActiveDark
                                  : AmanahColorTokens.brandAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: dark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brandAccent,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}


