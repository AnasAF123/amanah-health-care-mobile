import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/logging/sinks/log_sink.dart';

/// Industrial-grade, asynchronous, rotating File Log Sink.
///
/// Dumps structured log events to a dedicated file without polluting
/// the application's standard console output (main stream).
class FileLogSink implements LogSink {
  FileLogSink({
    this.customFilePath,
    this.fileName = 'amanah_trace.log',
    this.maxFileSizeBytes = 2 * 1024 * 1024, // 2 MB
    this.maxBackupFiles = 3,
    this.asJsonLines = false,
  });

  final String? customFilePath;
  final String fileName;
  final int maxFileSizeBytes;
  final int maxBackupFiles;
  final bool asJsonLines;

  File? _file;
  bool _isDisposed = false;
  final List<String> _writeQueue = <String>[];
  bool _isFlushingQueue = false;

  /// Resolves the target log file.
  Future<File> getTargetFile() async {
    if (_file != null) return _file!;

    if (customFilePath != null && customFilePath!.isNotEmpty) {
      _file = File(customFilePath!);
    } else {
      try {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final Directory logDir = Directory('${appDocDir.path}/logs');
        if (!await logDir.exists()) {
          await logDir.create(recursive: true);
        }
        _file = File('${logDir.path}/$fileName');
      } catch (_) {
        // Fallback to system temporary directory if documents directory is unavailable
        final Directory tempDir = Directory.systemTemp;
        _file = File('${tempDir.path}/$fileName');
      }
    }

    if (!await _file!.exists()) {
      await _file!.create(recursive: true);
    }
    return _file!;
  }

  @override
  void write(LogEvent event) {
    if (_isDisposed) return;
    final String line = asJsonLines ? '${event.toJson()}\n' : '${event.toLogLine()}\n';
    _writeQueue.add(line);
    _scheduleQueueDrain();
  }

  void _scheduleQueueDrain() {
    if (_isFlushingQueue || _writeQueue.isEmpty) return;
    _isFlushingQueue = true;

    Future<void>.microtask(() async {
      await _drainQueue();
      _isFlushingQueue = false;
      if (_writeQueue.isNotEmpty) {
        _scheduleQueueDrain();
      }
    });
  }

  Future<void> _drainQueue() async {
    if (_writeQueue.isEmpty) return;

    try {
      final File target = await getTargetFile();
      await _rotateIfNecessary(target);

      final StringBuffer buffer = StringBuffer();
      while (_writeQueue.isNotEmpty) {
        buffer.write(_writeQueue.removeAt(0));
      }

      await target.writeAsString(
        buffer.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Passive safety: Logging errors must never crash the application.
    }
  }

  Future<void> _rotateIfNecessary(File file) async {
    try {
      if (!await file.exists()) return;
      final int size = await file.length();
      if (size < maxFileSizeBytes) return;

      // Perform log rotation: file.N -> file.(N+1)
      final String basePath = file.path;
      for (int i = maxBackupFiles - 1; i >= 1; i--) {
        final File current = File('$basePath.$i');
        final File next = File('$basePath.${i + 1}');
        if (await current.exists()) {
          if (i == maxBackupFiles - 1 && await next.exists()) {
            await next.delete();
          }
          await current.rename(next.path);
        }
      }

      final File backup1 = File('$basePath.1');
      if (await backup1.exists()) {
        await backup1.delete();
      }
      await file.rename(backup1.path);

      // Re-create active file
      _file = File(basePath);
      await _file!.create(recursive: true);
    } catch (_) {}
  }

  /// Read current contents of the active log file (safe diagnostic utility).
  Future<String?> readCurrentLog() async {
    try {
      await flush();
      final File target = await getTargetFile();
      if (await target.exists()) {
        return await target.readAsString();
      }
      return null;
    } catch (e) {
      return 'Error reading log file: $e';
    }
  }

  /// Clear active log file and any rotated backups.
  Future<void> clearLog() async {
    try {
      final File target = await getTargetFile();
      if (await target.exists()) {
        await target.writeAsString('', flush: true);
      }
      final String basePath = target.path;
      for (int i = 1; i <= maxBackupFiles; i++) {
        final File backup = File('$basePath.$i');
        if (await backup.exists()) {
          await backup.delete();
        }
      }
    } catch (_) {}
  }

  /// Current log file size in bytes.
  Future<int> getLogSizeBytes() async {
    try {
      final File target = await getTargetFile();
      if (await target.exists()) {
        return await target.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> flush() async {
    while (_writeQueue.isNotEmpty) {
      await _drainQueue();
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    await flush();
    _file = null;
  }
}
