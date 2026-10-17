import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';

/// Persistent secure storage for device push tokens and backend synchronization status.
class DeviceTokenStorage {
  const DeviceTokenStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String _keyCachedToken = 'amanah_fcm_cached_token';
  static const String _keySyncedToken = 'amanah_fcm_synced_token';
  static const String _keySyncedUserId = 'amanah_fcm_synced_user_id';

  final FlutterSecureStorage _storage;

  /// Saves the last known raw FCM token locally.
  Future<void> cacheDeviceToken(String token) async {
    try {
      await _storage.write(key: _keyCachedToken, value: token);
    } catch (e) {
      AppLog.warning('[DeviceTokenStorage] Failed to cache token: $e');
    }
  }

  /// Returns the cached FCM token if present.
  Future<String?> getCachedDeviceToken() async {
    try {
      return await _storage.read(key: _keyCachedToken);
    } catch (e) {
      AppLog.warning('[DeviceTokenStorage] Failed to read cached token: $e');
      return null;
    }
  }

  /// Marks a specific token as successfully registered with the backend for the given userId.
  Future<void> markTokenSynced({
    required String token,
    required String userId,
  }) async {
    try {
      await _storage.write(key: _keySyncedToken, value: token);
      await _storage.write(key: _keySyncedUserId, value: userId);
    } catch (e) {
      AppLog.warning('[DeviceTokenStorage] Failed to mark token as synced: $e');
    }
  }

  /// Returns true if the given token has already been successfully synced to the backend for this user.
  Future<bool> isTokenSynced({
    required String token,
    required String userId,
  }) async {
    try {
      final String? syncedToken = await _storage.read(key: _keySyncedToken);
      final String? syncedUserId = await _storage.read(key: _keySyncedUserId);
      return syncedToken == token && syncedUserId == userId;
    } catch (_) {
      return false;
    }
  }

  /// Clears the synchronized token status (e.g. upon user logout).
  Future<void> clearSyncedState() async {
    try {
      await _storage.delete(key: _keySyncedToken);
      await _storage.delete(key: _keySyncedUserId);
    } catch (e) {
      AppLog.warning('[DeviceTokenStorage] Failed to clear synced state: $e');
    }
  }

  /// Clears all token storage entries.
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _keyCachedToken);
      await _storage.delete(key: _keySyncedToken);
      await _storage.delete(key: _keySyncedUserId);
    } catch (e) {
      AppLog.warning('[DeviceTokenStorage] Failed to clear all token storage: $e');
    }
  }
}
