import 'package:amanah_healthcare/core/constants/api_prefix.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';

abstract final class AttendanceEndpoints {
  static const String pathScan = '${ApiPrefix.v1}/attendance/scan';
  static const String pathCheckout = '${ApiPrefix.v1}/attendance/checkout';
  static const String pathMyHistory = '${ApiPrefix.v1}/attendance/my-history';

  static const ApiEndpoint scanEndpoint = ApiEndpoint(
    path: pathScan,
    method: HttpMethod.post,
    requiresAuth: true,
  );

  static const ApiEndpoint checkoutEndpoint = ApiEndpoint(
    path: pathCheckout,
    method: HttpMethod.post,
    requiresAuth: true,
  );

  static const ApiEndpoint myHistoryEndpoint = ApiEndpoint(
    path: pathMyHistory,
    method: HttpMethod.get,
    requiresAuth: true,
  );
}
