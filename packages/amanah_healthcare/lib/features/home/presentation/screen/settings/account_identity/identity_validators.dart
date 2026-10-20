/// Pure Dart validator functions for staff account identity fields.
/// Decoupled from UI widgets for complete unit testability and single responsibility.
abstract final class IdentityValidators {
  static final RegExp _nikRegex = RegExp(r'^\d{16}$');
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Validates Indonesian National Identity Number (NIK/KTP).
  /// Must be exactly 16 numeric digits.
  static String? nik(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'NIK tidak boleh kosong.';
    }
    if (!_nikRegex.hasMatch(trimmed)) {
      return 'NIK harus terdiri dari 16 digit angka.';
    }
    return null;
  }

  /// Validates staff operational telephone / WhatsApp number.
  /// Must be at least 9 characters/digits.
  static String? phone(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Nomor telepon tidak boleh kosong.';
    }
    if (trimmed.length < 9) {
      return 'Nomor telepon minimal 9 digit.';
    }
    return null;
  }

  /// Validates email address format using standard RFC 5322 compatible pattern.
  /// Rejects malformed addresses such as `@..` or spaces.
  static String? email(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Format email tidak valid.';
    }
    return null;
  }
}
