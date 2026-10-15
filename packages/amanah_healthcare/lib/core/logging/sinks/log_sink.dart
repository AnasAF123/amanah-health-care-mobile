import 'package:amanah_healthcare/core/logging/log_event.dart';

/// Contract for plug-and-play log destinations (file, console, memory, remote).
abstract interface class LogSink {
  /// Write a single event to this sink.
  void write(LogEvent event);

  /// Ensure all pending writes are persisted to disk / transport.
  Future<void> flush();

  /// Clean up resources held by the sink.
  Future<void> dispose();
}
