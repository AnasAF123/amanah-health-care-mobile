import 'dart:convert';

/// Single source of truth for recursive redaction and data sanitization.
class LogSanitizer {
  LogSanitizer({
    Set<String>? additionalSensitiveKeys,
    this.redactedMask = '[REDACTED]',
    this.maxDepth = 10,
  }) : sensitiveKeys = <String>{
          ..._defaultSensitiveKeys,
          if (additionalSensitiveKeys != null)
            ...additionalSensitiveKeys.map((String k) => k.toLowerCase()),
        };

  final Set<String> sensitiveKeys;
  final String redactedMask;
  final int maxDepth;

  static const Set<String> _defaultSensitiveKeys = <String>{
    'authorization',
    'cookie',
    'set-cookie',
    'password',
    'password_confirmation',
    'passwordconfirmation',
    'currentpassword',
    'newpassword',
    'pin',
    'otp',
    'token',
    'access_token',
    'accesstoken',
    'refresh_token',
    'refreshtoken',
    'id_token',
    'idtoken',
    'api_key',
    'apikey',
    'secret',
    'client_secret',
    'clientsecret',
    'private_key',
    'privatekey',
  };

  /// Sanitizes any dynamic object (Map, List, Primitive) recursively.
  dynamic sanitize(dynamic value, [int depth = 0]) {
    if (depth > maxDepth) return '<max-depth-reached>';
    if (value == null) return null;

    if (value is Map) {
      final Map<String, dynamic> result = <String, dynamic>{};
      for (final MapEntry<dynamic, dynamic> entry in value.entries) {
        final String keyStr = entry.key.toString();
        final String lowerKey = keyStr.toLowerCase();

        if (_isSensitiveKey(lowerKey)) {
          result[keyStr] = redactedMask;
        } else {
          result[keyStr] = sanitize(entry.value, depth + 1);
        }
      }
      return result;
    }

    if (value is List) {
      return value.map((dynamic item) => sanitize(item, depth + 1)).toList();
    }

    if (value is num || value is bool) {
      return value;
    }

    final String strVal = value.toString();
    return _sanitizeString(strVal);
  }

  /// Sanitizes HTTP headers map.
  Map<String, String> sanitizeHeaders(Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return <String, String>{};
    final Map<String, String> sanitized = <String, String>{};

    for (final MapEntry<String, dynamic> entry in headers.entries) {
      final String key = entry.key;
      final String lowerKey = key.toLowerCase();
      final String val = entry.value.toString();

      if (_isSensitiveKey(lowerKey)) {
        if (lowerKey == 'authorization' && val.toLowerCase().startsWith('bearer ')) {
          sanitized[key] = 'Bearer $redactedMask';
        } else {
          sanitized[key] = redactedMask;
        }
      } else {
        sanitized[key] = val;
      }
    }

    return sanitized;
  }

  /// Sanitizes JSON string or returns sanitized string representation.
  dynamic sanitizeJsonPayload(dynamic payload) {
    if (payload == null) return null;
    if (payload is Map || payload is List) {
      return sanitize(payload);
    }
    if (payload is String) {
      final String trimmed = payload.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final dynamic decoded = jsonDecode(trimmed);
          return sanitize(decoded);
        } catch (_) {
          return _sanitizeString(trimmed);
        }
      }
      return _sanitizeString(trimmed);
    }
    return sanitize(payload.toString());
  }

  bool _isSensitiveKey(String lowerKey) {
    if (sensitiveKeys.contains(lowerKey)) return true;
    final String normalizedLower = lowerKey.replaceAll(RegExp(r'[-_]'), '');
    for (final String key in sensitiveKeys) {
      if (lowerKey.contains(key)) return true;
      final String normalizedKey = key.replaceAll(RegExp(r'[-_]'), '');
      if (normalizedLower.contains(normalizedKey)) return true;
    }
    return false;
  }

  String _sanitizeString(String text) {
    // Quick check if string contains bearer tokens
    if (text.toLowerCase().contains('bearer ')) {
      return text.replaceAll(
        RegExp(r'bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
        'Bearer $redactedMask',
      );
    }
    return text;
  }
}
