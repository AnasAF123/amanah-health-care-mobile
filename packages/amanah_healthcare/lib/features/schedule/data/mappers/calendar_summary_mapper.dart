import 'package:amanah_healthcare/features/schedule/data/dto/calendar_summary_dto.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';

abstract final class CalendarSummaryMapper {
  static CalendarDaySummary fromDto(CalendarDaySummaryDto dto) {
    return CalendarDaySummary(
      date: dto.date,
      hasSchedule: dto.hasSchedule,
      isOnLeave: dto.isOnLeave,
      leaveReason: dto.leaveReason,
      sessionCount: dto.sessionCount,
      bookedPatientCount: dto.bookedPatientCount,
      isClosed: dto.isClosed,
      notes: dto.notes,
    );
  }
}
