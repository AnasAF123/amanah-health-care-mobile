import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/slot_occupied_info.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

class ScheduleSlotCollisionHelper {
  const ScheduleSlotCollisionHelper._();

  /// Computes available time options, disabled times due to collision,
  /// conflict subtitles, and rich occupied details for a schedule slot in Add/Edit.
  static ({
    List<String> timeOptions,
    List<String> disabledTimes,
    Map<String, String> subtitles,
    Map<String, SlotOccupiedInfo> occupiedDetails,
  }) computeSlotTimeOptions({
    required String sessionId,
    required ScheduleFormSlot currentSlot,
    required List<ScheduleFormSlot> sessionSlots,
    required List<ScheduleFormSession> allSessions,
    ScheduleShiftOccupancy? occupancy,
    ScheduleContext? context,
    DateTime? selectedDate,
    List<DoctorSchedule> existingSchedules = const <DoctorSchedule>[],
    String? editingScheduleId,
  }) {
    final List<String> timeOptions;
    final List<String> disabledTimes = <String>[];
    final Map<String, String> subtitles = <String, String>{};
    final Map<String, SlotOccupiedInfo> occupiedDetails =
        <String, SlotOccupiedInfo>{};

    if (occupancy != null && occupancy.slots.isNotEmpty) {
      timeOptions = occupancy.slots
          .map((ScheduleShiftSlot s) => s.startTime)
          .toList();
      for (final ScheduleShiftSlot s in occupancy.slots) {
        if (!s.isAvailable) {
          disabledTimes.add(s.startTime);
          final String occupant =
              s.conflictInfo?.practitionerName ?? 'Dokter Lain';
          final String subtitleText = s.status == 'OCCUPIED_BY_SELF' ||
                  s.conflictInfo?.type == 'SELF'
              ? 'Jadwal Anda'
              : (occupant.isNotEmpty && occupant != 'Dokter Lain'
                  ? occupant
                  : (s.displayLabel.isNotEmpty
                      ? s.displayLabel
                      : 'Telah Digunakan'));
          final String statusLabel = s.status == 'OCCUPIED_BY_SELF' ||
                  s.conflictInfo?.type == 'SELF'
              ? 'Jadwal Anda'
              : 'Slot Telah Digunakan';
          final String reason = s.conflictInfo?.message.isNotEmpty == true
              ? s.conflictInfo!.message
              : (statusLabel == 'Jadwal Anda'
                  ? 'Anda telah memiliki jadwal pada jam ini.'
                  : 'Slot waktu ini telah dialokasikan untuk jadwal praktik dokter lain.');

          subtitles[s.startTime] = subtitleText;
          occupiedDetails[s.startTime] = SlotOccupiedInfo(
            time: s.startTime,
            timeRange: s.timeRange.isNotEmpty
                ? s.timeRange
                : '${s.startTime} - ${s.endTime} WIB',
            statusLabel: statusLabel,
            occupiedBy: occupant,
            roomName: s.conflictInfo?.roomName,
            reason: reason,
          );
        }
      }
    } else {
      timeOptions = getTimeOptionsForSession(sessionId, context: context);
    }

    // 0. Temporal check: Disable time slots that have already passed
    if (selectedDate != null) {
      for (final String t in timeOptions) {
        if (isTemporalSlotPast(
          scheduleDate: selectedDate,
          timeSlotOrEndTime: t,
        )) {
          if (!disabledTimes.contains(t)) {
            disabledTimes.add(t);
          }
          subtitles[t] = ScheduleFormConstants.badgeSudahSelesai;
          occupiedDetails[t] = SlotOccupiedInfo(
            time: t,
            timeRange: 'Pukul $t WIB',
            statusLabel: ScheduleFormConstants.badgeSudahSelesai,
            occupiedBy: 'Waktu Telah Terlewati',
            reason: 'Slot waktu ini telah melewati jam operasional saat ini.',
          );
        }
      }
    }

    // 1. Conflict with doctor's existing schedules on this date
    for (final DoctorSchedule sch in existingSchedules) {
      if (sch.id == editingScheduleId) continue;
      final int? startMin =
          sch.startTime != null ? parseTimeToMinutes(sch.startTime!) : null;
      final int? endMin =
          sch.endTime != null ? parseTimeToMinutes(sch.endTime!) : null;
      if (startMin != null && endMin != null) {
        for (final String t in timeOptions) {
          final int? tMin = parseTimeToMinutes(t);
          if (tMin != null && tMin >= startMin && tMin < endMin) {
            if (!disabledTimes.contains(t)) {
              disabledTimes.add(t);
            }
            if (occupiedDetails[t]?.statusLabel !=
                ScheduleFormConstants.badgeSudahSelesai) {
              subtitles[t] = 'Jadwal Anda';
              occupiedDetails[t] = SlotOccupiedInfo(
                time: t,
                timeRange: sch.time,
                statusLabel: 'Jadwal Anda',
                occupiedBy: 'Jadwal Praktik Anda (${sch.sessionType})',
                poliName: sch.poli,
                roomName: sch.room,
                reason:
                    'Anda telah memiliki sesi praktik ${sch.sessionType} (${sch.time}) pada tanggal ini.',
                bookedPatientsCount: sch.bookedPatientCount,
              );
            }
          }
        }
      }
    }

    // 2. Conflict with other slots in current session
    for (final ScheduleFormSlot otherSlot in sessionSlots) {
      if (otherSlot.id != currentSlot.id &&
          otherSlot.from.isNotEmpty &&
          otherSlot.from != ScheduleFormConstants.selectTime) {
        if (!disabledTimes.contains(otherSlot.from)) {
          disabledTimes.add(otherSlot.from);
        }
        subtitles[otherSlot.from] = 'Antrean lain';
        occupiedDetails[otherSlot.from] = SlotOccupiedInfo(
          time: otherSlot.from,
          timeRange: otherSlot.to != ScheduleFormConstants.emptyTime
              ? '${otherSlot.from} - ${otherSlot.to} WIB'
              : 'Pukul ${otherSlot.from} WIB',
          statusLabel: 'Antrean Lain',
          occupiedBy: 'Antrean Lain dalam Sesi Ini',
          roomName: otherSlot.room != ScheduleFormConstants.selectRoom
              ? otherSlot.room
              : null,
          poliName: otherSlot.poli != ScheduleFormConstants.selectPoli
              ? otherSlot.poli
              : null,
          reason: 'Slot waktu ini telah dialokasikan pada antrean lain di sesi ini.',
        );

        final int? oFromMin = parseTimeToMinutes(otherSlot.from);
        final int? oToMin =
            otherSlot.to != ScheduleFormConstants.emptyTime
                ? parseTimeToMinutes(otherSlot.to)
                : null;
        if (oFromMin != null && oToMin != null && oToMin > oFromMin) {
          for (final String t in timeOptions) {
            final int? tMin = parseTimeToMinutes(t);
            if (tMin != null && tMin >= oFromMin && tMin < oToMin) {
              if (!disabledTimes.contains(t)) {
                disabledTimes.add(t);
              }
              subtitles[t] = 'Antrean lain';
              occupiedDetails[t] = SlotOccupiedInfo(
                time: t,
                timeRange: '${otherSlot.from} - ${otherSlot.to} WIB',
                statusLabel: 'Antrean Lain',
                occupiedBy: 'Antrean Lain dalam Sesi Ini',
                roomName: otherSlot.room != ScheduleFormConstants.selectRoom
                    ? otherSlot.room
                    : null,
                poliName: otherSlot.poli != ScheduleFormConstants.selectPoli
                    ? otherSlot.poli
                    : null,
                reason: 'Slot waktu ini termasuk dalam durasi antrean lain di sesi ini.',
              );
            }
          }
        }
      }
    }

    // 3. Conflict with slots in other active sessions in the form
    for (final ScheduleFormSession sess in allSessions) {
      if (sess.id == sessionId || !sess.active) continue;
      for (final ScheduleFormSlot otherSlot in sess.slots) {
        if (otherSlot.from.isNotEmpty &&
            otherSlot.from != ScheduleFormConstants.selectTime) {
          if (!disabledTimes.contains(otherSlot.from)) {
            disabledTimes.add(otherSlot.from);
          }
          subtitles[otherSlot.from] = 'Sesi ${sess.name}';
          occupiedDetails[otherSlot.from] = SlotOccupiedInfo(
            time: otherSlot.from,
            timeRange: otherSlot.to != ScheduleFormConstants.emptyTime
                ? '${otherSlot.from} - ${otherSlot.to} WIB'
                : 'Pukul ${otherSlot.from} WIB',
            statusLabel: 'Sesi ${sess.name}',
            occupiedBy: 'Sesi ${sess.name}',
            roomName: otherSlot.room != ScheduleFormConstants.selectRoom
                ? otherSlot.room
                : null,
            poliName: otherSlot.poli != ScheduleFormConstants.selectPoli
                ? otherSlot.poli
                : null,
            reason: 'Slot waktu ini dialokasikan pada ${sess.name} dalam formulir ini.',
          );

          final int? oFromMin = parseTimeToMinutes(otherSlot.from);
          final int? oToMin =
              otherSlot.to != ScheduleFormConstants.emptyTime
                  ? parseTimeToMinutes(otherSlot.to)
                  : null;
          if (oFromMin != null && oToMin != null && oToMin > oFromMin) {
            for (final String t in timeOptions) {
              final int? tMin = parseTimeToMinutes(t);
              if (tMin != null && tMin >= oFromMin && tMin < oToMin) {
                if (!disabledTimes.contains(t)) {
                  disabledTimes.add(t);
                }
                subtitles[t] = 'Sesi ${sess.name}';
                occupiedDetails[t] = SlotOccupiedInfo(
                  time: t,
                  timeRange: '${otherSlot.from} - ${otherSlot.to} WIB',
                  statusLabel: 'Sesi ${sess.name}',
                  occupiedBy: 'Sesi ${sess.name}',
                  roomName: otherSlot.room != 'Pilih Ruang Praktik'
                      ? otherSlot.room
                      : null,
                  poliName: otherSlot.poli != 'Pilih Poliklinik'
                      ? otherSlot.poli
                      : null,
                  reason: 'Slot waktu ini termasuk dalam durasi antrean pada sesi ${sess.name}.',
                );
              }
            }
          }
        }
      }
    }

    return (
      timeOptions: timeOptions,
      disabledTimes: disabledTimes,
      subtitles: subtitles,
      occupiedDetails: occupiedDetails,
    );
  }

  /// Computes disabled times, subtitles, and occupied details for RescheduleStartTimePicker.
  static ({
    List<String> disabledTimes,
    Map<String, String> subtitles,
    Map<String, SlotOccupiedInfo> occupiedDetails,
  }) computeRescheduleDisabledTimes({
    required List<String> allTimeOptions,
    required String currentSessionId,
    required List<DoctorSchedule> targetDateSchedules,
    ScheduleOccupancyOverviewData? targetOccupancy,
    DateTime? targetDate,
  }) {
    final List<String> disabledTimes = <String>[];
    final Map<String, String> subtitles = <String, String>{};
    final Map<String, SlotOccupiedInfo> occupiedDetails =
        <String, SlotOccupiedInfo>{};

    // 0. Temporal check: Disable time slots that have already passed on target date
    if (targetDate != null) {
      for (final String t in allTimeOptions) {
        if (isTemporalSlotPast(
          scheduleDate: targetDate,
          timeSlotOrEndTime: t,
        )) {
          if (!disabledTimes.contains(t)) {
            disabledTimes.add(t);
          }
          subtitles[t] = ScheduleFormConstants.badgeSudahSelesai;
          occupiedDetails[t] = SlotOccupiedInfo(
            time: t,
            timeRange: 'Pukul $t WIB',
            statusLabel: ScheduleFormConstants.badgeSudahSelesai,
            occupiedBy: 'Waktu Telah Terlewati',
            reason: 'Slot waktu ini telah melewati jam operasional saat ini.',
          );
        }
      }
    }

    // 1. Conflict with doctor's other sessions on target date
    for (final DoctorSchedule sch in targetDateSchedules) {
      if (sch.sessionId == currentSessionId || sch.id == currentSessionId) {
        continue;
      }
      final int? startMin =
          sch.startTime != null ? parseTimeToMinutes(sch.startTime!) : null;
      final int? endMin =
          sch.endTime != null ? parseTimeToMinutes(sch.endTime!) : null;
      if (startMin != null && endMin != null) {
        for (final String t in allTimeOptions) {
          final int? tMin = parseTimeToMinutes(t);
          if (tMin != null && tMin >= startMin && tMin < endMin) {
            if (!disabledTimes.contains(t)) {
              disabledTimes.add(t);
            }
            if (occupiedDetails[t]?.statusLabel !=
                ScheduleFormConstants.badgeSudahSelesai) {
              subtitles[t] = 'Jadwal Anda';
              occupiedDetails[t] = SlotOccupiedInfo(
                time: t,
                timeRange: sch.time,
                statusLabel: 'Jadwal Anda',
                occupiedBy: 'Jadwal Praktik Anda (${sch.sessionType})',
                poliName: sch.poli,
                roomName: sch.room,
                reason:
                    'Anda telah memiliki sesi praktik ${sch.sessionType} (${sch.time}) pada tanggal target.',
                bookedPatientsCount: sch.bookedPatientCount,
              );
            }
          }
        }
      }
    }

    // 2. Conflict with target room occupancy if available
    if (targetOccupancy != null) {
      for (final ScheduleShiftOccupancy shift in targetOccupancy.shifts) {
        for (final ScheduleShiftSlot slot in shift.slots) {
          if (!slot.isAvailable) {
            if (!disabledTimes.contains(slot.startTime)) {
              disabledTimes.add(slot.startTime);
            }
            final String label = slot.displayLabel.isNotEmpty
                ? slot.displayLabel
                : 'Telah Digunakan';
            final String occupant =
                slot.conflictInfo?.practitionerName ?? 'Dokter Lain';
            final String reason = slot.conflictInfo?.message.isNotEmpty == true
                ? slot.conflictInfo!.message
                : 'Ruangan sedang dialokasikan untuk sesi praktik dokter lain.';

            subtitles[slot.startTime] = label;
            occupiedDetails[slot.startTime] = SlotOccupiedInfo(
              time: slot.startTime,
              timeRange: slot.timeRange.isNotEmpty
                  ? slot.timeRange
                  : '${slot.startTime} - ${slot.endTime} WIB',
              statusLabel: label,
              occupiedBy: occupant,
              roomName: slot.conflictInfo?.roomName,
              reason: reason,
            );
          }
        }
      }
    }

    return (
      disabledTimes: disabledTimes,
      subtitles: subtitles,
      occupiedDetails: occupiedDetails,
    );
  }
}
