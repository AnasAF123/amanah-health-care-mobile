enum AmanahBadgeVariant { success, primary, warning, live, trend }

/// Domain exception for schedule operations.
class AmanahScheduleException implements Exception {
  const AmanahScheduleException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Conflict exception thrown on HTTP 409 Conflict responses.
class AmanahScheduleConflictException extends AmanahScheduleException {
  const AmanahScheduleConflictException({
    required String message,
    required String code,
    this.conflictingDoctor,
    this.conflictingRoom,
    this.conflictingTimeRange,
    this.activeBookingCount,
  }) : super(message, code: code);

  final String? conflictingDoctor;
  final String? conflictingRoom;
  final String? conflictingTimeRange;
  final int? activeBookingCount;

  static const String scheduleHasActiveBookings = 'SCHEDULE_HAS_ACTIVE_BOOKINGS';
  static const String roomAlreadyOccupied = 'ROOM_ALREADY_OCCUPIED';
  static const String practitionerAlreadyScheduled = 'PRACTITIONER_ALREADY_SCHEDULED';
  static const String invalidTimeRange = 'INVALID_TIME_RANGE';

  bool get hasActiveBookings => code == scheduleHasActiveBookings;
  bool get isRoomOccupied => code == roomAlreadyOccupied;
  bool get isPractitionerConflict => code == practitionerAlreadyScheduled;
  bool get isInvalidTimeRange => code == invalidTimeRange;
}

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
  });

  factory BookedPatient.fromJson(Map<String, dynamic> json) {
    final String statusStr = (json['status'] as String? ?? 'booked').toLowerCase();
    AmanahBadgeVariant variant;
    String badgeText = json['statusBadge'] as String? ?? 'Terdaftar';

    switch (statusStr) {
      case 'in_service':
        variant = AmanahBadgeVariant.live;
        badgeText = 'Pemeriksaan';
        break;
      case 'completed':
        variant = AmanahBadgeVariant.success;
        badgeText = 'Selesai';
        break;
      case 'checked_in':
      case 'waiting':
        variant = AmanahBadgeVariant.primary;
        badgeText = statusStr == 'checked_in' ? 'Check In' : 'Menunggu';
        break;
      case 'cancelled':
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
      appointmentId: json['appointmentId'] as String?,
      patientName: json['fullName'] as String? ?? json['patientName'] as String? ?? 'Pasien',
      patientRm: json['medicalRecordNumber'] as String? ?? json['patientRm'] as String? ?? 'RM-UNKNOWN',
      patientAge: json['age'] as String? ?? json['patientAge'] as String? ?? '-',
      patientComplaint: json['complaint'] as String? ?? json['patientComplaint'] as String? ?? 'Pemeriksaan rutin',
      queueNumber: json['queueNumber'] as String? ?? '#01',
      timeSlot: json['timeSlot'] as String? ?? '08:00 - 10:00 WIB',
      badge: badgeText,
      badgeVariant: variant,
      avatarUrl: json['avatarUrl'] as String?,
      patientGuardian: json['guardian'] as String? ?? json['patientGuardian'] as String?,
      gender: json['gender'] as String?,
      sessionTitle: json['sessionTitle'] as String?,
      room: json['room'] as String?,
      status: json['status'] as String?,
      statusBadge: json['statusBadge'] as String?,
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
    );
  }
}

class DoctorSchedule {
  const DoctorSchedule({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.poli,
    required this.room,
    required this.slotCount,
    required this.slotText,
    required this.badge,
    required this.badgeVariant,
    this.startTime,
    this.endTime,
    this.sessionType = 'Pagi',
    this.bookedPatients = const <BookedPatient>[],
    this.scheduleDate,
    this.roomId,
    this.poliklinikId,
    this.serviceId,
    this.capacity = 8,
    this.availableSlots,
    this.bookedPatientCount = 0,
    this.isAvailable = true,
    this.notes,
    this.sessionShift = 'morning',
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    final String sessionShift = json['sessionShift'] as String? ?? 'morning';
    final String sessionLabel = json['sessionLabel'] as String? ??
        (sessionShift == 'afternoon'
            ? 'Siang'
            : sessionShift == 'night'
                ? 'Malam'
                : 'Pagi');
    final String sessionTypeTitle = 'Sesi $sessionLabel';

    final String? startTime = json['startTime'] as String?;
    final String? endTime = json['endTime'] as String?;
    final String timeStr = json['timeRange'] as String? ??
        (startTime != null && endTime != null
            ? '$startTime - $endTime WIB'
            : '08:00 - 12:00 WIB');

    final String scheduleDate = json['scheduleDate'] as String? ??
        json['specificDate'] as String? ??
        '';

    final bool isAvailable = json['isAvailable'] as bool? ??
        (json['rawStatus'] == 'open' || json['status'] == 'Buka');
    final String badge = isAvailable ? 'Buka' : 'Tutup';
    final AmanahBadgeVariant badgeVariant = isAvailable
        ? AmanahBadgeVariant.success
        : AmanahBadgeVariant.warning;

    final int capacity = json['capacity'] as int? ?? 8;
    final int bookedPatientCount = json['bookedPatientCount'] as int? ?? 0;
    final int availableSlots = json['availableSlots'] as int? ?? (capacity - bookedPatientCount);

    final List<dynamic>? bookedPatientsRaw = json['bookedPatients'] as List<dynamic>?;
    final List<BookedPatient> bookedPatients = bookedPatientsRaw != null
        ? bookedPatientsRaw
            .whereType<Map<String, dynamic>>()
            .map(BookedPatient.fromJson)
            .toList()
        : <BookedPatient>[];

    return DoctorSchedule(
      id: json['id'] as String? ?? '',
      title: sessionTypeTitle,
      date: scheduleDate,
      time: timeStr,
      poli: json['poliklinikName'] as String? ?? 'Poliklinik',
      room: json['roomName'] as String? ?? 'Ruang Praktek',
      slotCount: bookedPatientCount.toString(),
      slotText: '$bookedPatientCount Pasien Booking',
      badge: badge,
      badgeVariant: badgeVariant,
      startTime: startTime,
      endTime: endTime,
      sessionType: sessionLabel,
      bookedPatients: bookedPatients,
      scheduleDate: scheduleDate,
      roomId: json['roomId'] as String?,
      poliklinikId: json['poliklinikId'] as String?,
      serviceId: json['serviceId'] as String?,
      capacity: capacity,
      availableSlots: availableSlots,
      bookedPatientCount: bookedPatientCount,
      isAvailable: isAvailable,
      notes: json['notes'] as String?,
      sessionShift: sessionShift,
    );
  }

  final String id;
  final String title;
  final String date;
  final String time;
  final String poli;
  final String room;
  final String slotCount;
  final String slotText;
  final String badge;
  final AmanahBadgeVariant badgeVariant;
  final String? startTime;
  final String? endTime;
  final String sessionType; // 'Pagi', 'Siang', 'Malam', 'Dini Hari'
  final List<BookedPatient> bookedPatients;
  final String? scheduleDate;
  final String? roomId;
  final String? poliklinikId;
  final String? serviceId;
  final int capacity;
  final int? availableSlots;
  final int bookedPatientCount;
  final bool isAvailable;
  final String? notes;
  final String sessionShift;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'scheduleDate': scheduleDate ?? date,
      'session': sessionType.toUpperCase(),
      'sessionLabel': sessionType,
      'sessionShift': sessionShift,
      'startTime': startTime,
      'endTime': endTime,
      'timeRange': time,
      'poliklinikId': poliklinikId,
      'poliklinikName': poli,
      'roomId': roomId,
      'roomName': room,
      'serviceId': serviceId,
      'capacity': capacity,
      'availableSlots': availableSlots,
      'bookedPatientCount': bookedPatientCount,
      'isAvailable': isAvailable,
      'status': badge,
      'notes': notes,
      'bookedPatients': bookedPatients.map((BookedPatient p) => p.toJson()).toList(),
    };
  }

  DoctorSchedule copyWith({
    String? id,
    String? title,
    String? date,
    String? time,
    String? poli,
    String? room,
    String? slotCount,
    String? slotText,
    String? badge,
    AmanahBadgeVariant? badgeVariant,
    String? startTime,
    String? endTime,
    String? sessionType,
    List<BookedPatient>? bookedPatients,
    String? scheduleDate,
    String? roomId,
    String? poliklinikId,
    String? serviceId,
    int? capacity,
    int? availableSlots,
    int? bookedPatientCount,
    bool? isAvailable,
    String? notes,
    String? sessionShift,
  }) {
    return DoctorSchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      poli: poli ?? this.poli,
      room: room ?? this.room,
      slotCount: slotCount ?? this.slotCount,
      slotText: slotText ?? this.slotText,
      badge: badge ?? this.badge,
      badgeVariant: badgeVariant ?? this.badgeVariant,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sessionType: sessionType ?? this.sessionType,
      bookedPatients: bookedPatients ?? this.bookedPatients,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      roomId: roomId ?? this.roomId,
      poliklinikId: poliklinikId ?? this.poliklinikId,
      serviceId: serviceId ?? this.serviceId,
      capacity: capacity ?? this.capacity,
      availableSlots: availableSlots ?? this.availableSlots,
      bookedPatientCount: bookedPatientCount ?? this.bookedPatientCount,
      isAvailable: isAvailable ?? this.isAvailable,
      notes: notes ?? this.notes,
      sessionShift: sessionShift ?? this.sessionShift,
    );
  }
}

class DayScheduleSetting {
  const DayScheduleSetting({
    required this.targetQuota,
    required this.isCuti,
    this.cutiReason,
    this.scheduleDate,
    this.totalBookedPatients = 0,
    this.capacityPercentage = 0,
  });

  factory DayScheduleSetting.fromJson(Map<String, dynamic> json) {
    return DayScheduleSetting(
      targetQuota: json['targetQuota'] as int? ?? 8,
      isCuti: json['isCuti'] as bool? ?? false,
      cutiReason: json['cutiReason'] as String?,
      scheduleDate: json['scheduleDate'] as String?,
      totalBookedPatients: json['totalBookedPatients'] as int? ?? 0,
      capacityPercentage: json['capacityPercentage'] as int? ?? 0,
    );
  }

  final int targetQuota;
  final bool isCuti;
  final String? cutiReason;
  final String? scheduleDate;
  final int totalBookedPatients;
  final int capacityPercentage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'targetQuota': targetQuota,
      'isCuti': isCuti,
      'cutiReason': cutiReason,
      'scheduleDate': scheduleDate,
      'totalBookedPatients': totalBookedPatients,
      'capacityPercentage': capacityPercentage,
    };
  }

  DayScheduleSetting copyWith({
    int? targetQuota,
    bool? isCuti,
    String? cutiReason,
    String? scheduleDate,
    int? totalBookedPatients,
    int? capacityPercentage,
  }) {
    return DayScheduleSetting(
      targetQuota: targetQuota ?? this.targetQuota,
      isCuti: isCuti ?? this.isCuti,
      cutiReason: cutiReason ?? this.cutiReason,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      totalBookedPatients: totalBookedPatients ?? this.totalBookedPatients,
      capacityPercentage: capacityPercentage ?? this.capacityPercentage,
    );
  }
}

class CalendarDaySummary {
  const CalendarDaySummary({
    required this.date,
    required this.hasSchedule,
    required this.isCuti,
    required this.cutiReason,
    required this.sessionCount,
    required this.targetQuota,
    required this.bookedPatientCount,
    required this.capacityPercentage,
  });

  factory CalendarDaySummary.fromJson(Map<String, dynamic> json) {
    return CalendarDaySummary(
      date: json['date'] as String? ?? '',
      hasSchedule: json['hasSchedule'] as bool? ?? false,
      isCuti: json['isCuti'] as bool? ?? false,
      cutiReason: json['cutiReason'] as String?,
      sessionCount: json['sessionCount'] as int? ?? 0,
      targetQuota: json['targetQuota'] as int? ?? 0,
      bookedPatientCount: json['bookedPatientCount'] as int? ?? 0,
      capacityPercentage: json['capacityPercentage'] as int? ?? 0,
    );
  }

  final String date;
  final bool hasSchedule;
  final bool isCuti;
  final String? cutiReason;
  final int sessionCount;
  final int targetQuota;
  final int bookedPatientCount;
  final int capacityPercentage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date,
      'hasSchedule': hasSchedule,
      'isCuti': isCuti,
      'cutiReason': cutiReason,
      'sessionCount': sessionCount,
      'targetQuota': targetQuota,
      'bookedPatientCount': bookedPatientCount,
      'capacityPercentage': capacityPercentage,
    };
  }
}

class CalendarSummaryResponse {
  const CalendarSummaryResponse({
    required this.month,
    required this.days,
  });

  factory CalendarSummaryResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawDays = json['days'] as List<dynamic>?;
    final List<CalendarDaySummary> parsedDays = rawDays != null
        ? rawDays
            .whereType<Map<String, dynamic>>()
            .map(CalendarDaySummary.fromJson)
            .toList()
        : <CalendarDaySummary>[];

    return CalendarSummaryResponse(
      month: json['month'] as String? ?? '',
      days: parsedDays,
    );
  }

  final String month;
  final List<CalendarDaySummary> days;
}

class ClinicRoomReference {
  const ClinicRoomReference({
    required this.id,
    required this.code,
    required this.name,
    this.location,
    this.floor,
    this.isOccupied = false,
    this.occupiedBy,
  });

  factory ClinicRoomReference.fromJson(Map<String, dynamic> json) {
    return ClinicRoomReference(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String?,
      floor: json['floor'] as String?,
      isOccupied: json['isOccupied'] as bool? ?? false,
      occupiedBy: json['occupiedBy'] as String?,
    );
  }

  final String id;
  final String code;
  final String name;
  final String? location;
  final String? floor;
  final bool isOccupied;
  final String? occupiedBy;
}

class ClinicPoliklinikReference {
  const ClinicPoliklinikReference({
    required this.id,
    required this.code,
    required this.name,
    this.location,
  });

  factory ClinicPoliklinikReference.fromJson(Map<String, dynamic> json) {
    return ClinicPoliklinikReference(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String?,
    );
  }

  final String id;
  final String code;
  final String name;
  final String? location;
}

class ClinicShiftReference {
  const ClinicShiftReference({
    required this.id,
    required this.label,
    required this.shift,
    required this.startTime,
    required this.endTime,
  });

  factory ClinicShiftReference.fromJson(Map<String, dynamic> json) {
    return ClinicShiftReference(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      shift: json['shift'] as String? ?? 'morning',
      startTime: json['startTime'] as String? ?? '08:00',
      endTime: json['endTime'] as String? ?? '12:00',
    );
  }

  final String id;
  final String label;
  final String shift;
  final String startTime;
  final String endTime;
}

class ClinicStatusReference {
  const ClinicStatusReference({
    required this.id,
    required this.label,
  });

  factory ClinicStatusReference.fromJson(Map<String, dynamic> json) {
    return ClinicStatusReference(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  final String id;
  final String label;
}

class ClinicScheduleOptionsReference {
  const ClinicScheduleOptionsReference({
    required this.shifts,
    required this.statuses,
    required this.timeIntervals,
  });

  factory ClinicScheduleOptionsReference.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawShifts = json['shifts'] as List<dynamic>?;
    final List<ClinicShiftReference> shifts = rawShifts != null
        ? rawShifts
            .whereType<Map<String, dynamic>>()
            .map(ClinicShiftReference.fromJson)
            .toList()
        : const <ClinicShiftReference>[];

    final List<dynamic>? rawStatuses = json['statuses'] as List<dynamic>?;
    final List<ClinicStatusReference> statuses = rawStatuses != null
        ? rawStatuses
            .whereType<Map<String, dynamic>>()
            .map(ClinicStatusReference.fromJson)
            .toList()
        : const <ClinicStatusReference>[];

    final List<dynamic>? rawIntervals = json['timeSlotIntervals'] as List<dynamic>?;
    final List<int> intervals = rawIntervals != null
        ? rawIntervals.whereType<num>().map((num n) => n.toInt()).toList()
        : const <int>[15, 30, 45, 60];

    return ClinicScheduleOptionsReference(
      shifts: shifts,
      statuses: statuses,
      timeIntervals: intervals,
    );
  }

  final List<ClinicShiftReference> shifts;
  final List<ClinicStatusReference> statuses;
  final List<int> timeIntervals;
}

