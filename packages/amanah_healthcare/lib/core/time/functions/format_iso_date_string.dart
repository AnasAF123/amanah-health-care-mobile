/// Formats a [DateTime] into a standard canonical ISO date string (`YYYY-MM-DD`).
///
/// Uses zero-padded year, month, and day without timezone distortion.
String formatIsoDateString(DateTime date) {
  final String y = date.year.toString().padLeft(4, '0');
  final String m = date.month.toString().padLeft(2, '0');
  final String d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
