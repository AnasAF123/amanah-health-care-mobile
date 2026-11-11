import 'dart:math' as math;

/// Standardized practice / duty hours formatter for Presence, Attendance, and Payroll.
/// Converts numerical hours (e.g. 0.5, 0.25, 1.5, 7.0) into natural, localized Indonesian units:
/// - 0 or null => "0 jam"
/// - 0.25 => "15 menit"
/// - 0.5 => "30 menit"
/// - 1.0 => "1 jam"
/// - 1.5 => "1 jam 30 menit"
/// - 7.0 => "7 jam"
String formatPracticeHours(double? hours) {
  if (hours == null || hours.isNaN || hours <= 0) {
    return '0 jam';
  }

  // Under 1 hour => format as pure minutes
  if (hours < 1) {
    final int minutes = (hours * 60).round();
    return '${math.max(1, minutes)} menit';
  }

  final int h = hours.floor();
  final int remMinutes = ((hours - h) * 60).round();
  return remMinutes > 0 ? '$h jam $remMinutes menit' : '$h jam';
}
