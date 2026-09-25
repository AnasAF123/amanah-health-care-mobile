import 'dart:convert';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';

/// Structured log event representation.
class LogEvent {
  LogEvent({
    required this.message,
    required this.level,
    this.category = LogCategory.system,
    this.context,
    this.error,
    this.stackTrace,
    DateTime? timestamp,
    String? id,
  })  : timestamp = timestamp ?? DateTime.now(),
        id = id ?? _generateEventId();

  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final LogCategory category;
  final String message;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;

  static int _counter = 0;
  static String _generateEventId() {
    _counter++;
    return 'evt_${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }

  /// Converts the event to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.label,
      'category': category.name,
      'message': message,
      if (context != null && context!.isNotEmpty) 'context': context,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  /// Formats the event as a structured log line suitable for file logs.
  String toLogLine() {
    final StringBuffer sb = StringBuffer();
    sb.write('[${timestamp.toIso8601String()}] ');
    sb.write('[${level.label}] ');
    sb.write('[${category.name}] ');
    sb.write(message);

    if (context != null && context!.isNotEmpty) {
      try {
        sb.write(' | context: ${jsonEncode(context)}');
      } catch (_) {
        sb.write(' | context: $context');
      }
    }

    if (error != null) {
      sb.write(' | error: $error');
    }

    if (stackTrace != null) {
      sb.write('\n$stackTrace');
    }

    return sb.toString();
  }

  @override
  String toString() => toLogLine();
}
