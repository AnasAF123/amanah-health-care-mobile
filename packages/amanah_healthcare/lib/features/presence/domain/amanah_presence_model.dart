import 'package:amanah_healthcare/core/time/functions/format_localized_date.dart';
import 'package:amanah_healthcare/core/time/functions/format_localized_time.dart';

enum AttendanceStatus { hadir, telat, missed, cuti }

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.date,
    required this.dayNumber,
    required this.time,
    required this.title,
    this.location = '',
    required this.status,
    this.isLatest = false,
    this.reason,
    this.lateDuration,
    this.attendanceDate,
    this.checkInAt,
    this.checkOutAt,
    this.validatedDurationHours,
    this.notes,
  });

  final String id;
  final String date;
  final int dayNumber;
  final String time;
  final String title;
  final String location;
  final AttendanceStatus status;
  final bool isLatest;
  final String? reason;
  final String? lateDuration;
  final DateTime? attendanceDate;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final double? validatedDurationHours;
  final String? notes;

  String get dayName {
    final DateTime? dt = attendanceDate ?? checkInAt;
    if (dt == null) return '';
    return formatLocalizedDate(dt, style: 'day_name');
  }

  String? get checkInTimeFormatted {
    if (checkInAt == null) return null;
    return '${formatLocalizedTime(checkInAt!.toLocal())} WIB';
  }

  String? get checkOutTimeFormatted {
    if (checkOutAt == null) return null;
    return '${formatLocalizedTime(checkOutAt!.toLocal())} WIB';
  }
}

class AttendanceFilterOption<T> {
  const AttendanceFilterOption({required this.label, required this.value});

  final String label;
  final T value;
}

class AttendanceStatusFacet {
  const AttendanceStatusFacet({
    required this.status,
    required this.label,
    required this.count,
    required this.colorHex,
  });

  final String status;
  final String label;
  final int count;
  final String colorHex;
}

class AttendanceHistorySummary {
  const AttendanceHistorySummary({
    required this.totalWorkHours,
    required this.totalDays,
    required this.periodLabel,
    this.facets = const <AttendanceStatusFacet>[],
  });

  final double totalWorkHours;
  final int totalDays;
  final String periodLabel;
  final List<AttendanceStatusFacet> facets;
}

class AttendanceHistoryResult {
  const AttendanceHistoryResult({required this.records, this.summary});

  final List<AttendanceRecord> records;
  final AttendanceHistorySummary? summary;
}
