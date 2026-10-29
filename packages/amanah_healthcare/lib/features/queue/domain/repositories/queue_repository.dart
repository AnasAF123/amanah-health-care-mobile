import 'package:amanah_healthcare/features/queue/domain/entities/queue_patient_card.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_session_info.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/reschedule_options_entity.dart';

/// Abstract port for queue repository operations.
abstract interface class QueueRepository {
  /// Fetches duty sessions assigned to the current authenticated practitioner for today.
  Future<List<QueueSessionInfo>> getDoctorTodaySessions();

  /// Fetches waiting queue patients scoped to a session definition.
  Future<List<QueuePatientCard>> getWaitingQueue(String sessionId, {String? date});

  /// Calls a patient to enter the consultation room.
  Future<void> callPatient(String appointmentId, {String? notes});

  /// Starts consultation examination (WAITING -> IN_SERVICE).
  Future<void> startService(String appointmentId);

  /// Completes consultation examination (IN_SERVICE -> COMPLETED).
  Future<void> completeService(String appointmentId);

  /// Cancels an appointment from queue.
  Future<void> cancelAppointment(String appointmentId, {String? reason});

  /// Reports patient did not respond to call.
  Future<void> reportNoShow(String appointmentId, {String? notes});

  /// Reschedules an appointment to a target date and session.
  Future<void> rescheduleAppointment(
    String appointmentId, {
    required String targetDate,
    String? session,
    String? targetSessionId,
    String? reason,
  });

  /// Fetches dynamic reschedule options for an appointment.
  Future<RescheduleOptionsEntity> getRescheduleOptions(String appointmentId);

  /// Fetches completed patients for a session.
  Future<List<QueuePatientCard>> getCompletedQueue(String sessionId, {String? date});

  /// Fetches appointments processed by the authenticated doctor for a given date (defaults to today).
  Future<List<QueuePatientCard>> getDoctorProcessedQueue({String? date});
}
