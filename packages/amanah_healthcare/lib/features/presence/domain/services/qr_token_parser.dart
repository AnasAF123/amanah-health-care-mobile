import 'dart:convert';

/// Domain service responsible for extracting and validating a canonical QR token
/// from raw camera barcode payloads (plain text or structured JSON).
abstract class QrTokenParser {
  /// Extracts the effective QR token from [rawInput].
  /// Returns null if the parsed token is empty or invalid.
  static String? parse(String rawInput) {
    final String trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final dynamic decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final dynamic tokenVal = decoded['token'];
          if (tokenVal != null) {
            final String tokenStr = tokenVal.toString().trim();
            return tokenStr.isNotEmpty ? tokenStr : null;
          }
        }
      } catch (_) {
        // Fallback to raw string if JSON parsing fails
      }
    }

    return trimmed;
  }
}
