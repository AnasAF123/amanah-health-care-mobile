import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class CancelLeaveUseCase {
  const CancelLeaveUseCase(this._repository);

  final PermissionRepository _repository;

  Future<LeaveRequestEntity> execute(String id) {
    return _repository.cancelLeave(id);
  }
}
