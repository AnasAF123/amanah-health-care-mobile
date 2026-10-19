import 'package:amanah_healthcare/core/time/models/clinic_attendance_time_config.dart';

/// Checks if [timestamp] is within the allowable check-in or attendance window
/// for a scheduled shift.
///
/// Window spans from:
/// `[scheduledStart - checkInWindowMinutesBefore]` to `[scheduledEnd + checkInWindowMinutesAfter]`.
bool isWithinToleranceWindow({
  required DateTime timestamp,
  required DateTime scheduledStart,
  required DateTime scheduledEnd,
  ClinicAttendanceTimeConfig config = ClinicAttendanceTimeConfig.defaultConfig,
}) {
  final DateTime windowStart = scheduledStart.subtract(
    Duration(minutes: config.checkInWindowMinutesBefore),
  );
  final DateTime windowEnd = scheduledEnd.add(
    Duration(minutes: config.checkInWindowMinutesAfter),
  );

  return !timestamp.isBefore(windowStart) && !timestamp.isAfter(windowEnd);
}
