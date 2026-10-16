import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

final class ToggleDayStatusParams {
  const ToggleDayStatusParams({
    required this.date,
    required this.isClosed,
    this.notes,
  });

  final String date;
  final bool isClosed;
  final String? notes;
}

final class ToggleDayStatusUseCase
    implements UseCase<void, ToggleDayStatusParams> {
  const ToggleDayStatusUseCase(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<void> call(ToggleDayStatusParams params) {
    return _repository.toggleDayStatus(
      params.date,
      isClosed: params.isClosed,
      notes: params.notes,
    );
  }
}
