import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/calendar_summary_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/mappers/calendar_summary_mapper.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';

void main() {
  group('CalendarSummaryMapper', () {
    test('maps CalendarDaySummaryDto to CalendarDaySummary entity', () {
      const CalendarDaySummaryDto dto = CalendarDaySummaryDto(
        date: '2026-10-17',
        hasSchedule: true,
        isOnLeave: false,
        sessionCount: 2,
        bookedPatientCount: 5,
        isClosed: false,
        notes: 'Praktek lancar',
      );

      final CalendarDaySummary entity = CalendarSummaryMapper.fromDto(dto);

      expect(entity.date, '2026-10-17');
      expect(entity.hasSchedule, true);
      expect(entity.isOnLeave, false);
      expect(entity.sessionCount, 2);
      expect(entity.bookedPatientCount, 5);
      expect(entity.isClosed, false);
      expect(entity.notes, 'Praktek lancar');
    });
  });
}
