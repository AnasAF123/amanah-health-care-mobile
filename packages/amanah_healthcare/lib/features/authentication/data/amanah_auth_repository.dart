import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/constants/api_error_code.dart';
import 'package:amanah_healthcare/core/notifications/amanah_push_service.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:amanah_healthcare/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:amanah_healthcare/features/authentication/data/dto/staff_onboarding_dto.dart';
import 'package:amanah_healthcare/features/authentication/data/mappers/auth_user_mapper.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';

export 'package:amanah_healthcare/features/authentication/data/staff_credential_repository.dart';
export 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';
export 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';

class AmanahAuthRepository implements AuthRepository {
  const AmanahAuthRepository({
    String? baseUrl,
    http.Client? httpClient,
    AmanahAuthTokenStorage tokenStorage = const AmanahAuthTokenStorage(),
    AuthRemoteDataSource? remoteDataSource,
    AuthLocalDataSource? localDataSource,
  })  : _tokenStorage = tokenStorage,
        _customBaseUrl = baseUrl,
        _customHttpClient = httpClient,
        _customRemoteDataSource = remoteDataSource,
        _customLocalDataSource = localDataSource;

  final AmanahAuthTokenStorage _tokenStorage;
  final String? _customBaseUrl;
  final http.Client? _customHttpClient;
  final AuthRemoteDataSource? _customRemoteDataSource;
  final AuthLocalDataSource? _customLocalDataSource;

  AuthRemoteDataSource get _remoteDataSource =>
      _customRemoteDataSource ??
      AuthRemoteDataSourceImpl(
        baseUrl: _customBaseUrl,
        httpClient: _customHttpClient,
      );

  AuthLocalDataSource get _localDataSource =>
      _customLocalDataSource ??
      AuthLocalDataSourceImpl(storage: _tokenStorage);

  AmanahAuthTokenStorage get tokenStorage => _tokenStorage;

  Future<AmanahAuthUser> _handleAuthSuccess(http.Response response) async {
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final String? token = data['token'] as String?;
    final String? refreshToken = data['refreshToken'] as String?;
    final Map<String, dynamic> userMap =
        (data['user'] as Map<String, dynamic>?) ?? data;

    final String? role = userMap['role'] is Map
        ? userMap['role']['code'] as String?
        : userMap['role'] as String?;
    if (AmanahAuthUser.isPatientRole(role)) {
      if (token != null) {
        await _remoteDataSource.signOut(token);
      }
      throw const PatientRestrictedFailure();
    }

    if (token != null) {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _localDataSource.saveTokens(
          accessToken: token,
          refreshToken: refreshToken,
        );
      } else {
        await _localDataSource.saveToken(token);
      }
      unawaited(AmanahPushService.instance.registerDeviceWithBackend());
    }
    return AuthUserMapper.fromJson(userMap);
  }

  AuthFailure _handleAuthError(
    http.Response response, {
    String fallbackMessage = 'Gagal masuk.',
  }) {
    try {
      final Map<String, dynamic> errorData =
          jsonDecode(response.body) as Map<String, dynamic>;
      final String? code = errorData['code'] as String?;
      final String? message =
          errorData['message'] as String? ?? errorData['error']?['message'];

      final ApiErrorCode? errorCode = ApiErrorCode.fromCode(code);

      if (errorCode == ApiErrorCode.clientNotAllowed ||
          (response.statusCode == 403 &&
              (message?.toLowerCase().contains('pasien') ?? false))) {
        return const PatientRestrictedFailure();
      }
      if (errorCode == ApiErrorCode.accountInactive) {
        return AccountInactiveFailure(
          message ?? 'Akun staf Anda telah dinonaktifkan.',
        );
      }
      if (errorCode == ApiErrorCode.notAuthorized) {
        return NotAuthorizedFailure(
          message ??
              'Akun ini tidak memiliki undangan aktif sebagai staf/dokter klinik.',
        );
      }
      if (response.statusCode == 401 ||
          errorCode == ApiErrorCode.invalidCredentials) {
        return InvalidCredentialsFailure(
          message ?? 'Kombinasi email atau kata sandi salah.',
        );
      }
      return ServerFailure(message ?? fallbackMessage, code);
    } catch (_) {
      return ServerFailure(fallbackMessage);
    }
  }

  @override
  Future<AmanahAuthUser?> authenticate(
    String identifier,
    String password,
  ) async {
    final http.Response response =
        await _remoteDataSource.emailLogin(identifier, password);
    if (response.statusCode == 200) {
      return _handleAuthSuccess(response);
    }
    throw _handleAuthError(
      response,
      fallbackMessage:
          'Kombinasi email atau kata sandi salah. Silakan periksa kembali.',
    );
  }

  @override
  Future<AmanahAuthUser?> signInWithGoogle(String idToken) async {
    final http.Response response =
        await _remoteDataSource.googleLogin(idToken);
    if (response.statusCode == 200) {
      return _handleAuthSuccess(response);
    }
    throw _handleAuthError(
      response,
      fallbackMessage: 'Autentikasi Google gagal atau ditolak server.',
    );
  }

  @override
  Future<AmanahAuthUser?> getSession() async {
    final String? token = await _localDataSource.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final http.Response response = await _remoteDataSource.getSession(token);

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty || response.body.trim() == 'null') {
          await _localDataSource.deleteAllTokens();
          return null;
        }

        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> userMap =
            (data['user'] as Map<String, dynamic>?) ?? data;

        if (userMap['id'] != null) {
          final String? role = userMap['role'] is Map
              ? userMap['role']['code'] as String?
              : userMap['role'] as String?;
          if (AmanahAuthUser.isPatientRole(role)) {
            await signOut();
            return null;
          }
          return AuthUserMapper.fromJson(userMap);
        }
      }
      if (response.statusCode == 401) {
        await _localDataSource.deleteAllTokens();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> refreshToken() async {
    final String? currentRefreshToken =
        await _localDataSource.getRefreshToken();
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      return false;
    }

    try {
      final http.Response response =
          await _remoteDataSource.refreshToken(currentRefreshToken);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? newToken = data['token'] as String?;
        final String? newRefreshToken = data['refreshToken'] as String?;

        if (newToken != null && newToken.isNotEmpty) {
          await _localDataSource.saveTokens(
            accessToken: newToken,
            refreshToken: (newRefreshToken != null &&
                    newRefreshToken.isNotEmpty)
                ? newRefreshToken
                : currentRefreshToken,
          );
          return true;
        }
      } else if (response.statusCode == 401) {
        await _localDataSource.deleteAllTokens();
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await AmanahPushService.instance.unregisterDeviceWithBackend();
    } catch (_) {}
    final String? token = await _localDataSource.getToken();
    if (token != null && token.isNotEmpty) {
      await _remoteDataSource.signOut(token);
    }
    await _localDataSource.deleteAllTokens();
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    final http.Response response =
        await _remoteDataSource.requestPasswordReset(email);
    return response.statusCode == 200;
  }

  @override
  Future<bool> checkVerificationOtp(String email, String otp) async {
    final http.Response response =
        await _remoteDataSource.checkVerificationOtp(email, otp);
    return response.statusCode == 200;
  }

  @override
  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    final http.Response response =
        await _remoteDataSource.resetPassword(email, otp, newPassword);
    return response.statusCode == 200;
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final String? token = await _localDataSource.getToken();
    if (token == null || token.isEmpty) {
      throw const ServerFailure(
        'Sesi Anda telah kedaluwarsa. Silakan masuk kembali.',
      );
    }

    final http.Response response = await _remoteDataSource.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      token: token,
    );

    if (response.statusCode == 200) {
      return true;
    }

    try {
      final Map<String, dynamic> errorData =
          jsonDecode(response.body) as Map<String, dynamic>;
      final dynamic errors = errorData['errors'];
      if (errors is Map && errors['oldPassword'] == 'incorrectOldPassword') {
        throw const ServerFailure(
          'Kata sandi saat ini tidak sesuai. Silakan periksa kembali.',
        );
      }
      final String? message =
          errorData['message'] as String? ?? errorData['error']?['message'];
      throw ServerFailure(
        message ?? 'Gagal mengubah kata sandi akun.',
      );
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const ServerFailure(
        'Terjadi kesalahan saat memperbarui kata sandi.',
      );
    }
  }

  @override
  Future<List<StaffOnboardingPoliOption>>
      fetchStaffOnboardingPolikliniks() async {
    final http.Response response = await _remoteDataSource.fetchClinics();

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

    throw ServerFailure(
      'Gagal mengambil daftar poliklinik dari server (Status: ${response.statusCode}).',
    );
  }

  @override
  Future<AmanahAuthUser?> submitStaffOnboarding(
    StaffOnboardingDto dto,
  ) async {
    final String? token = await _localDataSource.getToken();
    final http.Response response = await _remoteDataSource.submitStaffOnboarding(
      dto.toJson(),
      token,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> userMap =
          (data['user'] as Map<String, dynamic>?) ?? data;
      return AuthUserMapper.fromJson(userMap);
    } else {
      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String? message =
            errorData['message'] as String? ?? errorData['error']?['message'];
        throw ServerFailure(
          message ?? 'Gagal menyelesaikan onboarding staf.',
        );
      } catch (e) {
        if (e is AuthFailure) rethrow;
        throw const ServerFailure(
          'Terjadi kesalahan saat memproses onboarding staf.',
        );
      }
    }
  }

  @override
  Future<UserAvatar> uploadAvatar({
    List<int>? fileBytes,
    String? filePath,
    String fileName = 'avatar.jpg',
    bool useAuthAlias = false,
  }) async {
    final String? token = await _localDataSource.getToken();
    if (token == null || token.isEmpty) {
      throw const ServerFailure(
        'Sesi Anda telah kedaluwarsa. Silakan masuk kembali.',
      );
    }

    if (fileBytes == null && filePath == null) {
      throw const ServerFailure('Berkas foto tidak boleh kosong.');
    }

    final http.Response response = await _remoteDataSource.uploadAvatar(
      token: token,
      fileBytes: fileBytes,
      filePath: filePath,
      fileName: fileName,
      useAuthAlias: useAuthAlias,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
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
      throw const ServerFailure(
        'Format respons avatar dari server tidak valid.',
      );
    }
    throw const ServerFailure('Gagal mengunggah foto profil ke server.');
  }

  @override
  Future<bool> deleteAvatar() async {
    final String? token = await _localDataSource.getToken();
    if (token == null || token.isEmpty) {
      throw const ServerFailure(
        'Sesi Anda telah kedaluwarsa. Silakan masuk kembali.',
      );
    }

    final http.Response response = await _remoteDataSource.deleteAvatar(token);
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
