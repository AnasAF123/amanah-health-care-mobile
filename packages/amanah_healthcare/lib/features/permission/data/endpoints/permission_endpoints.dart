import 'package:amanah_healthcare/core/constants/api_prefix.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';

abstract final class PermissionEndpoints {
  static const String pathEligibleSessions =
      '${ApiPrefix.v1}/leaves/eligible-sessions';
  static const String pathLeaves = '${ApiPrefix.v1}/leaves';
  static const String pathMyLeaves = '${ApiPrefix.v1}/leaves/my-leaves';
  static const String pathReplacements = '${ApiPrefix.v1}/replacements';

  static String pathCancelLeave(String id) =>
      '${ApiPrefix.v1}/leaves/$id/cancel';

  static String pathClaimReplacement(String id) =>
      '${ApiPrefix.v1}/replacements/$id/claim';

  static const ApiEndpoint eligibleSessionsEndpoint = ApiEndpoint(
    path: pathEligibleSessions,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static const ApiEndpoint requestLeaveEndpoint = ApiEndpoint(
    path: pathLeaves,
    method: HttpMethod.post,
    requiresAuth: true,
  );

  static const ApiEndpoint myLeavesEndpoint = ApiEndpoint(
    path: pathMyLeaves,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static const ApiEndpoint availableReplacementsEndpoint = ApiEndpoint(
    path: pathReplacements,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static ApiEndpoint cancelLeaveEndpoint(String id) => ApiEndpoint(
        path: pathCancelLeave(id),
        method: HttpMethod.patch,
        requiresAuth: true,
      );

  static ApiEndpoint claimReplacementEndpoint(String id) => ApiEndpoint(
        path: pathClaimReplacement(id),
        method: HttpMethod.post,
        requiresAuth: true,
      );
}
