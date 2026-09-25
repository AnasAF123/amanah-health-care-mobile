import 'package:amanah_healthcare/core/logging/app_logger.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';
import 'package:amanah_healthcare/core/logging/log_sanitizer.dart';
import 'package:amanah_healthcare/core/logging/logging_config.dart';
import 'package:amanah_healthcare/core/logging/sinks/log_sink.dart';

/// Concrete implementation of [AppLogger] that routes events through
/// sanitization and dispatches to configured sinks.
class CompositeLogger implements AppLogger {
  CompositeLogger({
    required this.config,
    required List<LogSink> sinks,
    LogSanitizer? sanitizer,
  })  : _sinks = List<LogSink>.unmodifiable(sinks),
        _sanitizer = sanitizer ??
            LogSanitizer(
              additionalSensitiveKeys: config.additionalSensitiveKeys,
            );

  final LoggingConfig config;
  final List<LogSink> _sinks;
  final LogSanitizer _sanitizer;

  List<LogSink> get sinks => _sinks;
  LogSanitizer get sanitizer => _sanitizer;

  @override
  void trace(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
  }) {
    _dispatch(
      LogLevel.trace,
      message,
      category: category,
      context: context,
    );
  }

  @override
  void debug(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
  }) {
    _dispatch(
      LogLevel.debug,
      message,
      category: category,
      context: context,
    );
  }

  @override
  void info(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
  }) {
    _dispatch(
      LogLevel.info,
      message,
      category: category,
      context: context,
    );
  }

  @override
  void warning(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _dispatch(
      LogLevel.warning,
      message,
      category: category,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void error(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _dispatch(
      LogLevel.error,
      message,
      category: category,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void critical(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _dispatch(
      LogLevel.critical,
      message,
      category: category,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void logEvent(LogEvent event) {
    if (!config.isCategoryEnabled(event.category)) return;
    if (!config.isLevelEnabled(event.level)) return;

    try {
      final Map<String, dynamic>? sanitizedContext =
          config.redactSensitiveData && event.context != null
              ? _sanitizer.sanitize(event.context) as Map<String, dynamic>?
              : event.context;

      final LogEvent effectiveEvent = LogEvent(
        id: event.id,
        timestamp: event.timestamp,
        level: event.level,
        category: event.category,
        message: event.message,
        context: sanitizedContext,
        error: event.error,
        stackTrace: event.stackTrace,
      );

      for (final LogSink sink in _sinks) {
        sink.write(effectiveEvent);
      }
    } catch (_) {
      // Passive safety guarantee
    }
  }

  void _dispatch(
    LogLevel level,
    String message, {
    required LogCategory category,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!config.isCategoryEnabled(category)) return;
    if (!config.isLevelEnabled(level)) return;

    final LogEvent event = LogEvent(
      message: message,
      level: level,
      category: category,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );

    logEvent(event);
  }

  @override
  Future<void> flush() async {
    for (final LogSink sink in _sinks) {
      await sink.flush();
    }
  }
}
