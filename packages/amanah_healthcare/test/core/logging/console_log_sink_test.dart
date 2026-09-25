import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';
import 'package:amanah_healthcare/core/logging/sinks/console_log_sink.dart';

void main() {
  group('ConsoleLogSink Pretty Formatter Tests', () {
    const ConsoleLogSink sink = ConsoleLogSink();

    test('Formats HTTP Request with clean box and filtered headers', () {
      final LogEvent event = LogEvent(
        message: 'HTTP Request [req_123] GET /api/v1/schedules/my-schedules',
        level: LogLevel.info,
        category: LogCategory.http,
        context: <String, dynamic>{
          'event': 'http.request',
          'requestId': 'req_123',
          'method': 'GET',
          'url': 'http://10.0.2.2:3001/api/v1/schedules/my-schedules?date=2026-09-25',
          'headers': <String, dynamic>{
            'Authorization': '[REDACTED]',
            'Accept': 'application/json',
            'x-dns-prefetch-control': 'off',
            'strict-transport-security': 'max-age=31536000',
          },
        },
      );

      final String pretty = sink.formatPretty(event);
      expect(pretty, contains('┌── 🌐 [HTTP REQUEST] GET'));
      expect(pretty, contains('│ Request ID : req_123'));
      expect(pretty, contains('Authorization: [REDACTED]'));
      expect(pretty, contains('Accept: application/json'));
      // Noisy headers filtered out:
      expect(pretty, isNot(contains('x-dns-prefetch-control')));
      expect(pretty, contains('└───────────'));
    });

    test('Formats HTTP Response with pretty indented JSON body', () {
      final LogEvent event = LogEvent(
        message: 'HTTP Response [req_123] GET ... -> 200 (106ms)',
        level: LogLevel.info,
        category: LogCategory.http,
        context: <String, dynamic>{
          'event': 'http.response',
          'requestId': 'req_123',
          'method': 'GET',
          'url': 'http://10.0.2.2:3001/api/v1/schedules/my-schedules',
          'statusCode': 200,
          'durationMs': 106,
          'body': '[{"id":"ses_1","session":"PAGI"}]',
        },
      );

      final String pretty = sink.formatPretty(event);
      expect(pretty, contains('┌── ✅ [HTTP RESPONSE] 200 (106ms)'));
      expect(pretty, contains('│ Request ID : req_123'));
      expect(pretty, contains('│ Body:'));
      expect(pretty, contains('│   ['));
      expect(pretty, contains('│     {'));
      expect(pretty, contains('│       "id": "ses_1"'));
      expect(pretty, contains('└───────────'));
    });
  });
}
