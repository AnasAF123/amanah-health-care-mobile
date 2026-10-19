import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:amanah_healthcare/core/config/app_config.dart';

/// Centralized environment configuration for authentication and backend communication.
///
/// Delegates to compile-time [AppConfig] (--dart-define-from-file) first, with
/// backward-compatible fallback to runtime `.env` assets and platform defaults.
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
  static String get googleProjectId {
    if (AppConfig.googleProjectId.isNotEmpty) return AppConfig.googleProjectId;
    return get('GOOGLE_PROJECT_ID', fallback: 'klinik-amanah-healthcare');
  }

  /// Google OAuth Client ID for Android
  static String get googleOAuthClientIdAndroid {
    if (AppConfig.googleOAuthClientIdAndroid.isNotEmpty) {
      return AppConfig.googleOAuthClientIdAndroid;
    }
    return get('GOOGLE_OAUTH_CLIENT_ID_ANDROID');
  }

  /// Google OAuth Client ID for iOS
  static String get googleOAuthClientIdIos {
    if (AppConfig.googleOAuthClientIdIos.isNotEmpty) {
      return AppConfig.googleOAuthClientIdIos;
    }
    return get('GOOGLE_OAUTH_CLIENT_ID_IOS');
  }

  /// Google OAuth Client ID for Web / Server ID Token audience
  static String get googleOAuthClientIdWeb {
    if (AppConfig.googleOAuthClientIdWeb.isNotEmpty) {
      return AppConfig.googleOAuthClientIdWeb;
    }
    return get(
      'GOOGLE_OAUTH_CLIENT_ID_WEB',
      fallback: '649477011186-augsamgganq024tesomp0c8rvgs9c7ua.apps.googleusercontent.com',
    );
  }

  /// Base URL for backend communication, honoring compile-time AppConfig without naive rewrites.
  static String get authBaseUrl {
    // 1. Compile-time configuration via --dart-define-from-file or --dart-define takes precedence
    if (AppConfig.authBaseUrl.isNotEmpty) {
      return AppConfig.authBaseUrl;
    }

    // 2. Platform-specific override from runtime .env asset (if present)
    if (!kIsWeb && Platform.isAndroid) {
      final String androidUrl = get('AUTH_BASE_URL_ANDROID');
      if (androidUrl.isNotEmpty) return androidUrl;
    }

    // 3. General AUTH_BASE_URL from runtime .env asset
    final String base = get('AUTH_BASE_URL');
    if (base.isNotEmpty) return base;

    // 4. Default fallback: keep localhost for physical USB debugging / adb reverse
    return 'http://localhost:3001';
  }

  /// Full endpoint URL for Better Auth authentication
  static String get betterAuthUrl {
    final String explicitUrl = get('BETTER_AUTH_URL', fallback: const String.fromEnvironment('BETTER_AUTH_URL'));
    if (explicitUrl.isNotEmpty) return explicitUrl;
    return '$authBaseUrl/api/auth';
  }

  /// Deep link custom URL scheme for OAuth callbacks
  static String get authScheme {
    if (AppConfig.authScheme.isNotEmpty) return AppConfig.authScheme;
    return get('AUTH_SCHEME', fallback: 'amanahhealth');
  }
}

