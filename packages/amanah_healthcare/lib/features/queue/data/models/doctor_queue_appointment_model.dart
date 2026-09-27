import 'package:amanah_healthcare/core/constants/doctor_queue_status.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/doctor_queue_appointment.dart';

class DoctorQueueAppointmentModel extends DoctorQueueAppointment {
  const DoctorQueueAppointmentModel({
    required super.id,
    required super.queueNumber,
    required super.status,
    required super.callCount,
    required super.patientName,
    super.patientPhone,
    required super.appointmentDate,
    required super.session,
    super.estimatedDurationMinutes = 30,
    super.lastCalledAt,
  });

  factory DoctorQueueAppointmentModel.fromJson(Map<String, dynamic> json) {
    final patientJson = json['patient'] as Map<String, dynamic>?;
    final patientName = patientJson?['fullName'] as String? ??
        json['patientName'] as String? ??
        '-';
    final patientPhone =
        patientJson?['phoneNumber'] as String? ?? json['patientPhone'] as String?;

    return DoctorQueueAppointmentModel(
      id: json['id'] as String? ?? '',
      queueNumber: json['queueNumber'] as String? ?? '-',
      status: DoctorQueueStatus.fromString(json['status'] as String?),
      callCount: (json['callCount'] as num?)?.toInt() ?? 0,
      patientName: patientName,
      patientPhone: patientPhone,
      appointmentDate: json['appointmentDate'] as String? ?? '',
      session: json['session'] as String? ?? '',
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 30,
      lastCalledAt: json['lastCalledAt'] != null
          ? DateTime.tryParse(json['lastCalledAt'] as String)
          : null,
    );
  }
}
