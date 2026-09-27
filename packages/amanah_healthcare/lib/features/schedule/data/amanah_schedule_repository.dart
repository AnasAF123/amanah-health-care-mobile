import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/network/client/amanah_http_client.dart';
import 'package:amanah_healthcare/core/network/client/observable_http_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

part 'amanah_schedule_repository_reference.dart';
part 'amanah_schedule_repository_patient.dart';
part 'amanah_schedule_repository_doctor.dart';

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
    final String? custom = _customBaseUrl;
    if (custom != null) return custom;
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  http.Client get _httpClient {
    final http.Client? custom = _customClient;
    if (custom != null) {
      return custom is ObservableHttpClient
          ? custom
          : ObservableHttpClient(innerClient: custom);
    }
    return AmanahHttpClient.instance;
  }

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
            decoded['detail'] as String? ??
            message;
        code = decoded['code'] as String? ??
            decoded['error']?['code'] as String?;
      }
    } catch (_) {}

    if (response.statusCode == 409 || response.statusCode == 422) {
      final String codeStr =
          code ?? (response.statusCode == 409 ? 'CONFLICT' : 'UNPROCESSABLE');
      final String effectiveMsg = (message !=
                  'Terjadi kesalahan sistem (${response.statusCode})' &&
              message.isNotEmpty)
          ? message
          : AmanahScheduleConflictException.userMessageForCode(codeStr);
      throw AmanahScheduleConflictException(
        message: effectiveMsg,
        code: codeStr,
      );
    }

    if (response.statusCode == 401) {
      throw const AmanahScheduleException(
        'Sesi autentikasi telah berakhir. Silakan masuk kembali.',
        code: 'UNAUTHORIZED',
      );
    }

    if (response.statusCode == 403) {
      throw AmanahScheduleException(message, code: code ?? 'FORBIDDEN');
    }

    if (response.statusCode == 404) {
      throw AmanahScheduleException(message, code: code ?? 'NOT_FOUND');
    }

    throw AmanahScheduleException(message, code: code);
  }

  Future<http.Response> _get(Uri uri) async {
    final Map<String, String> headers = await _buildHeaders();
    return _httpClient.get(uri, headers: headers);
  }

  Future<http.Response> _post(Uri uri, {Map<String, dynamic>? body}) async {
    final Map<String, String> headers = await _buildHeaders();
    return _httpClient.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> _put(Uri uri, {Map<String, dynamic>? body}) async {
    final Map<String, String> headers = await _buildHeaders();
    return _httpClient.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> _patch(Uri uri, {Map<String, dynamic>? body}) async {
    final Map<String, String> headers = await _buildHeaders();
    return _httpClient.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> _delete(Uri uri) async {
    final Map<String, String> headers = await _buildHeaders();
    return _httpClient.delete(uri, headers: headers);
  }

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
      if (poliklinikId != null && poliklinikId.isNotEmpty)
        'poliklinikId': poliklinikId,
      if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (staffId != null && staffId.isNotEmpty) 'staffId': staffId,
    };

    final http.Response response = await _post(uri, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final dynamic payload = decoded is Map<String, dynamic> &&
              decoded['data'] != null
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

  static String? _cleanTime(String? t) {
    if (t == null || t.isEmpty || t == 'Pilih Jam' || t == '-') return null;
    final String trimmed = t.replaceAll('WIB', '').trim();
    final RegExp match = RegExp(r'^\d{1,2}:\d{2}');
    final RegExpMatch? m = match.firstMatch(trimmed);
    if (m != null) {
      final List<String> parts = m.group(0)!.split(':');
      final String h = parts[0].padLeft(2, '0');
      final String min = parts[1].padLeft(2, '0');
      return '$h:$min';
    }
    return null;
  }

  static String? _resolveCanonicalShift(String? session) {
    return CanonicalShift.tryResolve(session)?.dtoSession;
  }

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
    final String? validSession = _resolveCanonicalShift(session);

    final bool hasValidRoomId = roomId != null &&
        roomId.isNotEmpty &&
        !roomId.startsWith('Pilih');
    final bool hasValidPoliId = poliklinikId != null &&
        poliklinikId.isNotEmpty &&
        !poliklinikId.startsWith('Pilih');
    final bool hasValidServiceId = serviceId != null &&
        serviceId.isNotEmpty &&
        !serviceId.startsWith('Pilih');

    final Map<String, dynamic> body = <String, dynamic>{
      'date': date,
      'specificDate': date,
      'session': ?validSession,
      'sessionType': session,
      'startTime': _cleanTime(startTime) ?? startTime,
      'endTime': _cleanTime(endTime) ?? endTime,
      if (hasValidRoomId) 'roomId': roomId,
      if (hasValidPoliId) 'poliklinikId': poliklinikId,
      if (hasValidServiceId) 'serviceId': serviceId,
      if (capacity != null && capacity > 0) 'capacity': capacity,
      'isAvailable': ?isAvailable,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
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
    final String? validSession = _resolveCanonicalShift(session);

    String? canonicalStatus;
    if (status != null && status.isNotEmpty) {
      final String upper = status.toUpperCase();
      canonicalStatus = (upper == ScheduleFormConstants.statusBuka.toUpperCase() ||
              upper == ScheduleCanonicalStatus.open)
          ? ScheduleCanonicalStatus.open
          : ScheduleCanonicalStatus.closed;
    }

    final bool hasValidRoomId = roomId != null &&
        roomId.isNotEmpty &&
        !roomId.startsWith('Pilih');
    final bool hasValidPoliId = poliklinikId != null &&
        poliklinikId.isNotEmpty &&
        !poliklinikId.startsWith('Pilih');
    final bool hasValidServiceId = serviceId != null &&
        serviceId.isNotEmpty &&
        !serviceId.startsWith('Pilih');

    final String? cleanStart = _cleanTime(startTime);
    final String? cleanEnd = _cleanTime(endTime);

    final Map<String, dynamic> body = <String, dynamic>{
      'session': ?validSession,
      if (session != null && session.isNotEmpty) 'sessionType': session,
      'startTime': ?cleanStart,
      'endTime': ?cleanEnd,
      if (capacity != null && capacity > 0) 'capacity': capacity,
      if (hasValidRoomId) 'roomId': roomId,
      if (hasValidPoliId) 'poliklinikId': poliklinikId,
      if (hasValidServiceId) 'serviceId': serviceId,
      'status': ?canonicalStatus,
      'isAvailable': ?isAvailable,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
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

  Future<DoctorSchedule> toggleAvailability(
    String scheduleId,
    bool isAvailable,
  ) async {
    final Uri uri =
        Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId/availability');
    final Map<String, dynamic> body = <String, dynamic>{
      'isAvailable': isAvailable
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

  Future<void> deleteSchedule(String scheduleId) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId');
    final http.Response response = await _delete(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    _handleHttpError(response);
  }
}
