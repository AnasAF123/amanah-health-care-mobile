import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

final class VerifyEmailChangeParams {
  const VerifyEmailChangeParams({
    required this.newEmail,
    required this.otp,
  });

  final String newEmail;
  final String otp;
}

class VerifyEmailChangeUseCase
    implements UseCase<bool, VerifyEmailChangeParams> {
  const VerifyEmailChangeUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<bool> call(VerifyEmailChangeParams params) {
    return _repository.verifyEmailChange(
      newEmail: params.newEmail,
      otp: params.otp,
    );
  }
}
