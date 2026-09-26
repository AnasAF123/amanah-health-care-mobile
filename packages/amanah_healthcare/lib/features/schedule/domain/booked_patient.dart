enum AmanahBadgeVariant { success, primary, warning, live, trend }

class BookedPatient {
  const BookedPatient({
    required this.id,
    required this.patientName,
    required this.patientRm,
    required this.patientAge,
    required this.patientComplaint,
    required this.queueNumber,
    required this.timeSlot,
    required this.badge,
    required this.badgeVariant,
    this.appointmentId,
    this.avatarUrl,
    this.patientGuardian,
    this.gender,
    this.sessionTitle,
    this.room,
    this.status,
    this.statusBadge,
    this.nik,
  });

  factory BookedPatient.fromJson(Map<String, dynamic> json) {
    final String rawStatus = (json['status'] as String? ?? 'booked').toLowerCase();
    AmanahBadgeVariant variant;
    String badgeText = json['statusBadge'] as String? ?? 'Terdaftar';

    switch (rawStatus) {
      case 'in_service':
      case 'sedang_diperiksa':
        variant = AmanahBadgeVariant.live;
        badgeText = 'Pemeriksaan';
        break;
      case 'completed':
      case 'selesai':
        variant = AmanahBadgeVariant.success;
        badgeText = 'Selesai';
        break;
      case 'checked_in':
      case 'waiting':
      case 'menunggu':
        variant = AmanahBadgeVariant.primary;
        badgeText = rawStatus == 'checked_in' ? 'Check In' : 'Menunggu';
        break;
      case 'cancelled':
      case 'batal':
        variant = AmanahBadgeVariant.warning;
        badgeText = 'Dibatalkan';
        break;
      default:
        variant = AmanahBadgeVariant.primary;
        badgeText = 'Booked';
        break;
    }

    return BookedPatient(
      id: json['id'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? json['id'] as String?,
      patientName: json['fullName'] as String? ??
          json['patientName'] as String? ??
          json['name'] as String? ??
          '',
      patientRm: json['medicalRecordNumber'] as String? ??
          json['patientRm'] as String? ??
          json['noRm'] as String? ??
          '',
      patientAge: json['age'] as String? ?? json['patientAge'] as String? ?? '',
      patientComplaint: json['complaint'] as String? ??
          json['patientComplaint'] as String? ??
          '',
      queueNumber: json['queueNumber'] as String? ?? '',
      timeSlot: json['timeSlot'] as String? ??
          json['slotTime'] as String? ??
          '',
      badge: badgeText,
      badgeVariant: variant,
      avatarUrl: json['avatarUrl'] as String?,
      patientGuardian: json['guardian'] as String? ??
          json['patientGuardian'] as String? ??
          json['emergencyContact'] as String?,
      gender: json['gender'] as String?,
      sessionTitle: json['sessionTitle'] as String?,
      room: json['room'] as String?,
      status: json['status'] as String?,
      statusBadge: json['statusBadge'] as String?,
      nik: json['nik'] as String?,
    );
  }

  final String id;
  final String? appointmentId;
  final String patientName;
  final String patientRm;
  final String patientAge;
  final String patientComplaint;
  final String queueNumber;
  final String timeSlot;
  final String badge;
  final AmanahBadgeVariant badgeVariant;
  final String? avatarUrl;
  final String? patientGuardian;
  final String? gender;
  final String? sessionTitle;
  final String? room;
  final String? status;
  final String? statusBadge;
  final String? nik;

  bool get isInService =>
      status?.toLowerCase() == 'in_service' ||
      status?.toLowerCase() == 'sedang_diperiksa';

  bool get isCompleted =>
      status?.toLowerCase() == 'completed' ||
      status?.toLowerCase() == 'selesai';

  bool get isCancelled =>
      status?.toLowerCase() == 'cancelled' ||
      status?.toLowerCase() == 'batal';

  bool get isActive => !isCancelled;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'appointmentId': appointmentId,
      'fullName': patientName,
      'medicalRecordNumber': patientRm,
      'age': patientAge,
      'complaint': patientComplaint,
      'queueNumber': queueNumber,
      'timeSlot': timeSlot,
      'avatarUrl': avatarUrl,
      'guardian': patientGuardian,
      'gender': gender,
      'sessionTitle': sessionTitle,
      'room': room,
      'status': status,
      'statusBadge': statusBadge ?? badge,
      if (nik != null) 'nik': nik,
    };
  }

  BookedPatient copyWith({
    String? id,
    String? appointmentId,
    String? patientName,
    String? patientRm,
    String? patientAge,
    String? patientComplaint,
    String? queueNumber,
    String? timeSlot,
    String? badge,
    AmanahBadgeVariant? badgeVariant,
    String? avatarUrl,
    String? patientGuardian,
    String? gender,
    String? sessionTitle,
    String? room,
    String? status,
    String? statusBadge,
    String? nik,
  }) {
    return BookedPatient(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      patientName: patientName ?? this.patientName,
      patientRm: patientRm ?? this.patientRm,
      patientAge: patientAge ?? this.patientAge,
      patientComplaint: patientComplaint ?? this.patientComplaint,
      queueNumber: queueNumber ?? this.queueNumber,
      timeSlot: timeSlot ?? this.timeSlot,
      badge: badge ?? this.badge,
      badgeVariant: badgeVariant ?? this.badgeVariant,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      patientGuardian: patientGuardian ?? this.patientGuardian,
      gender: gender ?? this.gender,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      room: room ?? this.room,
      status: status ?? this.status,
      statusBadge: statusBadge ?? this.statusBadge,
      nik: nik ?? this.nik,
    );
  }
}

class SessionClinicRoom {
  const SessionClinicRoom({
    required this.id,
    required this.name,
    this.floor,
  });

  factory SessionClinicRoom.fromJson(Map<String, dynamic> json) {
    return SessionClinicRoom(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      floor: json['floor'] as String?,
    );
  }

  final String id;
  final String name;
  final String? floor;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        if (floor != null) 'floor': floor,
      };
}

class SessionPatientsData {
  const SessionPatientsData({
    required this.sessionId,
    required this.sessionLabel,
    required this.shift,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.availableSlots,
    required this.bookedCount,
    this.clinicRoom,
    this.patients = const <BookedPatient>[],
  });

  factory SessionPatientsData.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawPatients = json['patients'] as List<dynamic>?;
    final List<BookedPatient> parsedPatients = rawPatients != null
        ? rawPatients
            .whereType<Map<String, dynamic>>()
            .map(BookedPatient.fromJson)
            .toList()
        : const <BookedPatient>[];

    return SessionPatientsData(
      sessionId: json['sessionId'] as String? ?? '',
      sessionLabel: json['sessionLabel'] as String? ?? '',
      shift: json['shift'] as String? ?? '',
      scheduleDate: json['scheduleDate'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      capacity: json['capacity'] as int? ?? parsedPatients.length,
      availableSlots: json['availableSlots'] as int? ?? 0,
      bookedCount: json['bookedCount'] as int? ?? parsedPatients.length,
      clinicRoom: json['clinicRoom'] != null && json['clinicRoom'] is Map<String, dynamic>
          ? SessionClinicRoom.fromJson(json['clinicRoom'] as Map<String, dynamic>)
          : null,
      patients: parsedPatients,
    );
  }

  final String sessionId;
  final String sessionLabel;
  final String shift;
  final String scheduleDate;
  final String startTime;
  final String endTime;
  final int capacity;
  final int availableSlots;
  final int bookedCount;
  final SessionClinicRoom? clinicRoom;
  final List<BookedPatient> patients;

  SessionPatientsData copyWith({
    String? sessionId,
    String? sessionLabel,
    String? shift,
    String? scheduleDate,
    String? startTime,
    String? endTime,
    int? capacity,
    int? availableSlots,
    int? bookedCount,
    SessionClinicRoom? clinicRoom,
    List<BookedPatient>? patients,
  }) {
    return SessionPatientsData(
      sessionId: sessionId ?? this.sessionId,
      sessionLabel: sessionLabel ?? this.sessionLabel,
      shift: shift ?? this.shift,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      availableSlots: availableSlots ?? this.availableSlots,
      bookedCount: bookedCount ?? this.bookedCount,
      clinicRoom: clinicRoom ?? this.clinicRoom,
      patients: patients ?? this.patients,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sessionId': sessionId,
        'sessionLabel': sessionLabel,
        'shift': shift,
        'scheduleDate': scheduleDate,
        'startTime': startTime,
        'endTime': endTime,
        'capacity': capacity,
        'availableSlots': availableSlots,
        'bookedCount': bookedCount,
        if (clinicRoom != null) 'clinicRoom': clinicRoom!.toJson(),
        'patients': patients.map((BookedPatient p) => p.toJson()).toList(),
      };
}
