import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_session_builder.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_conflict_dialog.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

/// Helper to handle validation, backend payload transformation, and persistence
/// for doctor practice schedule creation and editing.
class ScheduleFormSaver {
  static Future<bool> save({
    required BuildContext context,
    required DateTime selectedDate,
    required String status,
    required List<ScheduleFormSession> sessions,
    required List<ClinicRoomReference> rooms,
    required List<ClinicPoliklinikReference> polis,
    required DoctorSchedule? scheduleToEdit,
    required ValueChanged<DateTime>? onSavedDate,
  }) async {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    final String dateStr = formatIndonesianDate(selectedDate);
    final bool isClosing = status == ScheduleFormConstants.statusTutup ||
        status == ScheduleFormConstants.statusCuti;
    final List<ScheduleFormSession> activeSessions = sessions
        .where((ScheduleFormSession session) =>
            session.active && session.slots.isNotEmpty)
        .toList();

    if (activeSessions.isEmpty && !(scheduleToEdit != null && isClosing)) {
      showScheduleConflictDialog(
        context,
        'Aktifkan minimal satu sesi praktik untuk menyimpan jadwal.',
        title: 'Validasi Jadwal Praktik',
      );
      return false;
    }

    if (!isClosing) {
      for (final ScheduleFormSession s in activeSessions) {
        for (final ScheduleFormSlot slot in s.slots) {
          if (slot.from.isEmpty ||
              slot.from == ScheduleFormConstants.selectTime) {
            showScheduleConflictDialog(
              context,
              'Silakan tentukan Jam Mulai praktik untuk ${s.name}.',
              title: 'Validasi Jadwal Praktik',
            );
            return false;
          }
          if (slot.room.isEmpty ||
              slot.room == ScheduleFormConstants.selectRoom) {
            showScheduleConflictDialog(
              context,
              'Silakan pilih Ruang Praktik untuk ${s.name}.',
              title: 'Validasi Jadwal Praktik',
            );
            return false;
          }
          if (slot.poli.isEmpty ||
              slot.poli == ScheduleFormConstants.selectPoli) {
            showScheduleConflictDialog(
              context,
              'Silakan pilih Poli / Spesialisasi untuk ${s.name}.',
              title: 'Validasi Jadwal Praktik',
            );
            return false;
          }
        }
      }
    }

    final ScheduleFormSession? firstActive = activeSessions.firstOrNull;
    final ScheduleFormSlot? firstSlot = firstActive?.slots.firstOrNull;
    final String timeStr = firstSlot != null
        ? '${firstSlot.from} - ${firstSlot.to} WIB'
        : (scheduleToEdit?.time ?? ScheduleFormConstants.emptyTime);

    try {
      final String? roomId = firstSlot != null
          ? (rooms
                  .where((ClinicRoomReference r) => r.name == firstSlot.room)
                  .firstOrNull
                  ?.id ??
              (rooms.isNotEmpty ? rooms.first.id : null))
          : scheduleToEdit?.roomId;
      final String? poliId = firstSlot != null
          ? (polis
                  .where((ClinicPoliklinikReference p) => p.name == firstSlot.poli)
                  .firstOrNull
                  ?.id ??
              (polis.isNotEmpty ? polis.first.id : null))
          : scheduleToEdit?.poliklinikId;

      if (scheduleToEdit != null) {
        final bool isAvail = !isClosing;
        final DoctorSchedule updated = scheduleToEdit.copyWith(
          title: firstActive?.name ?? scheduleToEdit.title,
          date: dateStr,
          time: timeStr,
          startTime: firstSlot?.from ?? scheduleToEdit.startTime,
          endTime: firstSlot?.to ?? scheduleToEdit.endTime,
          sessionType: firstActive?.sessionType ?? scheduleToEdit.sessionType,
          poli: firstSlot?.poli ?? scheduleToEdit.poli,
          room: firstSlot?.room ?? scheduleToEdit.room,
          roomId: roomId ?? scheduleToEdit.roomId,
          poliklinikId: poliId ?? scheduleToEdit.poliklinikId,
          isAvailable: isAvail,
          badge: status,
          badgeVariant: !isAvail
              ? AmanahBadgeVariant.warning
              : AmanahBadgeVariant.success,
        );

        if (!scheduleToEdit.id.startsWith('ses-')) {
          try {
            await store.repository.toggleAvailability(scheduleToEdit.id, isAvail);
          } catch (_) {}
        }

        try {
          await store.updateDayStatus(
            date: selectedDate,
            status: isClosing
                ? ScheduleCanonicalStatus.closed
                : ScheduleCanonicalStatus.open,
            notes: isClosing ? 'Jadwal ditutup oleh dokter' : 'Buka kembali',
          );
        } catch (_) {}

        await store.saveSchedule(selectedDate, updated);
        await store.syncAll(selectedDate, forceRefresh: true);
      } else {
        for (int index = 0; index < activeSessions.length; index++) {
          final ScheduleFormSession session = activeSessions[index];
          for (final ScheduleFormSlot slot in session.slots) {
            final String? slotRoomId = rooms
                    .where((ClinicRoomReference r) => r.name == slot.room)
                    .firstOrNull
                    ?.id ??
                (rooms.isNotEmpty ? rooms.first.id : null);
            final String? slotPoliId = polis
                    .where((ClinicPoliklinikReference p) => p.name == slot.poli)
                    .firstOrNull
                    ?.id ??
                (polis.isNotEmpty ? polis.first.id : null);

            final bool isAvail =
                status != ScheduleFormConstants.statusTutup &&
                status != ScheduleFormConstants.statusCuti;
            final DoctorSchedule newSch = DoctorSchedule(
              id: 'ses-${DateTime.now().millisecondsSinceEpoch}-${session.id}-$index',
              title: session.name,
              date: dateStr,
              time: '${slot.from} - ${slot.to} WIB',
              startTime: slot.from,
              endTime: slot.to,
              sessionType: session.sessionType,
              sessionShift: sessionIdFromType(session.sessionType),
              poli: slot.poli,
              room: slot.room,
              roomId: slotRoomId,
              poliklinikId: slotPoliId,
              slotCount: '0',
              slotText: '0 Pasien Booking',
              isAvailable: isAvail,
              badge: status,
              badgeVariant: !isAvail
                  ? AmanahBadgeVariant.warning
                  : AmanahBadgeVariant.success,
              bookedPatients: const <BookedPatient>[],
            );

            // Forward to authoritative Schedule V2 backend availability endpoint
            try {
              final String targetShift = sessionShiftFromId(session.id);
              final ScheduleContext? ctx = store.scheduleContexts
                  .where((ScheduleContext c) =>
                      c.sessionShift == targetShift ||
                      c.contextId == session.id ||
                      c.contextId == targetShift)
                  .firstOrNull;
              final String contextId = ctx?.contextId ?? targetShift;
              await store.createAvailability(
                date: selectedDate,
                scheduleContextId: contextId,
                startTime: slot.from,
                roomId: slotRoomId,
                poliklinikId: slotPoliId,
              );
            } on AmanahScheduleConflictException {
              rethrow;
            } catch (_) {
              await store.saveSchedule(selectedDate, newSch);
            }
          }
        }
        await store.syncAll(selectedDate, forceRefresh: true);
      }
      onSavedDate?.call(selectedDate);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return true;
    } on AmanahScheduleConflictException catch (e) {
      if (context.mounted) {
        showScheduleConflictDialog(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        showScheduleConflictDialog(context, e.toString());
      }
      return false;
    }
  }

  static Future<void> delete({
    required BuildContext context,
    required DateTime selectedDate,
    required DoctorSchedule? scheduleToEdit,
    required ValueChanged<DateTime>? onSavedDate,
  }) async {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    if (scheduleToEdit != null) {
      try {
        await store.removeSchedule(selectedDate, scheduleToEdit.id);
        await store.syncAll(selectedDate, forceRefresh: true);
        onSavedDate?.call(selectedDate);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } on AmanahScheduleConflictException catch (e) {
        if (context.mounted) {
          showScheduleConflictDialog(context, e.message);
        }
      } catch (_) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}
