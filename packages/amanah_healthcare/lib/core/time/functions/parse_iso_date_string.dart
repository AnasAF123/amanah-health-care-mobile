import 'package:amanah_healthcare/core/time/functions/normalize_to_calendar_date.dart';

/// Parses an ISO date string (`YYYY-MM-DD` or full ISO-8601) into a normalized
/// midnight calendar [DateTime].
///
/// Returns `null` if [dateStr] is null, empty, or cannot be parsed.
DateTime? parseIsoDateString(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) {
    return null;
  }
  try {
    final DateTime parsed = DateTime.parse(dateStr.trim());
    return normalizeToCalendarDate(parsed);
  } catch (_) {
    return null;
  }
}
