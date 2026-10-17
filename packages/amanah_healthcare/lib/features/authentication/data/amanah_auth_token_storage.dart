import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:amanah_healthcare/core/network/auth_token_provider.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';

class AmanahAuthTokenStorage implements AuthTokenProvider {
  const AmanahAuthTokenStorage({FlutterSecureStorage storage = const FlutterSecureStorage()})
      : _storage = storage;

  static const String tokenKey = 'amanah_auth_token';
  static const String refreshTokenKey = 'amanah_refresh_token';
  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    AmanahAuthLogger.logStorage('Save Token', key: tokenKey, length: token.length);
    await _storage.write(key: tokenKey, value: token);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    AmanahAuthLogger.logStorage(
      'Save Tokens',
      key: tokenKey,
      length: accessToken.length,
    );
    await Future.wait(<Future<void>>[
      _storage.write(key: tokenKey, value: accessToken),
      _storage.write(key: refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getToken() async {
    final String? token = await _storage.read(key: tokenKey);
    AmanahAuthLogger.logStorage(
      'Get Token',
      key: tokenKey,
      exists: token != null && token.isNotEmpty,
      length: token?.length,
    );
    return token;
  }

  @override
  Future<String?> getRefreshToken() async {
    final String? token = await _storage.read(key: refreshTokenKey);
    AmanahAuthLogger.logStorage(
      'Get Refresh Token',
      key: refreshTokenKey,
      exists: token != null && token.isNotEmpty,
      length: token?.length,
    );
    return token;
  }

  Future<void> deleteToken() async {
    AmanahAuthLogger.logStorage('Delete Token', key: tokenKey);
    await _storage.delete(key: tokenKey);
  }

  Future<void> deleteAllTokens() async {
    AmanahAuthLogger.logStorage('Delete All Tokens');
    await Future.wait(<Future<void>>[
      _storage.delete(key: tokenKey),
      _storage.delete(key: refreshTokenKey),
    ]);
  }

  Future<bool> hasToken() async {
    final String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
