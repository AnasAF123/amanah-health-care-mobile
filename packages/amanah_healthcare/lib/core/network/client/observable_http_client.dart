import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/logging/app_logger.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';
import 'package:amanah_healthcare/core/network/observability/http_log_sanitizer.dart';
import 'package:amanah_healthcare/core/network/observability/http_observability_config.dart';
import 'package:amanah_healthcare/core/network/observability/http_trace_factory.dart';

/// Transparent, observable wrapper around any [http.Client].
///
/// Attaches correlation identifiers, measures latency, captures request,
/// response, and error events passively, and routes them to [AppLogger].
class ObservableHttpClient extends http.BaseClient {
  ObservableHttpClient({
    http.Client? innerClient,
    AppLogger? logger,
    HttpObservabilityConfig? config,
    HttpTraceFactory? traceFactory,
    HttpLogSanitizer? sanitizer,
  })  : _inner = innerClient ?? http.Client(),
        _logger = logger ?? AppLog.instance,
        _config = config ?? const HttpObservabilityConfig(),
        _sanitizer = sanitizer ?? HttpLogSanitizer(),
        _traceFactory = traceFactory ??
            HttpTraceFactory(
              config: config,
              sanitizer: sanitizer,
            );

  final http.Client _inner;
  final AppLogger _logger;
  final HttpObservabilityConfig _config;
  final HttpLogSanitizer _sanitizer;
  final HttpTraceFactory _traceFactory;

  http.Client get innerClient => _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!_config.enabled) {
      return _inner.send(request);
    }

    // 1. Resolve or attach correlation Request ID
    String requestId = request.headers[_config.requestIdHeader] ??
        request.headers[_config.correlationIdHeader] ??
        '';

    if (requestId.isEmpty) {
      requestId = _traceFactory.generateRequestId();
      request.headers[_config.requestIdHeader] = requestId;
    }

    // 2. Extract request body safely
    dynamic requestPayload;
    String? bodyType;
    int? requestSize = request.contentLength;

    if (request is http.Request) {
      bodyType = 'raw';
      if (_config.logRequestBody) {
        requestPayload = request.body;
      }
    } else if (request is http.MultipartRequest) {
      bodyType = 'multipart/form-data';
      if (_config.logRequestBody) {
        final List<Map<String, dynamic>> filesSummary =
            _sanitizer.sanitizeMultipartFiles(
          request.files
              .map(
                (http.MultipartFile f) => (
                  field: f.field,
                  filename: f.filename,
                  contentType: f.contentType.toString(),
                  length: f.length,
                ),
              )
              .toList(),
        );

        requestPayload = <String, dynamic>{
          'fields': request.fields,
          'files': filesSummary,
        };
      }
    } else {
      bodyType = 'streamed';
    }

    // 3. Emit Request Trace
    try {
      final reqTrace = _traceFactory.createRequestTrace(
        requestId: requestId,
        method: request.method,
        uri: request.url,
        headers: request.headers,
        body: requestPayload,
        bodyType: bodyType,
        requestSizeBytes: requestSize,
      );

      _logger.logEvent(
        LogEvent(
          message: 'HTTP Request [${reqTrace.requestId}] ${reqTrace.method} ${reqTrace.path}',
          level: LogLevel.info,
          category: _config.category,
          context: reqTrace.toJson(),
        ),
      );
    } catch (_) {
      // Passive safety: Logging must never abort the request.
    }

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final http.StreamedResponse response = await _inner.send(request);
      stopwatch.stop();

      final String? contentType = response.headers['content-type'];
      final bool isTextual = contentType == null ||
          contentType.contains('application/json') ||
          contentType.contains('text/') ||
          contentType.contains('application/xml');

      // If response body inspection is disabled or content is binary/streaming, forward directly
      if (!_config.logResponseBody || !isTextual || response.contentLength != null && response.contentLength! > _config.maxBodyCharacters * 2) {
        _logResponseSafely(
          requestId: requestId,
          method: request.method,
          url: request.url,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          headers: response.headers,
          body: isTextual ? '<response body omitted>' : '[BINARY STREAM]',
          contentType: contentType,
          responseSizeBytes: response.contentLength,
        );
        return response;
      }

      // Buffer stream to inspect response body without consuming it for caller
      final List<int> bytes = await response.stream.toBytes();
      final String responseBody = utf8.decode(bytes, allowMalformed: true);

      _logResponseSafely(
        requestId: requestId,
        method: request.method,
        url: request.url,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        headers: response.headers,
        body: responseBody,
        contentType: contentType,
        responseSizeBytes: bytes.length,
      );

      // Recreate identical StreamedResponse for caller
      return http.StreamedResponse(
        http.ByteStream.fromBytes(bytes),
        response.statusCode,
        contentLength: bytes.length,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (error, stackTrace) {
      stopwatch.stop();

      try {
        final errTrace = _traceFactory.createErrorTrace(
          requestId: requestId,
          method: request.method,
          uri: request.url,
          error: error,
          duration: stopwatch.elapsed,
          requestBody: requestPayload,
          stackTrace: stackTrace,
        );

        _logger.logEvent(
          LogEvent(
            message: 'HTTP Error [${errTrace.requestId}] ${errTrace.method} ${errTrace.url} (${errTrace.errorType})',
            level: LogLevel.error,
            category: _config.category,
            context: errTrace.toJson(),
            error: error,
            stackTrace: stackTrace,
          ),
        );
      } catch (_) {}

      rethrow;
    }
  }

  void _logResponseSafely({
    required String requestId,
    required String method,
    required Uri url,
    required int statusCode,
    required Duration duration,
    required Map<String, String> headers,
    dynamic body,
    String? contentType,
    int? responseSizeBytes,
  }) {
    try {
      final resTrace = _traceFactory.createResponseTrace(
        requestId: requestId,
        method: method,
        uri: url,
        statusCode: statusCode,
        duration: duration,
        headers: headers,
        body: body,
        contentType: contentType,
        responseSizeBytes: responseSizeBytes,
      );

      final LogLevel level = statusCode >= 400 ? LogLevel.warning : LogLevel.info;

      _logger.logEvent(
        LogEvent(
          message: 'HTTP Response [${resTrace.requestId}] ${resTrace.method} ${resTrace.url} -> $statusCode (${resTrace.durationMs}ms)',
          level: level,
          category: _config.category,
          context: resTrace.toJson(),
        ),
      );
    } catch (_) {}
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
