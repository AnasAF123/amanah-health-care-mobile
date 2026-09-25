import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

class AmanahScheduleSessionsView extends StatelessWidget {
  const AmanahScheduleSessionsView({
    required this.daySetting,
    required this.isCuti,
    required this.schedules,
    required this.dark,
    required this.onTapDetail,
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onOpenAddSchedule,
    this.occupancyOverview,
    this.onToggleDayStatus,
    super.key,
  });

  final DayScheduleSetting daySetting;
  final bool isCuti;
  final List<DoctorSchedule> schedules;
  final ScheduleOccupancyOverviewData? occupancyOverview;
  final bool dark;
  final void Function(DoctorSchedule) onTapDetail;
  final void Function(DoctorSchedule) onTapEdit;
  final void Function(DoctorSchedule) onTapDelete;
  final VoidCallback onOpenAddSchedule;
  final VoidCallback? onToggleDayStatus;

  @override
  Widget build(BuildContext context) {
    final bool allSchedulesClosed = schedules.isNotEmpty &&
        schedules.every((DoctorSchedule s) =>
            !s.isAvailable ||
            s.badge == ScheduleFormConstants.statusTutup ||
            s.badge == ScheduleFormConstants.statusCuti);
    final bool isDayClosed = daySetting.isDayClosed || allSchedulesClosed;

    final List<DoctorSchedule> displaySchedules = _resolveDisplaySchedules(
      schedules: schedules,
      daySetting: daySetting,
      isDayClosed: isDayClosed,
      occupancyOverview: occupancyOverview,
    );

    return Column(
      key: const ValueKey<String>('view-sessions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isDayClosed) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.info_outline_rounded,
                  color: dark
                      ? AmanahColorTokens.neutral400
                      : AmanahColorTokens.neutral500,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Jadwal Hari Ini Ditutup',
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.pureWhite
                              : AmanahColorTokens.neutral900,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Seluruh sesi dinonaktifkan sementara untuk pendaftaran pasien.',
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral600,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onToggleDayStatus != null) ...<Widget>[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onToggleDayStatus,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      backgroundColor: dark
                          ? AmanahColorTokens.brand.withValues(alpha: 0.16)
                          : AmanahColorTokens.brandSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: dark
                              ? AmanahColorTokens.brandLight.withValues(alpha: 0.35)
                              : AmanahColorTokens.brandMuted,
                        ),
                      ),
                    ),
                    child: Text(
                      'Buka Kembali',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.brandLight
                            : AmanahColorTokens.brandPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        if (displaySchedules.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displaySchedules.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 14),
            itemBuilder: (BuildContext context, int index) {
              final DoctorSchedule sch = displaySchedules[index];
              return AmanahDoctorSessionCard(
                schedule: sch,
                imageIndex: index,
                isDayClosed: isDayClosed,
                onTapDetail: () => onTapDetail(sch),
                onTapEdit: () => onTapEdit(sch),
                onTapDelete: () => onTapDelete(sch),
              );
            },
          )
        else
          AmanahEmptyState.box(
            title: isDayClosed
                ? 'Jadwal Hari Ini Ditutup'
                : 'Belum Ada Sesi Praktik',
            message: isDayClosed
                ? 'Dokter tidak membuka praktik pada tanggal ini.'
                : 'Belum ada sesi praktik dokter yang ditambahkan pada tanggal ini.',
            actionText: 'Tambah Jadwal Dokter',
            actionLeadingIcon: Icons.add_rounded,
            onAction: onOpenAddSchedule,
          ),
      ],
    );
  }

  List<DoctorSchedule> _resolveDisplaySchedules({
    required List<DoctorSchedule> schedules,
    required DayScheduleSetting daySetting,
    required bool isDayClosed,
    ScheduleOccupancyOverviewData? occupancyOverview,
  }) {
    final String dateStr = daySetting.scheduleDate ??
        (schedules.isNotEmpty
            ? (schedules.first.scheduleDate ?? schedules.first.date)
            : (occupancyOverview?.date ?? ''));

    final List<DoctorSchedule> result = <DoctorSchedule>[];

    // Priority 1: If occupancyOverview contains doctor-scheduled slots, render per-slot schedules.
    if (occupancyOverview != null && occupancyOverview.shifts.isNotEmpty) {
      for (final ScheduleShiftOccupancy shift in occupancyOverview.shifts) {
        for (final ScheduleShiftSlot slot in shift.slots) {
          final bool isSelf = slot.status == 'OCCUPIED_BY_SELF' ||
              slot.conflictInfo?.type == 'SELF';
          if (!isSelf) {
            continue;
          }

          DoctorSchedule? matchingParent;
          if (slot.conflictInfo?.sessionId != null) {
            matchingParent = schedules.cast<DoctorSchedule?>().firstWhere(
              (DoctorSchedule? s) => s?.id == slot.conflictInfo!.sessionId,
              orElse: () => null,
            );
          }
          matchingParent ??= schedules.cast<DoctorSchedule?>().firstWhere(
            (DoctorSchedule? s) =>
                s?.sessionShift.toLowerCase() == shift.shift.toLowerCase(),
            orElse: () => schedules.isNotEmpty ? schedules.first : null,
          );

          final bool isSlotPast = isTemporalSlotPast(
            scheduleDate: DateTime.tryParse(dateStr),
            scheduleDateStr: dateStr,
            timeSlotOrEndTime: slot.endTime,
          );

          final bool isClosed = isDayClosed ||
              (matchingParent != null &&
                  (!matchingParent.isAvailable ||
                      matchingParent.badge == ScheduleFormConstants.statusTutup ||
                      matchingParent.badge == ScheduleFormConstants.statusCuti));

          final String badge;
          final AmanahBadgeVariant badgeVariant;

          if (isSlotPast) {
            badge = ScheduleFormConstants.badgeSelesai;
            badgeVariant = AmanahBadgeVariant.warning;
          } else if (isClosed) {
            badge = ScheduleFormConstants.statusTutup;
            badgeVariant = AmanahBadgeVariant.warning;
          } else if ((matchingParent?.bookedPatientCount ?? 0) > 0) {
            badge = ScheduleFormConstants.badgeTerisi;
            badgeVariant = AmanahBadgeVariant.primary;
          } else {
            badge = ScheduleFormConstants.statusBuka;
            badgeVariant = AmanahBadgeVariant.success;
          }

          final String formattedTime = slot.timeRange.isNotEmpty
              ? (slot.timeRange.endsWith('WIB')
                  ? slot.timeRange
                  : '${slot.timeRange} WIB')
              : '${slot.startTime} - ${slot.endTime} WIB';

          final String roomName = slot.conflictInfo?.roomName ??
              matchingParent?.room ??
              occupancyOverview.roomName ??
              'Ruang Poli Umum 1';

          final String poliName = matchingParent?.poli ?? 'Poli Umum';
          final String sessionTitle = matchingParent?.title ??
              'Sesi Praktik ($poliName - $roomName)';

          result.add(
            DoctorSchedule(
              id: slot.conflictInfo?.sessionId ??
                  matchingParent?.id ??
                  '${dateStr}_${slot.startTime}',
              title: sessionTitle,
              date: dateStr,
              time: formattedTime,
              poli: poliName,
              room: roomName,
              slotCount: (matchingParent?.bookedPatientCount ?? 0).toString(),
              slotText: matchingParent?.slotText ??
                  '${matchingParent?.bookedPatientCount ?? 0} Pasien Booking',
              badge: badge,
              badgeVariant: badgeVariant,
              startTime: slot.startTime,
              endTime: slot.endTime,
              sessionShift: shift.shift,
              sessionType: shift.shiftLabel,
              scheduleDate: dateStr,
              roomId: slot.conflictInfo?.roomId ??
                  matchingParent?.roomId ??
                  occupancyOverview.roomId,
              poliklinikId: matchingParent?.poliklinikId,
              serviceId: matchingParent?.serviceId,
              capacity: 1,
              availableSlots: isSlotPast || isClosed ? 0 : 1,
              bookedPatientCount: matchingParent?.bookedPatientCount ?? 0,
              bookedPatients:
                  matchingParent?.bookedPatients ?? const <BookedPatient>[],
              isAvailable: !isClosed && !isSlotPast,
              notes: matchingParent?.notes,
              version: matchingParent?.version,
              staffId: matchingParent?.staffId,
              practitionerId: slot.conflictInfo?.practitionerId ??
                  matchingParent?.practitionerId ??
                  occupancyOverview.practitionerId,
              doctorName: slot.conflictInfo?.practitionerName ??
                  matchingParent?.doctorName ??
                  occupancyOverview.practitionerName,
            ),
          );
        }
      }
    }

    if (result.isNotEmpty) {
      return result;
    }

    if (schedules.isEmpty) {
      return const <DoctorSchedule>[];
    }

    for (final DoctorSchedule sch in schedules) {
      final bool isSlotPast = isTemporalSlotPast(
        scheduleDate: DateTime.tryParse(dateStr),
        scheduleDateStr: dateStr,
        timeSlotOrEndTime: sch.endTime,
      );

      final bool isClosed = isDayClosed ||
          !sch.isAvailable ||
          sch.badge == ScheduleFormConstants.statusTutup ||
          sch.badge == ScheduleFormConstants.statusCuti;

      final String badge;
      final AmanahBadgeVariant badgeVariant;

      if (isSlotPast) {
        badge = ScheduleFormConstants.badgeSelesai;
        badgeVariant = AmanahBadgeVariant.warning;
      } else if (isClosed) {
        badge = ScheduleFormConstants.statusTutup;
        badgeVariant = AmanahBadgeVariant.warning;
      } else if (sch.bookedPatientCount > 0) {
        badge = ScheduleFormConstants.badgeTerisi;
        badgeVariant = AmanahBadgeVariant.primary;
      } else {
        badge = ScheduleFormConstants.statusBuka;
        badgeVariant = AmanahBadgeVariant.success;
      }

      result.add(
        sch.copyWith(
          badge: badge,
          badgeVariant: badgeVariant,
          isAvailable: !isClosed && !isSlotPast,
          scheduleDate: dateStr,
        ),
      );
    }

    return result;
  }
}


