/// Checks if [a] and [b] represent the exact same calendar day.
///
/// Ignores time components (hour, minute, second).
bool isSameCalendarDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
