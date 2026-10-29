import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_patient_card.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class GetSessionQueueParams {
  const GetSessionQueueParams({required this.sessionId, this.date});
  final String sessionId;
  final String? date;
}

class GetSessionQueueUseCase
    implements UseCase<List<QueuePatientCard>, GetSessionQueueParams> {
  const GetSessionQueueUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<List<QueuePatientCard>> call(GetSessionQueueParams params) {
    return _repository.getWaitingQueue(params.sessionId, date: params.date);
  }
}
