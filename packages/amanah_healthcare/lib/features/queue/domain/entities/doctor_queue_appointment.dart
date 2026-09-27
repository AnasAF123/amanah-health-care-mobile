import 'package:amanah_healthcare/core/constants/doctor_queue_status.dart';

class DoctorQueueAppointment {
  final String id;
  final String queueNumber;
  final DoctorQueueStatus status;
  final int callCount;
  final String patientName;
  final String? patientPhone;
  final String appointmentDate;
  final String session;
  final int estimatedDurationMinutes;
  final DateTime? lastCalledAt;

  const DoctorQueueAppointment({
    required this.id,
    required this.queueNumber,
    required this.status,
    required this.callCount,
    required this.patientName,
    this.patientPhone,
    required this.appointmentDate,
    required this.session,
    this.estimatedDurationMinutes = 30,
    this.lastCalledAt,
  });

  bool get canBeCalled =>
      status == DoctorQueueStatus.waiting ||
      (status == DoctorQueueStatus.called && callCount < 3);

  bool get isInConsultation => status == DoctorQueueStatus.inConsultation;

  bool get isCalled => status == DoctorQueueStatus.called;
}
