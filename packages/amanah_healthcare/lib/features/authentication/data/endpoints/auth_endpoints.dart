import 'package:amanah_healthcare/core/constants/api_prefix.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';

/// API Endpoints for Authentication, Staff Onboarding, and Credentials
/// Single Source of Truth for all route paths and endpoint definitions.
abstract final class AuthEndpoints {
  // Path constants composed with ApiPrefix
  static const String pathEmailLogin = '${ApiPrefix.v1}/auth/email/login';
  static const String pathGoogleLogin = '${ApiPrefix.v1}/auth/google';
  static const String pathRefresh = '${ApiPrefix.v1}/auth/refresh';
  static const String pathSession = '${ApiPrefix.v1}/auth/me';
  static const String pathSignOut = '${ApiPrefix.betterAuth}/auth/sign-out';
  static const String pathRequestPasswordReset =
      '${ApiPrefix.betterAuth}/auth/email-otp/request-password-reset';
  static const String pathCheckVerificationOtp =
      '${ApiPrefix.betterAuth}/auth/email-otp/check-verification-otp';
  static const String pathResetPassword =
      '${ApiPrefix.betterAuth}/auth/email-otp/reset-password';
  static const String pathChangePassword = '${ApiPrefix.v1}/auth/me';
  static const String pathClinics = '${ApiPrefix.v1}/clinics';
  static const String pathStaffOnboarding =
      '${ApiPrefix.v1}/auth/onboarding/staff';
  static const String pathAvatar = '${ApiPrefix.v1}/users/me/avatar';
  static const String pathAvatarAuthAlias = '${ApiPrefix.v1}/auth/me/avatar';
  static const String pathStaffCredentials =
      '${ApiPrefix.v1}/staffs/me/credentials';
  static const String pathStaffProfile = '${ApiPrefix.v1}/staffs/me';
  static const String pathReferenceProvinces =
      '${ApiPrefix.v1}/patients/reference/provinces';
  static const String pathReferenceRegencies =
      '${ApiPrefix.v1}/patients/reference/regencies';
  static const String pathReferenceDistricts =
      '${ApiPrefix.v1}/patients/reference/districts';
  static const String pathReferenceVillages =
      '${ApiPrefix.v1}/patients/reference/villages';

  // String aliases for direct path resolution
  static const String emailLogin = pathEmailLogin;
  static const String googleLogin = pathGoogleLogin;
  static const String refresh = pathRefresh;
  static const String session = pathSession;
  static const String signOut = pathSignOut;
  static const String requestPasswordReset = pathRequestPasswordReset;
  static const String checkVerificationOtp = pathCheckVerificationOtp;
  static const String resetPassword = pathResetPassword;
  static const String changePassword = pathChangePassword;
  static const String clinics = pathClinics;
  static const String staffOnboarding = pathStaffOnboarding;
  static const String avatar = pathAvatar;
  static const String avatarAuthAlias = pathAvatarAuthAlias;
  static const String staffCredentials = pathStaffCredentials;
  static const String staffProfile = pathStaffProfile;
  static const String referenceProvinces = pathReferenceProvinces;
  static const String referenceRegencies = pathReferenceRegencies;
  static const String referenceDistricts = pathReferenceDistricts;
  static const String referenceVillages = pathReferenceVillages;

  // Typed ApiEndpoint definitions for ApiClient
  static const ApiEndpoint emailLoginEndpoint = ApiEndpoint(
    path: pathEmailLogin,
    method: HttpMethod.post,
  );
  static const ApiEndpoint googleLoginEndpoint = ApiEndpoint(
    path: pathGoogleLogin,
    method: HttpMethod.post,
  );
  static const ApiEndpoint refreshEndpoint = ApiEndpoint(
    path: pathRefresh,
    method: HttpMethod.post,
    requiresAuth: true,
  );
  static const ApiEndpoint sessionEndpoint = ApiEndpoint(
    path: pathSession,
    method: HttpMethod.get,
    requiresAuth: true,
  );
  static const ApiEndpoint signOutEndpoint = ApiEndpoint(
    path: pathSignOut,
    method: HttpMethod.post,
    requiresAuth: true,
  );
  static const ApiEndpoint requestPasswordResetEndpoint = ApiEndpoint(
    path: pathRequestPasswordReset,
    method: HttpMethod.post,
  );
  static const ApiEndpoint checkVerificationOtpEndpoint = ApiEndpoint(
    path: pathCheckVerificationOtp,
    method: HttpMethod.post,
  );
  static const ApiEndpoint resetPasswordEndpoint = ApiEndpoint(
    path: pathResetPassword,
    method: HttpMethod.post,
  );
  static const ApiEndpoint changePasswordEndpoint = ApiEndpoint(
    path: pathChangePassword,
    method: HttpMethod.patch,
    requiresAuth: true,
  );
  static const ApiEndpoint clinicsEndpoint = ApiEndpoint(
    path: pathClinics,
    method: HttpMethod.get,
  );
  static const ApiEndpoint staffOnboardingEndpoint = ApiEndpoint(
    path: pathStaffOnboarding,
    method: HttpMethod.post,
    requiresAuth: true,
  );
  static const ApiEndpoint avatarEndpoint = ApiEndpoint(
    path: pathAvatar,
    method: HttpMethod.patch,
    requiresAuth: true,
  );
  static const ApiEndpoint avatarAuthAliasEndpoint = ApiEndpoint(
    path: pathAvatarAuthAlias,
    method: HttpMethod.post,
    requiresAuth: true,
  );
  static const ApiEndpoint avatarDeleteEndpoint = ApiEndpoint(
    path: pathAvatar,
    method: HttpMethod.delete,
    requiresAuth: true,
  );
  static const ApiEndpoint staffCredentialsEndpoint = ApiEndpoint(
    path: pathStaffCredentials,
    method: HttpMethod.get,
    requiresAuth: true,
  );
  static const ApiEndpoint staffProfileEndpoint = ApiEndpoint(
    path: pathStaffProfile,
    method: HttpMethod.patch,
    requiresAuth: true,
  );
  static const ApiEndpoint provincesEndpoint = ApiEndpoint(
    path: pathReferenceProvinces,
    method: HttpMethod.get,
  );
  static const ApiEndpoint regenciesEndpoint = ApiEndpoint(
    path: pathReferenceRegencies,
    method: HttpMethod.get,
  );
  static const ApiEndpoint districtsEndpoint = ApiEndpoint(
    path: pathReferenceDistricts,
    method: HttpMethod.get,
  );
  static const ApiEndpoint villagesEndpoint = ApiEndpoint(
    path: pathReferenceVillages,
    method: HttpMethod.get,
  );
}
