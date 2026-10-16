import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

final class ChangePasswordParams {
  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });

  final String oldPassword;
  final String newPassword;
}

class ChangePasswordUseCase implements UseCase<bool, ChangePasswordParams> {
  const ChangePasswordUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<bool> call(ChangePasswordParams params) {
    return _repository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}
