import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

final class RequestEmailChangeParams {
  const RequestEmailChangeParams({
    required this.newEmail,
    this.currentPassword,
  });

  final String newEmail;
  final String? currentPassword;
}

class RequestEmailChangeUseCase
    implements UseCase<bool, RequestEmailChangeParams> {
  const RequestEmailChangeUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<bool> call(RequestEmailChangeParams params) {
    return _repository.requestEmailChange(
      newEmail: params.newEmail,
      currentPassword: params.currentPassword,
    );
  }
}
