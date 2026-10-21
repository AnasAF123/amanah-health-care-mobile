import 'package:amanah_healthcare/core/constants/api_prefix.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';

abstract final class PayrollEndpoints {
  static const String pathMySummary = '${ApiPrefix.v1}/payroll/my-summary';
  static const String pathMyHistory = '${ApiPrefix.v1}/payroll/my-history';
  static const String pathPeriods = '${ApiPrefix.v1}/payroll/periods';

  static const ApiEndpoint mySummaryEndpoint = ApiEndpoint(
    path: pathMySummary,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static const ApiEndpoint myHistoryEndpoint = ApiEndpoint(
    path: pathMyHistory,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static const ApiEndpoint periodsEndpoint = ApiEndpoint(
    path: pathPeriods,
    method: HttpMethod.get,
    requiresAuth: true,
  );
}
