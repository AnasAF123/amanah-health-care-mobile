import 'dart:convert';
import 'package:amanah_healthcare/core/logging/log_sanitizer.dart';

/// Specialized sanitizer for HTTP headers, payloads, multipart forms, and binary streams.
class HttpLogSanitizer {
  HttpLogSanitizer({
    LogSanitizer? baseSanitizer,
    this.maxBodyCharacters = 32000,
    this.maxArrayItems = 100,
  }) : _baseSanitizer = baseSanitizer ?? LogSanitizer();

  final LogSanitizer _baseSanitizer;
  final int maxBodyCharacters;
  final int maxArrayItems;

  /// Sanitizes HTTP headers.
  Map<String, String> sanitizeHeaders(Map<String, dynamic>? headers) {
    return _baseSanitizer.sanitizeHeaders(headers);
  }

  /// Sanitizes request or response body while protecting against huge payloads and binary data.
  dynamic sanitizeBody(dynamic rawBody, {String? contentType}) {
    if (rawBody == null) return null;

    // Detect binary content types
    if (_isBinaryContentType(contentType)) {
      final int size = _estimateSize(rawBody);
      return <String, dynamic>{
        '_type': 'binary',
        'contentType': contentType,
        'sizeBytes': size,
        'note': '[BINARY OMITTED]',
      };
    }

    // Handle byte arrays
    if (rawBody is List<int>) {
      return <String, dynamic>{
        '_type': 'bytes',
        'length': rawBody.length,
        'note': '[BINARY OMITTED]',
      };
    }

    try {
      dynamic processedBody = rawBody;

      if (rawBody is String) {
        final String trimmed = rawBody.trim();
        if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
            (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
          try {
            processedBody = jsonDecode(trimmed);
          } catch (_) {
            processedBody = trimmed;
          }
        } else {
          processedBody = trimmed;
        }
      }

      final dynamic sanitized = _baseSanitizer.sanitize(processedBody);
      return _applyTruncationSafeguards(sanitized);
    } catch (_) {
      return '<non-serializable: ${rawBody.runtimeType}>';
    }
  }

  /// Formats multipart form files into safe metadata descriptors without dumping bytes.
  List<Map<String, dynamic>> sanitizeMultipartFiles(
    List<({String field, String? filename, String? contentType, int? length})> files,
  ) {
    return files.map((file) {
      return <String, dynamic>{
        'field': file.field,
        'filename': file.filename ?? 'unnamed',
        if (file.contentType != null) 'contentType': file.contentType,
        if (file.length != null) 'sizeBytes': file.length,
      };
    }).toList();
  }

  bool _isBinaryContentType(String? contentType) {
    if (contentType == null) return false;
    final String lower = contentType.toLowerCase();
    return lower.contains('image/') ||
        lower.contains('video/') ||
        lower.contains('audio/') ||
        lower.contains('application/octet-stream') ||
        lower.contains('application/pdf') ||
        lower.contains('application/zip');
  }

  int _estimateSize(dynamic body) {
    if (body is List<int>) return body.length;
    if (body is String) return body.length;
    return 0;
  }

  dynamic _applyTruncationSafeguards(dynamic value) {
    if (value is String) {
      if (value.length > maxBodyCharacters) {
        return <String, dynamic>{
          '_truncated': true,
          '_originalLength': value.length,
          'preview': value.substring(0, maxBodyCharacters),
        };
      }
      return value;
    }

    if (value is List) {
      if (value.length > maxArrayItems) {
        final List<dynamic> truncatedList =
            value.take(maxArrayItems).map(_applyTruncationSafeguards).toList();
        truncatedList.add(<String, dynamic>{
          '_truncated': true,
          '_omittedItems': value.length - maxArrayItems,
        });
        return truncatedList;
      }
      return value.map(_applyTruncationSafeguards).toList();
    }

    if (value is Map) {
      final Map<String, dynamic> result = <String, dynamic>{};
      for (final MapEntry<dynamic, dynamic> entry in value.entries) {
        result[entry.key.toString()] = _applyTruncationSafeguards(entry.value);
      }
      return result;
    }

    return value;
  }
}
