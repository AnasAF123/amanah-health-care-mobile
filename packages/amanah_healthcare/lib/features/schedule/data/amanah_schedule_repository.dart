import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class AmanahScheduleRepository {
  const AmanahScheduleRepository({
    String? baseUrl,
    http.Client? httpClient,
    AmanahAuthTokenStorage tokenStorage = const AmanahAuthTokenStorage(),
  })  : _customBaseUrl = baseUrl,
        _customClient = httpClient,
        _tokenStorage = tokenStorage;

  final String? _customBaseUrl;
  final http.Client? _customClient;
  final AmanahAuthTokenStorage _tokenStorage;

  String get _baseUrl {
    if (_customBaseUrl != null) return _customBaseUrl;
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  http.Client get _httpClient => _customClient ?? http.Client();
  AmanahAuthTokenStorage get tokenStorage => _tokenStorage;

  Future<Map<String, String>> _buildHeaders({Map<String, String>? extra}) async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?extra,
    };

    final String? token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _handleHttpError(http.Response response) {
    String message = 'Terjadi kesalahan sistem (${response.statusCode})';
    String? code;

    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        message = decoded['message'] as String? ??
            decoded['error']?['message'] as String? ??
            decoded['title'] as String? ??
            message;
        code = decoded['code'] as String? ??
            decoded['error']?['code'] as String?;
      }
    } catch (_) {}

    if (response.statusCode == 409 || response.statusCode == 422) {
      final String codeStr = code ?? (response.statusCode == 409 ? 'CONFLICT' : 'UNPROCESSABLE');
      final String effectiveMsg = (message != 'Terjadi kesalahan sistem (${response.statusCode})' && message.isNotEmpty)
          ? message
          : AmanahScheduleConflictException.userMessageForCode(codeStr);
      throw AmanahScheduleConflictException(
        message: effectiveMsg,
        code: codeStr,
      );
    }

    if (response.statusCode == 401) {
      throw AmanahScheduleException(
        'Sesi autentikasi telah berakhir. Silakan masuk kembali.',
        code: 'UNAUTHORIZED',
      );
    }

    if (response.statusCode == 403) {
      throw AmanahScheduleException(
        message,
        code: code ?? 'FORBIDDEN',
      );
    }

    if (response.statusCode == 404) {
      throw AmanahScheduleException(
        message,
        code: code ?? 'NOT_FOUND',
      );
    }

    throw AmanahScheduleException(message, code: code);
  }

  Future<http.Response> _get(Uri uri) async {
    final Map<String, String> headers = await _buildHeaders();
    AmanahAuthLogger.logRequest('GET', uri, headers: headers);
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final http.Response response = await _httpClient.get(uri, headers: headers);
      stopwatch.stop();
      AmanahAuthLogger.logResponse(
        'GET',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError('GET', uri, e, stackTrace: stack, elapsed: stopwatch.elapsed);
      rethrow;
    }
  }

  Future<http.Response> _post(Uri uri, {Map<String, dynamic>? body}) async {
    final Map<String, String> headers = await _buildHeaders();
    AmanahAuthLogger.logRequest('POST', uri, headers: headers, body: body);
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final http.Response response = await _httpClient.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      stopwatch.stop();
      AmanahAuthLogger.logResponse(
        'POST',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError('POST', uri, e, stackTrace: stack, elapsed: stopwatch.elapsed);
      rethrow;
    }
  }

  Future<http.Response> _put(Uri uri, {Map<String, dynamic>? body}) async {
    final Map<String, String> headers = await _buildHeaders();
    AmanahAuthLogger.logRequest('PUT', uri, headers: headers, body: body);
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final http.Response response = await _httpClient.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      stopwatch.stop();
      AmanahAuthLogger.logResponse(
        'PUT',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError('PUT', uri, e, stackTrace: stack, elapsed: stopwatch.elapsed);
      rethrow;
    }
  }

  Future<http.Response> _patch(Uri uri, {Map<String, dynamic>? body}) async {
    final Map<String, String> headers = await _buildHeaders();
    AmanahAuthLogger.logRequest('PATCH', uri, headers: headers, body: body);
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final http.Response response = await _httpClient.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      stopwatch.stop();
      AmanahAuthLogger.logResponse(
        'PATCH',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError('PATCH', uri, e, stackTrace: stack, elapsed: stopwatch.elapsed);
      rethrow;
    }
  }

  Future<http.Response> _delete(Uri uri) async {
    final Map<String, String> headers = await _buildHeaders();
    AmanahAuthLogger.logRequest('DELETE', uri, headers: headers);
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final http.Response response = await _httpClient.delete(uri, headers: headers);
      stopwatch.stop();
      AmanahAuthLogger.logResponse(
        'DELETE',
        uri,
        response.statusCode,
        stopwatch.elapsed,
        body: response.body,
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      AmanahAuthLogger.logError('DELETE', uri, e, stackTrace: stack, elapsed: stopwatch.elapsed);
      rethrow;
    }
  }

  /// GET /api/v1/schedules/my-schedules
  Future<List<DoctorSchedule>> fetchMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, String> queryParameters = <String, String>{};
    if (date != null && date.isNotEmpty) queryParameters['date'] = date;
    if (startDate != null && startDate.isNotEmpty) queryParameters['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) queryParameters['endDate'] = endDate;

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/my-schedules').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(DoctorSchedule.fromJson)
            .toList();
      }
      return <DoctorSchedule>[];
    }

    _handleHttpError(response);
    return <DoctorSchedule>[];
  }

  /// GET /api/v1/schedules/calendar-summary?month=YYYY-MM
  Future<CalendarSummaryResponse> fetchCalendarSummary(String month) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/calendar-summary').replace(
      queryParameters: <String, String>{'month': month},
    );

    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return CalendarSummaryResponse.fromJson(decoded);
      }
      return CalendarSummaryResponse(month: month, days: const <CalendarDaySummary>[]);
    }

    _handleHttpError(response);
    return CalendarSummaryResponse(month: month, days: const <CalendarDaySummary>[]);
  }

  /// GET /api/v1/schedules/day-settings?date=YYYY-MM-DD
  Future<DayScheduleSetting> fetchDaySettings(String date) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/day-settings').replace(
      queryParameters: <String, String>{'date': date},
    );

    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return DayScheduleSetting.fromJson(decoded);
      }
      return const DayScheduleSetting(targetQuota: 8, isCuti: false);
    }

    _handleHttpError(response);
    return const DayScheduleSetting(targetQuota: 8, isCuti: false);
  }

  /// PUT /api/v1/schedules/day-settings
  Future<DayScheduleSetting> updateDaySettings({
    required String date,
    int? targetQuota,
    bool? isCuti,
    String? cutiReason,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/day-settings');
    final Map<String, dynamic> body = <String, dynamic>{
      'date': date,
      'targetQuota': ?targetQuota,
      'isCuti': ?isCuti,
      'cutiReason': ?cutiReason,
    };

    final http.Response response = await _put(uri, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return DayScheduleSetting.fromJson(decoded);
      }
      return const DayScheduleSetting(targetQuota: 8, isCuti: false);
    }

    _handleHttpError(response);
    return const DayScheduleSetting(targetQuota: 8, isCuti: false);
  }

  /// POST /api/v1/schedules
  Future<DoctorSchedule> createSchedule({
    required String date,
    required String session,
    required String startTime,
    required String endTime,
    String? roomId,
    String? poliklinikId,
    String? serviceId,
    int? capacity,
    bool? isAvailable,
    String? notes,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules');
    final Map<String, dynamic> body = <String, dynamic>{
      'date': date,
      'specificDate': date,
      'session': session.toUpperCase(),
      'sessionType': session,
      'startTime': startTime,
      'endTime': endTime,
      'roomId': ?roomId,
      'poliklinikId': ?poliklinikId,
      'serviceId': ?serviceId,
      'capacity': ?capacity,
      'isAvailable': ?isAvailable,
      'notes': ?notes,
    };

    final http.Response response = await _post(uri, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return DoctorSchedule.fromJson(decoded);
      }
    }

    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal membuat jadwal praktik');
  }

  /// PATCH /api/v1/schedules/:id
  Future<DoctorSchedule> updateSchedule(
    String scheduleId, {
    String? session,
    String? startTime,
    String? endTime,
    int? capacity,
    String? roomId,
    String? poliklinikId,
    String? serviceId,
    String? status,
    bool? isAvailable,
    String? notes,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId');
    final Map<String, dynamic> body = <String, dynamic>{
      'session': ?session?.toUpperCase(),
      'sessionType': ?session,
      'startTime': ?startTime,
      'endTime': ?endTime,
      'capacity': ?capacity,
      'roomId': ?roomId,
      'poliklinikId': ?poliklinikId,
      'serviceId': ?serviceId,
      'status': ?status,
      'isAvailable': ?isAvailable,
      'notes': ?notes,
    };

    final http.Response response = await _patch(uri, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return DoctorSchedule.fromJson(decoded);
      }
    }

    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal memperbarui jadwal praktik');
  }

  /// PATCH /api/v1/schedules/:id/availability
  Future<DoctorSchedule> toggleAvailability(String scheduleId, bool isAvailable) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId/availability');
    final Map<String, dynamic> body = <String, dynamic>{
      'isAvailable': isAvailable,
    };

    final http.Response response = await _patch(uri, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return DoctorSchedule.fromJson(decoded);
      }
    }

    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal mengubah ketersediaan jadwal');
  }

  /// DELETE /api/v1/schedules/:id
  Future<void> deleteSchedule(String scheduleId) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId');
    final http.Response response = await _delete(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    _handleHttpError(response);
  }

  /// GET /api/v1/schedules/booked-patients OR GET /api/v1/schedules/:id/booked-patients
  Future<List<BookedPatient>> fetchBookedPatients({
    String? date,
    String? scheduleId,
  }) async {
    Uri uri;
    if (scheduleId != null && scheduleId.isNotEmpty) {
      uri = Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId/booked-patients');
    } else {
      final Map<String, String> queryParameters = <String, String>{};
      if (date != null && date.isNotEmpty) queryParameters['date'] = date;
      uri = Uri.parse('$_baseUrl/api/v1/schedules/booked-patients').replace(
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
    }

    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(BookedPatient.fromJson)
            .toList();
      }
      return <BookedPatient>[];
    }

    _handleHttpError(response);
    return <BookedPatient>[];
  }

  /// GET /api/v1/schedules/reference/rooms
  Future<List<ClinicRoomReference>> fetchReferenceRooms({
    String? date,
    String? startTime,
    String? endTime,
  }) async {
    final Map<String, String> queryParameters = <String, String>{};
    if (date != null) queryParameters['date'] = date;
    if (startTime != null) queryParameters['startTime'] = startTime;
    if (endTime != null) queryParameters['endTime'] = endTime;

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/reference/rooms').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ClinicRoomReference.fromJson)
            .toList();
      }
      return <ClinicRoomReference>[];
    }

    _handleHttpError(response);
    return <ClinicRoomReference>[];
  }

  /// GET /api/v1/schedules/reference/polikliniks
  Future<List<ClinicPoliklinikReference>> fetchReferencePolikliniks() async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/reference/polikliniks');
    final http.Response response = await _get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ClinicPoliklinikReference.fromJson)
            .toList();
      }
      return <ClinicPoliklinikReference>[];
    }

    _handleHttpError(response);
    return <ClinicPoliklinikReference>[];
  }

  /// GET /api/v1/schedules/reference/options
  Future<ClinicScheduleOptionsReference> fetchReferenceOptions() async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/reference/options');
    final http.Response response = await _get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return ClinicScheduleOptionsReference.fromJson(decoded);
      }
    }

    _handleHttpError(response);
    return const ClinicScheduleOptionsReference(
      shifts: <ClinicShiftReference>[],
      statuses: <ClinicStatusReference>[],
      timeIntervals: <int>[15, 30, 45, 60],
    );
  }

  /// GET /api/v1/schedules/contexts?date=YYYY-MM-DD
  Future<List<ScheduleContext>> fetchScheduleContexts({
    required String date,
    String? staffId,
  }) async {
    final Map<String, String> queryParameters = <String, String>{'date': date};
    if (staffId != null && staffId.isNotEmpty) {
      queryParameters['staffId'] = staffId;
    }

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/contexts').replace(
      queryParameters: queryParameters,
    );

    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final dynamic list = decoded is Map<String, dynamic> && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ScheduleContext.fromJson)
            .toList();
      }
      return <ScheduleContext>[];
    }

    _handleHttpError(response);
    return <ScheduleContext>[];
  }

  /// GET /api/v1/schedules/projection?date=...&scheduleContextId=...&startTime=...
  Future<ScheduleProjection> fetchProjection({
    required String date,
    required String scheduleContextId,
    required String startTime,
    String? roomId,
    String? serviceId,
    String? staffId,
  }) async {
    final Map<String, String> queryParameters = <String, String>{
      'date': date,
      'scheduleContextId': scheduleContextId,
      'startTime': startTime,
    };
    if (roomId != null && roomId.isNotEmpty) queryParameters['roomId'] = roomId;
    if (serviceId != null && serviceId.isNotEmpty) queryParameters['serviceId'] = serviceId;
    if (staffId != null && staffId.isNotEmpty) queryParameters['staffId'] = staffId;

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/projection').replace(
      queryParameters: queryParameters,
    );

    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = decoded is Map<String, dynamic> && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (data is Map<String, dynamic>) {
        return ScheduleProjection.fromJson(data);
      }
    }

    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal menghitung proyeksi jadwal');
  }

  /// POST /api/v1/schedules/availability
  Future<DoctorSchedule> createAvailability({
    required String date,
    required String scheduleContextId,
    required String startTime,
    String? roomId,
    String? poliklinikId,
    String? serviceId,
    String? notes,
    String? staffId,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/availability');
    final Map<String, dynamic> body = <String, dynamic>{
      'date': date,
      'scheduleContextId': scheduleContextId,
      'startTime': startTime,
      if (roomId != null && roomId.isNotEmpty) 'roomId': roomId,
      if (poliklinikId != null && poliklinikId.isNotEmpty) 'poliklinikId': poliklinikId,
      if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (staffId != null && staffId.isNotEmpty) 'staffId': staffId,
    };

    final http.Response response = await _post(uri, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final dynamic payload = decoded is Map<String, dynamic> && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (payload is Map<String, dynamic>) {
        final dynamic scheduleObj = payload['schedule'] ?? payload;
        if (scheduleObj is Map<String, dynamic>) {
          return DoctorSchedule.fromJson(scheduleObj);
        }
      }
    }

    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal membuat ketersediaan jadwal');
  }
}

