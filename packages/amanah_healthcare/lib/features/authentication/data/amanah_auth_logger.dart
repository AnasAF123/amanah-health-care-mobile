import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';

/// Centralized logger for authentication observability in Amanah Healthcare.
///
/// Backwards-compatible facade that forwards all events to the unified [AppLog]
/// infrastructure, routing to the industrial-grade [FileLogSink].
class AmanahAuthLogger {
  const AmanahAuthLogger._();

  /// Log outgoing HTTP auth request
  static void logRequest(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    AppLog.write(
      'HTTP Auth Request: $method ${uri.toString()}',
      category: LogCategory.auth,
      level: LogLevel.info,
      context: <String, dynamic>{
        'method': method,
        'url': uri.toString(),
        'headers': ?headers,
        'body': ?body,
      },
    );
  }

  /// Log incoming HTTP auth response
  static void logResponse(
    String method,
    Uri uri,
    int statusCode,
    Duration elapsed, {
    String? body,
  }) {
    final LogLevel level = statusCode >= 400 ? LogLevel.warning : LogLevel.info;
    AppLog.write(
      'HTTP Auth Response: $method ${uri.path} -> $statusCode (${elapsed.inMilliseconds}ms)',
      category: LogCategory.auth,
      level: level,
      context: <String, dynamic>{
        'method': method,
        'url': uri.toString(),
        'statusCode': statusCode,
        'durationMs': elapsed.inMilliseconds,
        'body': ?body,
      },
    );
  }

  /// Log network/server error with diagnostic hints
  static void logError(
    String method,
    Uri uri,
    Object error, {
    StackTrace? stackTrace,
    Duration? elapsed,
  }) {
    AppLog.write(
      'HTTP Auth Error: $method ${uri.toString()}',
      category: LogCategory.auth,
      level: LogLevel.error,
      error: error,
      stackTrace: stackTrace,
      context: <String, dynamic>{
        'method': method,
        'url': uri.toString(),
        if (elapsed != null) 'durationMs': elapsed.inMilliseconds,
        'diagnostic': _getDiagnosticHint(error, uri),
      },
    );
  }

  /// Log secure storage operations
  static void logStorage(
    String action, {
    String? key,
    bool? exists,
    int? length,
  }) {
    AppLog.write(
      'Storage: $action',
      category: LogCategory.storage,
      level: LogLevel.debug,
      context: <String, dynamic>{
        'action': action,
        'key': ?key,
        'exists': ?exists,
        'length': ?length,
      },
    );
  }

  /// Log OAuth operations (Google Sign-In, token exchange)
  static void logOAuth(String message, {Map<String, dynamic>? details}) {
    AppLog.write(
      'OAuth: $message',
      category: LogCategory.auth,
      level: LogLevel.info,
      context: details,
    );
  }

  /// Log auth lifecycle events (cold restore, state change, logout)
  static void logLifecycle(String message, {Map<String, dynamic>? details}) {
    AppLog.write(
      'Auth Lifecycle: $message',
      category: LogCategory.auth,
      level: LogLevel.info,
      context: details,
    );
  }

  /// Diagnostic suggestions based on common failure modes
  static String _getDiagnosticHint(Object error, Uri uri) {
    final String errStr = error.toString().toLowerCase();

    if (errStr.contains('connection refused') ||
        errStr.contains('socketexception')) {
      if (uri.host == '10.0.2.2') {
        return 'Connection refused to 10.0.2.2. Is the backend server running on host at port ${uri.port}?';
      } else if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        return 'Connection refused to localhost. On Android Emulator use 10.0.2.2 or `adb reverse`.';
      }
      return 'Server is unreachable. Check network connectivity.';
    }

    if (errStr.contains('timed out') || errStr.contains('timeout')) {
      return 'Request timed out.';
    }

    if (errStr.contains('formatexception')) {
      return 'Server returned non-JSON response.';
    }

    return 'Check server logs for corresponding request and error traces.';
  }
}
