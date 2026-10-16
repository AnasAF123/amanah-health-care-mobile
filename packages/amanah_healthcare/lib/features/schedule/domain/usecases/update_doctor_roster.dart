import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

final class UpdateDoctorRosterParams {
  const UpdateDoctorRosterParams({
    required this.assignments,
    this.reason,
  });

  final List<Map<String, dynamic>> assignments;
  final String? reason;
}

final class UpdateDoctorRosterUseCase
    implements UseCase<DoctorRoster, UpdateDoctorRosterParams> {
  const UpdateDoctorRosterUseCase(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<DoctorRoster> call(UpdateDoctorRosterParams params) {
    return _repository.updateDoctorRoster(
      params.assignments,
      reason: params.reason,
    );
  }
}
