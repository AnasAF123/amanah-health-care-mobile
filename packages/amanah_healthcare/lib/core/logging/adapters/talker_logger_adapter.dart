import 'package:talker/talker.dart' hide LogLevel;
import 'package:amanah_healthcare/core/logging/app_logger.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';

/// Adapter bridging our decoupled [AppLogger] contract with the [Talker] engine.
///
/// This satisfies the architectural requirement: features never depend on Talker directly,
/// but Talker can be plugged in as an infrastructure engine.
class TalkerLoggerAdapter implements AppLogger {
  TalkerLoggerAdapter({
    Talker? talker,
    AppLogger? delegate,
  })  : _talker = talker ?? Talker(),
        _delegate = delegate;

  final Talker _talker;
  final AppLogger? _delegate;

  Talker get talker => _talker;

  @override
  void trace(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
  }) {
    _talker.verbose('[$category] $message');
    _delegate?.trace(message, category: category, context: context);
  }

  @override
  void debug(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
  }) {
    _talker.debug('[$category] $message');
    _delegate?.debug(message, category: category, context: context);
  }

  @override
  void info(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
  }) {
    _talker.info('[$category] $message');
    _delegate?.info(message, category: category, context: context);
  }

  @override
  void warning(
    String message, {
    LogCategory category = LogCategory.system,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _talker.warning('[$category] $message', error, stackTrace);
    _delegate?.warning(
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
    _talker.error('[$category] $message', error, stackTrace);
    _delegate?.error(
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
    _talker.critical('[$category] $message', error, stackTrace);
    _delegate?.critical(
      message,
      category: category,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void logEvent(LogEvent event) {
    switch (event.level) {
      case LogLevel.trace:
        _talker.verbose(event.toLogLine());
        break;
      case LogLevel.debug:
        _talker.debug(event.toLogLine());
        break;
      case LogLevel.info:
        _talker.info(event.toLogLine());
        break;
      case LogLevel.warning:
        _talker.warning(event.toLogLine(), event.error, event.stackTrace);
        break;
      case LogLevel.error:
        _talker.error(event.toLogLine(), event.error, event.stackTrace);
        break;
      case LogLevel.critical:
        _talker.critical(event.toLogLine(), event.error, event.stackTrace);
        break;
    }
    _delegate?.logEvent(event);
  }

  @override
  Future<void> flush() async {
    await _delegate?.flush();
  }
}
