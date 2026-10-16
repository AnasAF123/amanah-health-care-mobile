import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

final class ResetPasswordParams {
  const ResetPasswordParams({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  final String email;
  final String otp;
  final String newPassword;
}

class ResetPasswordUseCase implements UseCase<bool, ResetPasswordParams> {
  const ResetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<bool> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      params.email,
      params.otp,
      params.newPassword,
    );
  }
}
