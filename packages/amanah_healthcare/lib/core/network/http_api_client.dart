import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/constants/auth_api_constants.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';
import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/client/amanah_http_client.dart';
import 'package:amanah_healthcare/core/network/client/observable_http_client.dart';

class HttpApiClient implements ApiClient {
  const HttpApiClient({String? baseUrl, http.Client? httpClient})
    : _customBaseUrl = baseUrl,
      _customClient = httpClient;

  final String? _customBaseUrl;
  final http.Client? _customClient;

  String get baseUrl => _customBaseUrl ?? AmanahAuthEnvironment.authBaseUrl;

  http.Client get _httpClient {
    final http.Client? custom = _customClient;
    if (custom != null) {
      return custom is ObservableHttpClient ? custom : ObservableHttpClient(innerClient: custom);
    }
    return AmanahHttpClient.instance;
  }

  Uri _buildUri(ApiEndpoint endpoint, Map<String, String>? queryParameters) {
    final String fullUrl = endpoint.url(baseUrl);
    final Uri uri = Uri.parse(fullUrl);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(
      queryParameters: <String, String>{...uri.queryParameters, ...queryParameters},
    );
  }

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
    final Uri uri = _buildUri(endpoint, queryParameters);

    final Map<String, String> resolvedHeaders = <String, String>{
      AuthHeaderNames.accept: AuthMimeTypes.applicationJson,
      if (fileBytes == null && filePath == null)
        AuthHeaderNames.contentType: AuthMimeTypes.applicationJson,
      ...?headers,
    };

    try {
      if (fileBytes != null || filePath != null) {
        return await _sendMultipart(
          endpoint: endpoint,
          uri: uri,
          headers: resolvedHeaders,
          body: body,
          fileBytes: fileBytes,
          filePath: filePath,
          fileField: fileField ?? 'file',
          fileName: fileName ?? 'file.bin',
        );
      }

      final http.Response response = await _sendStandard(
        endpoint: endpoint,
        uri: uri,
        headers: resolvedHeaders,
        body: body,
      );

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<http.Response> _sendStandard({
    required ApiEndpoint endpoint,
    required Uri uri,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    final String? encodedBody = body != null ? jsonEncode(body) : null;

    switch (endpoint.method) {
      case HttpMethod.get:
        return _httpClient.get(uri, headers: headers);
      case HttpMethod.post:
        return _httpClient.post(uri, headers: headers, body: encodedBody);
      case HttpMethod.put:
        return _httpClient.put(uri, headers: headers, body: encodedBody);
      case HttpMethod.patch:
        return _httpClient.patch(uri, headers: headers, body: encodedBody);
      case HttpMethod.delete:
        return _httpClient.delete(uri, headers: headers, body: encodedBody);
    }
  }

  Future<ApiResponse<dynamic>> _sendMultipart({
    required ApiEndpoint endpoint,
    required Uri uri,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
    List<int>? fileBytes,
    String? filePath,
    required String fileField,
    required String fileName,
  }) async {
    final String methodStr = switch (endpoint.method) {
      HttpMethod.post => 'POST',
      HttpMethod.patch => 'PATCH',
      HttpMethod.put => 'PUT',
      _ => 'POST',
    };

    final http.MultipartRequest request = http.MultipartRequest(methodStr, uri);
    request.headers.addAll(headers);

    if (body != null) {
      body.forEach((String key, dynamic value) {
        request.fields[key] = value.toString();
      });
    }

    if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName));
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath, filename: fileName));
    }

    final http.StreamedResponse streamed = await _httpClient.send(request);
    final http.Response response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  ApiResponse<dynamic> _handleResponse(http.Response response) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse<dynamic>(
        statusCode: response.statusCode,
        data: decoded,
        headers: response.headers,
      );
    }

    String? code;
    String? message;
    if (decoded is Map<String, dynamic>) {
      code = decoded['code'] as String?;
      message =
          decoded['detail'] as String? ??
          decoded['message'] as String? ??
          (decoded['error'] is Map
              ? decoded['error']['message'] as String?
              : decoded['error'] as String?);

      if (decoded['invalidParams'] is List && (decoded['invalidParams'] as List).isNotEmpty) {
        final List<dynamic> params = decoded['invalidParams'] as List<dynamic>;
        final String details = params
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> p) =>
                  '${p['name'] ?? 'bidang'}: ${p['reason'] ?? 'tidak valid'}',
            )
            .join(', ');
        if (details.isNotEmpty) {
          message = message != null && message.isNotEmpty ? '$message ($details)' : details;
        }
      }
    }

    switch (response.statusCode) {
      case 400:
      case 422:
        throw BadRequestException(message ?? 'Permintaan tidak valid.', code, decoded);
      case 401:
        throw UnauthorizedException(
          message ?? 'Kredensial salah atau sesi telah kedaluwarsa.',
          code,
        );
      case 403:
        throw ForbiddenException(message ?? 'Akses ditolak oleh server.', code: code);
      case 404:
        throw NotFoundException(message ?? 'Layanan tidak ditemukan.', code: code);
      case 409:
        throw ConflictException(message ?? 'Terjadi konflik data pada server.', code: code);
      default:
        throw ServerException(
          message ?? 'Terjadi kesalahan pada server (Status: ${response.statusCode}).',
          code,
          response.statusCode,
          decoded,
        );
    }
  }
}
