import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class ReportNoShowParams {
  const ReportNoShowParams({required this.appointmentId, this.notes});

  final String appointmentId;
  final String? notes;
}

class ReportNoShowUseCase implements UseCase<void, ReportNoShowParams> {
  const ReportNoShowUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<void> call(ReportNoShowParams params) {
    return _repository.reportNoShow(params.appointmentId, notes: params.notes);
  }
}
