import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/domain/repositories/intake_repository.dart';

/// Use case to fetch historical maternal intake consultations for a patient.
class GetMaternalHistoryUseCase implements UseCase<List<MaternalTimelineItem>, String> {
  const GetMaternalHistoryUseCase(this._repository);

  final IntakeRepository _repository;

  @override
  Future<List<MaternalTimelineItem>> call(String patientId) {
    return _repository.getMaternalHistory(patientId);
  }
}
