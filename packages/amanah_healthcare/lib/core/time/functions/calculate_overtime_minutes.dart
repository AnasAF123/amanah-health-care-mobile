import 'package:amanah_healthcare/core/time/models/clinic_attendance_time_config.dart';

/// Calculates overtime minutes earned between a scheduled shift end time and
/// the actual check-out time.
///
/// Adheres to clinic configuration:
/// - If [config.overtimeEnabled] is `false`, overtime is always 0.
/// - If excess time is within [config.lateToleranceMinutes], it is considered
///   accidental checkout delay (human error buffer) and overtime is 0.
/// - If excess time exceeds [config.lateToleranceMinutes], overtime minutes are
///   counted from the scheduled end time.
int calculateOvertimeMinutes({
  required DateTime scheduledEnd,
  required DateTime actualCheckOut,
  ClinicAttendanceTimeConfig config = ClinicAttendanceTimeConfig.defaultConfig,
}) {
  if (!config.overtimeEnabled) {
    return 0;
  }

  final int diffMinutes = actualCheckOut.difference(scheduledEnd).inMinutes;
  if (diffMinutes <= config.lateToleranceMinutes) {
    return 0;
  }

  return diffMinutes;
}
