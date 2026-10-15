import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amanah_healthcare/core/logging/app_logger.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/network/client/observable_http_client.dart';
import 'package:amanah_healthcare/core/network/observability/http_observability_config.dart';

class _CapturingLogger implements AppLogger {
  final List<LogEvent> events = <LogEvent>[];

  @override
  void logEvent(LogEvent event) {
    events.add(event);
  }

  @override
  void trace(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context}) {}
  @override
  void debug(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context}) {}
  @override
  void info(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context}) {}
  @override
  void warning(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {}
  @override
  void critical(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {}
  @override
  Future<void> flush() async {}
}

class _FailingLogger implements AppLogger {
  @override
  void logEvent(LogEvent event) {
    throw StateError('Simulated unexpected logger crash');
  }

  @override
  void trace(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context}) {}
  @override
  void debug(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context}) {}
  @override
  void info(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context}) {}
  @override
  void warning(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {}
  @override
  void critical(String message, {LogCategory category = LogCategory.system, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {}
  @override
  Future<void> flush() async {}
}

void main() {
  group('ObservableHttpClient Lifecycle & Correlation Tracing Tests', () {
    late _CapturingLogger logger;

    setUp(() {
      logger = _CapturingLogger();
    });

    test('Correlates request and response with identical requestId and captures duration', () async {
      final MockClient innerClient = MockClient((http.Request request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'success': true,
            'data': {'id': 'sched_999'},
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final ObservableHttpClient client = ObservableHttpClient(
        innerClient: innerClient,
        logger: logger,
      );

      final http.Response response = await client.post(
        Uri.parse('http://api.amanah.id/v1/schedules?doctor=dr_ahmad'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer secret-jwt-token-xyz',
        },
        body: jsonEncode({
          'session': 'PAGI',
          'password': 'ShouldBeRedacted123',
        }),
      );

      expect(response.statusCode, 201);
      expect(logger.events.length, 2);

      final LogEvent reqEvent = logger.events[0];
      final LogEvent resEvent = logger.events[1];

      // Request Trace assertions
      expect(reqEvent.context?['event'], 'http.request');
      final String requestId = reqEvent.context?['requestId'] as String;
      expect(requestId, isNotEmpty);
      expect(reqEvent.context?['method'], 'POST');
      expect(reqEvent.context?['path'], '/v1/schedules');
      expect(reqEvent.context?['query']['doctor'], 'dr_ahmad');

      // Security Redaction assertions
      expect(reqEvent.context?['headers']['Authorization'], 'Bearer [REDACTED]');
      expect(reqEvent.context?['body']['password'], '[REDACTED]');
      expect(reqEvent.context?['body']['session'], 'PAGI');

      // Response Trace assertions (correlated to same requestId)
      expect(resEvent.context?['event'], 'http.response');
      expect(resEvent.context?['requestId'], requestId);
      expect(resEvent.context?['statusCode'], 201);
      expect(resEvent.context?['durationMs'], isNotNull);
      expect(resEvent.context?['body']['success'], true);
    });

    test('Captures error trace with classified errorType and preserves correlation ID on failure', () async {
      final MockClient innerClient = MockClient((http.Request request) async {
        throw http.ClientException('Connection refused by server');
      });

      final ObservableHttpClient client = ObservableHttpClient(
        innerClient: innerClient,
        logger: logger,
      );

      try {
        await client.get(Uri.parse('http://api.amanah.id/v1/ping'));
        fail('Expected ClientException');
      } on http.ClientException {
        // Expected
      }

      expect(logger.events.length, 2);
      final LogEvent reqEvent = logger.events[0];
      final LogEvent errEvent = logger.events[1];

      final String reqId = reqEvent.context?['requestId'] as String;
      expect(errEvent.context?['event'], 'http.error');
      expect(errEvent.context?['requestId'], reqId);
      expect(errEvent.context?['errorType'], 'connectionError');
      expect(errEvent.context?['message'], contains('Connection refused'));
    });

    test('Multipart request logs file metadata without leaking binary bytes', () async {
      final MockClient innerClient = MockClient((http.BaseRequest request) async {
        return http.Response('{"ok": true}', 200, headers: {'content-type': 'application/json'});
      });

      final ObservableHttpClient client = ObservableHttpClient(
        innerClient: innerClient,
        logger: logger,
      );

      final http.MultipartRequest multipartReq = http.MultipartRequest(
        'POST',
        Uri.parse('http://api.amanah.id/v1/avatar'),
      );
      multipartReq.fields['title'] = 'Profile Photo';
      multipartReq.files.add(
        http.MultipartFile.fromBytes(
          'file',
          <int>[0x00, 0x01, 0x02, 0xFF],
          filename: 'avatar.png',
        ),
      );

      final http.StreamedResponse streamed = await client.send(multipartReq);
      final http.Response res = await http.Response.fromStream(streamed);

      expect(res.statusCode, 200);
      final LogEvent reqEvent = logger.events[0];
      final dynamic body = reqEvent.context?['body'];

      expect(body['fields']['title'], 'Profile Photo');
      expect(body['files'], isA<List>());
      expect(body['files'][0]['filename'], 'avatar.png');
      expect(body['files'][0]['sizeBytes'], 4);
    });

    test('Error Safety: Logging failures NEVER break the HTTP request', () async {
      final MockClient innerClient = MockClient((http.Request request) async {
        return http.Response('{"status": "ok"}', 200);
      });

      // Inject a logger that throws violently on every call
      final ObservableHttpClient client = ObservableHttpClient(
        innerClient: innerClient,
        logger: _FailingLogger(),
      );

      // The HTTP call must still succeed normally!
      final http.Response response = await client.get(Uri.parse('http://api.amanah.id/health'));
      expect(response.statusCode, 200);
      expect(response.body, '{"status": "ok"}');
    });

    test('Disabled config bypasses logging completely', () async {
      final MockClient innerClient = MockClient((http.Request request) async {
        return http.Response('{"active": true}', 200);
      });

      final ObservableHttpClient client = ObservableHttpClient(
        innerClient: innerClient,
        logger: logger,
        config: const HttpObservabilityConfig(enabled: false),
      );

      final http.Response response = await client.get(Uri.parse('http://api.amanah.id/health'));
      expect(response.statusCode, 200);
      expect(logger.events, isEmpty);
    });
  });
}
