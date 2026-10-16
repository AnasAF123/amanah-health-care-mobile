class CalendarDaySummaryDto {
  const CalendarDaySummaryDto({
    required this.date,
    required this.hasSchedule,
    required this.isOnLeave,
    this.leaveReason,
    this.sessionCount = 0,
    this.bookedPatientCount = 0,
    this.isClosed = false,
    this.notes,
  });

  factory CalendarDaySummaryDto.fromJson(Map<String, dynamic> json) {
    return CalendarDaySummaryDto(
      date: json['date'] as String? ?? '',
      hasSchedule: json['hasSchedule'] as bool? ?? false,
      isOnLeave: json['isOnLeave'] as bool? ?? false,
      leaveReason: json['leaveReason'] as String?,
      sessionCount: json['sessionCount'] as int? ?? 0,
      bookedPatientCount: json['bookedPatientCount'] as int? ?? 0,
      isClosed: json['isClosed'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  final String date;
  final bool hasSchedule;
  final bool isOnLeave;
  final String? leaveReason;
  final int sessionCount;
  final int bookedPatientCount;
  final bool isClosed;
  final String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date,
      'hasSchedule': hasSchedule,
      'isOnLeave': isOnLeave,
      'leaveReason': leaveReason,
      'sessionCount': sessionCount,
      'bookedPatientCount': bookedPatientCount,
      'isClosed': isClosed,
      'notes': notes,
    };
  }
}

class CalendarSummaryResponseDto {
  const CalendarSummaryResponseDto({
    required this.month,
    required this.days,
  });

  factory CalendarSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawDays = json['days'] as List<dynamic>?;
    return CalendarSummaryResponseDto(
      month: json['month'] as String? ?? '',
      days: rawDays != null
          ? rawDays
              .whereType<Map<String, dynamic>>()
              .map(CalendarDaySummaryDto.fromJson)
              .toList()
          : const <CalendarDaySummaryDto>[],
    );
  }

  final String month;
  final List<CalendarDaySummaryDto> days;
}
