import 'package:amanah_healthcare/features/permission/domain/entities/replacement_facets.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class GetReplacementFacetsUseCase {
  const GetReplacementFacetsUseCase(this._repository);

  final PermissionRepository _repository;

  Future<ReplacementFacets> execute() {
    return _repository.getReplacementFacets();
  }
}
