import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';

abstract interface class PermissionRepository {
  Future<List<EligibleSession>> getEligibleSessions(String date);

  Future<LeaveRequestEntity> requestLeave({
    required String startDate,
    required String endDate,
    required String reason,
    String? type,
    String? scope,
    List<String>? sessionIds,
  });

  Future<List<LeaveRequestEntity>> getMyLeaves();

  Future<LeaveRequestEntity> cancelLeave(String id);

  Future<List<ReplacementItem>> getAvailableReplacements();

  Future<ReplacementItem> claimReplacement(String id);
}
