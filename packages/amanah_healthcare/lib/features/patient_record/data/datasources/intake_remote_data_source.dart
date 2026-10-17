import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/patient_record/data/endpoints/intake_endpoints.dart';

abstract interface class IntakeRemoteDataSource {
  Future<dynamic> getIntakeByAppointmentId(String appointmentId);
}

class IntakeRemoteDataSourceImpl implements IntakeRemoteDataSource {
  IntakeRemoteDataSourceImpl({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ??
            AuthorizedApiClient(
              innerClient: HttpApiClient(
                baseUrl: AmanahAuthEnvironment.authBaseUrl,
              ),
              tokenProvider: const AmanahAuthTokenStorage(),
            );

  final ApiClient _apiClient;

  @override
  Future<dynamic> getIntakeByAppointmentId(String appointmentId) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      IntakeEndpoints.intakeByAppointment(appointmentId),
    );
    if (res.data is Map<String, dynamic>) {
      final Map<String, dynamic> map = res.data as Map<String, dynamic>;
      if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
        if (map.containsKey('flow') || map['data'].containsKey('flow')) {
          return map;
        }
        return map['data'];
      }
    }
    return res.data;
  }
}
