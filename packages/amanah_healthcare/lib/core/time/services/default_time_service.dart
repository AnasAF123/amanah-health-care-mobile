import 'package:amanah_healthcare/core/time/contracts/time_config_provider.dart';
import 'package:amanah_healthcare/core/time/contracts/time_service.dart';
import 'package:amanah_healthcare/core/time/functions/calculate_inclusive_day_count.dart';
import 'package:amanah_healthcare/core/time/functions/calculate_overtime_minutes.dart';
import 'package:amanah_healthcare/core/time/functions/format_localized_date.dart';
import 'package:amanah_healthcare/core/time/functions/format_localized_time.dart';
import 'package:amanah_healthcare/core/time/functions/is_same_calendar_day.dart';
import 'package:amanah_healthcare/core/time/functions/is_within_tolerance_window.dart';
import 'package:amanah_healthcare/core/time/functions/normalize_to_calendar_date.dart';
import 'package:amanah_healthcare/core/time/models/calendar_date_range.dart';
import 'package:amanah_healthcare/core/time/models/clinic_time_config.dart';
import 'package:amanah_healthcare/core/time/services/default_time_config_provider.dart';

/// Default service-agnostic implementation of [TimeService].
///
/// Composes dedicated pure functions and reads dynamic policy from [TimeConfigProvider].
class DefaultTimeService implements TimeService {
  final TimeConfigProvider _configProvider;

  DefaultTimeService({TimeConfigProvider? configProvider})
      : _configProvider = configProvider ?? DefaultTimeConfigProvider();

  @override
  ClinicTimeConfig get config => _configProvider.currentConfig;

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime today() => normalizeToCalendarDate(now());

  @override
  String formatDate(DateTime date, {String? style}) {
    return formatLocalizedDate(
      date,
      style: style ?? config.dateFormatStyle,
      locale: config.locale,
    );
  }

  @override
  String formatTime(DateTime time, {String? style}) {
    return formatLocalizedTime(
      time,
      style: style ?? config.timeFormatStyle,
    );
  }

  @override
  String formatDateRange(DateTime start, DateTime end, {String? style}) {
    if (isSameDay(start, end)) {
      return formatDate(start, style: style);
    }
    final String startStr = formatLocalizedDate(
      start,
      style: 'human_short',
      locale: config.locale,
    );
    final String endStr = formatLocalizedDate(
      end,
      style: 'human_short',
      locale: config.locale,
    );
    return '$startStr — $endStr';
  }

  @override
  CalendarDateRange createDateRange(DateTime start, DateTime end) {
    return CalendarDateRange(start: start, end: end);
  }

  @override
  int calculateDays(DateTime start, DateTime end) {
    return calculateInclusiveDayCount(start, end);
  }

  @override
  bool isSameDay(DateTime? a, DateTime? b) {
    return isSameCalendarDay(a, b);
  }

  @override
  bool isWithinAttendanceWindow({
    required DateTime timestamp,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
  }) {
    return isWithinToleranceWindow(
      timestamp: timestamp,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      config: config.attendanceConfig,
    );
  }

  @override
  int calculateOvertime({
    required DateTime scheduledEnd,
    required DateTime actualCheckOut,
  }) {
    return calculateOvertimeMinutes(
      scheduledEnd: scheduledEnd,
      actualCheckOut: actualCheckOut,
      config: config.attendanceConfig,
    );
  }
}
