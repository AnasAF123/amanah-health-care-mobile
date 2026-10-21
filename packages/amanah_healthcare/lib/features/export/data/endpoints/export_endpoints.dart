import 'package:amanah_healthcare/core/constants/api_prefix.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';

abstract final class ExportEndpoints {
  static const String pathExports = '${ApiPrefix.v1}/exports';
  static const String pathMyHistory = '${ApiPrefix.v1}/exports/my-history';

  static const ApiEndpoint createExportEndpoint = ApiEndpoint(
    path: pathExports,
    method: HttpMethod.post,
    requiresAuth: true,
  );

  static const ApiEndpoint myHistoryEndpoint = ApiEndpoint(
    path: pathMyHistory,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static ApiEndpoint statusEndpoint(String jobId) => ApiEndpoint(
    path: '$pathExports/$jobId',
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static ApiEndpoint downloadEndpoint(String jobId) => ApiEndpoint(
    path: '$pathExports/$jobId/download',
    method: HttpMethod.get,
    requiresAuth: true,
  );
}
