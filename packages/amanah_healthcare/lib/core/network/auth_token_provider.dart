abstract interface class AuthTokenProvider {
  Future<String?> getToken();
}
