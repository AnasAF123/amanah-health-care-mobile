import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';

abstract interface class AuthLocalDataSource {
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<void> saveToken(String token);
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> deleteToken();
  Future<void> deleteAllTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({
    AmanahAuthTokenStorage storage = const AmanahAuthTokenStorage(),
  }) : _storage = storage;

  final AmanahAuthTokenStorage _storage;

  @override
  Future<String?> getToken() => _storage.getToken();

  @override
  Future<String?> getRefreshToken() => _storage.getRefreshToken();

  @override
  Future<void> saveToken(String token) => _storage.saveToken(token);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

  @override
  Future<void> deleteToken() => _storage.deleteToken();

  @override
  Future<void> deleteAllTokens() => _storage.deleteAllTokens();
}
