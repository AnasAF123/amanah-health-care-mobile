import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';

/// Form payload for submitting a staff leave or permission application.
class AmanahPermissionFormData {
  final AmanahPermissionType type;
  final String startDate; // 'YYYY-MM-DD'
  final String endDate; // 'YYYY-MM-DD'
  final String reason;
  final String scope; // 'full_day' or 'session'
  final List<String>? sessionIds;

  const AmanahPermissionFormData({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.scope = 'full_day',
    this.sessionIds,
  });
}
