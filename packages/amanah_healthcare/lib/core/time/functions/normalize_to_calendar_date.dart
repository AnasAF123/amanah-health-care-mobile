/// Normalizes a [DateTime] to pure calendar date at midnight (00:00:00.000).
///
/// Strips hours, minutes, seconds, milliseconds, and microseconds so that
/// date comparisons and differences do not suffer from fractional hour/day
/// truncations or daylight shifts.
DateTime normalizeToCalendarDate(DateTime dt) {
  return DateTime(dt.year, dt.month, dt.day);
}
