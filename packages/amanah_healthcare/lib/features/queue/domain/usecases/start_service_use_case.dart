import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class StartServiceUseCase implements UseCase<void, String> {
  const StartServiceUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<void> call(String appointmentId) {
    return _repository.startService(appointmentId);
  }
}
