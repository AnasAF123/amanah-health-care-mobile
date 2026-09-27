import 'package:amanah_healthcare/features/queue/domain/entities/doctor_queue_appointment.dart';

abstract class DoctorQueueRepository {
  Future<List<DoctorQueueAppointment>> getDailyQueue({
    required String poliklinikId,
    required String date,
    String? session,
  });

  Future<DoctorQueueAppointment> callPatient(String appointmentId);

  Future<DoctorQueueAppointment> respondPatient(String appointmentId);

  Future<DoctorQueueAppointment> noShowPatient(String appointmentId);

  Future<DoctorQueueAppointment> completeAppointment(String appointmentId);
}
