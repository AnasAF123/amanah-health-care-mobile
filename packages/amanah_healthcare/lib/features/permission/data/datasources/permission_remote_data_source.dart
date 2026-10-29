import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/permission/data/dto/eligible_session_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/leave_request_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/replacement_facets_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/replacement_item_dto.dart';
import 'package:amanah_healthcare/features/permission/data/endpoints/permission_endpoints.dart';

abstract interface class PermissionRemoteDataSource {
  Future<List<EligibleSessionDto>> getEligibleSessions(String date);

  Future<LeaveRequestDto> requestLeave({
    required String startDate,
    required String endDate,
    required String reason,
    String? type,
    String? scope,
    List<String>? sessionIds,
  });

  Future<List<LeaveRequestDto>> getMyLeaves();

  Future<LeaveRequestDto> cancelLeave(String id);

  Future<List<ReplacementItemDto>> getAvailableReplacements({
    String? exactDate,
    String? staffProfileId,
  });

  Future<ReplacementFacetsDto> getReplacementFacets();

  Future<ReplacementItemDto> claimReplacement(String id);
}

class PermissionRemoteDataSourceImpl implements PermissionRemoteDataSource {
  PermissionRemoteDataSourceImpl({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          AuthorizedApiClient(
            innerClient: HttpApiClient(baseUrl: AmanahAuthEnvironment.authBaseUrl),
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
  Future<List<EligibleSessionDto>> getEligibleSessions(String date) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      PermissionEndpoints.eligibleSessionsEndpoint,
      queryParameters: <String, String>{'date': date},
    );

    final dynamic data = _extractData(res.data);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> e) => EligibleSessionDto.fromJson(e))
          .toList();
    }
    return <EligibleSessionDto>[];
  }

  @override
  Future<LeaveRequestDto> requestLeave({
    required String startDate,
    required String endDate,
    required String reason,
    String? type,
    String? scope,
    List<String>? sessionIds,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'type': ?type,
      'scope': ?scope,
      if (sessionIds != null && sessionIds.isNotEmpty) 'sessionIds': sessionIds,
    };

    final ApiResponse<dynamic> res = await _apiClient.request(
      PermissionEndpoints.requestLeaveEndpoint,
      body: body,
    );

    final dynamic data = _extractData(res.data);
    return LeaveRequestDto.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  @override
  Future<List<LeaveRequestDto>> getMyLeaves() async {
    final ApiResponse<dynamic> res = await _apiClient.request(PermissionEndpoints.myLeavesEndpoint);

    final dynamic data = _extractData(res.data);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> e) => LeaveRequestDto.fromJson(e))
          .toList();
    }
    return <LeaveRequestDto>[];
  }

  @override
  Future<LeaveRequestDto> cancelLeave(String id) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      PermissionEndpoints.cancelLeaveEndpoint(id),
    );

    final dynamic data = _extractData(res.data);
    return LeaveRequestDto.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  @override
  Future<List<ReplacementItemDto>> getAvailableReplacements({
    String? exactDate,
    String? staffProfileId,
  }) async {
    final Map<String, String> queryParameters = <String, String>{'status': 'open'};
    if (exactDate != null && exactDate.isNotEmpty) {
      queryParameters['exactDate'] = exactDate;
    }
    if (staffProfileId != null && staffProfileId.isNotEmpty) {
      queryParameters['staffProfileId'] = staffProfileId;
    }

    final ApiResponse<dynamic> res = await _apiClient.request(
      PermissionEndpoints.availableReplacementsEndpoint,
      queryParameters: queryParameters,
    );

    final dynamic data = _extractData(res.data);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> e) => ReplacementItemDto.fromJson(e))
          .toList();
    }
    return <ReplacementItemDto>[];
  }

  @override
  Future<ReplacementFacetsDto> getReplacementFacets() async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      PermissionEndpoints.replacementFacetsEndpoint,
    );

    final dynamic data = _extractData(res.data);
    return ReplacementFacetsDto.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }

  @override
  Future<ReplacementItemDto> claimReplacement(String id) async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      PermissionEndpoints.claimReplacementEndpoint(id),
    );

    final dynamic data = _extractData(res.data);
    return ReplacementItemDto.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
  }
}
