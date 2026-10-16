import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

final class GetSessionPatientsParams {
  const GetSessionPatientsParams({
    required this.sessionId,
    this.date,
  });

  final String sessionId;
  final String? date;
}

final class GetSessionPatientsUseCase
    implements UseCase<List<SessionPatient>, GetSessionPatientsParams> {
  const GetSessionPatientsUseCase(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<List<SessionPatient>> call(GetSessionPatientsParams params) {
    return _repository.getSessionPatients(
      params.sessionId,
      date: params.date,
    );
  }
}
