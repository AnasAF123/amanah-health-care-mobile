import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/notifications/device_token_storage.dart';

class MockFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _data = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceTokenStorage', () {
    late MockFlutterSecureStorage mockStorage;
    late DeviceTokenStorage storage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      storage = DeviceTokenStorage(storage: mockStorage);
    });

    test('caches and retrieves device push token', () async {
      expect(await storage.getCachedDeviceToken(), isNull);

      await storage.cacheDeviceToken('token_abc123');
      expect(await storage.getCachedDeviceToken(), 'token_abc123');
    });

    test('tracks and verifies backend token synchronization status', () async {
      expect(
        await storage.isTokenSynced(
          token: 'token_abc123',
          userId: 'user_xyz',
        ),
        isFalse,
      );

      await storage.markTokenSynced(
        token: 'token_abc123',
        userId: 'user_xyz',
      );

      expect(
        await storage.isTokenSynced(
          token: 'token_abc123',
          userId: 'user_xyz',
        ),
        isTrue,
      );

      // Different user should return false
      expect(
        await storage.isTokenSynced(
          token: 'token_abc123',
          userId: 'other_user',
        ),
        isFalse,
      );

      // Different token should return false
      expect(
        await storage.isTokenSynced(
          token: 'new_token',
          userId: 'user_xyz',
        ),
        isFalse,
      );
    });

    test('clears synced state on logout', () async {
      await storage.cacheDeviceToken('token_abc123');
      await storage.markTokenSynced(
        token: 'token_abc123',
        userId: 'user_xyz',
      );

      await storage.clearSyncedState();

      expect(
        await storage.isTokenSynced(
          token: 'token_abc123',
          userId: 'user_xyz',
        ),
        isFalse,
      );
      // Raw cached token remains
      expect(await storage.getCachedDeviceToken(), 'token_abc123');
    });

    test('clearAll wipes entire token storage', () async {
      await storage.cacheDeviceToken('token_abc123');
      await storage.markTokenSynced(
        token: 'token_abc123',
        userId: 'user_xyz',
      );

      await storage.clearAll();

      expect(await storage.getCachedDeviceToken(), isNull);
      expect(
        await storage.isTokenSynced(
          token: 'token_abc123',
          userId: 'user_xyz',
        ),
        isFalse,
      );
    });
  });
}
