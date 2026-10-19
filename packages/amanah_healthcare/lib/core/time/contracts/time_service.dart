import 'package:amanah_healthcare/core/time/models/calendar_date_range.dart';
import 'package:amanah_healthcare/core/time/models/clinic_time_config.dart';

/// Application-wide authoritative contract for time calculations, formatting,
/// and clinic policy enforcement.
///
/// Service-agnostic: implementations do not depend on Flutter UI elements
/// or direct HTTP clients.
abstract interface class TimeService {
  /// Current time according to clinic timezone/clock.
  DateTime now();

  /// Normalized calendar date for today (midnight, 00:00:00).
  DateTime today();

  /// Active clinic time configuration.
  ClinicTimeConfig get config;

  /// Formats a [date] according to clinic configuration or explicit [style].
  String formatDate(DateTime date, {String? style});

  /// Formats a [time] according to clinic configuration or explicit [style].
  String formatTime(DateTime time, {String? style});

  /// Formats a date range into a localized label (e.g. "22 Okt - 23 Okt 2026").
  String formatDateRange(DateTime start, DateTime end, {String? style});

  /// Creates a validated [CalendarDateRange] normalized to midnight.
  CalendarDateRange createDateRange(DateTime start, DateTime end);

  /// Calculates inclusive calendar days between [start] and [end] matching backend SSOT.
  int calculateDays(DateTime start, DateTime end);

  /// Checks if two dates represent the exact same calendar day.
  bool isSameDay(DateTime? a, DateTime? b);

  /// Checks if [timestamp] is within the allowable attendance check-in window.
  bool isWithinAttendanceWindow({
    required DateTime timestamp,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
  });

  /// Calculates overtime minutes based on scheduled shift end and actual check-out.
  int calculateOvertime({
    required DateTime scheduledEnd,
    required DateTime actualCheckOut,
  });
}
