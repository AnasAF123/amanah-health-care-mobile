part of 'amanah_schedule_repository.dart';

extension AmanahScheduleRepositoryReference on AmanahScheduleRepository {
  // ==========================================
  // 1. MASTER OPTIONS & REFERENCES
  // ==========================================

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
      timeIntervals: <int>[30],
    );
  }

  /// GET /api/v1/schedules/reference/rooms
  Future<List<ClinicRoomReference>> fetchReferenceRooms({
    String? date,
    String? startTime,
    String? endTime,
  }) async {
    final Map<String, String> qp = <String, String>{};
    if (date != null) qp['date'] = date;
    if (startTime != null) qp['startTime'] = startTime;
    if (endTime != null) qp['endTime'] = endTime;

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/reference/rooms')
        .replace(queryParameters: qp.isNotEmpty ? qp : null);
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
    final Uri uri =
        Uri.parse('$_baseUrl/api/v1/schedules/reference/polikliniks');
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

  // ==========================================
  // 2. CONTEXT & DYNAMIC PROJECTION
  // ==========================================

  /// GET /api/v1/schedules/contexts?date=YYYY-MM-DD
  Future<List<ScheduleContext>> fetchScheduleContexts({
    required String date,
    String? staffId,
  }) async {
    final Map<String, String> qp = <String, String>{'date': date};
    if (staffId != null && staffId.isNotEmpty) qp['staffId'] = staffId;

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/contexts')
        .replace(queryParameters: qp);
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

  /// GET /api/v1/schedules/projection
  Future<ScheduleProjection> fetchProjection({
    required String date,
    required String scheduleContextId,
    required String startTime,
    String? roomId,
    String? serviceId,
    String? staffId,
  }) async {
    final Map<String, String> qp = <String, String>{
      'date': date,
      'scheduleContextId': scheduleContextId,
      'startTime': startTime,
    };
    if (roomId != null && roomId.isNotEmpty) qp['roomId'] = roomId;
    if (serviceId != null && serviceId.isNotEmpty) qp['serviceId'] = serviceId;
    if (staffId != null && staffId.isNotEmpty) qp['staffId'] = staffId;

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/projection')
        .replace(queryParameters: qp);
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

  /// GET /api/v1/schedules/occupancy-overview?date=YYYY-MM-DD
  Future<ScheduleOccupancyOverviewData> fetchOccupancyOverview({
    required String date,
    String? roomId,
  }) async {
    final Map<String, String> qp = <String, String>{'date': date};
    if (roomId != null && roomId.isNotEmpty) qp['roomId'] = roomId;

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/occupancy-overview')
        .replace(queryParameters: qp);
    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = decoded is Map<String, dynamic> && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (data is Map<String, dynamic>) {
        return ScheduleOccupancyOverviewData.fromJson(data);
      }
    }
    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal mengambil data occupancy jadwal');
  }

  // ==========================================
  // 3. ZERO-CLIENT-CALCULATION & DELEGATION
  // ==========================================

  /// GET /api/v1/schedules/form-bootstrap?date=YYYY-MM-DD[&scheduleId=UUID]
  Future<ScheduleFormBootstrapData> fetchFormBootstrap({
    required String date,
    String? scheduleId,
  }) async {
    final Map<String, String> qp = <String, String>{'date': date};
    if (scheduleId != null && scheduleId.isNotEmpty) {
      qp['scheduleId'] = scheduleId;
    }

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/form-bootstrap')
        .replace(queryParameters: qp);
    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = decoded is Map<String, dynamic> && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (data is Map<String, dynamic>) {
        return ScheduleFormBootstrapData.fromJson(data);
      }
    }
    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal memuat form bootstrap jadwal');
  }

  /// GET /api/v1/schedules/slot-availability?date=YYYY-MM-DD&shift=...&roomId=UUID[&scheduleId=UUID]
  Future<ScheduleSlotAvailabilityData> fetchSlotAvailability({
    required String date,
    required String shift,
    required String roomId,
    String? scheduleId,
  }) async {
    final Map<String, String> qp = <String, String>{
      'date': date,
      'shift': shift,
      'roomId': roomId,
    };
    if (scheduleId != null && scheduleId.isNotEmpty) {
      qp['scheduleId'] = scheduleId;
    }

    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/slot-availability')
        .replace(queryParameters: qp);
    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = decoded is Map<String, dynamic> && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (data is Map<String, dynamic>) {
        return ScheduleSlotAvailabilityData.fromJson(data);
      }
    }
    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal memuat ketersediaan slot jadwal');
  }
}
