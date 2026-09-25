import 'package:amanah_healthcare/features/schedule/domain/schedule_shift_constants.dart';

class DayScheduleSetting {
  const DayScheduleSetting({
    required this.targetQuota,
    required this.isCuti,
    this.cutiReason,
    this.scheduleDate,
    this.totalBookedPatients = 0,
    this.capacityPercentage = 0,
    this.status = ScheduleCanonicalStatus.open,
    this.isClosed = false,
    this.notes,
  });

  factory DayScheduleSetting.fromJson(Map<String, dynamic> json) {
    final String rawStatus = (json['status'] as String? ??
            json['status_jadwal'] as String? ??
            json['status_dokter'] as String? ??
            ScheduleCanonicalStatus.open)
        .toUpperCase();
    final bool? isClosedRaw =
        json['isClosed'] as bool? ?? json['is_closed'] as bool?;
    final bool isClosed = isClosedRaw ?? (rawStatus == ScheduleCanonicalStatus.closed || rawStatus == ScheduleCanonicalStatus.tutup);
    final String status = isClosed
        ? ScheduleCanonicalStatus.closed
        : (rawStatus == ScheduleCanonicalStatus.occupied || rawStatus == ScheduleCanonicalStatus.terisi
            ? ScheduleCanonicalStatus.occupied
            : ScheduleCanonicalStatus.open);
    return DayScheduleSetting(
      targetQuota: json['targetQuota'] as int? ?? 0,
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

  String get displayStatus => isClosed
      ? ScheduleFormConstants.statusTutup
      : (status == ScheduleCanonicalStatus.occupied ? ScheduleFormConstants.badgeTerisi : ScheduleFormConstants.statusBuka);
  bool get isDayClosed =>
      isClosed || status.toUpperCase() == ScheduleCanonicalStatus.closed || status == ScheduleFormConstants.statusTutup;

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
    this.status = ScheduleCanonicalStatus.open,
    this.isClosed = false,
    this.notes,
  });

  factory CalendarDaySummary.fromJson(Map<String, dynamic> json) {
    final String rawStatus = (json['status'] as String? ??
            json['status_jadwal'] as String? ??
            ScheduleCanonicalStatus.open)
        .toUpperCase();
    final bool? isClosedRaw =
        json['isClosed'] as bool? ?? json['is_closed'] as bool?;
    final bool isClosed = isClosedRaw ?? (rawStatus == ScheduleCanonicalStatus.closed || rawStatus == ScheduleCanonicalStatus.tutup);
    final String status = isClosed
        ? ScheduleCanonicalStatus.closed
        : (rawStatus == ScheduleCanonicalStatus.occupied || rawStatus == ScheduleCanonicalStatus.terisi
            ? ScheduleCanonicalStatus.occupied
            : ScheduleCanonicalStatus.open);
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

  String get displayStatus => isClosed
      ? ScheduleFormConstants.statusTutup
      : (status == ScheduleCanonicalStatus.occupied ? ScheduleFormConstants.badgeTerisi : ScheduleFormConstants.statusBuka);
  bool get isDayClosed =>
      isClosed || status.toUpperCase() == ScheduleCanonicalStatus.closed || status == ScheduleFormConstants.statusTutup;

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
