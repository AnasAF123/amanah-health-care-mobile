import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logger for authentication observability in Amanah Healthcare.
/// Formats and sanitizes auth events, network requests, storage access,
/// and OAuth handshakes with clear visual tags and latency metrics.
class AmanahAuthLogger {
  const AmanahAuthLogger._();

  static const String _name = 'AmanahAuth';

  /// Log outgoing HTTP auth request
  static void logRequest(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    final String sanitizedBody = _sanitizeMap(body);
    final String sanitizedHeaders = _sanitizeHeaders(headers);

    final String message =
        '🚀 [REQUEST] $method ${uri.toString()}\n'
        '   Headers: $sanitizedHeaders\n'
        '   Payload: $sanitizedBody';

    _output(message, level: 800);
  }

  /// Log incoming HTTP auth response
  static void logResponse(
    String method,
    Uri uri,
    int statusCode,
    Duration elapsed, {
    String? body,
  }) {
    final String icon = statusCode >= 200 && statusCode < 300
        ? '✅'
        : (statusCode == 401 || statusCode == 403 ? '🔒' : '⚠️');

    final String sanitizedBody = _sanitizeJsonString(body);
    final String message =
        '$icon [RESPONSE] $method ${uri.path} -> Status $statusCode (${elapsed.inMilliseconds}ms)\n'
        '   URL: ${uri.toString()}\n'
        '   Body: $sanitizedBody';

    _output(message, level: statusCode >= 400 ? 900 : 800);
  }

  /// Log network/server error with diagnostic hints
  static void logError(
    String method,
    Uri uri,
    Object error, {
    StackTrace? stackTrace,
    Duration? elapsed,
  }) {
    final String elapsedStr =
        elapsed != null ? ' after ${elapsed.inMilliseconds}ms' : '';
    final String diagnosticHint = _getDiagnosticHint(error, uri);

    final String message =
        '💥 [NETWORK/ERROR] $method ${uri.toString()}$elapsedStr\n'
        '   Error: $error\n'
        '   Diagnostic: $diagnosticHint';

    _output(message, level: 1000, error: error, stackTrace: stackTrace);
  }

  /// Log secure storage operations
  static void logStorage(
    String action, {
    String? key,
    bool? exists,
    int? length,
  }) {
    final String details = <String>[
      if (key != null) 'key: $key',
      if (exists != null) 'exists: $exists',
      if (length != null) 'length: $length chars',
    ].join(', ');

    final String message = '🔑 [STORAGE] $action ($details)';
    _output(message, level: 700);
  }

  /// Log OAuth operations (Google Sign-In, token exchange)
  static void logOAuth(String message, {Map<String, dynamic>? details}) {
    final String detailStr =
        details != null ? ' -> ${_sanitizeMap(details)}' : '';
    _output('🌐 [OAUTH] $message$detailStr', level: 800);
  }

  /// Log auth lifecycle events (cold restore, state change, logout)
  static void logLifecycle(String message, {Map<String, dynamic>? details}) {
    final String detailStr =
        details != null ? ' -> ${_sanitizeMap(details)}' : '';
    _output('🔄 [LIFECYCLE] $message$detailStr', level: 800);
  }

  /// Helper to send output to developer.log and debugPrint
  static void _output(
    String message, {
    int level = 800,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _name,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint('[$_name] $message');
    }
  }

  /// Diagnostic suggestions based on common failure modes
  static String _getDiagnosticHint(Object error, Uri uri) {
    final String errStr = error.toString().toLowerCase();

    if (errStr.contains('connection refused') ||
        errStr.contains('socketexception')) {
      if (uri.host == '10.0.2.2') {
        return 'Connection refused to 10.0.2.2. Is the backend server running on the host machine at port ${uri.port}? Ensure Docker / NestJS is listening on 0.0.0.0:${uri.port}.';
      } else if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        return 'Connection refused to localhost. On Android Emulator, localhost refers to the emulator itself. Use 10.0.2.2 or run `adb reverse tcp:${uri.port} tcp:${uri.port}`.';
      }
      return 'Server is unreachable. Check network connectivity or server process status.';
    }

    if (errStr.contains('timed out') || errStr.contains('timeout')) {
      return 'Request timed out. Server may be overloaded or firewall is dropping packets.';
    }

    if (errStr.contains('formatexception')) {
      return 'Server returned non-JSON response (e.g. 502 Bad Gateway or raw HTML error page).';
    }

    return 'Check server logs for corresponding request and error traces.';
  }

  /// Sanitize sensitive data from maps
  static String _sanitizeMap(Map<String, dynamic>? map) {
    if (map == null) return '{}';
    final Map<String, dynamic> copy = <String, dynamic>{};

    for (final MapEntry<String, dynamic> entry in map.entries) {
      final String key = entry.key.toLowerCase();
      if (key.contains('password') ||
          key.contains('secret') ||
          key.contains('otp')) {
        copy[entry.key] = '***[REDACTED]***';
      } else if (key.contains('token') || key == 'idtoken') {
        final dynamic val = entry.value;
        if (val is String && val.length > 12) {
          copy[entry.key] =
              '${val.substring(0, 6)}...[${val.length} chars]...${val.substring(val.length - 4)}';
        } else {
          copy[entry.key] = '***[TOKEN]***';
        }
      } else if (entry.value is Map<String, dynamic>) {
        copy[entry.key] = jsonDecode(_sanitizeMap(entry.value as Map<String, dynamic>));
      } else {
        copy[entry.key] = entry.value;
      }
    }

    try {
      return jsonEncode(copy);
    } catch (_) {
      return copy.toString();
    }
  }

  /// Sanitize headers
  static String _sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return '{}';
    final Map<String, String> copy = <String, String>{};

    for (final MapEntry<String, String> entry in headers.entries) {
      final String key = entry.key.toLowerCase();
      if (key == 'authorization') {
        final String val = entry.value;
        if (val.startsWith('Bearer ') && val.length > 18) {
          copy[entry.key] =
              'Bearer ${val.substring(7, 13)}...[masked]...${val.substring(val.length - 4)}';
        } else {
          copy[entry.key] = 'Bearer ***[MASKED]***';
        }
      } else if (key.contains('cookie') || key.contains('key')) {
        copy[entry.key] = '***[MASKED]***';
      } else {
        copy[entry.key] = entry.value;
      }
    }

    return copy.toString();
  }

  /// Sanitize JSON response string
  static String _sanitizeJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '(empty)';
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return _sanitizeMap(decoded);
      } else if (decoded is List) {
        return '[List of ${decoded.length} items]';
      }
      return raw;
    } catch (_) {
      if (raw.length > 200) {
        return '${raw.substring(0, 200)}... (${raw.length} bytes)';
      }
      return raw;
    }
  }
}
