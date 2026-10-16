import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

class RestoreSessionUseCase implements UseCase<AmanahAuthUser?, NoParams> {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<AmanahAuthUser?> call(NoParams params) {
    return _repository.getSession();
  }
}
