import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/queue/data/endpoints/queue_endpoints.dart';

abstract interface class QueueRemoteDataSource {
  Future<dynamic> getMySchedules();
  Future<dynamic> getSessionPatients(String sessionId, {String? status});
  Future<dynamic> callPatient(String appointmentId, {String? notes});
  Future<dynamic> startService(String appointmentId);
  Future<dynamic> completeService(String appointmentId);
  Future<dynamic> cancelAppointment(String appointmentId, {String? reason});
  Future<dynamic> reportNoShow(String appointmentId, {String? notes});
  Future<dynamic> rescheduleAppointment(
    String appointmentId, {
    required String targetDate,
    String? session,
    String? targetSessionId,
    String? reason,
  });
  Future<dynamic> getRescheduleOptions(String appointmentId);
}

class QueueRemoteDataSourceImpl implements QueueRemoteDataSource {
  QueueRemoteDataSourceImpl({
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
  Future<dynamic> getMySchedules() async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      QueueEndpoints.mySchedules,
    );
    return _extractData(res.data);
  }

  @override
  Future<dynamic> getSessionPatients(String sessionId, {String? status}) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      QueueEndpoints.sessionPatients(sessionId, status: status),
    );
    return _extractData(res.data);
  }

  @override
  Future<dynamic> callPatient(String appointmentId, {String? notes}) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      QueueEndpoints.callPatient(appointmentId),
      body: notes != null ? <String, dynamic>{'notes': notes} : null,
    );
    return _extractData(res.data);
  }

  @override
  Future<dynamic> startService(String appointmentId) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      QueueEndpoints.startService(appointmentId),
    );
    return _extractData(res.data);
  }

  @override
  Future<dynamic> completeService(String appointmentId) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      QueueEndpoints.completeService(appointmentId),
    );
    return _extractData(res.data);
  }

  @override
  Future<dynamic> cancelAppointment(
    String appointmentId, {
    String? reason,
  }) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      QueueEndpoints.cancelAppointment(appointmentId),
      body: reason != null ? <String, dynamic>{'reason': reason} : null,
    );
    return _extractData(res.data);
  }

  @override
  Future<dynamic> reportNoShow(String appointmentId, {String? notes}) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      QueueEndpoints.reportNoShow(appointmentId),
      body: notes != null ? <String, dynamic>{'notes': notes} : null,
    );
    return _extractData(res.data);
  }

  @override
  Future<dynamic> rescheduleAppointment(
    String appointmentId, {
    required String targetDate,
    String? session,
    String? targetSessionId,
    String? reason,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'target_date': targetDate,
    };
    if (session != null) body['session'] = session;
    if (targetSessionId != null) body['target_session_id'] = targetSessionId;
    if (reason != null) body['reason'] = reason;

    final ApiResponse<dynamic> res = await _apiClient.request(
      QueueEndpoints.rescheduleAppointment(appointmentId),
      body: body,
    );
    return _extractData(res.data);
  }

  @override
  Future<dynamic> getRescheduleOptions(String appointmentId) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      QueueEndpoints.rescheduleOptions(appointmentId),
    );
    return _extractData(res.data);
  }
}
