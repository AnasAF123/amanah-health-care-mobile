import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class GetAvailableReplacementsUseCase {
  const GetAvailableReplacementsUseCase(this._repository);

  final PermissionRepository _repository;

  Future<List<ReplacementItem>> execute({String? exactDate, String? staffProfileId}) {
    return _repository.getAvailableReplacements(
      exactDate: exactDate,
      staffProfileId: staffProfileId,
    );
  }
}
