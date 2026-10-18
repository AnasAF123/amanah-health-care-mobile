import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class RequestLeaveUseCase {
  const RequestLeaveUseCase(this._repository);

  final PermissionRepository _repository;

  Future<LeaveRequestEntity> execute({
    required String startDate,
    required String endDate,
    required String reason,
    String? type,
    String? scope,
    List<String>? sessionIds,
  }) {
    return _repository.requestLeave(
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      type: type,
      scope: scope,
      sessionIds: sessionIds,
    );
  }
}
