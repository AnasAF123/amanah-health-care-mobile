import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:amanah_healthcare/features/authentication/data/datasources/google_auth_service.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/sign_in_with_google.dart';

class MockGoogleSignInAccount implements GoogleSignInAccount {
  MockGoogleSignInAccount({
    this.email = 'dokter@amanah.id',
    this.id = '12345',
    this.displayName = 'Dr. Dokter',
    this.photoUrl,
    this.serverAuthCode,
  });

  @override
  final String email;
  @override
  final String id;
  @override
  final String? displayName;
  @override
  final String? photoUrl;
  @override
  final String? serverAuthCode;

  @override
  Future<GoogleSignInAuthentication> get authentication =>
      Future<GoogleSignInAuthentication>.value(MockGoogleSignInAuthentication());

  @override
  Future<Map<String, String>> get authHeaders async => <String, String>{};

  @override
  Future<void> clearAuthCache() async {}
}

class MockGoogleSignInAuthentication implements GoogleSignInAuthentication {
  @override
  String? get idToken => 'mock_google_id_token_xyz';

  @override
  String? get accessToken => 'mock_google_access_token_xyz';

  @override
  String? get serverAuthCode => null;
}

class FakeGoogleSignIn extends GoogleSignIn {
  FakeGoogleSignIn({this.accountToReturn});

  final GoogleSignInAccount? accountToReturn;
  bool signOutCalled = false;

  @override
  Future<GoogleSignInAccount?> signIn() async => accountToReturn;

  @override
  Future<GoogleSignInAccount?> signOut() async {
    signOutCalled = true;
    return null;
  }
}

class MockAuthRepositoryForGoogle implements AuthRepository {
  AmanahAuthUser? mockUser;
  bool shouldThrowNotAuthorized = false;

  @override
  Future<AmanahAuthUser?> signInWithGoogle(String idToken) async {
    if (shouldThrowNotAuthorized) {
      throw const NotAuthorizedFailure(
        'Akun Google ini belum terdaftar atau belum diundang sebagai staf/dokter klinik.',
      );
    }
    return mockUser;
  }

  @override
  Future<AmanahAuthUser?> authenticate(String identifier, String password) async => null;
  @override
  Future<AmanahAuthUser?> getSession() async => null;
  @override
  Future<bool> refreshToken() async => true;
  @override
  Future<void> signOut() async {}
  @override
  Future<bool> checkVerificationOtp(String email, String otp) async => true;
  @override
  Future<bool> requestPasswordReset(String email) async => true;
  @override
  Future<bool> resetPassword(String email, String otp, String newPassword) async => true;
  @override
  Future<bool> changePassword({required String oldPassword, required String newPassword}) async => true;
  @override
  Future<List<StaffOnboardingPoliOption>> fetchStaffOnboardingPolikliniks() async => const <StaffOnboardingPoliOption>[];
  @override
  Future<AmanahAuthUser?> submitStaffOnboarding(dynamic dto) async => null;
  @override
  Future<UserAvatar> uploadAvatar({List<int>? fileBytes, String? filePath, String fileName = 'avatar.jpg', bool useAuthAlias = false}) async => UserAvatar.empty;
  @override
  Future<bool> deleteAvatar() async => true;
}

void main() {
  late MockAuthRepositoryForGoogle repository;

  setUp(() {
    repository = MockAuthRepositoryForGoogle();
  });

  test('GoogleAuthService returns null silently when user cancels account picker', () async {
    final FakeGoogleSignIn fakeGms = FakeGoogleSignIn(accountToReturn: null);
    final GoogleAuthService service = GoogleAuthService(googleSignIn: fakeGms);

    final String? token = await service.getIdToken();

    expect(token, isNull);
  });

  test('GoogleAuthService extracts idToken successfully', () async {
    final MockGoogleSignInAccount mockAccount = MockGoogleSignInAccount();
    final FakeGoogleSignIn fakeGms = FakeGoogleSignIn(accountToReturn: mockAccount);
    final GoogleAuthService service = GoogleAuthService(googleSignIn: fakeGms);

    final String? token = await service.getIdToken();

    expect(token, 'mock_google_id_token_xyz');
  });

  test('SignInWithGoogleUseCase handles silent cancellation', () async {
    final FakeGoogleSignIn fakeGms = FakeGoogleSignIn(accountToReturn: null);
    final GoogleAuthService service = GoogleAuthService(googleSignIn: fakeGms);
    final SignInWithGoogleUseCase useCase = SignInWithGoogleUseCase(
      repository: repository,
      googleAuthService: service,
    );

    final AmanahAuthUser? user = await useCase();

    expect(user, isNull);
    expect(fakeGms.signOutCalled, isTrue, reason: 'Must perform pre-flight signOut()');
  });

  test('SignInWithGoogleUseCase authenticates user successfully and extracts idToken', () async {
    final MockGoogleSignInAccount mockAccount = MockGoogleSignInAccount();
    final FakeGoogleSignIn fakeGms = FakeGoogleSignIn(accountToReturn: mockAccount);
    final GoogleAuthService service = GoogleAuthService(googleSignIn: fakeGms);
    final SignInWithGoogleUseCase useCase = SignInWithGoogleUseCase(
      repository: repository,
      googleAuthService: service,
    );

    const AmanahAuthUser expectedUser = AmanahAuthUser(
      id: 'doctor-google-1',
      role: AmanahUserRole.doctor,
      fullName: 'Dr. Dokter',
      email: 'dokter@amanah.id',
      phone: '08123456789',
    );
    repository.mockUser = expectedUser;

    final AmanahAuthUser? user = await useCase();

    expect(user, isNotNull);
    expect(user!.id, 'doctor-google-1');
    expect(fakeGms.signOutCalled, isTrue, reason: 'Must perform pre-flight signOut()');
  });

  test('SignInWithGoogleUseCase cleans up with signOut() when backend returns 403 NotAuthorizedFailure', () async {
    final MockGoogleSignInAccount mockAccount = MockGoogleSignInAccount();
    final FakeGoogleSignIn fakeGms = FakeGoogleSignIn(accountToReturn: mockAccount);
    final GoogleAuthService service = GoogleAuthService(googleSignIn: fakeGms);
    final SignInWithGoogleUseCase useCase = SignInWithGoogleUseCase(
      repository: repository,
      googleAuthService: service,
    );

    repository.shouldThrowNotAuthorized = true;

    expect(
      () => useCase(),
      throwsA(
        isA<NotAuthorizedFailure>().having(
          (NotAuthorizedFailure f) => f.message,
          'message',
          'Akun Google ini belum terdaftar atau belum diundang sebagai staf/dokter klinik.',
        ),
      ),
    );
  });
}
