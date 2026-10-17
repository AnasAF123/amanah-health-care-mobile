import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class CancelAppointmentParams {
  const CancelAppointmentParams({required this.appointmentId, this.reason});

  final String appointmentId;
  final String? reason;
}

class CancelAppointmentUseCase
    implements UseCase<void, CancelAppointmentParams> {
  const CancelAppointmentUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<void> call(CancelAppointmentParams params) {
    return _repository.cancelAppointment(params.appointmentId,
        reason: params.reason);
  }
}
