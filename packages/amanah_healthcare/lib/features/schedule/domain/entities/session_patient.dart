import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class SessionPatient {
  const SessionPatient({
    required this.id,
    required this.appointmentId,
    required this.fullName,
    required this.medicalRecordNumber,
    required this.age,
    required this.gender,
    required this.queueNumber,
    required this.sessionTitle,
    required this.room,
    this.guardian,
    this.complaint,
    required this.status,
    required this.statusBadge,
    this.avatarUrl,
    this.estimatedStartAt,
    this.estimatedEndAt,
    this.badgeVariant = AmanahBadgeVariant.primary,
    this.poliklinikName,
    this.etaRange,
    this.actualStartedAt,
    this.actualCompletedAt,
    this.consultationDurationFormatted,
    this.scheduledStartTime,
    this.scheduledEndTime,
  });

  final String id;
  final String appointmentId;
  final String fullName;
  final String medicalRecordNumber;
  final String age;
  final String gender;
  final String queueNumber;
  final String sessionTitle;
  final String room;
  final String? guardian;
  final String? complaint;
  final String status;
  final String statusBadge;
  final String? avatarUrl;
  final String? estimatedStartAt;
  final String? estimatedEndAt;
  final AmanahBadgeVariant badgeVariant;
  final String? poliklinikName;
  final String? etaRange;
  final String? actualStartedAt;
  final String? actualCompletedAt;
  final String? consultationDurationFormatted;
  final String? scheduledStartTime;
  final String? scheduledEndTime;

  BookedPatient toBookedPatient() {
    return BookedPatient(
      id: id,
      appointmentId: appointmentId,
      patientId: id,
      patientName: fullName,
      patientRm: medicalRecordNumber,
      patientAge: age,
      patientComplaint: complaint ?? '-',
      queueNumber: queueNumber,
      timeSlot: sessionTitle,
      badge: statusBadge.isNotEmpty ? statusBadge : status,
      badgeVariant: badgeVariant,
      avatarUrl: avatarUrl,
      patientGuardian: guardian,
      poliklinikName: poliklinikName,
      etaRange: etaRange,
      actualStartedAt: actualStartedAt,
      actualCompletedAt: actualCompletedAt,
      consultationDurationFormatted: consultationDurationFormatted,
      scheduledStartTime: scheduledStartTime,
      scheduledEndTime: scheduledEndTime,
      status: status,
    );
  }
}
