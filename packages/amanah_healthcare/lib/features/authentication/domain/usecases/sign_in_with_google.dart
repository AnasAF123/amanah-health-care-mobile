import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/data/datasources/google_auth_service.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

/// Clean Architecture Use Case orchestrating the full Google Sign-In transaction:
/// 1. Pre-flight SDK session reset (guaranteeing account chooser dialog)
/// 2. Account selection & ID token retrieval (silent return on cancellation)
/// 3. Backend authentication via [AuthRepository.signInWithGoogle]
/// 4. Post-failure SDK cleanup if backend denies access (e.g. 403 not authorized)
class SignInWithGoogleUseCase implements UseCase<AmanahAuthUser?, NoParams> {
  const SignInWithGoogleUseCase({
    required AuthRepository repository,
    GoogleAuthService? googleAuthService,
  })  : _repository = repository,
        _googleAuthService = googleAuthService ?? const GoogleAuthService();

  final AuthRepository _repository;
  final GoogleAuthService _googleAuthService;

  @override
  Future<AmanahAuthUser?> call([NoParams params = const NoParams()]) async {
    // 1. Pre-flight cleanup: clear active Google SDK account cache to force account chooser
    await _googleAuthService.signOut();

    // 2. Launch Google Account Chooser and obtain idToken
    final String? idToken = await _googleAuthService.getIdToken();
    if (idToken == null) {
      // User cancelled account selection -> return null without emitting error
      return null;
    }

    // 3. Authenticate with backend API
    try {
      return await _repository.signInWithGoogle(idToken);
    } catch (e) {
      // 4. Post-failure cleanup: purge uninvited account from SDK session
      await _googleAuthService.signOut();
      rethrow;
    }
  }
}
