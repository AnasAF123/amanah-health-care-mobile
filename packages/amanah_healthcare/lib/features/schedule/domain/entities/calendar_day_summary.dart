class CalendarDaySummary {
  const CalendarDaySummary({
    required this.date,
    required this.hasSchedule,
    required this.isOnLeave,
    this.leaveReason,
    this.sessionCount = 0,
    this.bookedPatientCount = 0,
    this.isClosed = false,
    this.notes,
  });

  final String date;
  final bool hasSchedule;
  final bool isOnLeave;
  final String? leaveReason;
  final int sessionCount;
  final int bookedPatientCount;
  final bool isClosed;
  final String? notes;

  CalendarDaySummary copyWith({
    String? date,
    bool? hasSchedule,
    bool? isOnLeave,
    String? leaveReason,
    int? sessionCount,
    int? bookedPatientCount,
    bool? isClosed,
    String? notes,
  }) {
    return CalendarDaySummary(
      date: date ?? this.date,
      hasSchedule: hasSchedule ?? this.hasSchedule,
      isOnLeave: isOnLeave ?? this.isOnLeave,
      leaveReason: leaveReason ?? this.leaveReason,
      sessionCount: sessionCount ?? this.sessionCount,
      bookedPatientCount: bookedPatientCount ?? this.bookedPatientCount,
      isClosed: isClosed ?? this.isClosed,
      notes: notes ?? this.notes,
    );
  }
}
