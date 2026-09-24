enum AmanahBadgeVariant { success, primary, warning, live, trend }

/// Domain exception for schedule operations.
class AmanahScheduleException implements Exception {
  const AmanahScheduleException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Conflict exception thrown on HTTP 409/422 Conflict and Unprocessable responses.
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
  static const String startOutsideBoundary = 'START_OUTSIDE_BOUNDARY';
  static const String invalidStartPrecision = 'INVALID_START_PRECISION';
  static const String durationLeavesNoCapacity = 'DURATION_LEAVES_NO_CAPACITY';
  static const String dateClosed = 'DATE_CLOSED';
  static const String scheduleModifiedConcurrently = 'SCHEDULE_MODIFIED_CONCURRENTLY';

  bool get hasActiveBookings => code == scheduleHasActiveBookings;
  bool get isRoomOccupied => code == roomAlreadyOccupied;
  bool get isPractitionerConflict => code == practitionerAlreadyScheduled;
  bool get isInvalidTimeRange => code == invalidTimeRange;
  bool get isStartOutsideBoundary => code == startOutsideBoundary;
  bool get isInvalidStartPrecision => code == invalidStartPrecision;
  bool get isDurationLeavesNoCapacity => code == durationLeavesNoCapacity;
  bool get isDateClosed => code == dateClosed;
  bool get isConcurrentModification => code == scheduleModifiedConcurrently;

  /// Returns user-facing Indonesian message based on canonical domain error codes.
  static String userMessageForCode(String code, {String? defaultMessage}) {
    switch (code) {
      case startOutsideBoundary:
        return 'Jam mulai berada di luar batas waktu shift yang dipilih.';
      case invalidStartPrecision:
        return 'Jam mulai tidak sesuai presisi menit yang diizinkan.';
      case durationLeavesNoCapacity:
        return 'Waktu mulai terlalu dekat dengan akhir shift sehingga tidak ada kuota konsultasi.';
      case dateClosed:
        return 'Tidak dapat membuat jadwal karena Anda tercatat sedang cuti pada tanggal ini.';
      case practitionerAlreadyScheduled:
        return 'Anda sudah memiliki jadwal lain yang bertabrakan pada rentang waktu ini.';
      case roomAlreadyOccupied:
        return 'Ruangan tersebut sudah digunakan oleh dokter lain pada jam ini.';
      case scheduleHasActiveBookings:
        return 'Jadwal tidak dapat dihapus atau diubah karena sudah ada pasien terdaftar. Silakan batalkan atau pindahkan pasien terlebih dahulu.';
      case scheduleModifiedConcurrently:
        return 'Jadwal telah diubah oleh pengguna lain. Silakan muat ulang halaman.';
      default:
        return defaultMessage ?? 'Terjadi kendala penjadwalan pada sistem.';
    }
  }
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
    this.version,
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

    final String? version = json['version'] as String?;
    final String rawStatus = (json['rawStatus'] as String? ?? json['status'] as String? ?? '').toLowerCase();
    final bool isAvailable = json['isAvailable'] as bool? ??
        (rawStatus != 'closed' && rawStatus != 'tutup');
    
    final int bookedPatientCount = json['bookedPatientCount'] as int? ??
        (json['bookedPatients'] as List<dynamic>?)?.length ??
        0;

    // Canonical status: OPEN ('Buka'), OCCUPIED ('Terisi'), CLOSED ('Tutup')
    final String badge;
    final AmanahBadgeVariant badgeVariant;
    if (!isAvailable || rawStatus == 'closed' || rawStatus == 'tutup') {
      badge = 'Tutup';
      badgeVariant = AmanahBadgeVariant.warning;
    } else if (bookedPatientCount > 0 || rawStatus == 'occupied' || rawStatus == 'terisi') {
      badge = 'Terisi';
      badgeVariant = AmanahBadgeVariant.primary;
    } else {
      badge = 'Buka';
      badgeVariant = AmanahBadgeVariant.success;
    }

    final int capacity = json['capacity'] as int? ?? 8;
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
      version: version,
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
  final String? version;

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
      'version': version,
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
    String? version,
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
      version: version ?? this.version,
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
    this.status = 'Buka',
    this.isClosed = false,
    this.notes,
  });

  factory DayScheduleSetting.fromJson(Map<String, dynamic> json) {
    final String status = json['status'] as String? ?? 'Buka';
    final bool isClosed = json['isClosed'] as bool? ?? (status == 'Tutup');
    return DayScheduleSetting(
      targetQuota: json['targetQuota'] as int? ?? 8,
      isCuti: json['isCuti'] as bool? ?? false,
      cutiReason: json['cutiReason'] as String?,
      scheduleDate: json['scheduleDate'] as String?,
      totalBookedPatients: json['totalBookedPatients'] as int? ?? 0,
      capacityPercentage: json['capacityPercentage'] as int? ?? 0,
      status: status,
      isClosed: isClosed,
      notes: json['notes'] as String?,
    );
  }

  final int targetQuota;
  final bool isCuti;
  final String? cutiReason;
  final String? scheduleDate;
  final int totalBookedPatients;
  final int capacityPercentage;
  final String status;
  final bool isClosed;
  final String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'targetQuota': targetQuota,
      'isCuti': isCuti,
      'cutiReason': cutiReason,
      'scheduleDate': scheduleDate,
      'totalBookedPatients': totalBookedPatients,
      'capacityPercentage': capacityPercentage,
      'status': status,
      'isClosed': isClosed,
      if (notes != null) 'notes': notes,
    };
  }

  DayScheduleSetting copyWith({
    int? targetQuota,
    bool? isCuti,
    String? cutiReason,
    String? scheduleDate,
    int? totalBookedPatients,
    int? capacityPercentage,
    String? status,
    bool? isClosed,
    String? notes,
  }) {
    return DayScheduleSetting(
      targetQuota: targetQuota ?? this.targetQuota,
      isCuti: isCuti ?? this.isCuti,
      cutiReason: cutiReason ?? this.cutiReason,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      totalBookedPatients: totalBookedPatients ?? this.totalBookedPatients,
      capacityPercentage: capacityPercentage ?? this.capacityPercentage,
      status: status ?? this.status,
      isClosed: isClosed ?? this.isClosed,
      notes: notes ?? this.notes,
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
    this.status = 'Buka',
    this.isClosed = false,
    this.notes,
  });

  factory CalendarDaySummary.fromJson(Map<String, dynamic> json) {
    final String status = json['status'] as String? ?? 'Buka';
    final bool isClosed = json['isClosed'] as bool? ?? (status == 'Tutup');
    return CalendarDaySummary(
      date: json['date'] as String? ?? '',
      hasSchedule: json['hasSchedule'] as bool? ?? false,
      isCuti: json['isCuti'] as bool? ?? false,
      cutiReason: json['cutiReason'] as String?,
      sessionCount: json['sessionCount'] as int? ?? 0,
      targetQuota: json['targetQuota'] as int? ?? 0,
      bookedPatientCount: json['bookedPatientCount'] as int? ?? 0,
      capacityPercentage: json['capacityPercentage'] as int? ?? 0,
      status: status,
      isClosed: isClosed,
      notes: json['notes'] as String?,
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
  final String status;
  final bool isClosed;
  final String? notes;

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
      'status': status,
      'isClosed': isClosed,
      if (notes != null) 'notes': notes,
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

class ScheduleContext {
  final String contextId;
  final String contextLabel;
  final String sessionShift;
  final String date;
  final String boundaryStartTime;
  final String boundaryEndTime;
  final int effectiveConsultationDurationMinutes;
  final int allowedStartPrecisionMinutes;
  final bool durationEditableByCurrentUser;

  const ScheduleContext({
    required this.contextId,
    required this.contextLabel,
    required this.sessionShift,
    required this.date,
    required this.boundaryStartTime,
    required this.boundaryEndTime,
    required this.effectiveConsultationDurationMinutes,
    required this.allowedStartPrecisionMinutes,
    required this.durationEditableByCurrentUser,
  });

  factory ScheduleContext.fromJson(Map<String, dynamic> json) {
    return ScheduleContext(
      contextId: json['contextId'] as String? ?? json['id'] as String? ?? '',
      contextLabel: json['contextLabel'] as String? ?? json['label'] as String? ?? '',
      sessionShift: json['sessionShift'] as String? ?? json['shift'] as String? ?? 'morning',
      date: json['date'] as String? ?? '',
      boundaryStartTime: json['boundaryStartTime'] as String? ?? json['startTime'] as String? ?? '06:00',
      boundaryEndTime: json['boundaryEndTime'] as String? ?? json['endTime'] as String? ?? '12:00',
      effectiveConsultationDurationMinutes:
          json['effectiveConsultationDurationMinutes'] as int? ?? 30,
      allowedStartPrecisionMinutes:
          json['allowedStartPrecisionMinutes'] as int? ?? 1,
      durationEditableByCurrentUser:
          json['durationEditableByCurrentUser'] as bool? ?? false,
    );
  }
}

enum ScheduleIntervalStatus {
  open('OPEN', 'Buka'),
  occupied('OCCUPIED', 'Terisi'),
  closed('CLOSED', 'Tutup');

  final String code;
  final String label;
  const ScheduleIntervalStatus(this.code, this.label);

  static ScheduleIntervalStatus fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'OCCUPIED':
      case 'TERISI':
        return ScheduleIntervalStatus.occupied;
      case 'CLOSED':
      case 'TUTUP':
        return ScheduleIntervalStatus.closed;
      case 'OPEN':
      case 'BUKA':
      default:
        return ScheduleIntervalStatus.open;
    }
  }
}

class AppointmentRef {
  final String appointmentId;
  final String? queueNumber;
  final String status;

  const AppointmentRef({
    required this.appointmentId,
    this.queueNumber,
    required this.status,
  });

  factory AppointmentRef.fromJson(Map<String, dynamic> json) {
    return AppointmentRef(
      appointmentId: json['appointmentId'] as String? ?? '',
      queueNumber: json['queueNumber'] as String?,
      status: json['status'] as String? ?? 'booked',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'appointmentId': appointmentId,
    if (queueNumber != null) 'queueNumber': queueNumber,
    'status': status,
  };
}

class ScheduleInterval {
  final int intervalIndex;
  final String startTime;
  final String endTime;
  final ScheduleIntervalStatus status;
  final String displayLabel;
  final bool isOccupied;
  final AppointmentRef? appointmentRef;
  final String? closedReason;

  const ScheduleInterval({
    required this.intervalIndex,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.displayLabel,
    required this.isOccupied,
    this.appointmentRef,
    this.closedReason,
  });

  factory ScheduleInterval.fromJson(Map<String, dynamic> json) {
    return ScheduleInterval(
      intervalIndex: json['intervalIndex'] as int? ?? 0,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: ScheduleIntervalStatus.fromCode(json['status'] as String? ?? 'OPEN'),
      displayLabel: json['displayLabel'] as String? ?? 'Buka',
      isOccupied: json['isOccupied'] as bool? ?? false,
      appointmentRef: json['appointmentRef'] != null
          ? AppointmentRef.fromJson(json['appointmentRef'] as Map<String, dynamic>)
          : null,
      closedReason: json['closedReason'] as String?,
    );
  }
}

class ScheduleProjection {
  final String? scheduleId;
  final String date;
  final String scheduleContextId;
  final String contextLabel;
  final String selectedStartTime;
  final String projectedEndTime;
  final int effectiveConsultationDurationMinutes;
  final int capacity;
  final List<ScheduleInterval> intervals;
  final String? version;

  const ScheduleProjection({
    this.scheduleId,
    required this.date,
    required this.scheduleContextId,
    required this.contextLabel,
    required this.selectedStartTime,
    required this.projectedEndTime,
    required this.effectiveConsultationDurationMinutes,
    required this.capacity,
    required this.intervals,
    this.version,
  });

  factory ScheduleProjection.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawIntervals = json['intervals'] as List<dynamic>?;
    final List<ScheduleInterval> parsedIntervals = rawIntervals != null
        ? rawIntervals
            .whereType<Map<String, dynamic>>()
            .map(ScheduleInterval.fromJson)
            .toList()
        : <ScheduleInterval>[];

    return ScheduleProjection(
      scheduleId: json['scheduleId'] as String?,
      date: json['date'] as String? ?? '',
      scheduleContextId: json['scheduleContextId'] as String? ?? '',
      contextLabel: json['contextLabel'] as String? ?? '',
      selectedStartTime: json['selectedStartTime'] as String? ?? '',
      projectedEndTime: json['projectedEndTime'] as String? ?? '',
      effectiveConsultationDurationMinutes:
          json['effectiveConsultationDurationMinutes'] as int? ?? 30,
      capacity: json['capacity'] as int? ?? parsedIntervals.length,
      intervals: parsedIntervals,
      version: json['version'] as String?,
    );
  }
}

class ScheduleSlotConflictInfo {
  final String type;
  final String message;
  final String? sessionId;
  final String? practitionerId;
  final String? practitionerName;
  final String? roomId;
  final String? roomName;

  const ScheduleSlotConflictInfo({
    required this.type,
    required this.message,
    this.sessionId,
    this.practitionerId,
    this.practitionerName,
    this.roomId,
    this.roomName,
  });

  factory ScheduleSlotConflictInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotConflictInfo(
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      sessionId: json['sessionId'] as String?,
      practitionerId: json['practitionerId'] as String?,
      practitionerName: json['practitionerName'] as String?,
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'message': message,
    if (sessionId != null) 'sessionId': sessionId,
    if (practitionerId != null) 'practitionerId': practitionerId,
    if (practitionerName != null) 'practitionerName': practitionerName,
    if (roomId != null) 'roomId': roomId,
    if (roomName != null) 'roomName': roomName,
  };
}

class ScheduleShiftSlot {
  final int slotIndex;
  final String startTime;
  final String endTime;
  final String timeRange;
  final bool isAvailable;
  final String status;
  final String displayLabel;
  final ScheduleSlotConflictInfo? conflictInfo;

  const ScheduleShiftSlot({
    required this.slotIndex,
    required this.startTime,
    required this.endTime,
    required this.timeRange,
    required this.isAvailable,
    required this.status,
    required this.displayLabel,
    this.conflictInfo,
  });

  factory ScheduleShiftSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleShiftSlot(
      slotIndex: json['slotIndex'] as int? ?? 0,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      timeRange: json['timeRange'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      status: json['status'] as String? ?? 'AVAILABLE',
      displayLabel: json['displayLabel'] as String? ?? 'Tersedia',
      conflictInfo: json['conflictInfo'] != null
          ? ScheduleSlotConflictInfo.fromJson(json['conflictInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'slotIndex': slotIndex,
    'startTime': startTime,
    'endTime': endTime,
    'timeRange': timeRange,
    'isAvailable': isAvailable,
    'status': status,
    'displayLabel': displayLabel,
    if (conflictInfo != null) 'conflictInfo': conflictInfo!.toJson(),
  };
}

class ScheduleShiftOccupancy {
  final String shift;
  final String shiftLabel;
  final String timeRange;
  final String boundaryStartTime;
  final String boundaryEndTime;
  final int slotDurationMinutes;
  final int totalSlots;
  final int availableSlotsCount;
  final int occupiedSlotsCount;
  final List<ScheduleShiftSlot> slots;

  const ScheduleShiftOccupancy({
    required this.shift,
    required this.shiftLabel,
    required this.timeRange,
    required this.boundaryStartTime,
    required this.boundaryEndTime,
    required this.slotDurationMinutes,
    required this.totalSlots,
    required this.availableSlotsCount,
    required this.occupiedSlotsCount,
    required this.slots,
  });

  factory ScheduleShiftOccupancy.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawSlots = json['slots'] as List<dynamic>?;
    final List<ScheduleShiftSlot> parsedSlots = rawSlots != null
        ? rawSlots
            .whereType<Map<String, dynamic>>()
            .map(ScheduleShiftSlot.fromJson)
            .toList()
        : <ScheduleShiftSlot>[];

    final String shiftCode = json['sessionShift'] as String? ??
        json['contextId'] as String? ??
        json['shift'] as String? ??
        '';
    final String label = json['contextLabel'] as String? ??
        json['shiftLabel'] as String? ??
        json['label'] as String? ??
        '';
    final String boundaryStart = json['boundaryStartTime'] as String? ?? '00:00';
    final String boundaryEnd = json['boundaryEndTime'] as String? ?? '23:59';
    final String timeRange = json['timeRange'] as String? ??
        '$boundaryStart - $boundaryEnd WIB';

    return ScheduleShiftOccupancy(
      shift: shiftCode,
      shiftLabel: label,
      timeRange: timeRange,
      boundaryStartTime: boundaryStart,
      boundaryEndTime: boundaryEnd,
      slotDurationMinutes: json['slotDurationMinutes'] as int? ?? 30,
      totalSlots: json['totalSlots'] as int? ?? parsedSlots.length,
      availableSlotsCount: json['availableSlotsCount'] as int? ??
          parsedSlots.where((ScheduleShiftSlot s) => s.isAvailable).length,
      occupiedSlotsCount: json['occupiedSlotsCount'] as int? ??
          parsedSlots.where((ScheduleShiftSlot s) => !s.isAvailable).length,
      slots: parsedSlots,
    );
  }
}

class ScheduleOccupancySummary {
  final int totalShifts;
  final int totalSlots;
  final int availableSlots;
  final int occupiedSlots;

  const ScheduleOccupancySummary({
    required this.totalShifts,
    required this.totalSlots,
    required this.availableSlots,
    required this.occupiedSlots,
  });

  factory ScheduleOccupancySummary.fromJson(Map<String, dynamic> json) {
    return ScheduleOccupancySummary(
      totalShifts: json['totalShifts'] as int? ?? 0,
      totalSlots: json['totalSlots'] as int? ?? 0,
      availableSlots: json['availableSlots'] as int? ?? 0,
      occupiedSlots:
          json['occupiedSlotsCount'] as int? ?? json['occupiedSlots'] as int? ?? 0,
    );
  }
}

class ScheduleOccupancyOverviewData {
  final String date;
  final String? roomId;
  final ScheduleOccupancySummary summary;
  final List<ScheduleShiftOccupancy> shifts;

  const ScheduleOccupancyOverviewData({
    required this.date,
    this.roomId,
    required this.summary,
    required this.shifts,
  });

  factory ScheduleOccupancyOverviewData.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawShifts = json['shifts'] as List<dynamic>?;
    final List<ScheduleShiftOccupancy> parsedShifts = rawShifts != null
        ? rawShifts
            .whereType<Map<String, dynamic>>()
            .map(ScheduleShiftOccupancy.fromJson)
            .toList()
        : <ScheduleShiftOccupancy>[];

    return ScheduleOccupancyOverviewData(
      date: json['date'] as String? ?? '',
      roomId: json['roomId'] as String?,
      summary: json['summary'] is Map<String, dynamic>
          ? ScheduleOccupancySummary.fromJson(json['summary'] as Map<String, dynamic>)
          : ScheduleOccupancySummary(
              totalShifts: parsedShifts.length,
              totalSlots: parsedShifts.fold(
                0,
                (int acc, ScheduleShiftOccupancy s) => acc + s.totalSlots,
              ),
              availableSlots: parsedShifts.fold(
                0,
                (int acc, ScheduleShiftOccupancy s) => acc + s.availableSlotsCount,
              ),
              occupiedSlots: parsedShifts.fold(
                0,
                (int acc, ScheduleShiftOccupancy s) => acc + s.occupiedSlotsCount,
              ),
            ),
      shifts: parsedShifts,
    );
  }
}

