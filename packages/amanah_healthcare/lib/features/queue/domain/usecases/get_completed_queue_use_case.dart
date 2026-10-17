import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_patient_card.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class GetCompletedQueueUseCase
    implements UseCase<List<QueuePatientCard>, String> {
  const GetCompletedQueueUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<List<QueuePatientCard>> call(String sessionId) {
    return _repository.getCompletedQueue(sessionId);
  }
}
