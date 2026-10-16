import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

final class VerifyOtpParams {
  const VerifyOtpParams({required this.email, required this.otp});
  final String email;
  final String otp;
}

class VerifyOtpUseCase implements UseCase<bool, VerifyOtpParams> {
  const VerifyOtpUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<bool> call(VerifyOtpParams params) {
    return _repository.checkVerificationOtp(params.email, params.otp);
  }
}
