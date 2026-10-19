/// Formats a time into a standard clock string based on [style].
///
/// Supported styles:
/// - `24h`: "14:30"
/// - `12h`: "02:30 PM"
String formatLocalizedTime(
  DateTime time, {
  String style = '24h',
}) {
  final int hour = time.hour;
  final int minute = time.minute;
  final String mm = minute.toString().padLeft(2, '0');

  if (style == '12h') {
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int h12 = hour % 12 == 0 ? 12 : hour % 12;
    final String hh = h12.toString().padLeft(2, '0');
    return '$hh:$mm $period';
  }

  final String hh = hour.toString().padLeft(2, '0');
  return '$hh:$mm';
}

/// Normalizes a raw time string (e.g. "08:00:00") into a clean 5-character string ("08:00").
String normalizeTimeString(String rawTime) {
  final String trimmed = rawTime.trim();
  if (trimmed.length >= 5) {
    return trimmed.substring(0, 5);
  }
  return trimmed;
}
