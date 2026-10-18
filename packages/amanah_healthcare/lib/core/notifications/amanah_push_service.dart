// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/core/notifications/device_token_storage.dart';
import 'package:amanah_healthcare/core/notifications/push_notification_service.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/firebase_options.dart';

export 'package:amanah_healthcare/core/notifications/device_token_storage.dart';
export 'package:amanah_healthcare/core/notifications/push_notification_service.dart';

/// Top-level background message handler required by Firebase Cloud Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    }
  } catch (e) {
    debugPrint('[AmanahPushService] Background handler init error: $e');
  }
}

/// Production implementation using Firebase Cloud Messaging (FCM) and
/// Flutter Local Notifications for heads-up foreground status bar alerts.
class AmanahPushService implements AmanahPushNotificationService {
  AmanahPushService({
    ApiClient? apiClient,
    DeviceTokenStorage tokenStorage = const DeviceTokenStorage(),
    AmanahAuthTokenStorage authTokenStorage = const AmanahAuthTokenStorage(),
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _customApiClient = apiClient,
        _tokenStorage = tokenStorage,
        _authTokenStorage = authTokenStorage,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  static final AmanahPushService instance = AmanahPushService();

  static const String channelId = 'high_importance_channel';
  static const String channelName = 'Notifikasi Antrean & Klinis Amanah';
  static const String channelDescription =
      'Notifikasi panggilan antrean, status konsultasi, dan peringatan klinis prioritas tinggi.';

  final FlutterLocalNotificationsPlugin _localNotifications;
  final DeviceTokenStorage _tokenStorage;
  final AmanahAuthTokenStorage _authTokenStorage;
  final ApiClient? _customApiClient;

  ApiClient? _apiClient;
  String? _lastKnownFcmToken;
  bool _isInitialized = false;

  final List<void Function(RemoteMessage message)> _messageListeners =
      <void Function(RemoteMessage message)>[];
  final List<void Function(RemoteMessage message)> _tapListeners =
      <void Function(RemoteMessage message)>[];

  @override
  bool get isInitialized => _isInitialized;

  @override
  void addMessageListener(void Function(RemoteMessage message) listener) {
    _messageListeners.add(listener);
  }

  @override
  void removeMessageListener(void Function(RemoteMessage message) listener) {
    _messageListeners.remove(listener);
  }

  @override
  void addTapListener(void Function(RemoteMessage message) listener) {
    _tapListeners.add(listener);
  }

  @override
  void removeTapListener(void Function(RemoteMessage message) listener) {
    _tapListeners.remove(listener);
  }

  ApiClient get apiClient {
    return _customApiClient ??
        (_apiClient ??= AuthorizedApiClient(
          innerClient:
              HttpApiClient(baseUrl: AmanahAuthEnvironment.authBaseUrl),
          tokenProvider: _authTokenStorage,
        ));
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      AppLog.info(
        '[AmanahPushService] Push notifications skipped on non-mobile platform',
      );
      return;
    }

    try {
      // 1. Gracefully initialize Firebase Core
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // 2. Register background handler
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      // 3. Initialize Flutter Local Notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          AppLog.info(
            '[AmanahPushService] Local notification tapped: ${response.payload}',
          );
        },
      );

      // 4. Create High Importance Notification Channel on Android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
        // Explicit runtime notification permission prompt for Android 13+ (API 33+)
        await androidImplementation.requestNotificationsPermission();
      }

      // 5. Request FCM notification permissions
      final NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      AppLog.info(
        '[AmanahPushService] Notification permission status: ${settings.authorizationStatus}',
      );

      // 6. Setup Foreground Message listener (Status bar heads-up)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      // 7. Setup Background/Resume tapped listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTapped(message);
      });

      // 8. Handle cold launch from terminated state via push notification
      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTapped(initialMessage);
      }

      // 9. Retrieve and cache FCM token
      _lastKnownFcmToken = await FirebaseMessaging.instance.getToken();
      if (_lastKnownFcmToken != null) {
        await _tokenStorage.cacheDeviceToken(_lastKnownFcmToken!);
        AppLog.info(
          '[AmanahPushService] FCM Device Token obtained successfully',
        );
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
        _lastKnownFcmToken = newToken;
        unawaited(_tokenStorage.cacheDeviceToken(newToken));
        unawaited(registerDeviceWithBackend(customToken: newToken));
      });

      _isInitialized = true;

      // Deterministic attempt to sync device token if user already authenticated
      final bool hasAuth = await _authTokenStorage.hasToken();
      if (hasAuth) {
        await registerDeviceWithBackend();
      }
    } catch (e, stack) {
      AppLog.warning(
        '[AmanahPushService] Push service gracefully degraded: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  @override
  Future<String?> getDeviceToken() async {
    if (_lastKnownFcmToken != null) return _lastKnownFcmToken;

    // Check cached token first for fast retrieval
    final String? cached = await _tokenStorage.getCachedDeviceToken();
    if (cached != null && cached.isNotEmpty) {
      _lastKnownFcmToken = cached;
      return cached;
    }

    try {
      _lastKnownFcmToken = await FirebaseMessaging.instance.getToken();
      if (_lastKnownFcmToken != null) {
        await _tokenStorage.cacheDeviceToken(_lastKnownFcmToken!);
      }
      return _lastKnownFcmToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> registerDeviceWithBackend({String? customToken}) async {
    final bool hasAuth = await _authTokenStorage.hasToken();
    if (!hasAuth) {
      AppLog.info(
        '[AmanahPushService] Device registration deferred: no active auth session',
      );
      return false;
    }

    final String? token = customToken ?? await getDeviceToken();
    if (token == null || token.isEmpty) {
      AppLog.warning(
        '[AmanahPushService] Device registration aborted: FCM token unavailable',
      );
      return false;
    }

    try {
      final String platform = Platform.isAndroid
          ? 'android'
          : (Platform.isIOS ? 'ios' : 'web');

      final ApiEndpoint endpoint = ApiEndpoint(
        path: '/api/v1/notifications/push/device',
        method: HttpMethod.post,
        requiresAuth: true,
      );

      final response = await apiClient.request(
        endpoint,
        body: <String, dynamic>{
          'pushToken': token,
          'platform': platform,
          'deviceName': '${Platform.operatingSystem} device',
          'osVersion': Platform.operatingSystemVersion,
          'appVersion': '1.0.0',
        },
      );

      final bool success = response.isSuccessful;
      if (success) {
        await _tokenStorage.markTokenSynced(
          token: token,
          userId: 'current_authenticated_user',
        );
        AppLog.info(
          '[AmanahPushService] Device token registered with backend successfully',
        );
      } else {
        AppLog.warning(
          '[AmanahPushService] Backend rejected device registration with code ${response.statusCode}',
        );
      }
      return success;
    } catch (e) {
      AppLog.warning(
        '[AmanahPushService] Network failure during device registration: $e',
      );
      return false;
    }
  }

  @override
  Future<bool> unregisterDeviceWithBackend() async {
    final String? token = _lastKnownFcmToken ?? await getDeviceToken();
    if (token == null || token.isEmpty) return false;

    try {
      final ApiEndpoint endpoint = ApiEndpoint(
        path: '/api/v1/notifications/push/device',
        method: HttpMethod.delete,
        requiresAuth: true,
      );

      final response = await apiClient.request(
        endpoint,
        body: <String, dynamic>{
          'pushToken': token,
        },
      );

      await _tokenStorage.clearSyncedState();
      AppLog.info(
        '[AmanahPushService] Device token unregistered from backend: success=${response.isSuccessful}',
      );
      return response.isSuccessful;
    } catch (e) {
      AppLog.warning(
        '[AmanahPushService] Failed to unregister device token with backend: $e',
      );
      return false;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLog.info(
      '[AmanahPushService] Foreground push notification received: ${message.notification?.title}',
    );

    for (final listener in _messageListeners) {
      try {
        listener(message);
      } catch (e) {
        debugPrint('[AmanahPushService] Listener error: $e');
      }
    }

    // Refresh in-app notification store from backend SSOT
    unawaited(AmanahNotificationStore.instance.fetchMyNotifications());

    final String title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Pembaruan Antrean Pasien';
    final String body = message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';

    if (title.isNotEmpty || body.isNotEmpty) {
      _localNotifications.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['actionUrl']?.toString() ??
            message.data['commandId']?.toString(),
      );
    }
  }

  void _handleNotificationTapped(RemoteMessage message) {
    AppLog.info(
      '[AmanahPushService] Notification tapped by user: data=${message.data}',
    );
    for (final listener in _tapListeners) {
      try {
        listener(message);
      } catch (e) {
        debugPrint('[AmanahPushService] Tap listener error: $e');
      }
    }
  }
}
