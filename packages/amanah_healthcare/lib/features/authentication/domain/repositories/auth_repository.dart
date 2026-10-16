import 'package:amanah_healthcare/features/authentication/data/dto/staff_onboarding_dto.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';

abstract interface class AuthRepository {
  Future<AmanahAuthUser?> authenticate(String identifier, String password);

  Future<AmanahAuthUser?> signInWithGoogle(String idToken);

  Future<AmanahAuthUser?> getSession();

  Future<void> signOut();

  Future<bool> requestPasswordReset(String email);

  Future<bool> checkVerificationOtp(String email, String otp);

  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  );

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<List<StaffOnboardingPoliOption>> fetchStaffOnboardingPolikliniks();

  Future<AmanahAuthUser?> submitStaffOnboarding(StaffOnboardingDto dto);

  Future<UserAvatar> uploadAvatar({
    List<int>? fileBytes,
    String? filePath,
    String fileName = 'avatar.jpg',
    bool useAuthAlias = false,
  });

  Future<bool> deleteAvatar();
}
