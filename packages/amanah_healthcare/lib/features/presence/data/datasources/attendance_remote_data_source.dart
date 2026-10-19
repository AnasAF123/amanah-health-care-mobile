import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/presence/data/endpoints/attendance_endpoints.dart';

abstract interface class AttendanceRemoteDataSource {
  Future<Map<String, dynamic>> submitScan({
    required String qrToken,
    String? shift,
    String? deviceInfo,
  });

  Future<Map<String, dynamic>> submitCheckout({
    String? qrToken,
    String? notes,
  });

  Future<List<dynamic>> getMyHistory();
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  AttendanceRemoteDataSourceImpl({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ??
            AuthorizedApiClient(
              innerClient: HttpApiClient(
                baseUrl: AmanahAuthEnvironment.authBaseUrl,
              ),
              tokenProvider: const AmanahAuthTokenStorage(),
            );

  final ApiClient _apiClient;

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        return responseData['data'];
      }
    }
    return responseData;
  }

  @override
  Future<Map<String, dynamic>> submitScan({
    required String qrToken,
    String? shift,
    String? deviceInfo,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'qrToken': qrToken,
      'shift': ?shift,
      'deviceInfo': ?deviceInfo,
    };

    final ApiResponse<dynamic> res = await _apiClient.request(
      AttendanceEndpoints.scanEndpoint,
      body: body,
    );

    final dynamic data = _extractData(res.data);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> submitCheckout({
    String? qrToken,
    String? notes,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (qrToken != null && qrToken.isNotEmpty) {
      body['qrToken'] = qrToken;
    }
    if (notes != null && notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }

    final ApiResponse<dynamic> res = await _apiClient.request(
      AttendanceEndpoints.checkoutEndpoint,
      body: body.isNotEmpty ? body : null,
    );

    final dynamic data = _extractData(res.data);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  @override
  Future<List<dynamic>> getMyHistory() async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      AttendanceEndpoints.myHistoryEndpoint,
    );

    final dynamic data = _extractData(res.data);
    if (data is List) {
      return data;
    }
    return <dynamic>[];
  }
}
