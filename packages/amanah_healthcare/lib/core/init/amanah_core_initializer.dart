import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/config/app_config.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/logging/logging_config.dart';
import 'package:amanah_healthcare/core/notifications/amanah_push_service.dart';
import 'package:amanah_healthcare/helpers/camera_helper.dart';

/// Immutable diagnostic report detailing subsystem readiness during core startup.
class CoreInitializationResult {
  const CoreInitializationResult({
    required this.authEnvironmentReady,
    required this.betterAuthReady,
    required this.cameraReady,
    required this.pushNotificationsReady,
  });

  final bool authEnvironmentReady;
  final bool betterAuthReady;
  final bool cameraReady;
  final bool pushNotificationsReady;

  bool get isHealthy =>
      authEnvironmentReady && betterAuthReady && pushNotificationsReady;
}

/// Centralized bootstrapper responsible for graceful and deterministic core initialization.
class AmanahCoreInitializer {
  const AmanahCoreInitializer._();

  /// Executes all required bootstrap sequences gracefully.
  static Future<CoreInitializationResult> initialize() async {
    final WidgetsBinding widgetsBinding =
        WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    AppLog.init(
      config: const LoggingConfig(
        enableFileOutput: true,
        enableConsoleOutput: kDebugMode,
      ),
    );

    AppLog.info('[CoreInitializer] Commencing core services bootstrap sequence');

    bool authEnvOk = false;
    try {
      await AmanahAuthEnvironment.initialize();
      authEnvOk = true;
    } catch (e) {
      AppLog.error('[CoreInitializer] AmanahAuthEnvironment initialization failed', error: e);
    }

    try {
      AppConfig.validate();
      AppLog.info(
        '[CoreInitializer] AppConfig verified: env=${AppConfig.env}, baseUrl=${AmanahAuthEnvironment.authBaseUrl}',
      );
    } catch (e) {
      AppLog.error('[CoreInitializer] AppConfig validation error: $e');
      if (AppConfig.isProduction) {
        rethrow;
      }
    }

    _enableEdgeToEdgeMode();

    bool betterAuthOk = false;
    try {
      await FlutterBetterAuth.initialize(
        url: AmanahAuthEnvironment.betterAuthUrl,
        scheme: AmanahAuthEnvironment.authScheme,
      );
      betterAuthOk = true;
    } catch (e) {
      AppLog.warning('[CoreInitializer] FlutterBetterAuth initialization degraded: $e');
    }

    bool cameraOk = false;
    try {
      await CameraHelper.init();
      cameraOk = true;
    } catch (e) {
      AppLog.warning('[CoreInitializer] CameraHelper initialization degraded: $e');
    }

    bool pushOk = false;
    try {
      await AmanahPushService.instance.initialize();
      pushOk = AmanahPushService.instance.isInitialized;
    } catch (e) {
      AppLog.warning('[CoreInitializer] AmanahPushService initialization degraded: $e');
    }

    final CoreInitializationResult result = CoreInitializationResult(
      authEnvironmentReady: authEnvOk,
      betterAuthReady: betterAuthOk,
      cameraReady: cameraOk,
      pushNotificationsReady: pushOk,
    );

    AppLog.info(
      '[CoreInitializer] Core services bootstrap completed: '
      'authEnv=$authEnvOk, betterAuth=$betterAuthOk, camera=$cameraOk, push=$pushOk',
    );

    return result;
  }

  static void _enableEdgeToEdgeMode() {
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
      );
    }
  }
}
