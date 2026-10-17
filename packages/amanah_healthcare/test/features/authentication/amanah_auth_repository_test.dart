import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:amanah_healthcare/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  String? _token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> deleteToken() async => _token = null;
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  http.Response? emailLoginResponse;
  http.Response? googleLoginResponse;
  http.Response? sessionResponse;
  http.Response? changePasswordResponse;
  bool signOutCalled = false;

  @override
  Future<http.Response> emailLogin(String identifier, String password) async =>
      emailLoginResponse ?? http.Response('{"error": "not configured"}', 500);

  @override
  Future<http.Response> googleLogin(String idToken) async =>
      googleLoginResponse ?? http.Response('{"error": "not configured"}', 500);

  @override
  Future<http.Response> getSession(String token) async =>
      sessionResponse ?? http.Response('{"error": "not configured"}', 500);

  @override
  Future<void> signOut(String? token) async {
    signOutCalled = true;
  }

  @override
  Future<http.Response> requestPasswordReset(String email) async =>
      http.Response('{"success": true}', 200);

  @override
  Future<http.Response> checkVerificationOtp(String email, String otp) async =>
      http.Response('{"success": true}', 200);

  @override
  Future<http.Response> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async =>
      http.Response('{"success": true}', 200);

  @override
  Future<http.Response> changePassword({
    required String oldPassword,
    required String newPassword,
    required String token,
  }) async =>
      changePasswordResponse ?? http.Response('{"success": true}', 200);

  @override
  Future<http.Response> fetchClinics() async =>
      http.Response('[{"id":"c1","code":"UMUM","name":"Poli Umum"}]', 200);

  @override
  Future<http.Response> submitStaffOnboarding(
    Map<String, dynamic> dto,
    String? token,
  ) async =>
      http.Response('{"user": {"id":"u1","fullName":"Staff","role":"staff"}}', 200);

  @override
  Future<http.Response> uploadAvatar({
    required String token,
    List<int>? fileBytes,
    String? filePath,
    String fileName = 'avatar.jpg',
    bool useAuthAlias = false,
  }) async =>
      http.Response('{"avatarUrl":"https://example.com/avatar.jpg"}', 200);

  @override
  Future<http.Response> deleteAvatar(String token) async =>
      http.Response('', 204);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeAuthLocalDataSource fakeLocal;
  late FakeAuthRemoteDataSource fakeRemote;
  late AmanahAuthRepository repository;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async => null,
    );
    fakeLocal = FakeAuthLocalDataSource();
    fakeRemote = FakeAuthRemoteDataSource();
    repository = AmanahAuthRepository(
      remoteDataSource: fakeRemote,
      localDataSource: fakeLocal,
    );
  });

  group('AmanahAuthRepository.authenticate', () {
    test('authenticates staff doctor successfully and saves token', () async {
      final Map<String, dynamic> responseBody = <String, dynamic>{
        'token': 'jwt_test_token_123',
        'user': <String, dynamic>{
          'id': 'doc_1',
          'fullName': 'dr. Zikri',
          'email': 'zikri@amanah.id',
          'role': 'doctor',
          'needsOnboarding': false,
        },
      };
      fakeRemote.emailLoginResponse = http.Response(
        jsonEncode(responseBody),
        200,
      );

      final AmanahAuthUser? user = await repository.authenticate(
        'zikri@amanah.id',
        'password123',
      );

      expect(user, isNotNull);
      expect(user!.id, 'doc_1');
      expect(user.role, AmanahUserRole.doctor);
      expect(await fakeLocal.getToken(), 'jwt_test_token_123');
    });

    test('throws InvalidCredentialsFailure on 401', () async {
      fakeRemote.emailLoginResponse = http.Response(
        '{"code": "INVALID_CREDENTIALS", "message": "Kredensial salah"}',
        401,
      );

      await expectLater(
        repository.authenticate('wrong@amanah.id', 'wrongpass'),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    test('throws PatientRestrictedFailure on 403 CLIENT_NOT_ALLOWED', () async {
      fakeRemote.emailLoginResponse = http.Response(
        jsonEncode(<String, dynamic>{
          'code': 'CLIENT_NOT_ALLOWED',
          'message': 'Akun Anda tidak memiliki akses ke aplikasi internal ini.',
        }),
        403,
      );

      await expectLater(
        repository.authenticate('pasien@gmail.com', 'password123'),
        throwsA(isA<PatientRestrictedFailure>()),
      );
    });

    test('throws PatientRestrictedFailure and signs out if patient role returned on 200', () async {
      final Map<String, dynamic> responseBody = <String, dynamic>{
        'token': 'jwt_patient_token',
        'user': <String, dynamic>{
          'id': 'pat_1',
          'fullName': 'Pasien Budi',
          'role': 'patient',
        },
      };
      fakeRemote.emailLoginResponse = http.Response(
        jsonEncode(responseBody),
        200,
      );

      await expectLater(
        repository.authenticate('budi@gmail.com', 'password123'),
        throwsA(isA<PatientRestrictedFailure>()),
      );
      expect(fakeRemote.signOutCalled, isTrue);
    });

    test('throws NotAuthorizedFailure with backend SSOT message when not invited', () async {
      const String ssotMessage =
          'Akun Google ini tidak memiliki undangan staf aktif di klinik.';
      fakeRemote.emailLoginResponse = http.Response(
        jsonEncode(<String, dynamic>{
          'code': 'NOT_AUTHORIZED',
          'message': ssotMessage,
        }),
        403,
      );

      try {
        await repository.authenticate('uninvited@gmail.com', 'password123');
        fail('Should throw NotAuthorizedFailure');
      } on NotAuthorizedFailure catch (e) {
        expect(e.message, ssotMessage);
        expect(e.code, 'NOT_AUTHORIZED');
      }
    });

    test('throws AccountInactiveFailure with backend SSOT message when inactive', () async {
      const String ssotMessage =
          'Akun Anda telah dinonaktifkan oleh faskes.';
      fakeRemote.emailLoginResponse = http.Response(
        jsonEncode(<String, dynamic>{
          'code': 'ACCOUNT_INACTIVE',
          'message': ssotMessage,
        }),
        403,
      );

      try {
        await repository.authenticate('inactive@amanah.id', 'password123');
        fail('Should throw AccountInactiveFailure');
      } on AccountInactiveFailure catch (e) {
        expect(e.message, ssotMessage);
        expect(e.code, 'ACCOUNT_INACTIVE');
      }
    });
  });

  group('AmanahAuthRepository.signInWithGoogle', () {
    test('authenticates invited Google user successfully', () async {
      fakeRemote.googleLoginResponse = http.Response(
        jsonEncode(<String, dynamic>{
          'token': 'google_jwt_token',
          'user': <String, dynamic>{
            'id': 'g_doc_1',
            'fullName': 'dr. Google User',
            'email': 'gdoc@gmail.com',
            'role': 'doctor',
            'needsOnboarding': false,
          },
        }),
        200,
      );

      final AmanahAuthUser? user =
          await repository.signInWithGoogle('google_id_token_xyz');

      expect(user, isNotNull);
      expect(user!.fullName, 'dr. Google User');
      expect(await fakeLocal.getToken(), 'google_jwt_token');
    });

    test('throws NotAuthorizedFailure if uninvited Google account signs in', () async {
      fakeRemote.googleLoginResponse = http.Response(
        jsonEncode(<String, dynamic>{
          'code': 'NOT_AUTHORIZED',
          'message': 'Akun Google ini tidak terdaftar sebagai staf medis.',
        }),
        403,
      );

      await expectLater(
        repository.signInWithGoogle('uninvited_id_token'),
        throwsA(isA<NotAuthorizedFailure>()),
      );
    });
  });

  group('AmanahAuthRepository session & signout', () {
    test('getSession restores active session', () async {
      await fakeLocal.saveToken('existing_token');
      fakeRemote.sessionResponse = http.Response(
        jsonEncode(<String, dynamic>{
          'user': <String, dynamic>{
            'id': 'active_user',
            'fullName': 'dr. Active',
            'role': 'doctor',
            'needsOnboarding': false,
          },
        }),
        200,
      );

      final AmanahAuthUser? user = await repository.getSession();
      expect(user, isNotNull);
      expect(user!.id, 'active_user');
      expect(await fakeLocal.getToken(), 'existing_token');
    });

    test('getSession deletes token on 401 unauthorized', () async {
      await fakeLocal.saveToken('expired_token');
      fakeRemote.sessionResponse = http.Response(
        '{"message": "Unauthorized"}',
        401,
      );

      final AmanahAuthUser? user = await repository.getSession();
      expect(user, isNull);
      expect(await fakeLocal.getToken(), isNull);
    });

    test('signOut clears token from local storage', () async {
      await fakeLocal.saveToken('token_to_remove');
      await repository.signOut();
      expect(await fakeLocal.getToken(), isNull);
      expect(fakeRemote.signOutCalled, isTrue);
    });

    test('changePassword returns true when server responds 200', () async {
      await fakeLocal.saveToken('valid_token');
      fakeRemote.changePasswordResponse = http.Response(
        '{"id": "user-1", "name": "Dr. User"}',
        200,
      );

      final bool success = await repository.changePassword(
        oldPassword: 'OldPassword123!',
        newPassword: 'NewPassword123!',
      );

      expect(success, isTrue);
    });

    test('changePassword throws ServerFailure with custom message on incorrectOldPassword', () async {
      await fakeLocal.saveToken('valid_token');
      fakeRemote.changePasswordResponse = http.Response(
        '{"statusCode": 422, "errors": {"oldPassword": "incorrectOldPassword"}}',
        422,
      );

      expect(
        () => repository.changePassword(
          oldPassword: 'WrongPassword!',
          newPassword: 'NewPassword123!',
        ),
        throwsA(
          isA<ServerFailure>().having(
            (ServerFailure f) => f.message,
            'message',
            contains('Kata sandi saat ini tidak sesuai'),
          ),
        ),
      );
    });

    test('changePassword throws ServerFailure when user has no active token', () async {
      await fakeLocal.deleteToken();

      expect(
        () => repository.changePassword(
          oldPassword: 'OldPassword123!',
          newPassword: 'NewPassword123!',
        ),
        throwsA(
          isA<ServerFailure>().having(
            (ServerFailure f) => f.message,
            'message',
            contains('Sesi Anda telah kedaluwarsa'),
          ),
        ),
      );
    });
  });
}
