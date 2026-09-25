import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_event.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';
import 'package:amanah_healthcare/core/logging/sinks/log_sink.dart';

/// Console log sink with rich, human-readable pretty formatting for development.
class ConsoleLogSink implements LogSink {
  const ConsoleLogSink({
    this.useDeveloperLog = true,
    this.useDebugPrint = true,
    this.prettyPrint = true,
  });

  final bool useDeveloperLog;
  final bool useDebugPrint;
  final bool prettyPrint;

  @override
  void write(LogEvent event) {
    if (useDeveloperLog) {
      developer.log(
        event.message,
        name: event.category.name,
        level: _toDeveloperLogLevel(event.level),
        error: event.error,
        stackTrace: event.stackTrace,
        time: event.timestamp,
      );
    }

    if (useDebugPrint) {
      final String text = prettyPrint ? formatPretty(event) : event.toLogLine();
      debugPrint(text);
    }
  }

  /// Formats log events into clean, readable ASCII boxes with indented JSON.
  String formatPretty(LogEvent event) {
    if (event.category == LogCategory.http ||
        (event.context != null && event.context!['event'] != null)) {
      final String? eventType = event.context?['event'] as String?;
      if (eventType == 'http.request') {
        return _formatHttpRequest(event);
      } else if (eventType == 'http.response') {
        return _formatHttpResponse(event);
      } else if (eventType == 'http.error') {
        return _formatHttpError(event);
      }
    }

    return _formatGenericEvent(event);
  }

  String _formatHttpRequest(LogEvent event) {
    final Map<String, dynamic> ctx = event.context ?? <String, dynamic>{};
    final String method = (ctx['method'] as String? ?? 'HTTP').toUpperCase();
    final String url = ctx['url'] as String? ?? ctx['path'] as String? ?? event.message;
    final String requestId = ctx['requestId'] as String? ?? event.id;
    final dynamic body = ctx['body'];
    final dynamic headers = ctx['headers'];

    final StringBuffer sb = StringBuffer();
    sb.writeln('┌── 🌐 [HTTP REQUEST] $method $url ──────────────────────────');
    sb.writeln('│ Request ID : $requestId');

    if (headers is Map && headers.isNotEmpty) {
      final Map<String, dynamic> filteredHeaders = _filterUsefulHeaders(headers);
      if (filteredHeaders.isNotEmpty) {
        final String headerSummary = filteredHeaders.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(' | ');
        sb.writeln('│ Headers    : $headerSummary');
      }
    }

    final String? formattedBody = _formatBody(body);
    if (formattedBody != null && formattedBody.isNotEmpty) {
      sb.writeln('│ Body:');
      for (final String line in formattedBody.split('\n')) {
        sb.writeln('│   $line');
      }
    }
    sb.write('└─────────────────────────────────────────────────────────────');
    return sb.toString();
  }

  String _formatHttpResponse(LogEvent event) {
    final Map<String, dynamic> ctx = event.context ?? <String, dynamic>{};
    final String method = (ctx['method'] as String? ?? '').toUpperCase();
    final String url = ctx['url'] as String? ?? event.message;
    final int statusCode = ctx['statusCode'] as int? ?? 200;
    final int durationMs = ctx['durationMs'] as int? ?? 0;
    final String requestId = ctx['requestId'] as String? ?? event.id;
    final dynamic body = ctx['body'];

    final String icon = statusCode >= 200 && statusCode < 300
        ? '✅'
        : (statusCode >= 400 && statusCode < 500 ? '⚠️' : '❌');

    final StringBuffer sb = StringBuffer();
    sb.writeln('┌── $icon [HTTP RESPONSE] $statusCode (${durationMs}ms) $method $url ──');
    sb.writeln('│ Request ID : $requestId');

    final String? formattedBody = _formatBody(body);
    if (formattedBody != null && formattedBody.isNotEmpty) {
      sb.writeln('│ Body:');
      for (final String line in formattedBody.split('\n')) {
        sb.writeln('│   $line');
      }
    }
    sb.write('└─────────────────────────────────────────────────────────────');
    return sb.toString();
  }

  String _formatHttpError(LogEvent event) {
    final Map<String, dynamic> ctx = event.context ?? <String, dynamic>{};
    final String method = (ctx['method'] as String? ?? '').toUpperCase();
    final String url = ctx['url'] as String? ?? event.message;
    final int? statusCode = ctx['statusCode'] as int?;
    final int durationMs = ctx['durationMs'] as int? ?? 0;
    final String requestId = ctx['requestId'] as String? ?? event.id;
    final String errorType = ctx['errorType'] as String? ?? 'unknown';
    final dynamic errorMsg = ctx['message'] ?? event.error;
    final dynamic responseBody = ctx['responseBody'];

    final StringBuffer sb = StringBuffer();
    sb.writeln('┌── ❌ [HTTP ERROR] ${statusCode != null ? '$statusCode ' : ''}($errorType, ${durationMs}ms) $method $url ──');
    sb.writeln('│ Request ID : $requestId');
    if (errorMsg != null) {
      sb.writeln('│ Error      : $errorMsg');
    }

    final String? formattedBody = _formatBody(responseBody);
    if (formattedBody != null && formattedBody.isNotEmpty) {
      sb.writeln('│ Response Body:');
      for (final String line in formattedBody.split('\n')) {
        sb.writeln('│   $line');
      }
    }
    sb.write('└─────────────────────────────────────────────────────────────');
    return sb.toString();
  }

  String _formatGenericEvent(LogEvent event) {
    final String icon = switch (event.level) {
      LogLevel.trace || LogLevel.debug => '🔍',
      LogLevel.info => 'ℹ️',
      LogLevel.warning => '⚠️',
      LogLevel.error || LogLevel.critical => '🚨',
    };

    final StringBuffer sb = StringBuffer();
    sb.writeln('┌── $icon [${event.category.name.toUpperCase()}] ${event.message} ──────');
    if (event.context != null && event.context!.isNotEmpty) {
      for (final MapEntry<String, dynamic> entry in event.context!.entries) {
        sb.writeln('│ ${entry.key.padRight(10)}: ${entry.value}');
      }
    }
    if (event.error != null) {
      sb.writeln('│ error     : ${event.error}');
    }
    if (event.stackTrace != null) {
      sb.writeln('│ stackTrace: ${event.stackTrace}');
    }
    sb.write('└─────────────────────────────────────────────────────────────');
    return sb.toString();
  }

  static const Set<String> _noisyHeaders = <String>{
    'x-dns-prefetch-control',
    'strict-transport-security',
    'origin-agent-cluster',
    'vary',
    'referrer-policy',
    'x-permitted-cross-domain-policies',
    'cross-origin-opener-policy',
    'cross-origin-resource-policy',
    'x-xss-protection',
    'x-content-type-options',
    'x-download-options',
    'connection',
    'date',
  };

  Map<String, dynamic> _filterUsefulHeaders(Map<dynamic, dynamic> headers) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<dynamic, dynamic> entry in headers.entries) {
      final String key = entry.key.toString();
      if (!_noisyHeaders.contains(key.toLowerCase()) &&
          !key.toLowerCase().startsWith('x-ratelimit-')) {
        result[key] = entry.value;
      }
    }
    return result;
  }

  String? _formatBody(dynamic body) {
    if (body == null) return null;
    if (body is String) {
      if (body.isEmpty || body == '""') return null;
      try {
        final dynamic decoded = jsonDecode(body);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        return body;
      }
    }
    if (body is Map || body is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(body);
      } catch (_) {
        return body.toString();
      }
    }
    return body.toString();
  }

  int _toDeveloperLogLevel(LogLevel level) {
    return switch (level) {
      LogLevel.trace => 500,
      LogLevel.debug => 700,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
      LogLevel.critical => 1200,
    };
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> dispose() async {}
}
