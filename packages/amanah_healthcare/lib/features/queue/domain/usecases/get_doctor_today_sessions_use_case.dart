import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_session_info.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class GetDoctorTodaySessionsUseCase
    implements UseCase<List<QueueSessionInfo>, NoParams> {
  const GetDoctorTodaySessionsUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<List<QueueSessionInfo>> call(NoParams params) {
    return _repository.getDoctorTodaySessions();
  }
}
