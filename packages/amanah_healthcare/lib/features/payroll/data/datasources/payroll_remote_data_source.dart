import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/payroll/data/dto/payroll_period_dto.dart';
import 'package:amanah_healthcare/features/payroll/data/dto/staff_payroll_summary_dto.dart';
import 'package:amanah_healthcare/features/payroll/data/endpoints/payroll_endpoints.dart';

abstract interface class PayrollRemoteDataSource {
  Future<StaffPayrollSummaryDto> getMyPayroll({String? periodId});
  Future<List<PayrollPeriodDto>> getPayrollPeriods();
}

class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
  PayrollRemoteDataSourceImpl({
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
  Future<StaffPayrollSummaryDto> getMyPayroll({String? periodId}) async {
    final Map<String, String>? queryParams =
        periodId != null ? <String, String>{'periodId': periodId} : null;

    final ApiResponse<dynamic> res = await _apiClient.request(
      PayrollEndpoints.mySummaryEndpoint,
      queryParameters: queryParams,
    );

    final dynamic data = _extractData(res.data);
    return StaffPayrollSummaryDto.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<List<PayrollPeriodDto>> getPayrollPeriods() async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      PayrollEndpoints.periodsEndpoint,
    );

    final dynamic data = _extractData(res.data);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> e) => PayrollPeriodDto.fromJson(e))
          .toList();
    }
    return <PayrollPeriodDto>[];
  }
}
