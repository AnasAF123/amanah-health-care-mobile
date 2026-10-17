import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/constants/gender_constants.dart';
import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/data/dto/staff_onboarding_dto.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/change_password.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/delete_avatar.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/fetch_staff_onboarding_polikliniks.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/request_password_reset.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/reset_password.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/restore_session.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/sign_out.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/submit_staff_onboarding.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/upload_avatar.dart';
import 'package:amanah_healthcare/features/authentication/data/datasources/google_auth_service.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/verify_otp.dart';

class FakeGoogleAuthService extends GoogleAuthService {
  FakeGoogleAuthService({this.tokenToReturn = 'mock_google_id_token'});
  final String? tokenToReturn;
  bool signOutCalled = false;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<String?> getIdToken() async => tokenToReturn;
}

class FakeAuthRepository implements AuthRepository {
  AmanahAuthUser? mockUser;
  bool signOutCalled = false;
  StaffOnboardingDto? lastSubmittedDto;

  @override
  Future<AmanahAuthUser?> authenticate(String identifier, String password) async =>
      mockUser;

  @override
  Future<AmanahAuthUser?> signInWithGoogle(String idToken) async => mockUser;

  @override
  Future<AmanahAuthUser?> getSession() async => mockUser;

  @override
  Future<bool> refreshToken() async => true;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<bool> checkVerificationOtp(String email, String otp) async => true;

  @override
  Future<bool> deleteAvatar() async => true;

  @override
  Future<List<StaffOnboardingPoliOption>> fetchStaffOnboardingPolikliniks() async =>
      const <StaffOnboardingPoliOption>[];

  @override
  Future<bool> requestPasswordReset(String email) async => true;

  @override
  Future<bool> resetPassword(String email, String otp, String newPassword) async =>
      true;

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async =>
      true;

  @override
  Future<AmanahAuthUser?> submitStaffOnboarding(StaffOnboardingDto dto) async {
    lastSubmittedDto = dto;
    return mockUser;
  }

  @override
  Future<UserAvatar> uploadAvatar({
    List<int>? fileBytes,
    String? filePath,
    String fileName = 'avatar.jpg',
    bool useAuthAlias = false,
  }) async =>
      UserAvatar.empty;
}

void main() {
  late FakeAuthRepository repository;
  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'u_100',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Zikri',
    email: 'zikri@amanah.id',
    phone: '08123456789',
  );

  setUp(() {
    repository = FakeAuthRepository();
    repository.mockUser = testUser;
  });

  group('Authentication UseCases', () {
    test('SignInWithEmailUseCase executes repository authenticate with params', () async {
      final SignInWithEmailUseCase useCase = SignInWithEmailUseCase(repository);

      final AmanahAuthUser? result = await useCase(
        const SignInWithEmailParams(
          email: 'zikri@amanah.id',
          password: 'secretPassword',
        ),
      );

      expect(result, isNotNull);
      expect(result!.id, 'u_100');
      expect(result.fullName, 'dr. Zikri');
    });

    test('SignInWithGoogleUseCase executes repository signInWithGoogle after obtaining token', () async {
      final FakeGoogleAuthService fakeGas = FakeGoogleAuthService();
      final SignInWithGoogleUseCase useCase = SignInWithGoogleUseCase(
        repository: repository,
        googleAuthService: fakeGas,
      );

      final AmanahAuthUser? result = await useCase();

      expect(result, isNotNull);
      expect(result!.role, AmanahUserRole.doctor);
      expect(fakeGas.signOutCalled, isTrue);
    });

    test('RestoreSessionUseCase retrieves active session from repository', () async {
      final RestoreSessionUseCase useCase = RestoreSessionUseCase(repository);

      final AmanahAuthUser? result = await useCase(const NoParams());

      expect(result, isNotNull);
      expect(result!.email, 'zikri@amanah.id');
    });

    test('SignOutUseCase triggers repository signOut', () async {
      final SignOutUseCase useCase = SignOutUseCase(repository);

      await useCase(const NoParams());

      expect(repository.signOutCalled, isTrue);
    });

    test('SubmitStaffOnboardingUseCase submits dto and returns updated user', () async {
      final SubmitStaffOnboardingUseCase useCase =
          SubmitStaffOnboardingUseCase(repository);

      const StaffOnboardingDto dto = StaffOnboardingDto(
        fullName: 'dr. Zikri Spesialis',
        phoneNumber: '08123456789',
        profession: 'DOCTOR',
        gender: GenderConstants.male,
      );

      final AmanahAuthUser? result = await useCase(dto);

      expect(result, isNotNull);
      expect(repository.lastSubmittedDto?.fullName, 'dr. Zikri Spesialis');
    });

    test('FetchStaffOnboardingPolikliniksUseCase fetches poliklinik options from repository', () async {
      final FetchStaffOnboardingPolikliniksUseCase useCase =
          FetchStaffOnboardingPolikliniksUseCase(repository);

      final List<StaffOnboardingPoliOption> result =
          await useCase(const NoParams());

      expect(result, isEmpty);
    });

    test('UploadAvatarUseCase calls repository uploadAvatar', () async {
      final UploadAvatarUseCase useCase = UploadAvatarUseCase(repository);

      final UserAvatar avatar = await useCase(
        const UploadAvatarParams(fileName: 'avatar.png', useAuthAlias: true),
      );

      expect(avatar, equals(UserAvatar.empty));
    });

    test('DeleteAvatarUseCase calls repository deleteAvatar', () async {
      final DeleteAvatarUseCase useCase = DeleteAvatarUseCase(repository);

      final bool success = await useCase(const NoParams());

      expect(success, isTrue);
    });

    test('RequestPasswordResetUseCase calls repository requestPasswordReset', () async {
      final RequestPasswordResetUseCase useCase =
          RequestPasswordResetUseCase(repository);

      final bool success = await useCase(
        const RequestPasswordResetParams(email: 'doctor@amanah.id'),
      );

      expect(success, isTrue);
    });

    test('VerifyOtpUseCase calls repository checkVerificationOtp', () async {
      final VerifyOtpUseCase useCase = VerifyOtpUseCase(repository);

      final bool valid = await useCase(
        const VerifyOtpParams(email: 'doctor@amanah.id', otp: '123456'),
      );

      expect(valid, isTrue);
    });

    test('ResetPasswordUseCase calls repository resetPassword', () async {
      final ResetPasswordUseCase useCase = ResetPasswordUseCase(repository);

      final bool success = await useCase(
        const ResetPasswordParams(
          email: 'doctor@amanah.id',
          otp: '123456',
          newPassword: 'NewSecurePassword123!',
        ),
      );

      expect(success, isTrue);
    });

    test('ChangePasswordUseCase calls repository changePassword', () async {
      final ChangePasswordUseCase useCase = ChangePasswordUseCase(repository);

      final bool success = await useCase(
        const ChangePasswordParams(
          oldPassword: 'TempPassword123!',
          newPassword: 'MyPermanentPassword456!',
        ),
      );

      expect(success, isTrue);
    });
  });
}
