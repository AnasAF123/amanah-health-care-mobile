import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class ClaimReplacementUseCase {
  const ClaimReplacementUseCase(this._repository);

  final PermissionRepository _repository;

  Future<ReplacementItem> execute(String id) {
    return _repository.claimReplacement(id);
  }
}
