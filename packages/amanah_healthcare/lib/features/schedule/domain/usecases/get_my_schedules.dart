import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

final class GetMySchedulesParams {
  const GetMySchedulesParams({
    this.date,
    this.startDate,
    this.endDate,
  });

  final String? date;
  final String? startDate;
  final String? endDate;
}

final class GetMySchedulesUseCase
    implements UseCase<List<MyScheduleSession>, GetMySchedulesParams> {
  const GetMySchedulesUseCase(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<List<MyScheduleSession>> call(GetMySchedulesParams params) {
    return _repository.getMySchedules(
      date: params.date,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
