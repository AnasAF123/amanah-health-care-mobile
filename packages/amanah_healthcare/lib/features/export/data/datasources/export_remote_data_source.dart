import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/export/data/endpoints/export_endpoints.dart';
import 'package:amanah_healthcare/features/export/domain/entities/export_job.dart';

abstract interface class ExportRemoteDataSource {
  Future<ExportJob> requestExport({
    required String exportType,
    required String format,
    Map<String, dynamic>? parameters,
  });

  Future<bool> checkAvailability({required String exportType, Map<String, dynamic>? parameters});

  Future<ExportJob> getJobStatus(String jobId);

  Future<File> downloadFile({required String downloadUrl, required String savePath});
}

class ExportRemoteDataSourceImpl implements ExportRemoteDataSource {
  ExportRemoteDataSourceImpl({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          AuthorizedApiClient(
            innerClient: HttpApiClient(baseUrl: AmanahAuthEnvironment.authBaseUrl),
            tokenProvider: const AmanahAuthTokenStorage(),
          ),
      _tokenStorage = const AmanahAuthTokenStorage();

  final ApiClient _apiClient;
  final AmanahAuthTokenStorage _tokenStorage;

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        return responseData['data'];
      }
    }
    return responseData;
  }

  @override
  Future<ExportJob> requestExport({
    required String exportType,
    required String format,
    Map<String, dynamic>? parameters,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'exportType': exportType,
      'format': format,
      'parameters': parameters ?? <String, dynamic>{},
    };

    final ApiResponse<dynamic> res = await _apiClient.request(
      ExportEndpoints.createExportEndpoint,
      body: body,
    );

    final dynamic data = _extractData(res.data);
    return ExportJob.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  @override
  Future<bool> checkAvailability({
    required String exportType,
    Map<String, dynamic>? parameters,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'exportType': exportType,
      'parameters': parameters ?? <String, dynamic>{},
    };

    final ApiResponse<dynamic> res = await _apiClient.request(
      ExportEndpoints.checkAvailabilityEndpoint,
      body: body,
    );

    final dynamic data = _extractData(res.data);
    if (data is Map<String, dynamic>) {
      return (data['available'] as bool?) ?? false;
    }
    return false;
  }

  @override
  Future<ExportJob> getJobStatus(String jobId) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      ExportEndpoints.statusEndpoint(jobId),
    );

    final dynamic data = _extractData(res.data);
    return ExportJob.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  @override
  Future<File> downloadFile({required String downloadUrl, required String savePath}) async {
    final String fullUrl = downloadUrl.startsWith('http')
        ? downloadUrl
        : '${AmanahAuthEnvironment.authBaseUrl}$downloadUrl';

    final String? token = await _tokenStorage.getToken();
    final Map<String, String> headers = <String, String>{
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final http.Response response = await http.get(Uri.parse(fullUrl), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengunduh berkas laporan (HTTP ${response.statusCode})');
    }

    final File file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}
