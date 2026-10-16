import 'package:amanah_healthcare/core/network/api_endpoint.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';

abstract interface class ApiClient {
  Future<ApiResponse<dynamic>> request(
    ApiEndpoint endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    List<int>? fileBytes,
    String? filePath,
    String? fileField,
    String? fileName,
  });
}
