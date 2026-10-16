import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/calendar_summary_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/doctor_roster_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/my_schedule_session_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/session_patient_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/update_doctor_roster_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/endpoints/schedule_endpoints.dart';

abstract interface class ScheduleRemoteDataSource {
  Future<DoctorRosterOverviewDto> getDoctorRoster();
  Future<DoctorRosterOverviewDto> updateDoctorRoster(UpdateDoctorRosterDto dto);
  Future<DoctorRosterOverviewDto> resetDoctorRoster();
  Future<CalendarSummaryResponseDto> getCalendarSummary(String month);
  Future<List<SessionPatientDto>> getBookedPatients(String date);
  Future<List<SessionPatientDto>> getSessionPatients(
    String sessionId, {
    String? date,
  });
  Future<List<MyScheduleSessionDto>> getMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  });
  Future<void> toggleDayStatus(
    String date, {
    required bool isClosed,
    String? notes,
  });
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  ScheduleRemoteDataSourceImpl({
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
  Future<DoctorRosterOverviewDto> getDoctorRoster() async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      ScheduleEndpoints.myRosterGetEndpoint,
    );
    final dynamic data = _extractData(res.data);
    return DoctorRosterOverviewDto.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<DoctorRosterOverviewDto> updateDoctorRoster(
    UpdateDoctorRosterDto dto,
  ) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      ScheduleEndpoints.myRosterPutEndpoint,
      body: dto.toJson(),
    );
    final dynamic data = _extractData(res.data);
    return DoctorRosterOverviewDto.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<DoctorRosterOverviewDto> resetDoctorRoster() async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      ScheduleEndpoints.myRosterDeleteEndpoint,
    );
    final dynamic data = _extractData(res.data);
    return DoctorRosterOverviewDto.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<CalendarSummaryResponseDto> getCalendarSummary(String month) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      ScheduleEndpoints.calendarSummaryEndpoint,
      queryParameters: <String, String>{'month': month},
    );
    final dynamic data = _extractData(res.data);
    return CalendarSummaryResponseDto.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<List<SessionPatientDto>> getBookedPatients(String date) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      ScheduleEndpoints.bookedPatientsEndpoint,
      queryParameters: <String, String>{'date': date},
    );
    final dynamic data = _extractData(res.data);
    final List<dynamic> list = data is List<dynamic> ? data : const <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(SessionPatientDto.fromJson)
        .toList();
  }

  @override
  Future<List<SessionPatientDto>> getSessionPatients(
    String sessionId, {
    String? date,
  }) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      ScheduleEndpoints.sessionPatientsEndpoint(sessionId),
      queryParameters: date != null ? <String, String>{'date': date} : null,
    );
    final dynamic data = _extractData(res.data);

    // If response is AdminSessionPatientsResponse: { session: ..., patients: [...] }
    List<dynamic> list = const <dynamic>[];
    if (data is Map<String, dynamic> && data['patients'] is List) {
      list = data['patients'] as List<dynamic>;
    } else if (data is List<dynamic>) {
      list = data;
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map(SessionPatientDto.fromJson)
        .toList();
  }

  @override
  Future<List<MyScheduleSessionDto>> getMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, String> query = <String, String>{};
    if (date != null && date.isNotEmpty) query['date'] = date;
    if (startDate != null && startDate.isNotEmpty) query['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) query['endDate'] = endDate;

    final ApiResponse<dynamic> res = await _apiClient.request(
      ScheduleEndpoints.mySchedulesEndpoint,
      queryParameters: query.isNotEmpty ? query : null,
    );
    final dynamic data = _extractData(res.data);
    final List<dynamic> list = data is List<dynamic> ? data : const <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(MyScheduleSessionDto.fromJson)
        .toList();
  }

  @override
  Future<void> toggleDayStatus(
    String date, {
    required bool isClosed,
    String? notes,
  }) async {
    await _apiClient.request(
      ScheduleEndpoints.daysPatchEndpoint(date),
      body: <String, dynamic>{
        'status': isClosed ? 'CLOSED' : 'OPEN',
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }
}
