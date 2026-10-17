/// Canonical single source of truth (SSOT) enum for clinical session shifts.
enum ClinicalSessionShift {
  earlyMorning(
    code: 'early_morning',
    backendSession: 'DINI_HARI',
    displayName: 'Dini Hari',
    displaySessionName: 'Sesi Dini Hari',
  ),
  morning(
    code: 'morning',
    backendSession: 'PAGI',
    displayName: 'Pagi',
    displaySessionName: 'Sesi Pagi',
  ),
  afternoon(
    code: 'afternoon',
    backendSession: 'SIANG',
    displayName: 'Siang',
    displaySessionName: 'Sesi Siang',
  ),
  evening(
    code: 'evening',
    backendSession: 'SORE',
    displayName: 'Sore',
    displaySessionName: 'Sesi Sore',
  ),
  night(
    code: 'night',
    backendSession: 'MALAM',
    displayName: 'Malam',
    displaySessionName: 'Sesi Malam',
  );

  const ClinicalSessionShift({
    required this.code,
    required this.backendSession,
    required this.displayName,
    required this.displaySessionName,
  });

  final String code;
  final String backendSession;
  final String displayName;
  final String displaySessionName;
}

/// Domain service helper that resolves and normalizes clinical session data
/// coming from backend endpoints (`session`, `sessionShift`, `sessionLabel`, `shift`).
/// Eliminates hardcoded magic strings and translation leakage across presentation layers.
abstract final class ClinicalSessionResolver {
  /// Resolves the canonical [ClinicalSessionShift] from various raw backend indicators.
  static ClinicalSessionShift resolveShift({
    String? session,
    String? sessionShift,
    String? sessionLabel,
    String? fallback,
  }) {
    final String sUpper = session?.trim().toUpperCase() ?? '';
    final String sLower = sessionShift?.trim().toLowerCase() ?? '';
    final String label = (sessionLabel ?? fallback ?? '').trim().toLowerCase();

    // 1. Direct match on backend session code ("PAGI", "SIANG", "MALAM", "DINI_HARI", etc.)
    if (sUpper.isNotEmpty) {
      for (final ClinicalSessionShift shift in ClinicalSessionShift.values) {
        if (sUpper == shift.backendSession || sUpper.contains(shift.backendSession)) {
          return shift;
        }
      }
    }

    // 2. Match on sessionShift string code ("morning", "afternoon", "night", etc.)
    if (sLower.isNotEmpty) {
      for (final ClinicalSessionShift shift in ClinicalSessionShift.values) {
        if (sLower.contains(shift.code)) {
          return shift;
        }
      }
    }

    // 3. Match on sessionLabel / title string parsing
    if (label.isNotEmpty) {
      for (final ClinicalSessionShift shift in ClinicalSessionShift.values) {
        if (label.contains(shift.code) ||
            label.contains(shift.displayName.toLowerCase())) {
          return shift;
        }
      }
    }

    return ClinicalSessionShift.morning;
  }

  /// Returns clean human-readable session name ("Sesi Pagi", "Sesi Siang", "Sesi Malam", etc.).
  static String resolveSessionName({
    String? session,
    String? sessionShift,
    String? sessionLabel,
    String? fallback,
  }) {
    return resolveShift(
      session: session,
      sessionShift: sessionShift,
      sessionLabel: sessionLabel,
      fallback: fallback,
    ).displaySessionName;
  }

  /// Returns clean shift time name ("Pagi", "Siang", "Malam", etc.).
  static String resolveShiftName({
    String? session,
    String? sessionShift,
    String? sessionLabel,
    String? fallback,
  }) {
    return resolveShift(
      session: session,
      sessionShift: sessionShift,
      sessionLabel: sessionLabel,
      fallback: fallback,
    ).displayName;
  }

  /// Sanitizes any raw label or i18n backend key into clean Indonesian format.
  static String sanitize(String? rawLabel) {
    if (rawLabel == null || rawLabel.trim().isEmpty) {
      return 'Sesi Praktik';
    }
    String result = rawLabel;
    for (final ClinicalSessionShift shift in ClinicalSessionShift.values) {
      result = result.replaceAll('session.${shift.code}', shift.displaySessionName);
    }
    return result;
  }
}
