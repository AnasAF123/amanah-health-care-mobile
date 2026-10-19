import 'package:amanah_healthcare/core/time/functions/normalize_to_calendar_date.dart';

/// Calculates the inclusive calendar day count between [start] and [end].
///
/// Strictly mirrors the authoritative backend arithmetic in `leave.drizzle-repository.ts`:
/// `durationDays = Math.max(1, Math.round((end - start) / 86400000) + 1)`
///
/// Both dates are first normalized to midnight calendar boundaries to eliminate
/// time-of-day offsets.
///
/// Examples:
/// - `2026-10-22` to `2026-10-22` -> `1` day
/// - `2026-10-22` to `2026-10-23` -> `2` days
int calculateInclusiveDayCount(DateTime start, DateTime end) {
  final DateTime s = normalizeToCalendarDate(start);
  final DateTime e = normalizeToCalendarDate(end);
  final int diff = e.difference(s).inDays + 1;
  return diff > 0 ? diff : 1;
}
