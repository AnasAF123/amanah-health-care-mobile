import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/client/amanah_http_client.dart';
import 'package:amanah_healthcare/core/network/client/observable_http_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/authentication/data/endpoints/auth_endpoints.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';

class StaffCredentialRepository {
  const StaffCredentialRepository({
    String? baseUrl,
    http.Client? httpClient,
    AmanahAuthTokenStorage tokenStorage = const AmanahAuthTokenStorage(),
  })  : _customBaseUrl = baseUrl,
        _customClient = httpClient,
        _tokenStorage = tokenStorage;

  final String? _customBaseUrl;
  final http.Client? _customClient;
  final AmanahAuthTokenStorage _tokenStorage;

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

  /// 0. Ambil data profil staf dokter login saat ini (authoritative SSOT)
  /// Endpoint: GET /api/v1/staffs/me
  Future<AmanahStaffProfile> getMyProfile() async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }

    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.staffProfile}');
    final http.Response response = await _httpClient.get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return AmanahStaffProfile.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw const AmanahAuthException('Gagal memuat profil staf dari server.');
  }

  /// 1. Ambil daftar SIP / STR dokter login
  /// Endpoint: GET /api/v1/staffs/me/credentials
  Future<List<StaffCredentialModel>> getMyCredentials() async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) return <StaffCredentialModel>[];

    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.staffCredentials}');
    final http.Response response = await _httpClient.get(
      uri,
      headers: <String, String>{'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .map((dynamic e) => StaffCredentialModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <StaffCredentialModel>[];
    } else {
      throw const AmanahAuthException('Gagal memuat kredensial medis dari server.');
    }
  }

  /// 2. Tambah SIP / STR baru
  /// Endpoint: POST /api/v1/staffs/me/credentials
  Future<StaffCredentialModel> addCredential({
    required CredentialType type,
    required String number,
    String? issuer,
    String? issuedAt,
    String? expiresAt,
  }) async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }

    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.staffCredentials}');
    final http.Response response = await _httpClient.post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'credentialType': type.toApiValue(),
        'credentialNumber': number.trim(),
        if (issuer != null && issuer.trim().isNotEmpty) 'issuer': issuer.trim(),
        if (issuedAt != null && issuedAt.trim().isNotEmpty) 'issuedAt': issuedAt.trim(),
        if (expiresAt != null && expiresAt.trim().isNotEmpty) 'expiresAt': expiresAt.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StaffCredentialModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw const AmanahAuthException('Gagal menambahkan kredensial medis.');
  }

  /// 3. Update SIP / STR yang sudah ada
  /// Endpoint: PATCH /api/v1/staffs/me/credentials/:credentialId
  Future<StaffCredentialModel> updateCredential({
    required String credentialId,
    String? number,
    String? issuer,
    String? expiresAt,
    String? status,
  }) async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }

    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.staffCredentials}/$credentialId');
    final http.Response response = await _httpClient.patch(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        if (number != null && number.trim().isNotEmpty) 'credentialNumber': number.trim(),
        if (issuer != null && issuer.trim().isNotEmpty) 'issuer': issuer.trim(),
        if (expiresAt != null && expiresAt.trim().isNotEmpty) 'expiresAt': expiresAt.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim().toLowerCase(),
      }),
    );

    if (response.statusCode == 200) {
      return StaffCredentialModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw const AmanahAuthException('Gagal memperbarui kredensial medis.');
  }

  /// 4. Hapus kredensial
  /// Endpoint: DELETE /api/v1/staffs/me/credentials/:credentialId
  Future<bool> deleteCredential(String credentialId) async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }

    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.staffCredentials}/$credentialId');
    final http.Response response = await _httpClient.delete(
      uri,
      headers: <String, String>{'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// 5. Self-update data profil staf dokter (Data Pribadi, Kontak, Alamat Domisili)
  /// Endpoint: PATCH /api/v1/staffs/me
  Future<AmanahStaffProfile> updateMyProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? birthPlace,
    String? birthDate,
    String? gender,
    String? nationalId,
    String? licenseNumber,
    Map<String, dynamic>? address,
  }) async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }

    final Uri uri = Uri.parse('$_baseUrl${AuthEndpoints.staffProfile}');
    final http.Response response = await _httpClient.patch(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        if (fullName != null && fullName.trim().isNotEmpty) 'fullName': fullName.trim(),
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty) 'phoneNumber': phoneNumber.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (birthPlace != null && birthPlace.trim().isNotEmpty) 'birthPlace': birthPlace.trim(),
        if (birthDate != null && birthDate.trim().isNotEmpty) 'birthDate': birthDate.trim(),
        if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim().toLowerCase(),
        if (nationalId != null && nationalId.trim().isNotEmpty) 'nationalId': nationalId.trim(),
        if (licenseNumber != null && licenseNumber.trim().isNotEmpty) 'licenseNumber': licenseNumber.trim(),
        if (address != null && address.isNotEmpty) 'address': address,
      }),
    );

    if (response.statusCode == 200) {
      return AmanahStaffProfile.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw const AmanahAuthException('Gagal memperbarui profil.');
  }
}
