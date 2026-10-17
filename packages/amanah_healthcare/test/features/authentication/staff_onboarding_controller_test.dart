import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/data/dto/staff_onboarding_dto.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/delete_avatar.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/fetch_staff_onboarding_polikliniks.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/submit_staff_onboarding.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/upload_avatar.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';

class MockAuthRepository implements AuthRepository {
  StaffOnboardingDto? submittedDto;
  bool deleteAvatarCalled = false;
  UploadAvatarParams? lastUploadParams;

  @override
  Future<AmanahAuthUser?> authenticate(String identifier, String password) async => null;

  @override
  Future<AmanahAuthUser?> signInWithGoogle(String idToken) async => null;

  @override
  Future<AmanahAuthUser?> getSession() async => null;

  @override
  Future<bool> refreshToken() async => true;

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> checkVerificationOtp(String email, String otp) async => true;

  @override
  Future<bool> deleteAvatar() async {
    deleteAvatarCalled = true;
    return true;
  }

  @override
  Future<List<StaffOnboardingPoliOption>> fetchStaffOnboardingPolikliniks() async {
    return const <StaffOnboardingPoliOption>[
      StaffOnboardingPoliOption(
        id: 'poli-umum',
        code: 'UMUM',
        name: 'Poli Umum',
        description: 'Layanan kesehatan umum',
      ),
      StaffOnboardingPoliOption(
        id: 'poli-gigi',
        code: 'GIGI',
        name: 'Poli Gigi',
        description: 'Layanan kesehatan gigi',
      ),
    ];
  }

  @override
  Future<bool> requestPasswordReset(String email) async => true;

  @override
  Future<bool> resetPassword(String email, String otp, String newPassword) async => true;

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async =>
      true;

  @override
  Future<AmanahAuthUser?> submitStaffOnboarding(StaffOnboardingDto dto) async {
    submittedDto = dto;
    return AmanahAuthUser(
      id: 'doctor-123',
      role: AmanahUserRole.doctor,
      fullName: dto.fullName,
      email: 'doctor@amanah.id',
      phone: dto.phoneNumber ?? '',
      needsOnboarding: false,
    );
  }

  @override
  Future<UserAvatar> uploadAvatar({
    List<int>? fileBytes,
    String? filePath,
    String fileName = 'avatar.jpg',
    bool useAuthAlias = false,
  }) async {
    lastUploadParams = UploadAvatarParams(
      fileBytes: fileBytes,
      filePath: filePath,
      fileName: fileName,
      useAuthAlias: useAuthAlias,
    );
    return const UserAvatar(
      url: 'https://cdn.amanah.id/avatars/new.jpg',
      initials: 'DZ',
      type: 'custom',
      hasCustomAvatar: true,
      directUrl: 'https://cdn.amanah.id/avatars/new.jpg',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockRepo;
  late AmanahAuthUser doctorUser;
  late StaffOnboardingController controller;

  setUp(() {
    mockRepo = MockAuthRepository();
    doctorUser = const AmanahAuthUser(
      id: 'doctor-123',
      role: AmanahUserRole.doctor,
      fullName: 'dr. Zikri Rahman',
      email: 'doctor@amanah.id',
      phone: '08123456789',
      needsOnboarding: true,
    );
    controller = StaffOnboardingController(
      user: doctorUser,
      repository: mockRepo,
      fetchPolikliniksUseCase: FetchStaffOnboardingPolikliniksUseCase(mockRepo),
      submitUseCase: SubmitStaffOnboardingUseCase(mockRepo),
      uploadAvatarUseCase: UploadAvatarUseCase(mockRepo),
      deleteAvatarUseCase: DeleteAvatarUseCase(mockRepo),
    );
  });

  group('StaffOnboardingController with Clean Architecture UseCases', () {
    test('init() fetches polikliniks using FetchStaffOnboardingPolikliniksUseCase', () async {
      await controller.loadPolikliniks();

      expect(controller.poliklinikOptions.length, 2);
      expect(controller.poliklinikOptions.first.name, 'Poli Umum');
      expect(controller.selectedPoliklinik?.id, 'poli-umum');
      expect(controller.isLoadingPolikliniks, isFalse);
    });

    test('submit() fails if birth date or required fields are missing', () async {
      final AmanahAuthUser? result = await controller.submit();

      expect(result, isNull);
      expect(controller.submitErrorMessage, contains('tanggal lahir'));
    });

    test('submit() delegates to SubmitStaffOnboardingUseCase and returns updated user', () async {
      controller.birthDate = DateTime(1990, 5, 20);
      await controller.loadPolikliniks();
      controller.nikController.text = '3201012345678901';
      controller.birthPlaceController.text = 'Bandung';

      final AmanahAuthUser? result = await controller.submit();

      expect(result, isNotNull);
      expect(result!.needsOnboarding, isFalse);
      expect(mockRepo.submittedDto, isNotNull);
      expect(mockRepo.submittedDto?.birthDate, '1990-05-20');
      expect(mockRepo.submittedDto?.poliklinikId, 'poli-umum');
    });

    test('uploadAvatarPhoto() invokes UploadAvatarUseCase and updates controller avatar', () async {
      final List<int> bytes = <int>[1, 2, 3, 4];
      await controller.uploadAvatarPhoto(
        fileBytes: bytes,
        fileName: 'profile.jpg',
      );

      expect(mockRepo.lastUploadParams?.fileName, 'profile.jpg');
      expect(controller.avatar.hasCustomAvatar, isTrue);
      expect(controller.avatar.url, 'https://cdn.amanah.id/avatars/new.jpg');
    });

    test('deleteAvatarPhoto() invokes DeleteAvatarUseCase and sets fallback avatar', () async {
      await controller.deleteAvatarPhoto();

      expect(mockRepo.deleteAvatarCalled, isTrue);
      expect(controller.avatar.hasCustomAvatar, isFalse);
      expect(controller.avatar.initials, 'ZR');
    });
  });
}
