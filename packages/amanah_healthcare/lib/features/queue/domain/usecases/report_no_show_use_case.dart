import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_no_show_result.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class ReportNoShowParams {
  const ReportNoShowParams({required this.appointmentId, this.notes});

  final String appointmentId;
  final String? notes;
}

class ReportNoShowUseCase implements UseCase<QueueNoShowResult, ReportNoShowParams> {
  const ReportNoShowUseCase(this._repository);

  final QueueRepository _repository;

  @override
  Future<QueueNoShowResult> call(ReportNoShowParams params) {
    return _repository.reportNoShow(params.appointmentId, notes: params.notes);
  }
}
