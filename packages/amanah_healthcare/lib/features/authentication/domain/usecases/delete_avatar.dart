import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

class DeleteAvatarUseCase implements UseCase<bool, NoParams> {
  const DeleteAvatarUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<bool> call(NoParams params) {
    return _repository.deleteAvatar();
  }
}
