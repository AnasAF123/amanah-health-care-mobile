import 'package:amanah_healthcare/core/constants/auth_schemes.dart';
import 'package:amanah_healthcare/core/constants/http_header_names.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/auth_token_provider.dart';

class AuthorizedApiClient implements ApiClient {
  const AuthorizedApiClient({
    required ApiClient innerClient,
    required AuthTokenProvider tokenProvider,
  })  : _innerClient = innerClient,
        _tokenProvider = tokenProvider;

  final ApiClient _innerClient;
  final AuthTokenProvider _tokenProvider;

  @override
  Future<ApiResponse<dynamic>> request(
    ApiEndpoint endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    List<int>? fileBytes,
    String? filePath,
    String? fileField,
    String? fileName,
  }) async {
    final Map<String, String> resolvedHeaders = <String, String>{
      ...?headers,
    };

    if (endpoint.requiresAuth) {
      final String? token = await _tokenProvider.getToken();
      if (token != null && token.isNotEmpty) {
        resolvedHeaders[HttpHeaderNames.authorization] =
            '${AuthSchemes.bearer} $token';
      }
    }

    return _innerClient.request(
      endpoint,
      body: body,
      queryParameters: queryParameters,
      headers: resolvedHeaders,
      fileBytes: fileBytes,
      filePath: filePath,
      fileField: fileField,
      fileName: fileName,
    );
  }
}
