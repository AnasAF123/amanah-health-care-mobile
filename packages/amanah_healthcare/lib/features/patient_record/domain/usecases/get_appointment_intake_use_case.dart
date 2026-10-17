import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/domain/repositories/intake_repository.dart';

/// Use case to fetch clinical intake record associated with an appointment.
class GetAppointmentIntakeUseCase implements UseCase<PatientIntakeRecord, String> {
  const GetAppointmentIntakeUseCase(this._repository);

  final IntakeRepository _repository;

  @override
  Future<PatientIntakeRecord> call(String appointmentId) {
    return _repository.getIntakeByAppointmentId(appointmentId);
  }
}
