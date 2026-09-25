import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_slot_collision_helper.dart';

void main() {
  group('ScheduleSlotCollisionHelper Tests', () {
    test('computeSlotTimeOptions disables times overlapping existing doctor schedules', () {
      const ScheduleFormSlot currentSlot = ScheduleFormSlot(
        id: 'slot-1',
        from: 'Pilih Jam',
        to: '-',
        room: 'Pilih Ruang Praktik',
        poli: 'Poli Umum',
      );

      final List<DoctorSchedule> existing = <DoctorSchedule>[
        const DoctorSchedule(
          id: 'existing-1',
          title: 'Sesi Pagi',
          date: '2026-09-26',
          time: '08:00 - 10:00 WIB',
          startTime: '08:00',
          endTime: '10:00',
          sessionType: 'Pagi',
          poli: 'Poli Umum',
          room: 'Ruang 1',
          slotCount: '4',
          slotText: '4 Slot',
          badge: 'Buka',
          badgeVariant: AmanahBadgeVariant.success,
        ),
      ];

      final result = ScheduleSlotCollisionHelper.computeSlotTimeOptions(
        sessionId: 'pagi',
        currentSlot: currentSlot,
        sessionSlots: <ScheduleFormSlot>[currentSlot],
        allSessions: const <ScheduleFormSession>[],
        existingSchedules: existing,
        editingScheduleId: null,
      );

      expect(result.disabledTimes.contains('08:00'), isTrue);
      expect(result.disabledTimes.contains('08:30'), isTrue);
      expect(result.disabledTimes.contains('09:00'), isTrue);
      expect(result.disabledTimes.contains('09:30'), isTrue);
      expect(result.subtitles['08:00'], contains('Jadwal Anda'));
      expect(result.occupiedDetails['08:00'], isNotNull);
      expect(result.occupiedDetails['08:00']?.occupiedBy, contains('Jadwal Praktik Anda'));
    });

    test('computeSlotTimeOptions disables times from other slots in current form', () {
      const ScheduleFormSlot slot1 = ScheduleFormSlot(
        id: 'slot-1',
        from: '07:30',
        to: '08:00',
        room: 'Pilih Ruang Praktik',
        poli: 'Poli Umum',
      );
      const ScheduleFormSlot slot2 = ScheduleFormSlot(
        id: 'slot-2',
        from: 'Pilih Jam',
        to: '-',
        room: 'Pilih Ruang Praktik',
        poli: 'Poli Umum',
      );

      final result = ScheduleSlotCollisionHelper.computeSlotTimeOptions(
        sessionId: 'pagi',
        currentSlot: slot2,
        sessionSlots: <ScheduleFormSlot>[slot1, slot2],
        allSessions: const <ScheduleFormSession>[],
      );

      expect(result.disabledTimes.contains('07:30'), isTrue);
      expect(result.subtitles['07:30'], 'Antrean lain');
    });

    test('computeRescheduleDisabledTimes correctly identifies collisions on target date', () {
      final List<DoctorSchedule> targetSchedules = <DoctorSchedule>[
        const DoctorSchedule(
          id: 'ses-other-99',
          title: 'Sesi Siang',
          date: '2026-09-26',
          time: '13:00 - 15:00 WIB',
          startTime: '13:00',
          endTime: '15:00',
          sessionType: 'Siang',
          poli: 'Poli Umum',
          room: 'Ruang 2',
          slotCount: '4',
          slotText: '4 Slot',
          badge: 'Buka',
          badgeVariant: AmanahBadgeVariant.success,
        ),
      ];

      final result = ScheduleSlotCollisionHelper.computeRescheduleDisabledTimes(
        allTimeOptions: <String>[
          '12:00',
          '12:30',
          '13:00',
          '13:30',
          '14:00',
          '14:30',
          '15:00',
        ],
        currentSessionId: 'ses-active-1',
        targetDateSchedules: targetSchedules,
      );

      expect(result.disabledTimes.contains('13:00'), isTrue);
      expect(result.disabledTimes.contains('13:30'), isTrue);
      expect(result.disabledTimes.contains('14:00'), isTrue);
      expect(result.disabledTimes.contains('14:30'), isTrue);
      expect(result.disabledTimes.contains('12:00'), isFalse);
      expect(result.disabledTimes.contains('15:00'), isFalse);
      expect(result.subtitles['13:00'], contains('Jadwal Anda'));
    });
  });
}
