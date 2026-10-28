import 'package:amanah_healthcare/features/schedule/domain/helpers/clinical_session_resolver.dart';

class DoctorRosterSessionDto {
  const DoctorRosterSessionDto({
    required this.sessionId,
    required this.sessionCode,
    required this.sessionLabel,
    required this.timeRange,
    required this.isActive,
    this.isTemplateActive,
    this.preferredRoomId,
    this.preferredRoomName,
  });

  factory DoctorRosterSessionDto.fromJson(Map<String, dynamic> json) {
    final String sessionCode = json['sessionCode'] as String? ?? '';
    final String resolvedLabel = ClinicalSessionResolver.resolveSessionName(
      sessionShift: sessionCode,
    );

    return DoctorRosterSessionDto(
      sessionId: json['sessionId'] as String? ?? '',
      sessionCode: sessionCode,
      sessionLabel: resolvedLabel,
      timeRange: json['timeRange'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      isTemplateActive: json['isTemplateActive'] as bool?,
      preferredRoomId: json['preferredRoomId'] as String?,
      preferredRoomName: json['preferredRoomName'] as String?,
    );
  }

  final String sessionId;
  final String sessionCode;
  final String sessionLabel;
  final String timeRange;
  final bool isActive;
  final bool? isTemplateActive;
  final String? preferredRoomId;
  final String? preferredRoomName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'sessionCode': sessionCode,
      'timeRange': timeRange,
      'isActive': isActive,
      if (isTemplateActive != null) 'isTemplateActive': isTemplateActive,
      'preferredRoomId': preferredRoomId,
      'preferredRoomName': preferredRoomName,
    };
  }
}

class DoctorRosterDayDto {
  const DoctorRosterDayDto({
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

  factory DoctorRosterDayDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawSessions = json['sessions'] as List<dynamic>?;
    return DoctorRosterDayDto(
      dow: json['dow'] as int? ?? 0,
      dayCode: json['dayCode'] as String? ?? '',
      dayName: json['dayName'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
      isWeekend: json['isWeekend'] as bool? ?? false,
      isOperatingDay: json['isOperatingDay'] as bool? ?? true,
      isDoctorActive: json['isDoctorActive'] as bool? ?? false,
      hasOverride: json['hasOverride'] as bool? ?? false,
      sessions: rawSessions != null
          ? rawSessions
                .whereType<Map<String, dynamic>>()
                .map(DoctorRosterSessionDto.fromJson)
                .toList()
          : const <DoctorRosterSessionDto>[],
    );
  }

  final int dow;
  final String dayCode;
  final String dayName;
  final int sortOrder;
  final bool isWeekend;
  final bool isOperatingDay;
  final bool isDoctorActive;
  final bool hasOverride;
  final List<DoctorRosterSessionDto> sessions;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dow': dow,
      'dayCode': dayCode,
      'dayName': dayName,
      'sortOrder': sortOrder,
      'isWeekend': isWeekend,
      'isOperatingDay': isOperatingDay,
      'isDoctorActive': isDoctorActive,
      'hasOverride': hasOverride,
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };
  }
}

class DoctorRosterOverviewDto {
  const DoctorRosterOverviewDto({
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.hasAnyOverride,
    required this.days,
  });

  factory DoctorRosterOverviewDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? doctorMap = json['doctor'] as Map<String, dynamic>?;
    final List<dynamic>? rawDays = json['days'] as List<dynamic>?;
    return DoctorRosterOverviewDto(
      doctorId: (doctorMap?['id'] as String?) ?? (json['doctorId'] as String? ?? ''),
      doctorName: (doctorMap?['fullName'] as String?) ?? (json['doctorName'] as String? ?? ''),
      specialization:
          (doctorMap?['specialization'] as String?) ?? (json['specialization'] as String? ?? ''),
      hasAnyOverride: json['hasAnyOverride'] as bool? ?? false,
      days: rawDays != null
          ? rawDays.whereType<Map<String, dynamic>>().map(DoctorRosterDayDto.fromJson).toList()
          : const <DoctorRosterDayDto>[],
    );
  }

  final String doctorId;
  final String doctorName;
  final String specialization;
  final bool hasAnyOverride;
  final List<DoctorRosterDayDto> days;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialization': specialization,
      'hasAnyOverride': hasAnyOverride,
      'days': days.map((d) => d.toJson()).toList(),
    };
  }
}
