import 'package:amanah_healthcare/core/time/functions/normalize_to_calendar_date.dart';

/// Immutable value object representing an inclusive calendar date range.
///
/// Ensures dates are normalized to midnight calendar boundaries (stripping hours,
/// minutes, seconds), ensuring [durationDays] matches backend inclusive arithmetic
/// (`end - start + 1`) without daylight/fractional-hour distortion.
class CalendarDateRange {
  final DateTime startDate;
  final DateTime endDate;

  CalendarDateRange({
    required DateTime start,
    required DateTime end,
  })  : startDate = normalizeToCalendarDate(start),
        endDate = normalizeToCalendarDate(end) {
    if (endDate.isBefore(startDate)) {
      throw ArgumentError.value(
        end,
        'endDate',
        'End date ($endDate) cannot be before start date ($startDate)',
      );
    }
  }

  /// Factory creating a single-day calendar range where start == end.
  factory CalendarDateRange.singleDay(DateTime date) {
    return CalendarDateRange(start: date, end: date);
  }

  /// Total inclusive days spanned by this range.
  ///
  /// Examples:
  /// - 22 Okt to 22 Okt = 1 day
  /// - 22 Okt to 23 Okt = 2 days
  int get durationDays => endDate.difference(startDate).inDays + 1;

  /// Whether this range spans exactly one calendar day.
  bool get isSingleDay => durationDays == 1;

  /// Checks if a given [date] falls within this inclusive calendar range.
  bool contains(DateTime date) {
    final DateTime normalized = normalizeToCalendarDate(date);
    return !normalized.isBefore(startDate) && !normalized.isAfter(endDate);
  }

  /// Checks if this range overlaps with [other].
  bool overlaps(CalendarDateRange other) {
    return !startDate.isAfter(other.endDate) && !endDate.isBefore(other.startDate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDateRange &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;

  @override
  String toString() =>
      'CalendarDateRange(start: $startDate, end: $endDate, days: $durationDays)';
}
