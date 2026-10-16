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
  });

  factory SessionPatientDto.fromJson(Map<String, dynamic> json) {
    return SessionPatientDto(
      id: json['id'] as String? ?? json['appointmentId'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['patientName'] as String? ?? 'Pasien Tanpa Nama',
      medicalRecordNumber: json['medicalRecordNumber'] as String? ?? json['patientRm'] as String? ?? '-',
      age: json['age']?.toString() ?? json['patientAge']?.toString() ?? '-',
      gender: json['gender'] as String? ?? 'L',
      queueNumber: json['queueNumber']?.toString() ?? '-',
      sessionTitle: json['sessionTitle'] as String? ?? json['sessionLabel'] as String? ?? 'Sesi Praktik',
      room: json['room'] as String? ?? json['roomName'] as String? ?? '',
      guardian: json['guardian'] as String? ?? json['patientGuardian'] as String?,
      complaint: json['complaint'] as String? ?? json['patientComplaint'] as String?,
      status: json['status'] as String? ?? 'REGISTERED',
      statusBadge: json['statusBadge'] as String? ?? json['badge'] as String? ?? 'Terdaftar',
      avatarUrl: json['avatarUrl'] as String?,
      estimatedStartAt: json['estimatedStartAt']?.toString(),
      estimatedEndAt: json['estimatedEndAt']?.toString(),
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
    };
  }
}
