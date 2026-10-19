import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/config/app_config.dart';
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig', () {
    test('provides sensible defaults when compile-time flags are absent', () {
      expect(AppConfig.authScheme, equals('amanahhealth'));
      expect(AppConfig.googleProjectId, equals('klinik-amanah-healthcare'));
      expect(
        AppConfig.googleOAuthClientIdWeb,
        equals('649477011186-augsamgganq024tesomp0c8rvgs9c7ua.apps.googleusercontent.com'),
      );
    });

    test('validates and throws StateError when authBaseUrl is empty', () {
      expect(
        () => AppConfig.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('AUTH_BASE_URL belum diisi!'),
        )),
      );
    });

    test('AmanahAuthEnvironment delegates correctly to AppConfig and defaults without auto-replacing localhost', () {
      // In default test environment without compile-time flags, authBaseUrl falls back to localhost:3001
      expect(AmanahAuthEnvironment.authBaseUrl, contains(':3001'));
      // Verifies no naive replacement occurs when localhost is given
      expect(AmanahAuthEnvironment.authBaseUrl, equals('http://localhost:3001'));
      expect(AmanahAuthEnvironment.betterAuthUrl, equals('http://localhost:3001/api/auth'));
      expect(AmanahAuthEnvironment.authScheme, equals('amanahhealth'));
    });
  });
}
