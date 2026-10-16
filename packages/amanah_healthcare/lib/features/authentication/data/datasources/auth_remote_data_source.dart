import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/constants/auth_endpoints.dart';
import 'package:amanah_healthcare/core/constants/auth_schemes.dart';
import 'package:amanah_healthcare/core/constants/client_id.dart';
import 'package:amanah_healthcare/core/constants/http_header_names.dart';
import 'package:amanah_healthcare/core/constants/mime_types.dart';
import 'package:amanah_healthcare/core/network/client/amanah_http_client.dart';
import 'package:amanah_healthcare/core/network/client/observable_http_client.dart';

abstract interface class AuthRemoteDataSource {
  Future<http.Response> emailLogin(String identifier, String password);
  Future<http.Response> googleLogin(String idToken);
  Future<http.Response> getSession(String token);
  Future<void> signOut(String? token);
  Future<http.Response> requestPasswordReset(String email);
  Future<http.Response> checkVerificationOtp(String email, String otp);
  Future<http.Response> resetPassword(
    String email,
    String otp,
    String newPassword,
  );
  Future<http.Response> changePassword({
    required String oldPassword,
    required String newPassword,
    required String token,
  });
  Future<http.Response> fetchClinics();
  Future<http.Response> submitStaffOnboarding(
    Map<String, dynamic> dto,
    String? token,
  );
  Future<http.Response> uploadAvatar({
    required String token,
    List<int>? fileBytes,
    String? filePath,
    String fileName = 'avatar.jpg',
    bool useAuthAlias = false,
  });
  Future<http.Response> deleteAvatar(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    String? baseUrl,
    http.Client? httpClient,
  })  : _customBaseUrl = baseUrl,
        _customClient = httpClient;

  final String? _customBaseUrl;
  final http.Client? _customClient;

  String get _baseUrl =>
      _customBaseUrl ?? AmanahAuthEnvironment.authBaseUrl;

  http.Client get _httpClient {
    final http.Client? custom = _customClient;
    if (custom != null) {
      return custom is ObservableHttpClient
          ? custom
          : ObservableHttpClient(innerClient: custom);
    }
    return AmanahHttpClient.instance;
  }

  Map<String, String> _headers({String? token}) {
    return <String, String>{
      HttpHeaderNames.contentType: MimeTypes.applicationJson,
      HttpHeaderNames.accept: MimeTypes.applicationJson,
      if (token != null && token.isNotEmpty)
        HttpHeaderNames.authorization: '${AuthSchemes.bearer} $token',
    };
  }

  @override
  Future<http.Response> emailLogin(String identifier, String password) {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.emailLogin}');
    return _httpClient.post(
      uri,
      headers: _headers(),
      body: jsonEncode(<String, dynamic>{
        'email': identifier.trim(),
        'password': password,
        'clientId': ClientId.mobileInternal,
      }),
    );
  }

  @override
  Future<http.Response> googleLogin(String idToken) {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.googleLogin}');
    return _httpClient.post(
      uri,
      headers: _headers(),
      body: jsonEncode(<String, dynamic>{
        'idToken': idToken,
        'clientId': ClientId.mobileInternal,
      }),
    );
  }

  @override
  Future<http.Response> getSession(String token) {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.session}');
    return _httpClient.get(uri, headers: _headers(token: token));
  }

  @override
  Future<void> signOut(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.signOut}');
      await _httpClient.post(uri, headers: _headers(token: token));
    } catch (_) {}
  }

  @override
  Future<http.Response> requestPasswordReset(String email) {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.requestPasswordReset}');
    return _httpClient.post(
      uri,
      headers: _headers(),
      body: jsonEncode(<String, dynamic>{'email': email.trim()}),
    );
  }

  @override
  Future<http.Response> checkVerificationOtp(String email, String otp) {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.checkVerificationOtp}');
    return _httpClient.post(
      uri,
      headers: _headers(),
      body: jsonEncode(<String, dynamic>{
        'email': email.trim(),
        'type': 'forget-password',
        'otp': otp.trim(),
      }),
    );
  }

  @override
  Future<http.Response> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.resetPassword}');
    return _httpClient.post(
      uri,
      headers: _headers(),
      body: jsonEncode(<String, dynamic>{
        'email': email.trim(),
        'otp': otp.trim(),
        'password': newPassword,
      }),
    );
  }

  @override
  Future<http.Response> changePassword({
    required String oldPassword,
    required String newPassword,
    required String token,
  }) {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.changePassword}');
    return _httpClient.patch(
      uri,
      headers: _headers(token: token),
      body: jsonEncode(<String, dynamic>{
        'oldPassword': oldPassword,
        'password': newPassword,
      }),
    );
  }

  @override
  Future<http.Response> fetchClinics() {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.clinics}');
    return _httpClient.get(uri, headers: _headers());
  }

  @override
  Future<http.Response> submitStaffOnboarding(
    Map<String, dynamic> dto,
    String? token,
  ) {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.staffOnboarding}');
    return _httpClient.post(
      uri,
      headers: _headers(token: token),
      body: jsonEncode(dto),
    );
  }

  @override
  Future<http.Response> uploadAvatar({
    required String token,
    List<int>? fileBytes,
    String? filePath,
    String fileName = 'avatar.jpg',
    bool useAuthAlias = false,
  }) async {
    final String path =
        useAuthAlias ? AuthEndpoints.avatarAuthAlias : AuthEndpoints.avatar;
    final Uri uri = Uri.parse('$_baseUrl$path');

    final http.MultipartRequest request =
        http.MultipartRequest(useAuthAlias ? 'POST' : 'PATCH', uri);
    request.headers[HttpHeaderNames.authorization] =
        '${AuthSchemes.bearer} $token';
    request.headers[HttpHeaderNames.accept] = MimeTypes.applicationJson;

    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );
    } else if (filePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath, filename: fileName),
      );
    }

    final http.StreamedResponse streamed = await _httpClient.send(request);
    return http.Response.fromStream(streamed);
  }

  @override
  Future<http.Response> deleteAvatar(String token) {
    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.avatar}');
    return _httpClient.delete(uri, headers: _headers(token: token));
  }
}
