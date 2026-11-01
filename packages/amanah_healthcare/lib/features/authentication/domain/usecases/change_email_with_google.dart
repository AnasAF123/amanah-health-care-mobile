import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

final class ChangeEmailWithGoogleParams {
  const ChangeEmailWithGoogleParams({
    required this.idToken,
  });

  final String idToken;
}

class ChangeEmailWithGoogleUseCase
    implements UseCase<bool, ChangeEmailWithGoogleParams> {
  const ChangeEmailWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<bool> call(ChangeEmailWithGoogleParams params) {
    return _repository.changeEmailWithGoogle(
      idToken: params.idToken,
    );
  }
}
