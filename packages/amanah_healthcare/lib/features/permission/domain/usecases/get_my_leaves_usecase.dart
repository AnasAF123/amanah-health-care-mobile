import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class GetMyLeavesUseCase {
  const GetMyLeavesUseCase(this._repository);

  final PermissionRepository _repository;

  Future<List<LeaveRequestEntity>> execute() {
    return _repository.getMyLeaves();
  }
}
