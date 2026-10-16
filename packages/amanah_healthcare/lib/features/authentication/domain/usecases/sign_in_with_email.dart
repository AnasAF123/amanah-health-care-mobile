import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

final class SignInWithEmailParams {
  const SignInWithEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class SignInWithEmailUseCase
    implements UseCase<AmanahAuthUser?, SignInWithEmailParams> {
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<AmanahAuthUser?> call(SignInWithEmailParams params) {
    return _repository.authenticate(params.email, params.password);
  }
}
