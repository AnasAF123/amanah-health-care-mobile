import 'package:amanah_healthcare/features/schedule/domain/constants/appointment_status_dictionary.dart';
import 'package:amanah_healthcare/features/schedule/domain/helpers/clinical_session_resolver.dart';

class SessionPatientDto {
  const SessionPatientDto({
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
    this.poliklinikName,
    this.etaRange,
    this.actualStartedAt,
    this.actualCompletedAt,
    this.consultationDurationFormatted,
    this.scheduledStartTime,
    this.scheduledEndTime,
  });

  factory SessionPatientDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? patientMap =
        json['patient'] is Map<String, dynamic>
            ? json['patient'] as Map<String, dynamic>
            : null;

    final String aptId = json['appointmentId'] as String? ??
        (patientMap != null ? json['id'] as String? : null) ??
        json['id'] as String? ??
        '';
    final String pId = patientMap?['id'] as String? ??
        json['patientId'] as String? ??
        (patientMap == null ? json['id'] as String? : null) ??
        aptId;

    final String rawSession = json['sessionName'] as String? ??
        json['sessionTitle'] as String? ??
        json['sessionLabel'] as String? ??
        (json['session'] != null ? 'Sesi ${json['session']}' : 'Sesi Praktik');

    return SessionPatientDto(
      id: pId,
      appointmentId: aptId.isNotEmpty ? aptId : pId,
      fullName: patientMap?['fullName'] as String? ??
          json['fullName'] as String? ??
          json['patientName'] as String? ??
          'Pasien Tanpa Nama',
      medicalRecordNumber: patientMap?['medicalRecordNumber'] as String? ??
          json['medicalRecordNumber'] as String? ??
          json['patientRm'] as String? ??
          (json['bookingCode'] != null ? json['bookingCode'].toString() : '-'),
      age: patientMap?['age']?.toString() ??
          json['age']?.toString() ??
          json['patientAge']?.toString() ??
          '-',
      gender: patientMap?['gender'] as String? ??
          json['gender'] as String? ??
          'L',
      queueNumber: json['queueNumber']?.toString() ?? '-',
      sessionTitle: ClinicalSessionResolver.sanitize(rawSession),
      room: json['room'] as String? ??
          json['roomName'] as String? ??
          json['clinicRoomName'] as String? ??
          '',
      guardian: patientMap?['guardianName'] as String? ??
          json['guardian'] as String? ??
          json['parentUserName'] as String? ??
          json['patientGuardian'] as String?,
      complaint: json['chiefComplaint'] as String? ??
          json['complaint'] as String? ??
          json['patientComplaint'] as String?,
      status: (json['status'] as String? ?? 'WAITING').toUpperCase(),
      statusBadge: AppointmentStatusDescriptor.resolve(
        json['status'] as String?,
      ).badge,
      avatarUrl: json['patientAvatarUrl'] as String? ??
          patientMap?['avatarUrl'] as String? ??
          json['avatarUrl'] as String?,
      estimatedStartAt: json['estimatedStartAt']?.toString(),
      estimatedEndAt: json['estimatedEndAt']?.toString(),
      poliklinikName: json['poliklinikName'] as String? ?? json['poli'] as String?,
      etaRange: json['etaRange'] as String?,
      actualStartedAt: json['actualStartedAt']?.toString(),
      actualCompletedAt: json['actualCompletedAt']?.toString(),
      consultationDurationFormatted:
          json['consultationDurationFormatted'] as String?,
      scheduledStartTime: json['scheduledStartTime'] as String?,
      scheduledEndTime: json['scheduledEndTime'] as String?,
    );
  }

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
  final String? poliklinikName;
  final String? etaRange;
  final String? actualStartedAt;
  final String? actualCompletedAt;
  final String? consultationDurationFormatted;
  final String? scheduledStartTime;
  final String? scheduledEndTime;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'appointmentId': appointmentId,
      'fullName': fullName,
      'medicalRecordNumber': medicalRecordNumber,
      'age': age,
      'gender': gender,
      'queueNumber': queueNumber,
      'sessionTitle': sessionTitle,
      'room': room,
      'guardian': guardian,
      'complaint': complaint,
      'status': status,
      'statusBadge': statusBadge,
      'avatarUrl': avatarUrl,
      'estimatedStartAt': estimatedStartAt,
      'estimatedEndAt': estimatedEndAt,
      'poliklinikName': poliklinikName,
      'etaRange': etaRange,
      'actualStartedAt': actualStartedAt,
      'actualCompletedAt': actualCompletedAt,
      'consultationDurationFormatted': consultationDurationFormatted,
      'scheduledStartTime': scheduledStartTime,
      'scheduledEndTime': scheduledEndTime,
    };
  }
}
