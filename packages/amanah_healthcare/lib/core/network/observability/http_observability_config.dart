import 'package:amanah_healthcare/core/logging/log_category.dart';

/// Runtime configuration for HTTP observability and network tracing.
class HttpObservabilityConfig {
  const HttpObservabilityConfig({
    this.enabled = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.logHeaders = true,
    this.redactSensitiveData = true,
    this.maxBodyCharacters = 32000,
    this.requestIdHeader = 'X-Request-ID',
    this.correlationIdHeader = 'X-Correlation-ID',
    this.category = LogCategory.http,
  });

  /// Master switch for network observability.
  final bool enabled;

  /// Whether request bodies are logged.
  final bool logRequestBody;

  /// Whether response bodies are logged.
  final bool logResponseBody;

  /// Whether headers are captured and logged.
  final bool logHeaders;

  /// Whether credentials, tokens, and secrets are sanitized.
  final bool redactSensitiveData;

  /// Maximum character threshold before body truncation is applied.
  final int maxBodyCharacters;

  /// Standard HTTP header name for request correlation.
  final String requestIdHeader;

  /// Secondary correlation header name.
  final String correlationIdHeader;

  /// Log category under which HTTP traces are published.
  final LogCategory category;

  HttpObservabilityConfig copyWith({
    bool? enabled,
    bool? logRequestBody,
    bool? logResponseBody,
    bool? logHeaders,
    bool? redactSensitiveData,
    int? maxBodyCharacters,
    String? requestIdHeader,
    String? correlationIdHeader,
    LogCategory? category,
  }) {
    return HttpObservabilityConfig(
      enabled: enabled ?? this.enabled,
      logRequestBody: logRequestBody ?? this.logRequestBody,
      logResponseBody: logResponseBody ?? this.logResponseBody,
      logHeaders: logHeaders ?? this.logHeaders,
      redactSensitiveData: redactSensitiveData ?? this.redactSensitiveData,
      maxBodyCharacters: maxBodyCharacters ?? this.maxBodyCharacters,
      requestIdHeader: requestIdHeader ?? this.requestIdHeader,
      correlationIdHeader: correlationIdHeader ?? this.correlationIdHeader,
      category: category ?? this.category,
    );
  }
}
