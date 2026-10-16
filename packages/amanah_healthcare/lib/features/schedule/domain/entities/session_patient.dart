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

  BookedPatient toBookedPatient() {
    return BookedPatient(
      id: id,
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
    );
  }
}
