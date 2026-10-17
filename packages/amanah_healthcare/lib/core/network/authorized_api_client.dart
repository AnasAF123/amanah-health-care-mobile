import 'dart:async';
import 'package:amanah_healthcare/core/auth/amanah_auth_session_manager.dart';
import 'package:amanah_healthcare/core/constants/auth_schemes.dart';
import 'package:amanah_healthcare/core/constants/http_header_names.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';
import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/auth_token_provider.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';

class AuthorizedApiClient implements ApiClient {
  const AuthorizedApiClient({
    required ApiClient innerClient,
    required AuthTokenProvider tokenProvider,
    AuthRepository? authRepository,
  })  : _innerClient = innerClient,
        _tokenProvider = tokenProvider,
        _authRepository = authRepository;

  final ApiClient _innerClient;
  final AuthTokenProvider _tokenProvider;
  final AuthRepository? _authRepository;

  static Completer<bool>? _refreshCompleter;

  AuthRepository get _repository =>
      _authRepository ?? const AmanahAuthRepository();

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

    try {
      return await _innerClient.request(
        endpoint,
        body: body,
        queryParameters: queryParameters,
        headers: resolvedHeaders,
        fileBytes: fileBytes,
        filePath: filePath,
        fileField: fileField,
        fileName: fileName,
      );
    } on UnauthorizedException catch (e) {
      if (!endpoint.requiresAuth || endpoint.path.contains('/auth/refresh')) {
        AmanahAuthSessionManager.instance.notifySessionExpired(
          reason: 'Refresh token invalid or unauthorized',
        );
        rethrow;
      }

      // Perform or await mutex-protected silent refresh
      final bool refreshSuccess = await _performSilentRefresh();

      if (refreshSuccess) {
        final String? newToken = await _tokenProvider.getToken();
        if (newToken != null && newToken.isNotEmpty) {
          resolvedHeaders[HttpHeaderNames.authorization] =
              '${AuthSchemes.bearer} $newToken';
        }

        // Retry the original request with fresh token
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

      AmanahAuthSessionManager.instance.notifySessionExpired(
        reason: 'Session expired and silent refresh failed',
      );
      throw UnauthorizedException(e.message, e.code);
    }
  }

  Future<bool> _performSilentRefresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final Completer<bool> completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final bool success = await _repository.refreshToken();
      completer.complete(success);
      return success;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}

