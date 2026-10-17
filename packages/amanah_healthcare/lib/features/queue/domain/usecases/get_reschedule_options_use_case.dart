import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/reschedule_options_entity.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class GetRescheduleOptionsUseCase
    implements UseCase<RescheduleOptionsEntity, String> {
  const GetRescheduleOptionsUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<RescheduleOptionsEntity> call(String appointmentId) {
    return _repository.getRescheduleOptions(appointmentId);
  }
}
