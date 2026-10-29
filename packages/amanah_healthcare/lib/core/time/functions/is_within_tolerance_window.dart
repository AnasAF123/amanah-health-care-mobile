import 'package:amanah_healthcare/core/time/models/clinic_attendance_time_config.dart';

/// Checks if [timestamp] is within the allowable attendance window for a scheduled shift.
///
/// For check-in: window opens at `[scheduledStart - checkInWindowMinutesBefore]`
/// and extends across the active shift duration until `[scheduledEnd]`.
bool isWithinToleranceWindow({
  required DateTime timestamp,
  required DateTime scheduledStart,
  required DateTime scheduledEnd,
  ClinicAttendanceTimeConfig config = ClinicAttendanceTimeConfig.defaultConfig,
}) {
  final DateTime windowStart = scheduledStart.subtract(
    Duration(minutes: config.checkInWindowMinutesBefore),
  );
  // Preserves scheduled shift operability window aligned with backend attendance-session.resolver
  final DateTime windowEnd = scheduledEnd.isAfter(scheduledStart)
      ? scheduledEnd
      : scheduledEnd.add(const Duration(days: 1));

  return !timestamp.isBefore(windowStart) && !timestamp.isAfter(windowEnd);
}
