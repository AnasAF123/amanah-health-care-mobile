import 'package:dio/dio.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/logging/app_logger.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';
import 'package:amanah_healthcare/core/network/observability/http_observability_config.dart';
import 'package:amanah_healthcare/core/network/observability/http_trace_factory.dart';

/// Dio transport interceptor for HTTP observability and network tracing.
///
/// Passive, non-mutating observer that maps request lifecycle events to [AppLogger].
class HttpObservabilityInterceptor extends Interceptor {
  HttpObservabilityInterceptor({
    AppLogger? logger,
    HttpObservabilityConfig? config,
    HttpTraceFactory? traceFactory,
  })  : _logger = logger ?? AppLog.instance,
        _config = config ?? const HttpObservabilityConfig(),
        _traceFactory = traceFactory ?? HttpTraceFactory(config: config);

  final AppLogger _logger;
  final HttpObservabilityConfig _config;
  final HttpTraceFactory _traceFactory;

  static const String _kStopwatchKey = '_amanah_stopwatch';
  static const String _kRequestIdKey = '_amanah_request_id';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_config.enabled) {
      return handler.next(options);
    }

    String requestId = options.headers[_config.requestIdHeader]?.toString() ??
        options.headers[_config.correlationIdHeader]?.toString() ??
        '';

    if (requestId.isEmpty) {
      requestId = _traceFactory.generateRequestId();
      options.headers[_config.requestIdHeader] = requestId;
    }

    final Stopwatch stopwatch = Stopwatch()..start();
    options.extra[_kStopwatchKey] = stopwatch;
    options.extra[_kRequestIdKey] = requestId;

    try {
      final reqTrace = _traceFactory.createRequestTrace(
        requestId: requestId,
        method: options.method,
        uri: options.uri,
        headers: options.headers,
        body: options.data,
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
      // Passive safety guarantee
    }

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (!_config.enabled) {
      return handler.next(response);
    }

    final Stopwatch? stopwatch = response.requestOptions.extra[_kStopwatchKey] as Stopwatch?;
    stopwatch?.stop();
    final Duration elapsed = stopwatch?.elapsed ?? Duration.zero;

    final String requestId = response.requestOptions.extra[_kRequestIdKey]?.toString() ??
        response.requestOptions.headers[_config.requestIdHeader]?.toString() ??
        'req_unknown';

    try {
      final resTrace = _traceFactory.createResponseTrace(
        requestId: requestId,
        method: response.requestOptions.method,
        uri: response.requestOptions.uri,
        statusCode: response.statusCode ?? 0,
        duration: elapsed,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.join(', '))),
        body: response.data,
      );

      final LogLevel level = (response.statusCode ?? 200) >= 400 ? LogLevel.warning : LogLevel.info;

      _logger.logEvent(
        LogEvent(
          message: 'HTTP Response [${resTrace.requestId}] ${resTrace.method} ${resTrace.url} -> ${resTrace.statusCode} (${resTrace.durationMs}ms)',
          level: level,
          category: _config.category,
          context: resTrace.toJson(),
        ),
      );
    } catch (_) {}

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_config.enabled) {
      return handler.next(err);
    }

    final Stopwatch? stopwatch = err.requestOptions.extra[_kStopwatchKey] as Stopwatch?;
    stopwatch?.stop();
    final Duration elapsed = stopwatch?.elapsed ?? Duration.zero;

    final String requestId = err.requestOptions.extra[_kRequestIdKey]?.toString() ??
        err.requestOptions.headers[_config.requestIdHeader]?.toString() ??
        'req_unknown';

    try {
      final errTrace = _traceFactory.createErrorTrace(
        requestId: requestId,
        method: err.requestOptions.method,
        uri: err.requestOptions.uri,
        error: err,
        statusCode: err.response?.statusCode,
        duration: elapsed,
        requestBody: err.requestOptions.data,
        responseBody: err.response?.data,
        stackTrace: err.stackTrace,
      );

      _logger.logEvent(
        LogEvent(
          message: 'HTTP Error [${errTrace.requestId}] ${errTrace.method} ${errTrace.url} (${errTrace.errorType})',
          level: LogLevel.error,
          category: _config.category,
          context: errTrace.toJson(),
          error: err,
          stackTrace: err.stackTrace,
        ),
      );
    } catch (_) {}

    handler.next(err);
  }
}
