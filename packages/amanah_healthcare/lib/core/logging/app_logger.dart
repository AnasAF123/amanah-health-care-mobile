import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';

/// Application-owned logging contract.
///
/// Features and domain layers depend solely on this contract,
/// keeping them decoupled from underlying logging frameworks or sinks.
abstract interface class AppLogger {
  void trace(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
  });

  void debug(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
  });

  void info(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
  });

  void warning(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  });

  void error(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  });

  void critical(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Submit a pre-structured LogEvent.
  void logEvent(LogEvent event);

  /// Flushes all active sinks.
  Future<void> flush();
}
