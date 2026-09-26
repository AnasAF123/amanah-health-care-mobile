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

/// Single source of truth repository for Schedule management and interactive workflows.
///
/// Implements canonical mobile & admin parity routes per backend specification:
/// - Schedular CRUD & 4-Shift Calendar (`/api/v1/schedules/...`)
/// - Dynamic Slot Math & Anti-Collision Occupancy Grid
/// - Interactive Session Patient Demographics & Actions (`/api/v1/schedules/sessions/:id/patients`, `/api/v1/appointments/...`)
/// - Canonical Reschedule System (`/api/v1/schedules/sessions/:id/reschedule...`)
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

  // ==========================================
  // 3. DOCTOR SCHEDULES & CALENDAR
  // ==========================================

  /// GET /api/v1/schedules/my-schedules
  Future<List<DoctorSchedule>> fetchMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, String> qp = <String, String>{};
    if (date != null && date.isNotEmpty) qp['date'] = date;
    if (startDate != null && startDate.isNotEmpty) qp['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) qp['endDate'] = endDate;

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/my-schedules')
        .replace(queryParameters: qp.isNotEmpty ? qp : null);
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

  /// GET /api/v1/admin/doctor-schedules/:doctorId?month=YYYY-MM&date=YYYY-MM-DD
  Future<List<DoctorSchedule>> fetchDoctorDailySchedules({
    required String doctorId,
    required String date,
    String? month,
  }) async {
    final Map<String, String> qp = <String, String>{
      'date': date,
    };
    final String effectiveMonth =
        month ?? (date.length >= 7 ? date.substring(0, 7) : '');
    if (effectiveMonth.isNotEmpty) {
      qp['month'] = effectiveMonth;
    }

    final Uri uri =
        Uri.parse('$_baseUrl/api/v1/admin/doctor-schedules/$doctorId')
            .replace(queryParameters: qp);
    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final dynamic data = decoded['data'] ?? decoded;
        if (data is Map<String, dynamic>) {
          final dynamic sesiList = data['sesi_harian'] ?? data['sessions'];
          if (sesiList is List) {
            final String? practitionerId =
                data['practitioner_id'] as String? ?? data['id'] as String?;
            final String? doctorName = data['nama_dokter'] as String?;
            final String? spesialisasi = data['spesialisasi'] as String?;
            final String? ruangPraktik = data['ruang_praktik'] as String?;

            return sesiList
                .whereType<Map<String, dynamic>>()
                .map((Map<String, dynamic> item) {
              final Map<String, dynamic> enriched =
                  Map<String, dynamic>.from(item);
              enriched['scheduleDate'] ??= date;
              enriched['date'] ??= date;
              enriched['practitioner_id'] ??= practitionerId;
              enriched['doctor_name'] ??= doctorName;
              enriched['spesialisasi'] ??= spesialisasi;
              enriched['ruang'] ??= ruangPraktik;
              return DoctorSchedule.fromJson(enriched);
            }).toList();
          }
        }
      }
      return <DoctorSchedule>[];
    }
    _handleHttpError(response);
    return <DoctorSchedule>[];
  }

  /// GET /api/v1/admin/doctor-schedules/:doctorId?month=YYYY-MM&date=YYYY-MM-DD
  ///
  /// Fetches 30-minute interval slots from `timeline_intervals`.
  /// Scheduled slots (AVAILABLE, CLOSED, OCCUPIED) are parsed into [DoctorSchedule].
  /// Unscheduled slots (UNSCHEDULED, sessionId == null) are strictly excluded.
  Future<List<DoctorSchedule>> fetchDoctorDailyIntervalSlots({
    required String doctorId,
    required String date,
    String? month,
  }) async {
    final Map<String, String> qp = <String, String>{
      'date': date,
    };
    final String effectiveMonth =
        month ?? (date.length >= 7 ? date.substring(0, 7) : '');
    if (effectiveMonth.isNotEmpty) {
      qp['month'] = effectiveMonth;
    }

    final Uri uri =
        Uri.parse('$_baseUrl/api/v1/admin/doctor-schedules/$doctorId')
            .replace(queryParameters: qp);
    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final dynamic data = decoded['data'] ?? decoded;
        if (data is Map<String, dynamic>) {
          final dynamic intervalsList =
              data['timeline_intervals'] ?? data['intervals'];
          final String? practitionerId =
              data['practitioner_id'] as String? ?? data['id'] as String?;
          final String? doctorName = data['nama_dokter'] as String?;
          final String? spesialisasi = data['spesialisasi'] as String?;
          final String? ruangPraktik = data['ruang_praktik'] as String?;

          if (intervalsList is List) {
            final List<DoctorSchedule> result = <DoctorSchedule>[];
            for (final dynamic item in intervalsList) {
              if (item is! Map<String, dynamic>) continue;

              final String availState =
                  (item['availabilityState'] as String? ?? '').toUpperCase();
              final String effStatus =
                  (item['effectiveStatus'] as String? ?? '').toUpperCase();
              final String tempState =
                  (item['temporalState'] as String? ?? '').toUpperCase();
              final String? sessionId = item['sessionId'] as String?;

              // Exclude unscheduled slots
              if (availState == 'UNSCHEDULED' ||
                  effStatus == 'UNSCHEDULED' ||
                  sessionId == null ||
                  sessionId.isEmpty) {
                continue;
              }

              // On today or future dates, exclude past expired slots so mobile renders
              // only active/upcoming scheduled sessions (Tersedia and Ditutup).
              final DateTime? slotDate = DateTime.tryParse(date);
              final DateTime now = DateTime.now();
              final DateTime todayMidnight =
                  DateTime(now.year, now.month, now.day);
              final bool isBeforeToday = slotDate != null &&
                  DateTime(slotDate.year, slotDate.month, slotDate.day)
                      .isBefore(todayMidnight);

              if (!isBeforeToday &&
                  (tempState == 'PAST' || effStatus == 'EXPIRED')) {
                continue;
              }

              final String intervalId =
                  item['intervalId'] as String? ?? item['slotId'] as String? ?? '';
              final String startTime =
                  item['startTime'] as String? ?? item['timeStart'] as String? ?? '';
              final String endTime =
                  item['endTime'] as String? ?? item['timeEnd'] as String? ?? '';
              final String timeStr = item['timeRange'] as String? ??
                  (startTime.isNotEmpty && endTime.isNotEmpty
                      ? '$startTime - $endTime WIB'
                      : '');

              // Resolve shift code and session label
              final String shiftCode;
              final String sessionLabel;
              if (intervalId.contains('early_morning')) {
                shiftCode = 'early_morning';
                sessionLabel = 'Dini Hari';
              } else if (intervalId.contains('morning')) {
                shiftCode = 'morning';
                sessionLabel = 'Pagi';
              } else if (intervalId.contains('afternoon')) {
                shiftCode = 'afternoon';
                sessionLabel = 'Siang';
              } else if (intervalId.contains('night')) {
                shiftCode = 'night';
                sessionLabel = 'Malam';
              } else {
                shiftCode = 'morning';
                sessionLabel = 'Pagi';
              }

              final String uiStatus =
                  (item['uiStatus'] as String? ?? '').toUpperCase();
              final String? uiLabel = item['uiLabel'] as String?;
              final dynamic closureInfo =
                  item['closureInfo'] ?? item['closure'];
              final String? closureReason = closureInfo is Map<String, dynamic>
                  ? closureInfo['reasonText'] as String?
                  : null;

              final bool isExpired =
                  tempState == 'PAST' || effStatus == 'EXPIRED';
              final bool isClosed = availState == 'CLOSED' ||
                  effStatus == 'CLOSED' ||
                  uiStatus.startsWith('CLOSED');
              final dynamic patientInfo = item['patientInfo'];
              final bool hasPatient =
                  item['isOccupied'] == true || patientInfo != null;

              final String badge;
              final AmanahBadgeVariant badgeVariant;
              if (isExpired) {
                badge = ScheduleFormConstants.badgeSelesai;
                badgeVariant = AmanahBadgeVariant.warning;
              } else if (isClosed) {
                badge = ScheduleFormConstants.statusTutup;
                badgeVariant = AmanahBadgeVariant.warning;
              } else if (hasPatient) {
                badge = ScheduleFormConstants.badgeTerisi;
                badgeVariant = AmanahBadgeVariant.primary;
              } else {
                badge = ScheduleFormConstants.statusBuka;
                badgeVariant = AmanahBadgeVariant.success;
              }

              final String notes =
                  closureReason ?? (isClosed ? (uiLabel ?? '') : '');
              final String slotText = notes.isNotEmpty
                  ? notes
                  : (uiLabel != null && uiLabel.isNotEmpty
                      ? uiLabel
                      : (hasPatient ? '1 Pasien Booking' : 'Tersedia'));

              result.add(
                DoctorSchedule(
                  id: intervalId.isNotEmpty
                      ? intervalId
                      : '${sessionId}_$startTime',
                  title: 'Sesi $sessionLabel',
                  date: date,
                  time: timeStr,
                  poli: spesialisasi ?? '',
                  room: ruangPraktik ?? '',
                  slotCount: hasPatient ? '1' : '0',
                  slotText: slotText,
                  badge: badge,
                  badgeVariant: badgeVariant,
                  startTime: startTime,
                  endTime: endTime,
                  sessionType: sessionLabel,
                  sessionShift: shiftCode,
                  scheduleDate: date,
                  practitionerId: practitionerId,
                  doctorName: doctorName,
                  isAvailable: !isClosed && !isExpired,
                  capacity: 1,
                  availableSlots: (!isClosed && !isExpired && !hasPatient) ? 1 : 0,
                  bookedPatientCount: hasPatient ? 1 : 0,
                  notes: notes.isNotEmpty ? notes : null,
                ),
              );
            }
            if (result.isNotEmpty) {
              return result;
            }
          }
        }
      }
      return <DoctorSchedule>[];
    }
    _handleHttpError(response);
    return <DoctorSchedule>[];
  }

  /// GET /api/v1/schedules/calendar-summary?month=YYYY-MM
  Future<CalendarSummaryResponse> fetchCalendarSummary(String month) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/calendar-summary')
        .replace(queryParameters: <String, String>{'month': month});
    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return CalendarSummaryResponse.fromJson(decoded);
      }
      return CalendarSummaryResponse(
        month: month,
        days: const <CalendarDaySummary>[],
      );
    }
    _handleHttpError(response);
    return CalendarSummaryResponse(
      month: month,
      days: const <CalendarDaySummary>[],
    );
  }

  /// GET /api/v1/schedules/day-settings?date=YYYY-MM-DD
  Future<DayScheduleSetting> fetchDaySettings(String date) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/day-settings')
        .replace(queryParameters: <String, String>{'date': date});
    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return DayScheduleSetting.fromJson(decoded);
      }
      return const DayScheduleSetting(targetQuota: 0, isCuti: false);
    }
    _handleHttpError(response);
    return const DayScheduleSetting(targetQuota: 0, isCuti: false);
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
      return const DayScheduleSetting(targetQuota: 0, isCuti: false);
    }
    _handleHttpError(response);
    return const DayScheduleSetting(targetQuota: 0, isCuti: false);
  }

  /// PATCH /api/v1/schedules/days/:date (Canonical Mobile Cascading Day Status)
  Future<Map<String, dynamic>> updateDayStatus({
    required String date,
    required String status,
    String? notes,
    String? doctorId,
  }) async {
    final String canonical =
        (status.toUpperCase() == ScheduleFormConstants.statusBuka.toUpperCase() ||
                status.toUpperCase() == ScheduleCanonicalStatus.open)
            ? ScheduleCanonicalStatus.open
            : ScheduleCanonicalStatus.closed;
    final String path = (doctorId != null && doctorId.isNotEmpty)
        ? '$_baseUrl/api/v1/admin/doctor-schedules/$doctorId/days/$date'
        : '$_baseUrl/api/v1/schedules/days/$date';
    final Uri uri = Uri.parse(path);
    final Map<String, dynamic> body = <String, dynamic>{
      'status': canonical,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final http.Response response = await _patch(uri, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) return decoded;
        } catch (_) {}
      }
      return <String, dynamic>{'success': true};
    }
    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal memperbarui status hari');
  }

  /// POST /api/v1/schedules/availability (Auto calculate end time)
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

  /// POST /api/v1/schedules (Standard Create)
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

  /// PATCH /api/v1/schedules/:id/availability
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

  /// DELETE /api/v1/schedules/:id
  Future<void> deleteSchedule(String scheduleId) async {
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId');
    final http.Response response = await _delete(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    _handleHttpError(response);
  }
}
