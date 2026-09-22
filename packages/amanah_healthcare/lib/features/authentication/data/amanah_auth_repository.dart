import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';

class AmanahAuthException implements Exception {
  const AmanahAuthException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AmanahAuthPatientRestrictedException extends AmanahAuthException {
  const AmanahAuthPatientRestrictedException()
      : super(
          'Akun Anda terdaftar sebagai pasien. Aplikasi ini khusus staf medis klinik.',
          code: 'PATIENT_RESTRICTED',
        );
}

class StaffOnboardingPoliOption {
  const StaffOnboardingPoliOption({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory StaffOnboardingPoliOption.fromJson(Map<String, dynamic> json) {
    return StaffOnboardingPoliOption(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? json['kodePoli'] as String? ?? '',
      name: json['name'] as String? ?? json['namaPoli'] as String? ?? '',
      description:
          json['description'] as String? ?? json['deskripsi'] as String?,
    );
  }

  final String id;
  final String code;
  final String name;
  final String? description;
}

class AmanahAuthRepository {
  const AmanahAuthRepository({
    String? baseUrl,
    http.Client? httpClient,
    AmanahAuthTokenStorage tokenStorage = const AmanahAuthTokenStorage(),
  })  : _customBaseUrl = baseUrl,
        _customClient = httpClient,
        _tokenStorage = tokenStorage;

  final String? _customBaseUrl;
  final http.Client? _customClient;
  final AmanahAuthTokenStorage _tokenStorage;

  String get _baseUrl {
    if (_customBaseUrl != null) return _customBaseUrl;
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  http.Client get _httpClient => _customClient ?? http.Client();
  AmanahAuthTokenStorage get tokenStorage => _tokenStorage;

  /// Internal POST helper with complete observability logging
  Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final Map<String, String> resolvedHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    AmanahAuthLogger.logRequest(
      'POST',
      uri,
      headers: resolvedHeaders,
      body: body,
    );

    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final http.Response response = await _httpClient.post(
        uri,
        headers: resolvedHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      stopwatch.stop();

      AmanahAuthLogger.logResponse(
        'POST',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError(
        'POST',
        uri,
        e,
        stackTrace: stack,
        elapsed: stopwatch.elapsed,
      );
      rethrow;
    }
  }

  /// Internal GET helper with complete observability logging
  Future<http.Response> _get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final Map<String, String> resolvedHeaders = <String, String>{
      'Accept': 'application/json',
      ...?headers,
    };

    AmanahAuthLogger.logRequest(
      'GET',
      uri,
      headers: resolvedHeaders,
    );

    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final http.Response response = await _httpClient.get(
        uri,
        headers: resolvedHeaders,
      );
      stopwatch.stop();

      AmanahAuthLogger.logResponse(
        'GET',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError(
        'GET',
        uri,
        e,
        stackTrace: stack,
        elapsed: stopwatch.elapsed,
      );
      rethrow;
    }
  }

  /// Internal PATCH helper with complete observability logging
  Future<http.Response> _patch(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final Map<String, String> resolvedHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    AmanahAuthLogger.logRequest(
      'PATCH',
      uri,
      headers: resolvedHeaders,
      body: body,
    );

    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final http.Response response = await _httpClient.patch(
        uri,
        headers: resolvedHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      stopwatch.stop();

      AmanahAuthLogger.logResponse(
        'PATCH',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError(
        'PATCH',
        uri,
        e,
        stackTrace: stack,
        elapsed: stopwatch.elapsed,
      );
      rethrow;
    }
  }

  /// Internal DELETE helper with complete observability logging
  Future<http.Response> _delete(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final Map<String, String> resolvedHeaders = <String, String>{
      'Accept': 'application/json',
      ...?headers,
    };

    AmanahAuthLogger.logRequest(
      'DELETE',
      uri,
      headers: resolvedHeaders,
    );

    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final http.Response response = await _httpClient.delete(
        uri,
        headers: resolvedHeaders,
      );
      stopwatch.stop();

      AmanahAuthLogger.logResponse(
        'DELETE',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError(
        'DELETE',
        uri,
        e,
        stackTrace: stack,
        elapsed: stopwatch.elapsed,
      );
      rethrow;
    }
  }

  /// Sign In with Email & Password via Better Auth
  /// Endpoint: POST /api/auth/sign-in/email
  Future<AmanahAuthUser?> authenticate(String identifier, String password) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/sign-in/email');
    final http.Response response = await _post(
      uri,
      body: <String, dynamic>{
        'email': identifier.trim(),
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final String? token = data['token'] as String?;
      final Map<String, dynamic>? userMap =
          data['user'] as Map<String, dynamic>?;

      if (userMap != null) {
        final String? role = userMap['role'] as String?;
        final bool needsOnboarding = userMap['needsOnboarding'] as bool? ??
            AmanahAuthUser.isPatientRole(role);
        if (!needsOnboarding && AmanahAuthUser.isPatientRole(role)) {
          if (token != null) {
            await _signOutWithToken(token);
          }
          throw const AmanahAuthPatientRestrictedException();
        }

        if (token != null) {
          await _tokenStorage.saveToken(token);
        }
        return AmanahAuthUser.fromBetterAuthJson(userMap);
      }
      return null;
    } else if (response.statusCode == 401) {
      return null;
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(message ?? 'Gagal masuk. Silakan coba lagi.');
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException('Terjadi kesalahan pada server.');
      }
    }
  }

  /// Sign Up with Email & Password via Better Auth
  /// Endpoint: POST /api/auth/sign-up/email
  Future<AmanahAuthUser?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/sign-up/email');
    final http.Response response = await _post(
      uri,
      body: <String, dynamic>{
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final String? token = data['token'] as String?;
      final Map<String, dynamic>? userMap =
          data['user'] as Map<String, dynamic>?;

      if (userMap != null) {
        if (token != null) {
          await _tokenStorage.saveToken(token);
        }
        return AmanahAuthUser.fromBetterAuthJson(userMap);
      }
      return null;
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(
          message ?? 'Gagal mendaftar. Silakan periksa data Anda.',
        );
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException(
          'Terjadi kesalahan pada server saat pendaftaran.',
        );
      }
    }
  }

  /// Sign In with Native Google idToken via Better Auth
  /// Endpoint: POST /api/auth/sign-in/social
  Future<AmanahAuthUser?> signInWithGoogle(String idToken) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/sign-in/social');
    final http.Response response = await _post(
      uri,
      body: <String, dynamic>{
        'provider': 'google',
        'idToken': <String, dynamic>{'token': idToken},
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final String? token = data['token'] as String?;
      final Map<String, dynamic>? userMap =
          data['user'] as Map<String, dynamic>?;

      if (userMap != null) {
        final String? role = userMap['role'] as String?;
        final bool needsOnboarding = userMap['needsOnboarding'] as bool? ??
            AmanahAuthUser.isPatientRole(role);
        if (!needsOnboarding && AmanahAuthUser.isPatientRole(role)) {
          if (token != null) {
            await _signOutWithToken(token);
          }
          throw const AmanahAuthPatientRestrictedException();
        }

        if (token != null) {
          await _tokenStorage.saveToken(token);
        }
        return AmanahAuthUser.fromBetterAuthJson(userMap);
      }
      return null;
    } else {
      throw const AmanahAuthException('Autentikasi Google gagal atau token tidak valid.');
    }
  }

  /// Restore active session on app startup
  /// Endpoint: GET /api/auth/get-session
  Future<AmanahAuthUser?> getSession() async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final Uri uri = Uri.parse('$_baseUrl/api/auth/get-session');
      final http.Response response = await _get(
        uri,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty || response.body.trim() == 'null') {
          await _tokenStorage.deleteToken();
          return null;
        }

        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic>? userMap =
            data['user'] as Map<String, dynamic>?;

        if (userMap != null) {
          final String? role = userMap['role'] as String?;
          final bool needsOnboarding = userMap['needsOnboarding'] as bool? ??
              AmanahAuthUser.isPatientRole(role);
          if (!needsOnboarding && AmanahAuthUser.isPatientRole(role)) {
            await signOut();
            return null;
          }
          return AmanahAuthUser.fromBetterAuthJson(userMap);
        }
      }
      await _tokenStorage.deleteToken();
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Sign out & invalidate session on server
  /// Endpoint: POST /api/auth/sign-out
  Future<void> signOut() async {
    final String? token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      await _signOutWithToken(token);
    }
    await _tokenStorage.deleteToken();
  }

  Future<void> _signOutWithToken(String token) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/api/auth/sign-out');
      await _post(
        uri,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {
      // Ignore network failure on sign out, local storage will still be cleared
    }
  }

  /// Request Password Reset OTP
  /// Endpoint: POST /api/auth/email-otp/request-password-reset
  Future<bool> requestPasswordReset(String email) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/email-otp/request-password-reset');
    final http.Response response = await _post(
      uri,
      body: <String, dynamic>{'email': email.trim()},
    );
    return response.statusCode == 200;
  }

  /// Verify OTP Challenge
  /// Endpoint: POST /api/auth/email-otp/check-verification-otp
  Future<bool> checkVerificationOtp(String email, String otp) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/email-otp/check-verification-otp');
    final http.Response response = await _post(
      uri,
      body: <String, dynamic>{
        'email': email.trim(),
        'type': 'forget-password',
        'otp': otp.trim(),
      },
    );
    return response.statusCode == 200;
  }

  /// Set New Password using verified OTP
  /// Endpoint: POST /api/auth/email-otp/reset-password
  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/email-otp/reset-password');
    final http.Response response = await _post(
      uri,
      body: <String, dynamic>{
        'email': email.trim(),
        'otp': otp.trim(),
        'password': newPassword,
      },
    );
    return response.statusCode == 200;
  }

  /// Verify Email with OTP for Sign Up
  /// Endpoint: POST /api/auth/email-otp/verify-email
  Future<AmanahAuthUser?> verifyEmailOtp(String email, String otp) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/email-otp/verify-email');
    final http.Response response = await _post(
      uri,
      body: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final String? token = data['token'] as String?;
      final Map<String, dynamic>? userMap =
          data['user'] as Map<String, dynamic>?;

      if (userMap != null) {
        final String? role = userMap['role'] as String?;
        final bool needsOnboarding = userMap['needsOnboarding'] as bool? ??
            AmanahAuthUser.isPatientRole(role);
        if (!needsOnboarding && AmanahAuthUser.isPatientRole(role)) {
          if (token != null) {
            await _signOutWithToken(token);
          }
          throw const AmanahAuthPatientRestrictedException();
        }

        if (token != null) {
          await _tokenStorage.saveToken(token);
        }
        return AmanahAuthUser.fromBetterAuthJson(userMap);
      }
      return null;
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(
          message ?? 'Kode OTP salah atau telah kedaluwarsa.',
        );
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException('Gagal memverifikasi kode OTP email.');
      }
    }
  }

  /// Resend Email Verification OTP
  /// Endpoint: POST /api/auth/email-otp/send-verification-otp
  Future<bool> resendEmailVerificationOtp(String email) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/email-otp/send-verification-otp');
    final http.Response response = await _post(
      uri,
      body: <String, dynamic>{
        'email': email.trim(),
        'type': 'email-verification',
      },
    );
    return response.statusCode == 200;
  }

  /// Change Password for Authenticated User
  /// Endpoint: POST /api/auth/change-password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    bool revokeOtherSessions = true,
  }) async {
    final String? token = await _tokenStorage.getToken();
    final Uri uri = Uri.parse('$_baseUrl/api/auth/change-password');
    final http.Response response = await _post(
      uri,
      headers: <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: <String, dynamic>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'revokeOtherSessions': revokeOtherSessions,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final String? newToken = data['token'] as String?;
      if (newToken != null && newToken.isNotEmpty) {
        await _tokenStorage.saveToken(newToken);
      }
      return true;
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(
          message ?? 'Gagal mengubah kata sandi. Periksa kata sandi saat ini.',
        );
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException(
          'Terjadi kesalahan pada server saat mengubah kata sandi.',
        );
      }
    }
  }

  /// Fetch active poliklinik options for staff onboarding from backend data.
  /// Endpoint: GET /api/v1/clinics
  Future<List<StaffOnboardingPoliOption>>
      fetchStaffOnboardingPolikliniks() async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/clinics');
    final http.Response response = await _get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> records = decoded is List<dynamic>
          ? decoded
          : decoded is Map<String, dynamic> && decoded['data'] is List<dynamic>
              ? decoded['data'] as List<dynamic>
              : const <dynamic>[];

      return records
          .whereType<Map<String, dynamic>>()
          .where((Map<String, dynamic> item) => item['isActive'] != false)
          .map(StaffOnboardingPoliOption.fromJson)
          .where(
            (StaffOnboardingPoliOption item) =>
                item.id.isNotEmpty && item.name.isNotEmpty,
          )
          .toList();
    }

    throw const AmanahAuthException(
      'Gagal mengambil daftar poliklinik. Silakan coba lagi.',
    );
  }

  /// Complete Staff Onboarding & Role Selection
  /// Endpoint: POST /api/v1/auth/onboarding/staff
  Future<AmanahAuthUser?> completeStaffOnboarding({
    required String role, // 'doctor' | 'midwife' | 'worker' | 'staff'
    required String fullName,
    String? phoneNumber,
    String? profession,
    String? licenseNumber,
    String? staffCode,
    String? poliklinikId,
  }) async {
    final String? token = await _tokenStorage.getToken();
    final Uri uri = Uri.parse('$_baseUrl/api/v1/auth/onboarding/staff');
    final Map<String, dynamic> body = <String, dynamic>{
      'role': role,
      'fullName': fullName.trim(),
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'phoneNumber': phoneNumber.trim(),
      if (profession != null && profession.isNotEmpty)
        'profession': profession.trim(),
      if (licenseNumber != null && licenseNumber.isNotEmpty)
        'licenseNumber': licenseNumber.trim(),
      if (staffCode != null && staffCode.isNotEmpty)
        'staffCode': staffCode.trim(),
      if (poliklinikId != null && poliklinikId.isNotEmpty)
        'poliklinikId': poliklinikId.trim(),
    };

    final http.Response response = await _post(
      uri,
      headers: <String, String>{
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      return AmanahAuthUser.fromBetterAuthJson(data);
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(
          message ?? 'Gagal menyelesaikan onboarding staf.',
        );
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException(
          'Terjadi kesalahan saat memproses onboarding staf.',
        );
      }
    }
  }

  /// Upload or update user profile image / avatar
  /// Endpoint: PATCH /api/v1/users/me/avatar (or POST /api/v1/auth/me/avatar)
  Future<UserAvatar> uploadAvatar({
    List<int>? fileBytes,
    String? filePath,
    String fileName = 'avatar.jpg',
    bool useAuthAlias = false,
  }) async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }

    final String path = useAuthAlias ? '/api/v1/auth/me/avatar' : '/api/v1/users/me/avatar';
    final Uri uri = Uri.parse('$_baseUrl$path');

    final http.MultipartRequest request = http.MultipartRequest(useAuthAlias ? 'POST' : 'PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
    } else if (filePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: fileName,
        ),
      );
    } else {
      throw const AmanahAuthException('Berkas foto tidak boleh kosong.');
    }

    AmanahAuthLogger.logRequest(
      request.method,
      uri,
      headers: request.headers,
      body: <String, dynamic>{'filename': fileName, 'useAlias': useAuthAlias},
    );

    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final http.StreamedResponse streamedResponse = await _httpClient.send(request);
      final http.Response response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      AmanahAuthLogger.logResponse(
        request.method,
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['avatar'] != null && data['avatar'] is Map<String, dynamic>) {
          return UserAvatar.fromJson(data['avatar'] as Map<String, dynamic>);
        } else if (data['avatarUrl'] != null) {
          final String avatarUrl = data['avatarUrl'] as String;
          return UserAvatar(
            url: avatarUrl,
            initials: 'AH',
            type: 'custom',
            hasCustomAvatar: true,
            directUrl: avatarUrl,
          );
        }
        throw const AmanahAuthException('Format respons avatar dari server tidak valid.');
      } else if (response.statusCode == 422) {
        throw const AmanahAuthException(
          'Berkas yang dipilih bukan format gambar yang didukung (Gunakan JPEG, PNG, atau WebP max 5MB).',
        );
      } else if (response.statusCode == 401) {
        throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final String? message = errorData['message'] as String? ?? errorData['error']?['message'];
          throw AmanahAuthException(message ?? 'Gagal mengunggah foto profil.');
        } catch (e) {
          if (e is AmanahAuthException) rethrow;
          throw const AmanahAuthException('Terjadi kesalahan saat mengunggah foto profil.');
        }
      }
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError(
        request.method,
        uri,
        e,
        stackTrace: stack,
        elapsed: stopwatch.elapsed,
      );
      if (e is AmanahAuthException) rethrow;
      throw AmanahAuthException('Gagal mengunggah foto profil: $e');
    }
  }

  /// Delete custom avatar and revert to clinical initials SVG fallback
  /// Endpoint: DELETE /api/v1/users/me/avatar
  Future<bool> deleteAvatar() async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }

    final Uri uri = Uri.parse('$_baseUrl/api/v1/users/me/avatar');
    final Map<String, String> headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    AmanahAuthLogger.logRequest('DELETE', uri, headers: headers);
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final http.Response response = await _httpClient.delete(uri, headers: headers);
      stopwatch.stop();

      AmanahAuthLogger.logResponse(
        'DELETE',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final String? message = errorData['message'] as String? ?? errorData['error']?['message'];
          throw AmanahAuthException(message ?? 'Gagal menghapus avatar kustom.');
        } catch (e) {
          if (e is AmanahAuthException) rethrow;
          throw const AmanahAuthException('Terjadi kesalahan saat menghapus avatar.');
        }
      }
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError('DELETE', uri, e, stackTrace: stack, elapsed: stopwatch.elapsed);
      if (e is AmanahAuthException) rethrow;
      throw AmanahAuthException('Gagal menghapus avatar: $e');
    }
  }

  /// 1. Ambil daftar SIP / STR dokter login
  /// Endpoint: GET /api/v1/staffs/me/credentials
  Future<List<StaffCredentialModel>> getMyCredentials() async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return <StaffCredentialModel>[];
    }
    final Uri uri = Uri.parse('$_baseUrl/api/v1/staffs/me/credentials');
    final http.Response response = await _get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
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
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(
          message ?? 'Gagal memuat kredensial medis.',
        );
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException('Terjadi kesalahan saat memuat kredensial.');
      }
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
    final Uri uri = Uri.parse('$_baseUrl/api/v1/staffs/me/credentials');
    final Map<String, dynamic> body = <String, dynamic>{
      'credentialType': type.toApiValue(),
      'credentialNumber': number.trim(),
      if (issuer != null && issuer.trim().isNotEmpty) 'issuer': issuer.trim(),
      if (issuedAt != null && issuedAt.trim().isNotEmpty) 'issuedAt': issuedAt.trim(),
      if (expiresAt != null && expiresAt.trim().isNotEmpty) 'expiresAt': expiresAt.trim(),
    };

    final http.Response response = await _post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      return StaffCredentialModel.fromJson(data);
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(
          message ?? 'Gagal menambahkan kredensial medis.',
        );
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException('Terjadi kesalahan saat menyimpan kredensial.');
      }
    }
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
    final Uri uri = Uri.parse('$_baseUrl/api/v1/staffs/me/credentials/$credentialId');
    final Map<String, dynamic> body = <String, dynamic>{
      if (number != null && number.trim().isNotEmpty)
        'credentialNumber': number.trim(),
      if (issuer != null && issuer.trim().isNotEmpty)
        'issuer': issuer.trim(),
      if (expiresAt != null && expiresAt.trim().isNotEmpty)
        'expiresAt': expiresAt.trim(),
      if (status != null && status.trim().isNotEmpty)
        'status': status.trim().toLowerCase(),
    };

    final http.Response response = await _patch(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      return StaffCredentialModel.fromJson(data);
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(
          message ?? 'Gagal memperbarui kredensial medis.',
        );
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException('Terjadi kesalahan saat memperbarui kredensial.');
      }
    }
  }

  /// 4. Hapus kredensial
  /// Endpoint: DELETE /api/v1/staffs/me/credentials/:credentialId
  Future<bool> deleteCredential(String credentialId) async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }
    final Uri uri = Uri.parse('$_baseUrl/api/v1/staffs/me/credentials/$credentialId');

    final http.Response response = await _delete(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(
          message ?? 'Gagal menghapus kredensial medis.',
        );
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException('Terjadi kesalahan saat menghapus kredensial.');
      }
    }
  }

  /// 5. Self-update nama atau nomor telepon staf dokter
  /// Endpoint: PATCH /api/v1/staffs/me
  /// IMPORTANT: Email is immutable and never included in this request.
  Future<AmanahStaffProfile> updateMyProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    final String? token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const AmanahAuthException('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }
    final Uri uri = Uri.parse('$_baseUrl/api/v1/staffs/me');
    final Map<String, dynamic> body = <String, dynamic>{
      if (fullName != null && fullName.trim().isNotEmpty)
        'fullName': fullName.trim(),
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
        'phoneNumber': phoneNumber.trim(),
    };

    final http.Response response = await _patch(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      return AmanahStaffProfile.fromJson(data);
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw AmanahAuthException(
          message ?? 'Gagal memperbarui profil dokter.',
        );
      } catch (e) {
        if (e is AmanahAuthException) rethrow;
        throw const AmanahAuthException('Terjadi kesalahan saat memperbarui profil dokter.');
      }
    }
  }
}
