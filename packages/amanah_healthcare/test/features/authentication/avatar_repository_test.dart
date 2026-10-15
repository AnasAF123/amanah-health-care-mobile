import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/authentication/domain/user_avatar.dart';

class FakeAuthTokenStorage extends AmanahAuthTokenStorage {
  FakeAuthTokenStorage([this._token = 'valid-jwt-token']);
  String? _token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> deleteToken() async => _token = null;

  @override
  Future<bool> hasToken() async => _token != null && _token!.isNotEmpty;
}

class MockHttpClient extends http.BaseClient {
  MockHttpClient(this._handler);
  final Future<http.StreamedResponse> Function(http.BaseRequest request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _handler(request);
}

void main() {
  group('AmanahAuthRepository Avatar Lifecycle Tests', () {
    test('uploadAvatar sends multipart request and parses UserAvatar response', () async {
      late http.BaseRequest capturedRequest;

      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        capturedRequest = req;
        expect(req.method, 'PATCH');
        expect(req.url.path, '/api/v1/users/me/avatar');
        expect(req.headers['Authorization'], 'Bearer valid-jwt-token');

        final String responseBody = jsonEncode(<String, dynamic>{
          'avatar': <String, dynamic>{
            'url': '/api/v1/users/usr-123/avatar',
            'initials': 'AS',
            'type': 'custom',
            'hasCustomAvatar': true,
            'directUrl': 'http://localhost:3001/api/v1/users/usr-123/avatar?v=1710000000',
          },
        });

        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode(responseBody)),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: mockClient,
        tokenStorage: FakeAuthTokenStorage(),
      );

      final UserAvatar avatar = await repo.uploadAvatar(
        fileBytes: <int>[1, 2, 3, 4],
        fileName: 'profile.webp',
      );

      expect(avatar.url, '/api/v1/users/usr-123/avatar');
      expect(avatar.initials, 'AS');
      expect(avatar.type, 'custom');
      expect(avatar.hasCustomAvatar, isTrue);
      expect(avatar.directUrl, 'http://localhost:3001/api/v1/users/usr-123/avatar?v=1710000000');
      expect(capturedRequest is http.MultipartRequest, isTrue);
    });

    test('uploadAvatar with useAuthAlias sends POST to /api/v1/auth/me/avatar', () async {
      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        expect(req.method, 'POST');
        expect(req.url.path, '/api/v1/auth/me/avatar');

        final String responseBody = jsonEncode(<String, dynamic>{
          'avatar': <String, dynamic>{
            'url': '/api/v1/users/usr-123/avatar',
            'initials': 'AS',
            'type': 'custom',
            'hasCustomAvatar': true,
          },
        });

        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode(responseBody)),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: mockClient,
        tokenStorage: FakeAuthTokenStorage(),
      );

      final UserAvatar avatar = await repo.uploadAvatar(
        fileBytes: <int>[255, 216, 255, 224],
        fileName: 'photo.jpg',
        useAuthAlias: true,
      );

      expect(avatar.hasCustomAvatar, isTrue);
      expect(avatar.type, 'custom');
    });

    test('fetchStaffOnboardingPolikliniks decodes active clinics from backend', () async {
      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        expect(req.method, 'GET');
        expect(req.url.path, '/api/v1/clinics');

        final String responseBody = jsonEncode(<Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'clinic-umum-id',
            'namaPoli': 'Poli Umum',
            'kodePoli': 'POLI-UMUM',
            'isActive': true,
          },
          <String, dynamic>{
            'id': 'clinic-kia-id',
            'namaPoli': 'Poli KIA',
            'kodePoli': 'POLI-KIA',
            'isActive': true,
          },
        ]);

        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode(responseBody)),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: mockClient,
        tokenStorage: FakeAuthTokenStorage(),
      );

      final List<StaffOnboardingPoliOption> polikliniks =
          await repo.fetchStaffOnboardingPolikliniks();

      expect(polikliniks, hasLength(2));
      expect(polikliniks.first.id, 'clinic-umum-id');
      expect(polikliniks.first.name, 'Poli Umum');
      expect(polikliniks.first.code, 'POLI-UMUM');
    });

    test('uploadAvatar handles HTTP 422 magic-byte validation error', () async {
      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode(jsonEncode(<String, dynamic>{
            'error': 'Unsupported format',
          }))),
          422,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: mockClient,
        tokenStorage: FakeAuthTokenStorage(),
      );

      expect(
        () => repo.uploadAvatar(fileBytes: <int>[0, 0, 0, 0]),
        throwsA(isA<AmanahAuthException>().having(
          (AmanahAuthException e) => e.message,
          'message',
          contains('bukan format gambar yang didukung'),
        )),
      );
    });

    test('uploadAvatar throws when no token present in storage', () async {
      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: MockHttpClient((_) async => throw UnimplementedError()),
        tokenStorage: FakeAuthTokenStorage(null),
      );

      expect(
        () => repo.uploadAvatar(fileBytes: <int>[1, 2, 3]),
        throwsA(isA<AmanahAuthException>().having(
          (AmanahAuthException e) => e.message,
          'message',
          contains('Sesi Anda telah kedaluwarsa'),
        )),
      );
    });

    test('deleteAvatar sends DELETE request and returns true on 200', () async {
      late http.BaseRequest capturedRequest;

      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        capturedRequest = req;
        expect(req.method, 'DELETE');
        expect(req.url.path, '/api/v1/users/me/avatar');
        expect(req.headers['Authorization'], 'Bearer valid-jwt-token');

        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode(jsonEncode(<String, dynamic>{
            'success': true,
          }))),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: mockClient,
        tokenStorage: FakeAuthTokenStorage(),
      );

      final bool result = await repo.deleteAvatar();
      expect(result, isTrue);
      expect(capturedRequest.method, 'DELETE');
    });

    test('deleteAvatar throws when HTTP 401 unauthenticated', () async {
      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode(jsonEncode(<String, dynamic>{
            'message': 'Unauthorized',
          }))),
          401,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: mockClient,
        tokenStorage: FakeAuthTokenStorage(),
      );

      expect(
        () => repo.deleteAvatar(),
        throwsA(isA<AmanahAuthException>().having(
          (AmanahAuthException e) => e.message,
          'message',
          contains('Sesi Anda telah kedaluwarsa'),
        )),
      );
    });
  });
}
