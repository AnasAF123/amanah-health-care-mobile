import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

final class GetCalendarSummaryParams {
  const GetCalendarSummaryParams({required this.month});

  final String month; // YYYY-MM
}

final class GetCalendarSummaryUseCase
    implements UseCase<List<CalendarDaySummary>, GetCalendarSummaryParams> {
  const GetCalendarSummaryUseCase(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<List<CalendarDaySummary>> call(GetCalendarSummaryParams params) {
    return _repository.getCalendarSummary(params.month);
  }
}
