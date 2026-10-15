import 'dart:io';
import 'package:amanah_healthcare/core/network/observability/http_log_sanitizer.dart';
import 'package:amanah_healthcare/core/network/observability/http_observability_config.dart';
import 'package:amanah_healthcare/core/network/observability/http_trace_event.dart';

/// Factory transforming transport objects into typed [HttpTraceEvent] records.
class HttpTraceFactory {
  HttpTraceFactory({
    HttpLogSanitizer? sanitizer,
    HttpObservabilityConfig? config,
  })  : _sanitizer = sanitizer ?? HttpLogSanitizer(),
        _config = config ?? const HttpObservabilityConfig();

  final HttpLogSanitizer _sanitizer;
  final HttpObservabilityConfig _config;

  static int _idCounter = 0;

  /// Generates a unique correlation request identifier.
  String generateRequestId() {
    _idCounter++;
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'req_${timestamp}_$_idCounter';
  }

  /// Builds an [HttpRequestTrace] from raw request components.
  HttpRequestTrace createRequestTrace({
    required String requestId,
    required String method,
    required Uri uri,
    Map<String, dynamic>? headers,
    dynamic body,
    String? bodyType,
    int? requestSizeBytes,
    DateTime? timestamp,
  }) {
    final Map<String, String> sanitizedHeaders = _config.logHeaders
        ? _sanitizer.sanitizeHeaders(headers)
        : <String, String>{'note': '<headers omitted by config>'};

    final dynamic sanitizedBody = _config.logRequestBody
        ? _sanitizer.sanitizeBody(body, contentType: headers?['content-type']?.toString())
        : '<body omitted by config>';

    return HttpRequestTrace(
      requestId: requestId,
      method: method.toUpperCase(),
      url: uri.toString(),
      path: uri.path.isEmpty ? '/' : uri.path,
      query: uri.queryParameters,
      headers: sanitizedHeaders,
      body: sanitizedBody,
      bodyType: bodyType,
      requestSizeBytes: requestSizeBytes,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Builds an [HttpResponseTrace] from raw response components.
  HttpResponseTrace createResponseTrace({
    required String requestId,
    required String method,
    required Uri uri,
    required int statusCode,
    required Duration duration,
    Map<String, dynamic>? headers,
    dynamic body,
    String? contentType,
    int? responseSizeBytes,
    DateTime? timestamp,
  }) {
    final Map<String, String> sanitizedHeaders = _config.logHeaders
        ? _sanitizer.sanitizeHeaders(headers)
        : <String, String>{'note': '<headers omitted by config>'};

    final dynamic sanitizedBody = _config.logResponseBody
        ? _sanitizer.sanitizeBody(body, contentType: contentType)
        : '<body omitted by config>';

    return HttpResponseTrace(
      requestId: requestId,
      method: method.toUpperCase(),
      url: uri.toString(),
      statusCode: statusCode,
      durationMs: duration.inMilliseconds,
      headers: sanitizedHeaders,
      body: sanitizedBody,
      responseContentType: contentType,
      responseSizeBytes: responseSizeBytes,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Builds an [HttpErrorTrace] from an caught error or failure response.
  HttpErrorTrace createErrorTrace({
    required String requestId,
    required String method,
    required Uri uri,
    required Object error,
    Duration? duration,
    int? statusCode,
    dynamic requestBody,
    dynamic responseBody,
    StackTrace? stackTrace,
    DateTime? timestamp,
  }) {
    final String errorType = classifyErrorType(error, statusCode);
    final String message = error.toString();

    final dynamic sanitizedReqBody = _config.logRequestBody
        ? _sanitizer.sanitizeBody(requestBody)
        : '<request body omitted>';

    final dynamic sanitizedResBody = _config.logResponseBody
        ? _sanitizer.sanitizeBody(responseBody)
        : '<response body omitted>';

    return HttpErrorTrace(
      requestId: requestId,
      method: method.toUpperCase(),
      url: uri.toString(),
      durationMs: duration?.inMilliseconds,
      statusCode: statusCode,
      errorType: errorType,
      message: message,
      requestBody: sanitizedReqBody,
      responseBody: sanitizedResBody,
      rawError: error,
      stackTrace: stackTrace,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Classifies an error into a standardized taxonomy identifier.
  String classifyErrorType(Object error, int? statusCode) {
    if (statusCode != null) {
      if (statusCode == 401) return 'unauthorized';
      if (statusCode == 403) return 'forbidden';
      if (statusCode == 404) return 'notFound';
      if (statusCode == 409) return 'conflict';
      if (statusCode == 422) return 'unprocessableEntity';
      if (statusCode >= 500) return 'serverError';
      if (statusCode >= 400) return 'badRequest';
    }

    final String errStr = error.toString().toLowerCase();

    if (error is SocketException ||
        errStr.contains('socketexception') ||
        errStr.contains('connection refused') ||
        errStr.contains('failed host lookup')) {
      return 'connectionError';
    }

    if (errStr.contains('timeout') || errStr.contains('timed out')) {
      return 'timeout';
    }

    if (error is FormatException || errStr.contains('formatexception')) {
      return 'badResponseParsing';
    }

    if (errStr.contains('cancel')) {
      return 'cancelled';
    }

    if (errStr.contains('certificate') || errStr.contains('handshake')) {
      return 'badCertificate';
    }

    return 'unknownTransportError';
  }
}
