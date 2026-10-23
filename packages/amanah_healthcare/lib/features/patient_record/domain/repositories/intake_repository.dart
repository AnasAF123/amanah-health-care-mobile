import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';

/// Abstract port interface for clinical intake repository operations.
abstract interface class IntakeRepository {
  /// Fetches complete unified clinical intake record (Maternal, Immunization, or Regular) by appointment ID.
  Future<PatientIntakeRecord> getIntakeByAppointmentId(String appointmentId);

  /// Fetches historical maternal intake consultations for a patient.
  Future<List<MaternalTimelineItem>> getMaternalHistory(String patientId);
}
