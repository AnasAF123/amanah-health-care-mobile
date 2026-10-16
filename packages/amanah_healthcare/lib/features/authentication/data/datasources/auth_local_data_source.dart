import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';

abstract interface class AuthLocalDataSource {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({
    AmanahAuthTokenStorage storage = const AmanahAuthTokenStorage(),
  }) : _storage = storage;

  final AmanahAuthTokenStorage _storage;

  @override
  Future<String?> getToken() => _storage.getToken();

  @override
  Future<void> saveToken(String token) => _storage.saveToken(token);

  @override
  Future<void> deleteToken() => _storage.deleteToken();
}
