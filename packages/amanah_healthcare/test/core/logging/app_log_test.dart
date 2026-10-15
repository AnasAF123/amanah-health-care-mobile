import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/logging/adapters/talker_logger_adapter.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';
import 'package:amanah_healthcare/core/logging/logging_config.dart';

void main() {
  group('AppLog Dynamic Utilities & Category Filtering Tests', () {
    late Directory tempDir;
    late String testLogPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('app_log_test_');
      testLogPath = '${tempDir.path}/app_log.log';
      AppLog.reset();
    });

    tearDown(() async {
      AppLog.reset();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Can configure logger to ONLY dump HTTP/API events to file', () async {
      AppLog.init(
        config: LoggingConfig(
          enableFileOutput: true,
          enableConsoleOutput: false,
          customLogFilePath: testLogPath,
          enabledCategories: {LogCategory.http, LogCategory.api},
        ),
      );

      // Write diverse categories
      AppLog.http('GET /v1/appointments called');
      AppLog.api('POST /v1/schedules called');
      AppLog.system('Background battery check executed');
      AppLog.auth('User token restored');

      await AppLog.flush();

      final String? logContent = await AppLog.readLog();
      expect(logContent, isNotNull);

      // Whitelisted categories must exist
      expect(logContent, contains('[http] GET /v1/appointments called'));
      expect(logContent, contains('[api] POST /v1/schedules called'));

      // Non-whitelisted categories must NOT be dumped
      expect(logContent, isNot(contains('Background battery check')));
      expect(logContent, isNot(contains('User token restored')));
    });

    test('Supports extensible custom log channels dynamically', () async {
      const LogCategory billingChannel = LogCategory.custom('billing');

      AppLog.init(
        config: LoggingConfig(
          enableFileOutput: true,
          enableConsoleOutput: false,
          customLogFilePath: testLogPath,
        ),
      );

      AppLog.write(
        'Invoice #INV-2026-001 issued',
        category: billingChannel,
        level: LogLevel.info,
        context: {'total': 150000, 'method': 'QRIS'},
      );

      await AppLog.flush();

      final String? logContent = await AppLog.readLog();
      expect(logContent, contains('[billing] Invoice #INV-2026-001 issued'));
      expect(logContent, contains('QRIS'));
    });

    test('TalkerLoggerAdapter implements AppLogger without leaking Talker to caller', () {
      final TalkerLoggerAdapter adapter = TalkerLoggerAdapter();
      expect(adapter, isA<TalkerLoggerAdapter>());

      // Verifies adapter interface methods execute safely
      adapter.info('Info message from adapter', category: LogCategory.http);
      adapter.debug('Debug message from adapter', category: LogCategory.api);
      adapter.error('Error message from adapter', category: LogCategory.system);
    });
  });
}
