import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class CallPatientParams {
  const CallPatientParams({required this.appointmentId, this.notes});

  final String appointmentId;
  final String? notes;
}

class CallPatientUseCase implements UseCase<void, CallPatientParams> {
  const CallPatientUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<void> call(CallPatientParams params) {
    return _repository.callPatient(params.appointmentId, notes: params.notes);
  }
}
