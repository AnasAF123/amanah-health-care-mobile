import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Abstract contract for decoupled push notification transport and device lifecycle.
abstract interface class AmanahPushNotificationService {
  /// Indicates whether the push notification service has been successfully initialized.
  bool get isInitialized;

  /// Initializes native push notification channels, permissions, and platform listeners.
  Future<void> initialize();

  /// Retrieves the current Firebase Cloud Messaging (FCM) device push token.
  Future<String?> getDeviceToken();

  /// Registers the device push token with the backend database for the authenticated user.
  Future<bool> registerDeviceWithBackend({String? customToken});

  /// Unregisters/revokes the device push token on the backend when the user signs out.
  Future<bool> unregisterDeviceWithBackend();

  /// Adds a listener for incoming push messages while the app is in the foreground.
  void addMessageListener(void Function(RemoteMessage message) listener);

  /// Removes a previously registered message listener.
  void removeMessageListener(void Function(RemoteMessage message) listener);

  /// Adds a listener for when a push notification is tapped by the user.
  void addTapListener(void Function(RemoteMessage message) listener);

  /// Removes a previously registered tap listener.
  void removeTapListener(void Function(RemoteMessage message) listener);
}
