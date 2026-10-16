enum HttpMethod { get, post, put, patch, delete }

class ApiEndpoint {
  const ApiEndpoint({
    required this.path,
    required this.method,
    this.requiresAuth = false,
  });

  final String path;
  final HttpMethod method;
  final bool requiresAuth;

  String url(String baseUrl) => '$baseUrl$path';
}
