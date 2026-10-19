/// Centralized compile-time environment configuration for Amanah Healthcare.
///
/// Values are injected at compile time via `--dart-define-from-file=env/<target>.json`
/// or `--dart-define=KEY=VALUE`.
///
/// This eliminates raw plain-text secret bundling in release APK assets and
/// provides deterministic environment switching between emulator, USB physical
/// device, staging, and production.
class AppConfig {
  const AppConfig._();

  /// Current application lifecycle environment ('development', 'staging', 'production').
  static const String env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// Base URL for backend API and authentication services.
  static const String authBaseUrl = String.fromEnvironment(
    'AUTH_BASE_URL',
    defaultValue: '',
  );

  /// Deep link custom URL scheme for OAuth and app navigation.
  static const String authScheme = String.fromEnvironment(
    'AUTH_SCHEME',
    defaultValue: 'amanahhealth',
  );

  /// Google Cloud Project ID.
  static const String googleProjectId = String.fromEnvironment(
    'GOOGLE_PROJECT_ID',
    defaultValue: 'klinik-amanah-healthcare',
  );

  /// Google OAuth Client ID for Android native authentication.
  static const String googleOAuthClientIdAndroid = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_ID_ANDROID',
    defaultValue: '',
  );

  /// Google OAuth Client ID for iOS native authentication.
  static const String googleOAuthClientIdIos = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_ID_IOS',
    defaultValue: '',
  );

  /// Google OAuth Client ID for Web / Server ID Token verification audience.
  static const String googleOAuthClientIdWeb = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_ID_WEB',
    defaultValue: '649477011186-augsamgganq024tesomp0c8rvgs9c7ua.apps.googleusercontent.com',
  );

  /// True if running in production mode.
  static bool get isProduction => env == 'production' || env == 'prod';

  /// True if running in staging mode.
  static bool get isStaging => env == 'staging';

  /// True if running in development mode.
  static bool get isDevelopment => !isProduction && !isStaging;

  /// Full endpoint URL for Better Auth authentication.
  static String get betterAuthUrl => '$authBaseUrl/api/auth';

  /// Validates configuration sanity at startup.
  ///
  /// Throws [StateError] immediately if essential configuration is missing or invalid.
  static void validate() {
    if (authBaseUrl.isEmpty) {
      throw StateError(
        '[AppConfig] AUTH_BASE_URL belum diisi! '
        'Pastikan aplikasi dijalankan dengan flag --dart-define-from-file=env/<target>.json\n\n'
        'Contoh Penggunaan:\n'
        '  - HP Fisik (USB):  flutter run -t lib/entrypoints/android/main_google_play.dart --dart-define-from-file=env/dev.device.json\n'
        '  - Emulator:       flutter run -t lib/entrypoints/android/main_google_play.dart --dart-define-from-file=env/dev.emulator.json\n'
        '  - Production:     flutter build appbundle --release -t lib/entrypoints/android/main_google_play.dart --dart-define-from-file=env/prod.json\n',
      );
    }

    if (isProduction && !authBaseUrl.startsWith('https://')) {
      throw StateError(
        '[AppConfig] Pelanggaran Keamanan: Environment production WAJIB menggunakan protokol HTTPS!\n'
        'URL saat ini: "$authBaseUrl"',
      );
    }
  }
}
