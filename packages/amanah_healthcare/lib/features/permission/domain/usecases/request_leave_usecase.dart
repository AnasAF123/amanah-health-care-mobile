import 'package:amanah_healthcare/features/permission/domain/entities/amanah_permission_form_data.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class RequestLeaveUseCase {
  const RequestLeaveUseCase(this._repository);

  final PermissionRepository _repository;

  Future<LeaveRequestEntity> execute(AmanahPermissionFormData formData) {
    return _repository.requestLeave(formData);
  }
}
