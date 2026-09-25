import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_slot_collision_helper.dart';

void main() {
  group('Canonical 4-Shift 24-Hour Cycle & SSOT Constants Tests', () {
    test('CanonicalShift enums strictly match PostgreSQL staff_shift and backend contracts', () {
      expect(CanonicalShift.earlyMorning.code, 'early_morning');
      expect(CanonicalShift.earlyMorning.dtoSession, 'DINI_HARI');
      expect(CanonicalShift.earlyMorning.startMinutes, 0);
      expect(CanonicalShift.earlyMorning.endMinutes, 360);
      expect(CanonicalShift.earlyMorning.defaultStartTime, '00:00');
      expect(CanonicalShift.earlyMorning.defaultEndTime, '06:00');

      expect(CanonicalShift.morning.code, 'morning');
      expect(CanonicalShift.morning.dtoSession, 'PAGI');
      expect(CanonicalShift.morning.startMinutes, 360);
      expect(CanonicalShift.morning.endMinutes, 720);
      expect(CanonicalShift.morning.defaultStartTime, '06:00');
      expect(CanonicalShift.morning.defaultEndTime, '12:00');

      expect(CanonicalShift.afternoon.code, 'afternoon');
      expect(CanonicalShift.afternoon.dtoSession, 'SIANG');
      expect(CanonicalShift.afternoon.startMinutes, 720);
      expect(CanonicalShift.afternoon.endMinutes, 1080);
      expect(CanonicalShift.afternoon.defaultStartTime, '12:00');
      expect(CanonicalShift.afternoon.defaultEndTime, '18:00');

      expect(CanonicalShift.night.code, 'night');
      expect(CanonicalShift.night.dtoSession, 'MALAM');
      expect(CanonicalShift.night.startMinutes, 1080);
      expect(CanonicalShift.night.endMinutes, 1440);
      expect(CanonicalShift.night.defaultStartTime, '18:00');
      expect(CanonicalShift.night.defaultEndTime, '24:00');
    });

    test('CanonicalShift.tryResolve resolves case-insensitively for English and Indonesian identifiers', () {
      expect(CanonicalShift.tryResolve('dini_hari'), CanonicalShift.earlyMorning);
      expect(CanonicalShift.tryResolve('DINI_HARI'), CanonicalShift.earlyMorning);
      expect(CanonicalShift.tryResolve('early_morning'), CanonicalShift.earlyMorning);

      expect(CanonicalShift.tryResolve('pagi'), CanonicalShift.morning);
      expect(CanonicalShift.tryResolve('PAGI'), CanonicalShift.morning);
      expect(CanonicalShift.tryResolve('morning'), CanonicalShift.morning);

      expect(CanonicalShift.tryResolve('siang'), CanonicalShift.afternoon);
      expect(CanonicalShift.tryResolve('SIANG'), CanonicalShift.afternoon);
      expect(CanonicalShift.tryResolve('afternoon'), CanonicalShift.afternoon);

      expect(CanonicalShift.tryResolve('malam'), CanonicalShift.night);
      expect(CanonicalShift.tryResolve('MALAM'), CanonicalShift.night);
      expect(CanonicalShift.tryResolve('night'), CanonicalShift.night);
    });

    test('formatMinutesToTime and parseTimeToMinutes handle 24:00 WIB (1440m) accurately', () {
      expect(formatMinutesToTime(1440), '24:00');
      expect(formatMinutesToTime(1080), '18:00');
      expect(formatMinutesToTime(720), '12:00');
      expect(formatMinutesToTime(360), '06:00');
      expect(formatMinutesToTime(0), '00:00');

      expect(parseTimeToMinutes('24:00'), 1440);
      expect(parseTimeToMinutes('18:00'), 1080);
      expect(parseTimeToMinutes('12:00'), 720);
      expect(parseTimeToMinutes('06:00'), 360);
      expect(parseTimeToMinutes('00:00'), 0);
    });

    test('isSessionShiftPast correctly handles night shift at 09:00 WIB and 21:04 WIB', () {
      final DateTime testDate = DateTime(2026, 9, 25);

      // At 09:00 WIB:
      final DateTime at0900 = DateTime(2026, 9, 25, 9, 0);
      // Dini hari (00:00 - 06:00) is past at 09:00 WIB
      expect(
        isSessionShiftPast(
          sessionId: 'dini_hari',
          selectedDate: testDate,
          referenceNow: at0900,
        ),
        isTrue,
      );
      // Malam (18:00 - 24:00) is NOT past at 09:00 WIB
      expect(
        isSessionShiftPast(
          sessionId: 'malam',
          selectedDate: testDate,
          referenceNow: at0900,
        ),
        isFalse,
      );

      // At 21:04 WIB:
      final DateTime at2104 = DateTime(2026, 9, 25, 21, 4);
      // Malam (18:00 - 24:00) is STILL ONGOING at 21:04 WIB (NOT PAST!)
      expect(
        isSessionShiftPast(
          sessionId: 'malam',
          selectedDate: testDate,
          referenceNow: at2104,
        ),
        isFalse,
      );
      expect(
        isSessionShiftPast(
          sessionId: 'night',
          selectedDate: testDate,
          referenceNow: at2104,
        ),
        isFalse,
      );
    });

    test('ScheduleSlotCollisionHelper renders annotations for occupied slots (e.g. dr. Wulan) from the start', () {
      const ScheduleFormSlot currentSlot = ScheduleFormSlot(
        id: 'slot-1',
        from: 'Pilih Jam',
        to: '-',
        room: 'Ruang KIA 2',
        poli: 'KIA',
      );

      const ScheduleShiftOccupancy occupancy = ScheduleShiftOccupancy(
        shift: 'morning',
        shiftLabel: 'Pagi',
        timeRange: '06:00 - 12:00 WIB',
        boundaryStartTime: '06:00',
        boundaryEndTime: '12:00',
        slotDurationMinutes: 30,
        totalSlots: 2,
        availableSlotsCount: 1,
        occupiedSlotsCount: 1,
        slots: <ScheduleShiftSlot>[
          ScheduleShiftSlot(
            slotIndex: 1,
            startTime: '06:00',
            endTime: '06:30',
            timeRange: '06:00 - 06:30 WIB',
            isAvailable: false,
            status: 'OCCUPIED_BY_OTHER',
            displayLabel: 'Terisi oleh dr. Wulan',
            conflictInfo: ScheduleSlotConflictInfo(
              type: 'ROOM_OCCUPIED',
              message: 'Ruangan sudah digunakan dr. Wulan',
              practitionerName: 'dr. Wulan',
              roomName: 'Ruang KIA 2',
            ),
          ),
          ScheduleShiftSlot(
            slotIndex: 2,
            startTime: '06:30',
            endTime: '07:00',
            timeRange: '06:30 - 07:00 WIB',
            isAvailable: true,
            status: 'AVAILABLE',
            displayLabel: 'Tersedia',
          ),
        ],
      );

      final result = ScheduleSlotCollisionHelper.computeSlotTimeOptions(
        sessionId: 'morning',
        currentSlot: currentSlot,
        sessionSlots: <ScheduleFormSlot>[currentSlot],
        allSessions: const <ScheduleFormSession>[],
        occupancy: occupancy,
      );

      // 06:00 is occupied by dr. Wulan
      expect(result.disabledTimes.contains('06:00'), isTrue);
      expect(result.subtitles['06:00'], 'dr. Wulan');
      expect(result.occupiedDetails['06:00']?.occupiedBy, 'dr. Wulan');
      expect(result.occupiedDetails['06:00']?.roomName, 'Ruang KIA 2');

      // 06:30 is available
      expect(result.disabledTimes.contains('06:30'), isFalse);
    });
  });
}
