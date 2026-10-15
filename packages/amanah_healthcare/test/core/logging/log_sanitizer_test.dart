import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/logging/log_sanitizer.dart';
import 'package:amanah_healthcare/core/network/observability/http_log_sanitizer.dart';

void main() {
  group('LogSanitizer Tests', () {
    late LogSanitizer sanitizer;

    setUp(() {
      sanitizer = LogSanitizer();
    });

    test('Recursively redacts passwords, tokens, secrets, and OTPs in maps', () {
      final Map<String, dynamic> raw = <String, dynamic>{
        'user': {
          'id': 'usr_123',
          'email': 'doctor@amanah.id',
          'password': 'SuperSecretPassword!123',
          'nested': {
            'accessToken': 'eyJhbGciOi...',
            'refreshToken': 'refresh_xyz_987',
            'otp': '654321',
            'pin': '1234',
          },
        },
        'publicData': 'safe_value',
      };

      final dynamic sanitized = sanitizer.sanitize(raw);

      expect(sanitized['user']['email'], 'doctor@amanah.id');
      expect(sanitized['user']['password'], '[REDACTED]');
      expect(sanitized['user']['nested']['accessToken'], '[REDACTED]');
      expect(sanitized['user']['nested']['refreshToken'], '[REDACTED]');
      expect(sanitized['user']['nested']['otp'], '[REDACTED]');
      expect(sanitized['user']['nested']['pin'], '[REDACTED]');
      expect(sanitized['publicData'], 'safe_value');
    });

    test('Redacts Authorization Bearer headers', () {
      final Map<String, dynamic> headers = <String, dynamic>{
        'Authorization': 'Bearer test-secret-jwt-token-999',
        'Content-Type': 'application/json',
        'Cookie': 'session=abc123secret',
        'X-Api-Key': 'key-secret-456',
      };

      final Map<String, String> sanitized = sanitizer.sanitizeHeaders(headers);

      expect(sanitized['Authorization'], 'Bearer [REDACTED]');
      expect(sanitized['Content-Type'], 'application/json');
      expect(sanitized['Cookie'], '[REDACTED]');
      expect(sanitized['X-Api-Key'], '[REDACTED]');
    });

    test('Redacts inline Bearer tokens in text strings', () {
      final dynamic sanitized = sanitizer.sanitize('Sent request with Bearer secret-token-xyz');
      expect(sanitized, 'Sent request with Bearer [REDACTED]');
    });

    test('Supports additional application-specific sensitive keys', () {
      final LogSanitizer custom = LogSanitizer(
        additionalSensitiveKeys: {'nik', 'bpjsNumber'},
      );

      final Map<String, dynamic> data = <String, dynamic>{
        'patient': {
          'name': 'Ahmad',
          'nik': '3201234567890001',
          'bpjsNumber': '00012345678',
        }
      };

      final dynamic sanitized = custom.sanitize(data);
      expect(sanitized['patient']['name'], 'Ahmad');
      expect(sanitized['patient']['nik'], '[REDACTED]');
      expect(sanitized['patient']['bpjsNumber'], '[REDACTED]');
    });
  });

  group('HttpLogSanitizer Tests', () {
    late HttpLogSanitizer httpSanitizer;

    setUp(() {
      httpSanitizer = HttpLogSanitizer(maxBodyCharacters: 50);
    });

    test('Omits binary bytes and records metadata instead', () {
      final List<int> binaryBytes = List<int>.filled(1024, 0xFF);
      final dynamic sanitized = httpSanitizer.sanitizeBody(
        binaryBytes,
        contentType: 'image/jpeg',
      );

      expect(sanitized['_type'], 'binary');
      expect(sanitized['sizeBytes'], 1024);
      expect(sanitized['note'], '[BINARY OMITTED]');
    });

    test('Sanitizes multipart file metadata without exposing bytes', () {
      final files = [
        (field: 'avatar', filename: 'photo.jpg', contentType: 'image/jpeg', length: 245000),
      ];

      final summary = httpSanitizer.sanitizeMultipartFiles(files);
      expect(summary.length, 1);
      expect(summary.first['field'], 'avatar');
      expect(summary.first['filename'], 'photo.jpg');
      expect(summary.first['sizeBytes'], 245000);
    });

    test('Applies truncation safeguards to excessively large payloads', () {
      final String hugeString = 'A' * 200;
      final dynamic sanitized = httpSanitizer.sanitizeBody(hugeString);

      expect(sanitized['_truncated'], isTrue);
      expect(sanitized['_originalLength'], 200);
      expect((sanitized['preview'] as String).length, 50);
    });
  });
}
