import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

final class GetBookedPatientsParams {
  const GetBookedPatientsParams({required this.date});

  final String date; // YYYY-MM-DD
}

final class GetBookedPatientsUseCase
    implements UseCase<List<SessionPatient>, GetBookedPatientsParams> {
  const GetBookedPatientsUseCase(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<List<SessionPatient>> call(GetBookedPatientsParams params) {
    return _repository.getBookedPatients(params.date);
  }
}
