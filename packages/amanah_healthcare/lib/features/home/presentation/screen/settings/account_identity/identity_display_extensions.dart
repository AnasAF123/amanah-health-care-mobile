/// Extension to streamline fallback string presentation across identity settings rows.
extension IdentityDisplayText on String? {
  /// Returns the trimmed non-empty string, or [fallback] if null or blank.
  String orFallback([String fallback = 'Belum diisi']) {
    final String? v = this;
    if (v == null || v.trim().isEmpty) {
      return fallback;
    }
    return v.trim();
  }
}

/// Baseline layout and initial values for identity settings.
abstract final class IdentitySettingsConstants {
  /// Bottom padding to clear floating docks and system navigation.
  static const double bottomPadding = 130.0;

  /// Default date selected if user has not yet specified a birth date.
  static final DateTime defaultBirthDate = DateTime(1995, 1, 1);
}
