import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';
import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/auth_token_provider.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';

class MockTokenProvider implements AuthTokenProvider {
  String? token = 'mock_jwt_token_456';

  @override
  Future<String?> getToken() async => token;
}

void main() {
  group('HttpApiClient', () {
    test('sends GET request to correct endpoint url and parses json response', () async {
      final MockClient mockHttp = MockClient((http.Request request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'https://api.example.com/api/v1/clinics?active=true');
        return http.Response(jsonEncode(<Map<String, dynamic>>[{'id': 'c1', 'name': 'Poli Umum'}]), 200);
      });

      final ApiClient client = HttpApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockHttp,
      );

      const ApiEndpoint endpoint = ApiEndpoint(
        path: '/api/v1/clinics',
        method: HttpMethod.get,
      );

      final ApiResponse<dynamic> response = await client.request(
        endpoint,
        queryParameters: <String, String>{'active': 'true'},
      );

      expect(response.statusCode, 200);
      expect(response.isSuccessful, isTrue);
      expect(response.data, isA<List<dynamic>>());
    });

    test('throws UnauthorizedException on 401', () async {
      final MockClient mockHttp = MockClient((http.Request request) async {
        return http.Response('{"message": "Unauthorized"}', 401);
      });

      final ApiClient client = HttpApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockHttp,
      );

      const ApiEndpoint endpoint = ApiEndpoint(
        path: '/api/v1/auth/me',
        method: HttpMethod.get,
      );

      await expectLater(
        client.request(endpoint),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('throws ForbiddenException on 403 with SSOT backend message', () async {
      final MockClient mockHttp = MockClient((http.Request request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'code': 'NOT_AUTHORIZED',
            'message': 'Akun Google ini tidak memiliki undangan staf.',
          }),
          403,
        );
      });

      final ApiClient client = HttpApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockHttp,
      );

      const ApiEndpoint endpoint = ApiEndpoint(
        path: '/api/v1/auth/google',
        method: HttpMethod.post,
      );

      try {
        await client.request(endpoint);
        fail('Should throw ForbiddenException');
      } on ForbiddenException catch (e) {
        expect(e.message, 'Akun Google ini tidak memiliki undangan staf.');
        expect(e.code, 'NOT_AUTHORIZED');
      }
    });
  });

  group('AuthorizedApiClient', () {
    test('attaches Bearer token when endpoint requiresAuth is true', () async {
      final MockTokenProvider tokenProvider = MockTokenProvider();

      final MockClient mockHttp = MockClient((http.Request request) async {
        expect(request.headers['Authorization'], 'Bearer mock_jwt_token_456');
        return http.Response('{"id": "user_1"}', 200);
      });

      final ApiClient innerClient = HttpApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockHttp,
      );

      final ApiClient authorizedClient = AuthorizedApiClient(
        innerClient: innerClient,
        tokenProvider: tokenProvider,
      );

      const ApiEndpoint protectedEndpoint = ApiEndpoint(
        path: '/api/v1/auth/me',
        method: HttpMethod.get,
        requiresAuth: true,
      );

      final ApiResponse<dynamic> response =
          await authorizedClient.request(protectedEndpoint);
      expect(response.statusCode, 200);
    });

    test('does NOT attach Authorization header when endpoint requiresAuth is false', () async {
      final MockTokenProvider tokenProvider = MockTokenProvider();

      final MockClient mockHttp = MockClient((http.Request request) async {
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response('{"token": "new_token"}', 200);
      });

      final ApiClient innerClient = HttpApiClient(
        baseUrl: 'https://api.example.com',
        httpClient: mockHttp,
      );

      final ApiClient authorizedClient = AuthorizedApiClient(
        innerClient: innerClient,
        tokenProvider: tokenProvider,
      );

      const ApiEndpoint publicEndpoint = ApiEndpoint(
        path: '/api/v1/auth/email/login',
        method: HttpMethod.post,
        requiresAuth: false,
      );

      final ApiResponse<dynamic> response =
          await authorizedClient.request(publicEndpoint);
      expect(response.statusCode, 200);
    });
  });
}
