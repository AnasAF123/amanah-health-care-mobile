import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:amanah_healthcare/core/logging/app_logger.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/network/interceptors/http_observability_interceptor.dart';

class _DioCapturingLogger implements AppLogger {
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

void main() {
  group('HttpObservabilityInterceptor (Dio) Tests', () {
    late _DioCapturingLogger logger;
    late Dio dio;

    setUp(() {
      logger = _DioCapturingLogger();
      dio = Dio(
        BaseOptions(
          baseUrl: 'http://test.amanah.internal',
          connectTimeout: const Duration(seconds: 1),
        ),
      );
      dio.interceptors.add(
        HttpObservabilityInterceptor(logger: logger),
      );
    });

    test('Intercepts Dio request and response with matching correlation ID', () async {
      // Mock Dio adapter
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '{"status":"ok","code":200}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final Response res = await dio.post(
        '/api/v1/auth/login',
        data: {'email': 'doc@amanah.id', 'password': 'super-secret-password'},
        options: Options(
          headers: {'Authorization': 'Bearer access-token-abc'},
        ),
      );

      expect(res.statusCode, 200);
      expect(logger.events.length, 2);

      final LogEvent req = logger.events[0];
      final LogEvent resp = logger.events[1];

      expect(req.context?['event'], 'http.request');
      final String reqId = req.context?['requestId'] as String;
      expect(reqId, isNotEmpty);
      expect(req.context?['headers']['Authorization'], 'Bearer [REDACTED]');
      expect(req.context?['body']['password'], '[REDACTED]');

      expect(resp.context?['event'], 'http.response');
      expect(resp.context?['requestId'], reqId);
      expect(resp.context?['statusCode'], 200);
      expect(resp.context?['durationMs'], isNotNull);
    });

    test('Intercepts Dio error and preserves correlation ID', () async {
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '{"message":"Doctor schedule conflict"}',
          409,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      try {
        await dio.get('/api/v1/schedules/conflict');
        fail('Expected DioException');
      } on DioException {
        // Expected
      }

      expect(logger.events.length, 2);
      final LogEvent req = logger.events[0];
      final LogEvent err = logger.events[1];

      final String reqId = req.context?['requestId'] as String;
      expect(err.context?['event'], 'http.error');
      expect(err.context?['requestId'], reqId);
      expect(err.context?['statusCode'], 409);
      expect(err.context?['errorType'], 'conflict');
    });
  });
}

class _MockHttpClientAdapter implements HttpClientAdapter {
  _MockHttpClientAdapter(this._handler);
  final ResponseBody Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
