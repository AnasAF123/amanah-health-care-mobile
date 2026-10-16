import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/auth_modal_sheet.dart';

class MockAuthRepository implements AuthRepository {
  String? lastIdentifier;
  String? lastPassword;

  @override
  Future<AmanahAuthUser?> authenticate(String identifier, String password) async {
    lastIdentifier = identifier;
    lastPassword = password;
    return const AmanahAuthUser(
      id: 'staff-999',
      role: AmanahUserRole.staff,
      fullName: 'Siti Administrator',
      email: 'siti@amanah.id',
      phone: '081234567890',
    );
  }

  @override
  Future<AmanahAuthUser?> signInWithGoogle(String idToken) async => null;

  @override
  Future<AmanahAuthUser?> getSession() async => null;

  @override
  Future<void> signOut() async {}

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
  Future<bool> resetPassword(String email, String otp, String newPassword) async => true;

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async =>
      true;

  @override
  Future<AmanahAuthUser?> submitStaffOnboarding(dynamic dto) async => null;

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
  testWidgets('AuthModalSheet executes SignInWithEmailUseCase and triggers onAuthenticated',
      (WidgetTester tester) async {
    final MockAuthRepository mockRepo = MockAuthRepository();
    final SignInWithEmailUseCase signInUseCase = SignInWithEmailUseCase(mockRepo);

    AmanahAuthUser? authenticatedUser;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthModalSheet(
            repository: mockRepo,
            signInWithEmailUseCase: signInUseCase,
            onAuthenticated: (AmanahAuthUser user) {
              authenticatedUser = user;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify fields exist
    final Finder emailField = find.byType(TextFormField).first;
    final Finder passwordField = find.byType(TextFormField).last;

    await tester.enterText(emailField, 'siti@amanah.id');
    await tester.enterText(passwordField, 'Password123!');
    await tester.pumpAndSettle();

    // Tap submit button (Masuk)
    final Finder submitBtn = find.text('Masuk');
    expect(submitBtn, findsOneWidget);

    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Verify UseCase executed repository authenticate
    expect(mockRepo.lastIdentifier, 'siti@amanah.id');
    expect(mockRepo.lastPassword, 'Password123!');

    // Verify onAuthenticated was called with the user
    expect(authenticatedUser, isNotNull);
    expect(authenticatedUser!.id, 'staff-999');
    expect(authenticatedUser!.fullName, 'Siti Administrator');
  });
}
