class DoctorRosterSession {
  const DoctorRosterSession({
    required this.sessionId,
    required this.sessionCode,
    required this.sessionLabel,
    required this.timeRange,
    required this.isActive,
    this.isTemplateActive,
    this.preferredRoomId,
    this.preferredRoomName,
  });

  final String sessionId;
  final String sessionCode;
  final String sessionLabel;
  final String timeRange;
  final bool isActive;
  final bool? isTemplateActive;
  final String? preferredRoomId;
  final String? preferredRoomName;

  DoctorRosterSession copyWith({
    String? sessionId,
    String? sessionCode,
    String? sessionLabel,
    String? timeRange,
    bool? isActive,
    bool? isTemplateActive,
    String? preferredRoomId,
    String? preferredRoomName,
  }) {
    return DoctorRosterSession(
      sessionId: sessionId ?? this.sessionId,
      sessionCode: sessionCode ?? this.sessionCode,
      sessionLabel: sessionLabel ?? this.sessionLabel,
      timeRange: timeRange ?? this.timeRange,
      isActive: isActive ?? this.isActive,
      isTemplateActive: isTemplateActive ?? this.isTemplateActive,
      preferredRoomId: preferredRoomId ?? this.preferredRoomId,
      preferredRoomName: preferredRoomName ?? this.preferredRoomName,
    );
  }
}

class DoctorRosterDay {
  const DoctorRosterDay({
    required this.dow,
    required this.dayCode,
    required this.dayName,
    required this.sortOrder,
    required this.isWeekend,
    required this.isOperatingDay,
    required this.isDoctorActive,
    required this.hasOverride,
    required this.sessions,
  });

  final int dow;
  final String dayCode;
  final String dayName;
  final int sortOrder;
  final bool isWeekend;
  final bool isOperatingDay;
  final bool isDoctorActive;
  final bool hasOverride;
  final List<DoctorRosterSession> sessions;

  DoctorRosterDay copyWith({
    int? dow,
    String? dayCode,
    String? dayName,
    int? sortOrder,
    bool? isWeekend,
    bool? isOperatingDay,
    bool? isDoctorActive,
    bool? hasOverride,
    List<DoctorRosterSession>? sessions,
  }) {
    return DoctorRosterDay(
      dow: dow ?? this.dow,
      dayCode: dayCode ?? this.dayCode,
      dayName: dayName ?? this.dayName,
      sortOrder: sortOrder ?? this.sortOrder,
      isWeekend: isWeekend ?? this.isWeekend,
      isOperatingDay: isOperatingDay ?? this.isOperatingDay,
      isDoctorActive: isDoctorActive ?? this.isDoctorActive,
      hasOverride: hasOverride ?? this.hasOverride,
      sessions: sessions ?? this.sessions,
    );
  }
}

class DoctorRoster {
  const DoctorRoster({
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.hasAnyOverride,
    required this.days,
  });

  final String doctorId;
  final String doctorName;
  final String specialization;
  final bool hasAnyOverride;
  final List<DoctorRosterDay> days;

  DoctorRoster copyWith({
    String? doctorId,
    String? doctorName,
    String? specialization,
    bool? hasAnyOverride,
    List<DoctorRosterDay>? days,
  }) {
    return DoctorRoster(
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      specialization: specialization ?? this.specialization,
      hasAnyOverride: hasAnyOverride ?? this.hasAnyOverride,
      days: days ?? this.days,
    );
  }
}
