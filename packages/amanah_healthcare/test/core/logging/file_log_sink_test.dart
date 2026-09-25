import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';
import 'package:amanah_healthcare/core/logging/sinks/file_log_sink.dart';

void main() {
  group('FileLogSink Tests', () {
    late Directory tempDir;
    late String testLogPath;
    late FileLogSink sink;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('amanah_log_test_');
      testLogPath = '${tempDir.path}/test_trace.log';
      sink = FileLogSink(
        customFilePath: testLogPath,
        maxFileSizeBytes: 500, // Small size to test rotation
        maxBackupFiles: 2,
      );
    });

    tearDown(() async {
      await sink.dispose();
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {}
    });

    test('Dumps log events directly to the specified log file', () async {
      final LogEvent event = LogEvent(
        message: 'Doctor schedule created',
        level: LogLevel.info,
        category: LogCategory.http,
        context: {'scheduleId': 'sched_123', 'status': 'OPEN'},
      );

      sink.write(event);
      await sink.flush();

      final File logFile = File(testLogPath);
      expect(await logFile.exists(), isTrue);

      final String content = await logFile.readAsString();
      expect(content, contains('[INFO]'));
      expect(content, contains('[http]'));
      expect(content, contains('Doctor schedule created'));
      expect(content, contains('sched_123'));
    });

    test('Rotating file policy creates backup files when size threshold exceeded', () async {
      // 1. Write initial batch to exceed 500 bytes and flush
      for (int i = 0; i < 10; i++) {
        sink.write(
          LogEvent(
            message: 'Long message line $i with sufficient padding bytes 1234567890 1234567890',
            level: LogLevel.info,
            category: LogCategory.api,
          ),
        );
      }
      await sink.flush();

      // 2. Subsequent write triggers rotation
      sink.write(
        LogEvent(
          message: 'Trigger rotation write event',
          level: LogLevel.info,
          category: LogCategory.api,
        ),
      );
      await sink.flush();

      final File activeFile = File(testLogPath);
      final File backup1 = File('$testLogPath.1');

      expect(await activeFile.exists(), isTrue);
      expect(await backup1.exists(), isTrue);
    });

    test('clearLog purges the active log file', () async {
      sink.write(
        LogEvent(
          message: 'Initial log entry',
          level: LogLevel.info,
        ),
      );
      await sink.flush();

      expect(await sink.readCurrentLog(), contains('Initial log entry'));

      await sink.clearLog();
      final String? cleared = await sink.readCurrentLog();
      expect(cleared, isEmpty);
    });
  });
}
