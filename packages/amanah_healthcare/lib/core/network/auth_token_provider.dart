abstract interface class AuthTokenProvider {
  Future<String?> getToken();
  Future<String?> getRefreshToken() => Future<String?>.value(null);
}
