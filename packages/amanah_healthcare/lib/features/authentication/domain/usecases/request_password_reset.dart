import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

final class RequestPasswordResetParams {
  const RequestPasswordResetParams({required this.email});
  final String email;
}

class RequestPasswordResetUseCase
    implements UseCase<bool, RequestPasswordResetParams> {
  const RequestPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<bool> call(RequestPasswordResetParams params) {
    return _repository.requestPasswordReset(params.email);
  }
}
