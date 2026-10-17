import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class RescheduleAppointmentParams {
  const RescheduleAppointmentParams({
    required this.appointmentId,
    required this.targetDate,
    this.session,
    this.targetSessionId,
    this.reason,
  });

  final String appointmentId;
  final String targetDate;
  final String? session;
  final String? targetSessionId;
  final String? reason;
}

class RescheduleAppointmentUseCase
    implements UseCase<void, RescheduleAppointmentParams> {
  const RescheduleAppointmentUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<void> call(RescheduleAppointmentParams params) {
    return _repository.rescheduleAppointment(
      params.appointmentId,
      targetDate: params.targetDate,
      session: params.session,
      targetSessionId: params.targetSessionId,
      reason: params.reason,
    );
  }
}
