import 'package:amanah_healthcare/features/schedule/domain/constants/appointment_status_dictionary.dart';

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
        json['patient'] is Map<String, dynamic> ? json['patient'] as Map<String, dynamic> : null;

    final String aptId = (json['appointmentId'] ?? json['id'] ?? '') as String;
    final String pId = (patientMap?['id'] ?? json['patientId'] ?? aptId) as String;
    final String rawStatus = (json['status'] as String? ?? '').toLowerCase();

    return SessionPatientDto(
      id: pId,
      appointmentId: aptId.isNotEmpty ? aptId : pId,
      fullName: (patientMap?['fullName'] ?? json['patientName'] ?? json['fullName'] ?? '') as String,
      medicalRecordNumber:
          (patientMap?['medicalRecordNumber'] ?? json['medicalRecordNumber'] ?? json['bookingCode'] ?? '') as String,
      age: (patientMap?['age'] ?? json['age'] ?? '').toString(),
      gender: (patientMap?['gender'] ?? json['gender'] ?? '') as String,
      queueNumber: (json['queueNumber'] ?? '').toString(),
      sessionTitle: (json['sessionTitle'] ?? json['sessionLabel'] ?? '') as String,
      room: (json['roomName'] ?? json['clinicRoomName'] ?? json['room'] ?? '') as String,
      guardian: (patientMap?['guardianName'] ?? json['guardian']) as String?,
      complaint: (json['chiefComplaint'] ?? json['complaint']) as String?,
      status: rawStatus,
      statusBadge: json['statusBadge'] as String? ??
          AppointmentStatusDescriptor.resolve(rawStatus).label,
      avatarUrl: (patientMap?['avatarUrl'] ?? json['avatarUrl']) as String?,
      estimatedStartAt: json['estimatedStartAt']?.toString(),
      estimatedEndAt: json['estimatedEndAt']?.toString(),
      poliklinikName: json['poliklinikName'] as String?,
      etaRange: json['etaRange'] as String?,
      actualStartedAt: json['actualStartedAt']?.toString(),
      actualCompletedAt: json['actualCompletedAt']?.toString(),
      consultationDurationFormatted: json['consultationDurationFormatted'] as String?,
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
