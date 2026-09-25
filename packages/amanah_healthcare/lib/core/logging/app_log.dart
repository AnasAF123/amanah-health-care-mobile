import 'dart:io';
import 'package:amanah_healthcare/core/logging/app_logger.dart';
import 'package:amanah_healthcare/core/logging/composite_logger.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';
import 'package:amanah_healthcare/core/logging/logging_config.dart';
import 'package:amanah_healthcare/core/logging/sinks/console_log_sink.dart';
import 'package:amanah_healthcare/core/logging/sinks/file_log_sink.dart';
import 'package:amanah_healthcare/core/logging/sinks/log_sink.dart';

/// Dynamic, ergonomic utility facade for plug-and-play logging.
///
/// Features SSOT configuration, category filtering (e.g. HTTP-only or API-only),
/// and dumps to a dedicated file log without polluting the console main stream.
class AppLog {
  const AppLog._();

  static AppLogger? _instance;
  static FileLogSink? _fileSink;
  static LoggingConfig _config = const LoggingConfig();

  /// Currently configured logger instance.
  static AppLogger get instance {
    if (_instance == null) {
      init();
    }
    return _instance!;
  }

  /// Active file log sink (if file output is enabled).
  static FileLogSink? get fileSink => _fileSink;

  /// Active configuration.
  static LoggingConfig get config => _config;

  /// Initializes or reconfigures the global logging pipeline.
  static void init({
    LoggingConfig? config,
    AppLogger? customLogger,
    List<LogSink>? additionalSinks,
  }) {
    _config = config ?? const LoggingConfig();

    if (customLogger != null) {
      _instance = customLogger;
      return;
    }

    final List<LogSink> sinks = <LogSink>[...?additionalSinks];

    if (_config.enableFileOutput) {
      _fileSink = FileLogSink(
        customFilePath: _config.customLogFilePath,
        maxFileSizeBytes: _config.maxFileSizeBytes,
        maxBackupFiles: _config.maxBackupFiles,
      );
      sinks.add(_fileSink!);
    } else {
      _fileSink = null;
    }

    if (_config.enableConsoleOutput) {
      sinks.add(const ConsoleLogSink());
    }

    _instance = CompositeLogger(
      config: _config,
      sinks: sinks,
    );
  }

  /// Log generic event with arbitrary category
  static void write(
    String message, {
    required LogCategory category,
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final LogEvent event = LogEvent(
      message: message,
      level: level,
      category: category,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
    instance.logEvent(event);
  }

  /// Shortcut for HTTP telemetry
  static void http(
    String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    write(
      message,
      category: LogCategory.http,
      level: level,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Shortcut for API telemetry
  static void api(
    String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    write(
      message,
      category: LogCategory.api,
      level: level,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Shortcut for Auth events
  static void auth(
    String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    write(
      message,
      category: LogCategory.auth,
      level: level,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Shortcut for Storage events
  static void storage(
    String message, {
    LogLevel level = LogLevel.debug,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    write(
      message,
      category: LogCategory.storage,
      level: level,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Shortcut for System events
  static void system(
    String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    write(
      message,
      category: LogCategory.system,
      level: level,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Convenience log level shortcuts
  static void trace(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context}) =>
      instance.trace(message, category: category, context: context);

  static void debug(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context}) =>
      instance.debug(message, category: category, context: context);

  static void info(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context}) =>
      instance.info(message, category: category, context: context);

  static void warning(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) =>
      instance.warning(message, category: category, context: context, error: error, stackTrace: stackTrace);

  static void error(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) =>
      instance.error(message, category: category, context: context, error: error, stackTrace: stackTrace);

  static void critical(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) =>
      instance.critical(message, category: category, context: context, error: error, stackTrace: stackTrace);

  /// Safe diagnostic helper: read the contents of the current log file.
  static Future<String?> readLog() async {
    if (_fileSink == null) return null;
    return await _fileSink!.readCurrentLog();
  }

  /// Safe diagnostic helper: clear the active log file and backups.
  static Future<void> clearLog() async {
    if (_fileSink != null) {
      await _fileSink!.clearLog();
    }
  }

  /// Safe diagnostic helper: retrieve the active log File instance.
  static Future<File?> getLogFile() async {
    if (_fileSink == null) return null;
    return await _fileSink!.getTargetFile();
  }

  /// Flush any pending log writes to disk.
  static Future<void> flush() async {
    await _instance?.flush();
  }

  /// Reset internal state (useful for test tear-downs).
  static void reset() {
    _instance = null;
    _fileSink = null;
    _config = const LoggingConfig();
  }
}
