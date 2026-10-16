import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

final class ResetDoctorRosterUseCase implements UseCase<DoctorRoster, NoParams> {
  const ResetDoctorRosterUseCase(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<DoctorRoster> call(NoParams params) {
    return _repository.resetDoctorRoster();
  }
}
