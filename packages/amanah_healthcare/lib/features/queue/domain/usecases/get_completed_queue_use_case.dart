import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_patient_card.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/get_session_queue_use_case.dart';

class GetCompletedQueueUseCase
    implements UseCase<List<QueuePatientCard>, GetSessionQueueParams> {
  const GetCompletedQueueUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<List<QueuePatientCard>> call(GetSessionQueueParams params) {
    return _repository.getCompletedQueue(params.sessionId, date: params.date);
  }
}
