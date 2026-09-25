import 'dart:convert';

/// Sealed class hierarchy representing structured HTTP network trace events.
sealed class HttpTraceEvent {
  const HttpTraceEvent({
    required this.event,
    required this.requestId,
    required this.method,
    required this.url,
    required this.timestamp,
  });

  final String event;
  final String requestId;
  final String method;
  final String url;
  final DateTime timestamp;

  Map<String, dynamic> toJson();
}

/// Outbound HTTP request trace.
class HttpRequestTrace extends HttpTraceEvent {
  const HttpRequestTrace({
    required super.requestId,
    required super.method,
    required super.url,
    required this.path,
    required this.query,
    required this.headers,
    this.body,
    this.bodyType,
    this.requestSizeBytes,
    required super.timestamp,
  }) : super(event: 'http.request');

  final String path;
  final Map<String, dynamic> query;
  final Map<String, String> headers;
  final dynamic body;
  final String? bodyType;
  final int? requestSizeBytes;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'event': event,
      'requestId': requestId,
      'method': method,
      'url': url,
      'path': path,
      'query': query,
      'headers': headers,
      if (body != null) 'body': body,
      if (bodyType != null) 'bodyType': bodyType,
      if (requestSizeBytes != null) 'requestSizeBytes': requestSizeBytes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    try {
      return jsonEncode(toJson());
    } catch (_) {
      return 'HttpRequestTrace($requestId $method $url)';
    }
  }
}

/// Inbound HTTP response trace.
class HttpResponseTrace extends HttpTraceEvent {
  const HttpResponseTrace({
    required super.requestId,
    required super.method,
    required super.url,
    required this.statusCode,
    required this.durationMs,
    required this.headers,
    this.body,
    this.responseContentType,
    this.responseSizeBytes,
    required super.timestamp,
  }) : super(event: 'http.response');

  final int statusCode;
  final int durationMs;
  final Map<String, String> headers;
  final dynamic body;
  final String? responseContentType;
  final int? responseSizeBytes;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'event': event,
      'requestId': requestId,
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'durationMs': durationMs,
      'headers': headers,
      if (body != null) 'body': body,
      if (responseContentType != null) 'responseContentType': responseContentType,
      if (responseSizeBytes != null) 'responseSizeBytes': responseSizeBytes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    try {
      return jsonEncode(toJson());
    } catch (_) {
      return 'HttpResponseTrace($requestId $method $statusCode ${durationMs}ms)';
    }
  }
}

/// HTTP error or transport failure trace.
class HttpErrorTrace extends HttpTraceEvent {
  const HttpErrorTrace({
    required super.requestId,
    required super.method,
    required super.url,
    this.durationMs,
    this.statusCode,
    required this.errorType,
    required this.message,
    this.requestBody,
    this.responseBody,
    this.rawError,
    this.stackTrace,
    required super.timestamp,
  }) : super(event: 'http.error');

  final int? durationMs;
  final int? statusCode;
  final String errorType;
  final String message;
  final dynamic requestBody;
  final dynamic responseBody;
  final Object? rawError;
  final StackTrace? stackTrace;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'event': event,
      'requestId': requestId,
      'method': method,
      'url': url,
      if (statusCode != null) 'statusCode': statusCode,
      if (durationMs != null) 'durationMs': durationMs,
      'errorType': errorType,
      'message': message,
      if (requestBody != null) 'requestBody': requestBody,
      if (responseBody != null) 'responseBody': responseBody,
      if (rawError != null) 'rawError': rawError.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    try {
      return jsonEncode(toJson());
    } catch (_) {
      return 'HttpErrorTrace($requestId $method $statusCode $errorType)';
    }
  }
}
