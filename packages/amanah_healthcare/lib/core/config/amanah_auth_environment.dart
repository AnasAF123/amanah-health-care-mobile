import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Centralized environment configuration for authentication and backend communication.
///
/// Loads configuration from an `.env` file packaged as an asset, with fallback to
/// compile-time `--dart-define` environment declarations and sensible local defaults.
class AmanahAuthEnvironment {
  AmanahAuthEnvironment._();

  static final Map<String, String> _env = <String, String>{};
  static bool _initialized = false;

  /// Returns true if the environment has been initialized.
  static bool get isInitialized => _initialized;

  /// Initializes the environment configuration by loading and parsing `.env`.
  ///
  /// Can be called with explicit [envContent] for testing or custom loaders.
  static Future<void> initialize({String? envContent}) async {
    if (_initialized && envContent == null) return;

    String content = envContent ?? '';
    if (content.isEmpty) {
      try {
        content = await rootBundle.loadString('.env');
      } catch (_) {
        try {
          content = await rootBundle.loadString('assets/.env');
        } catch (_) {
          // If asset is not found, continue with dart-define environment variables
        }
      }
    }

    if (content.isNotEmpty) {
      _parseEnv(content);
    }

    _initialized = true;
  }

  /// Parses the raw contents of an `.env` file into key-value pairs.
  static void _parseEnv(String rawContent) {
    final List<String> lines = rawContent.split(RegExp(r'\r?\n'));
    for (final String line in lines) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      final int separatorIndex = trimmed.indexOf('=');
      if (separatorIndex == -1) continue;

      final String key = trimmed.substring(0, separatorIndex).trim();
      String value = trimmed.substring(separatorIndex + 1).trim();

      // Strip matching enclosing quotes
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        if (value.length >= 2) {
          value = value.substring(1, value.length - 1);
        }
      }

      if (key.isNotEmpty) {
        _env[key] = value;
      }
    }
  }

  /// Reads an environment variable by [key], checking `.env` first,
  /// then compile-time declarations via [String.fromEnvironment], and finally [fallback].
  static String get(String key, {String fallback = ''}) {
    final String? fromFile = _env[key];
    if (fromFile != null && fromFile.isNotEmpty) {
      return fromFile;
    }
    return fallback;
  }

  /// Google Cloud Project ID
  static String get googleProjectId =>
      get('GOOGLE_PROJECT_ID', fallback: const String.fromEnvironment('GOOGLE_PROJECT_ID', defaultValue: 'klinik-amanah-healthcare'));

  /// Google OAuth Client ID for Android
  static String get googleOAuthClientIdAndroid =>
      get('GOOGLE_OAUTH_CLIENT_ID_ANDROID', fallback: const String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID_ANDROID'));

  /// Google OAuth Client ID for iOS
  static String get googleOAuthClientIdIos =>
      get('GOOGLE_OAUTH_CLIENT_ID_IOS', fallback: const String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID_IOS'));

  /// Google OAuth Client ID for Web / Server ID Token audience
  static String get googleOAuthClientIdWeb =>
      get('GOOGLE_OAUTH_CLIENT_ID_WEB', fallback: const String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID_WEB', defaultValue: '649477011186-augsamgganq024tesomp0c8rvgs9c7ua.apps.googleusercontent.com'));

  /// Base URL for backend communication, automatically resolving Android emulator localhost if applicable
  static String get authBaseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      final String androidUrl = get('AUTH_BASE_URL_ANDROID', fallback: const String.fromEnvironment('AUTH_BASE_URL_ANDROID'));
      if (androidUrl.isNotEmpty) return androidUrl;

      final String defaultBase = get('AUTH_BASE_URL', fallback: const String.fromEnvironment('AUTH_BASE_URL'));
      if (defaultBase.contains('localhost')) {
        return defaultBase.replaceFirst('localhost', '10.0.2.2');
      } else if (defaultBase.contains('127.0.0.1')) {
        return defaultBase.replaceFirst('127.0.0.1', '10.0.2.2');
      } else if (defaultBase.isNotEmpty) {
        return defaultBase;
      }
      return 'http://10.0.2.2:3001';
    }

    final String base = get('AUTH_BASE_URL', fallback: const String.fromEnvironment('AUTH_BASE_URL'));
    if (base.isNotEmpty) return base;
    return 'http://localhost:3001';
  }

  /// Full endpoint URL for Better Auth authentication
  static String get betterAuthUrl {
    final String explicitUrl = get('BETTER_AUTH_URL', fallback: const String.fromEnvironment('BETTER_AUTH_URL'));
    if (explicitUrl.isNotEmpty) return explicitUrl;
    return '$authBaseUrl/api/auth';
  }

  /// Deep link custom URL scheme for OAuth callbacks
  static String get authScheme =>
      get('AUTH_SCHEME', fallback: const String.fromEnvironment('AUTH_SCHEME', defaultValue: 'amanahhealth'));
}
