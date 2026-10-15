import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';

class FakeAuthTokenStorage extends AmanahAuthTokenStorage {
  FakeAuthTokenStorage([this._token = 'test-doctor-token']);
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
  group('CredentialType & StaffCredentialModel Domain Tests', () {
    test('CredentialType toApiValue produces strictly lowercase API strings', () {
      expect(CredentialType.sip.toApiValue(), 'sip');
      expect(CredentialType.str.toApiValue(), 'str');
      expect(CredentialType.kki.toApiValue(), 'kki');
      expect(CredentialType.npwp.toApiValue(), 'npwp');
      expect(CredentialType.nib.toApiValue(), 'nib');
      expect(CredentialType.nationalId.toApiValue(), 'national_id');
      expect(CredentialType.other.toApiValue(), 'other');
    });

    test('CredentialType fromApiValue parses uppercase, lowercase, and unknown values safely', () {
      expect(CredentialType.fromApiValue('sip'), CredentialType.sip);
      expect(CredentialType.fromApiValue('SIP'), CredentialType.sip);
      expect(CredentialType.fromApiValue('str'), CredentialType.str);
      expect(CredentialType.fromApiValue('STR'), CredentialType.str);
      expect(CredentialType.fromApiValue('kki'), CredentialType.kki);
      expect(CredentialType.fromApiValue('npwp'), CredentialType.npwp);
      expect(CredentialType.fromApiValue('nib'), CredentialType.nib);
      expect(CredentialType.fromApiValue('national_id'), CredentialType.nationalId);
      expect(CredentialType.fromApiValue('NIK'), CredentialType.nationalId);
      expect(CredentialType.fromApiValue('UNKNOWN_TYPE'), CredentialType.other);
      expect(CredentialType.fromApiValue(null), CredentialType.other);
    });

    test('StaffCredentialModel JSON serialization and deserialization roundtrip', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'cred-001',
        'staffProfileId': 'staff-123',
        'credentialType': 'sip',
        'credentialNumber': '503/4421/SIP-D/2026',
        'issuer': 'Dinas Kesehatan Kota Bandung',
        'issuedAt': '2024-01-01',
        'expiresAt': '2029-01-01',
        'status': 'verified',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final StaffCredentialModel model = StaffCredentialModel.fromJson(json);

      expect(model.id, 'cred-001');
      expect(model.staffProfileId, 'staff-123');
      expect(model.credentialType, CredentialType.sip);
      expect(model.credentialNumber, '503/4421/SIP-D/2026');
      expect(model.issuer, 'Dinas Kesehatan Kota Bandung');
      expect(model.status, 'verified');
      expect(model.isVerified, isTrue);
      expect(model.statusDisplayLabel, 'Terverifikasi');

      final Map<String, dynamic> serialized = model.toJson();
      expect(serialized['credentialType'], 'sip');
      expect(serialized['status'], 'verified');
      expect(serialized['credentialNumber'], '503/4421/SIP-D/2026');
    });

    test('StaffCredentialModel status badges and helper getters', () {
      const StaffCredentialModel unverified = StaffCredentialModel(
        id: '1',
        staffProfileId: 's1',
        credentialType: CredentialType.str,
        credentialNumber: 'STR-999',
        status: 'unverified',
      );
      expect(unverified.isVerified, isFalse);
      expect(unverified.statusDisplayLabel, 'Menunggu Verifikasi');

      const StaffCredentialModel expired = StaffCredentialModel(
        id: '2',
        staffProfileId: 's1',
        credentialType: CredentialType.str,
        credentialNumber: 'STR-999',
        status: 'expired',
      );
      expect(expired.isVerified, isFalse);
      expect(expired.statusDisplayLabel, 'Kedaluwarsa');

      const StaffCredentialModel revoked = StaffCredentialModel(
        id: '3',
        staffProfileId: 's1',
        credentialType: CredentialType.str,
        credentialNumber: 'STR-999',
        status: 'revoked',
      );
      expect(revoked.statusDisplayLabel, 'Dicabut');
    });

    test('StaffCredentialModel copyWith and equality work accurately', () {
      const StaffCredentialModel cred1 = StaffCredentialModel(
        id: 'cred-1',
        staffProfileId: 's-1',
        credentialType: CredentialType.sip,
        credentialNumber: 'SIP-100',
        status: 'verified',
      );

      final StaffCredentialModel cred2 = cred1.copyWith(
        credentialNumber: 'SIP-200',
        issuer: 'Kemenkes RI',
      );

      expect(cred2.id, cred1.id);
      expect(cred2.credentialNumber, 'SIP-200');
      expect(cred2.issuer, 'Kemenkes RI');
      expect(cred1 == cred2, isFalse);

      final StaffCredentialModel credClone = cred1.copyWith();
      expect(credClone, cred1);
      expect(credClone.hashCode, cred1.hashCode);
    });
  });

  group('AmanahAuthRepository Credential & Self-Update API Tests', () {
    test('getMyCredentials sends GET /api/v1/staffs/me/credentials and parses list', () async {
      late http.BaseRequest capturedRequest;

      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        capturedRequest = req;
        expect(req.method, 'GET');
        expect(req.url.path, '/api/v1/staffs/me/credentials');
        expect(req.headers['Authorization'], 'Bearer test-doctor-token');

        final String responseBody = jsonEncode(<Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'e0a29792-7104-41d3-9f5b-11c521eb231f',
            'staffProfileId': '0db995d3-88bc-4aa6-bfd1-a20c329dcbff',
            'credentialType': 'sip',
            'credentialNumber': '446/123/SIP-D/DPMPTSP/2024',
            'issuer': 'Dinas Kesehatan Kota Bandung',
            'issuedAt': '2024-01-01',
            'expiresAt': '2029-01-01',
            'status': 'verified',
          },
          <String, dynamic>{
            'id': 'e0a29792-7104-41d3-9f5b-11c521eb2320',
            'staffProfileId': '0db995d3-88bc-4aa6-bfd1-a20c329dcbff',
            'credentialType': 'str',
            'credentialNumber': '31.1.1.100.1.20.123456',
            'issuer': 'Konsil Kedokteran Indonesia (KKI)',
            'issuedAt': '2023-06-01',
            'expiresAt': '2028-06-01',
            'status': 'verified',
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

      final List<StaffCredentialModel> list = await repo.getMyCredentials();

      expect(list.length, 2);
      expect(list[0].credentialType, CredentialType.sip);
      expect(list[0].credentialNumber, '446/123/SIP-D/DPMPTSP/2024');
      expect(list[1].credentialType, CredentialType.str);
      expect(list[1].credentialNumber, '31.1.1.100.1.20.123456');
      expect(capturedRequest.url.path, '/api/v1/staffs/me/credentials');
    });

    test('getMyCredentials returns empty list immediately when no token is present', () async {
      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: MockHttpClient((_) async => throw StateError('Should not be called')),
        tokenStorage: FakeAuthTokenStorage(null),
      );

      final List<StaffCredentialModel> list = await repo.getMyCredentials();
      expect(list, isEmpty);
    });

    test('addCredential sends POST /api/v1/staffs/me/credentials with lowercase type', () async {
      late String capturedBody;

      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        expect(req.method, 'POST');
        expect(req.url.path, '/api/v1/staffs/me/credentials');
        expect(req.headers['Authorization'], 'Bearer test-doctor-token');

        if (req is http.Request) {
          capturedBody = req.body;
        }

        final String responseBody = jsonEncode(<String, dynamic>{
          'id': 'new-cred-123',
          'staffProfileId': 'staff-1',
          'credentialType': 'str',
          'credentialNumber': 'STR-2026-888',
          'issuer': 'KKI',
          'issuedAt': '2024-05-10',
          'expiresAt': '2029-05-10',
          'status': 'unverified',
        });

        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode(responseBody)),
          201,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: mockClient,
        tokenStorage: FakeAuthTokenStorage(),
      );

      final StaffCredentialModel result = await repo.addCredential(
        type: CredentialType.str,
        number: 'STR-2026-888',
        issuer: 'KKI',
        issuedAt: '2024-05-10',
        expiresAt: '2029-05-10',
      );

      expect(result.id, 'new-cred-123');
      expect(result.credentialType, CredentialType.str);
      expect(result.credentialNumber, 'STR-2026-888');

      final Map<String, dynamic> bodyJson =
          jsonDecode(capturedBody) as Map<String, dynamic>;
      expect(bodyJson['credentialType'], 'str'); // Must be lowercase
      expect(bodyJson['credentialNumber'], 'STR-2026-888');
      expect(bodyJson['issuer'], 'KKI');
    });

    test('updateCredential sends PATCH /api/v1/staffs/me/credentials/:credentialId', () async {
      late String capturedPath;
      late String capturedBody;

      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        capturedPath = req.url.path;
        expect(req.method, 'PATCH');
        expect(req.headers['Authorization'], 'Bearer test-doctor-token');

        if (req is http.Request) {
          capturedBody = req.body;
        }

        final String responseBody = jsonEncode(<String, dynamic>{
          'id': 'cred-999',
          'staffProfileId': 'staff-1',
          'credentialType': 'sip',
          'credentialNumber': '503/4421/SIP-RENEWED/2026',
          'issuer': 'Dinkes Jabar',
          'expiresAt': '2031-01-01',
          'status': 'verified',
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

      final StaffCredentialModel result = await repo.updateCredential(
        credentialId: 'cred-999',
        number: '503/4421/SIP-RENEWED/2026',
        issuer: 'Dinkes Jabar',
        expiresAt: '2031-01-01',
        status: 'verified',
      );

      expect(capturedPath, '/api/v1/staffs/me/credentials/cred-999');
      expect(result.credentialNumber, '503/4421/SIP-RENEWED/2026');
      expect(result.status, 'verified');

      final Map<String, dynamic> bodyJson =
          jsonDecode(capturedBody) as Map<String, dynamic>;
      expect(bodyJson['credentialNumber'], '503/4421/SIP-RENEWED/2026');
      expect(bodyJson['status'], 'verified');
    });

    test('deleteCredential sends DELETE /api/v1/staffs/me/credentials/:credentialId', () async {
      late String capturedPath;

      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        capturedPath = req.url.path;
        expect(req.method, 'DELETE');
        expect(req.headers['Authorization'], 'Bearer test-doctor-token');

        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode(jsonEncode(<String, dynamic>{'success': true}))),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: mockClient,
        tokenStorage: FakeAuthTokenStorage(),
      );

      final bool success = await repo.deleteCredential('cred-to-delete');

      expect(capturedPath, '/api/v1/staffs/me/credentials/cred-to-delete');
      expect(success, isTrue);
    });

    test('updateMyProfile sends PATCH /api/v1/staffs/me with fullName and phone, never email', () async {
      late String capturedBody;

      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        expect(req.method, 'PATCH');
        expect(req.url.path, '/api/v1/staffs/me');
        expect(req.headers['Authorization'], 'Bearer test-doctor-token');

        if (req is http.Request) {
          capturedBody = req.body;
        }

        final String responseBody = jsonEncode(<String, dynamic>{
          'id': 'staff-001',
          'userId': 'usr-001',
          'fullName': 'dr. Andika Perkasa, Sp.A',
          'phoneNumber': '+62 811-2233-4455',
          'profession': 'Dokter Spesialis Anak',
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

      final AmanahStaffProfile profile = await repo.updateMyProfile(
        fullName: 'dr. Andika Perkasa, Sp.A',
        phoneNumber: '+62 811-2233-4455',
      );

      expect(profile.fullName, 'dr. Andika Perkasa, Sp.A');
      expect(profile.phoneNumber, '+62 811-2233-4455');

      final Map<String, dynamic> bodyJson =
          jsonDecode(capturedBody) as Map<String, dynamic>;
      expect(bodyJson['fullName'], 'dr. Andika Perkasa, Sp.A');
      expect(bodyJson['phoneNumber'], '+62 811-2233-4455');
      // Immutable Email verification: key 'email' must NOT be present
      expect(bodyJson.containsKey('email'), isFalse);
    });

    test('API error handling throws AmanahAuthException with server error message', () async {
      final MockHttpClient mockClient = MockHttpClient((http.BaseRequest req) async {
        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode(jsonEncode(<String, dynamic>{
            'message': 'Format nomor SIP tidak valid untuk wilayah Jawa Barat.',
          }))),
          400,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahAuthRepository repo = AmanahAuthRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: mockClient,
        tokenStorage: FakeAuthTokenStorage(),
      );

      expect(
        () => repo.addCredential(
          type: CredentialType.sip,
          number: 'BAD-SIP',
        ),
        throwsA(isA<AmanahAuthException>().having(
          (AmanahAuthException e) => e.message,
          'message',
          contains('Format nomor SIP tidak valid'),
        )),
      );
    });
  });
}
