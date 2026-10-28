import 'package:amanah_healthcare/features/permission/domain/entities/amanah_permission_form_data.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';

abstract interface class PermissionRepository {
  Future<List<EligibleSession>> getEligibleSessions(String date);

  Future<LeaveRequestEntity> requestLeave(AmanahPermissionFormData formData);

  Future<List<LeaveRequestEntity>> getMyLeaves();

  Future<LeaveRequestEntity> cancelLeave(String id);

  Future<List<ReplacementItem>> getAvailableReplacements();

  Future<ReplacementItem> claimReplacement(String id);
}
