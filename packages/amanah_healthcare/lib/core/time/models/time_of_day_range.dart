/// Immutable value object representing a daily time window between two clock times (`HH:mm`).
class TimeOfDayRange {
  final String startTime;
  final String endTime;

  const TimeOfDayRange({
    required this.startTime,
    required this.endTime,
  });

  /// Converts an `HH:mm` string to minutes from midnight (0..1439).
  static int parseMinutesFromMidnight(String timeStr) {
    final List<String> parts = timeStr.split(':');
    final int hours = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final int minutes = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return (hours * 60) + minutes;
  }

  /// Start time in minutes from midnight.
  int get startMinutes => parseMinutesFromMidnight(startTime);

  /// End time in minutes from midnight.
  int get endMinutes => parseMinutesFromMidnight(endTime);

  /// Total duration of this time window in minutes.
  int get durationMinutes {
    final int diff = endMinutes - startMinutes;
    return diff >= 0 ? diff : diff + (24 * 60); // Handles overnight spans
  }

  /// Checks if a [time] falls within this daily time window.
  bool containsTime(DateTime time) {
    final int currentMinutes = (time.hour * 60) + time.minute;
    if (endMinutes >= startMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight span (e.g. 22:00 to 06:00)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDayRange &&
          runtimeType == other.runtimeType &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => startTime.hashCode ^ endTime.hashCode;

  @override
  String toString() => 'TimeOfDayRange($startTime - $endTime)';
}
