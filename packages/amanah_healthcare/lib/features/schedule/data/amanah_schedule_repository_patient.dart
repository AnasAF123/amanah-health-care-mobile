part of 'amanah_schedule_repository.dart';

extension AmanahScheduleRepositoryPatient on AmanahScheduleRepository {
  // ==========================================
  // 4. INTERACTIVE PATIENT FLOW & ACTIONS
  // ==========================================

  /// GET /api/v1/schedules/sessions/:sessionId/patients (Canonical Session Patient List)
  Future<SessionPatientsData> fetchSessionPatients(String sessionId) async {
    final Uri uri =
        Uri.parse('$_baseUrl/api/v1/schedules/sessions/$sessionId/patients');
    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = decoded is Map<String, dynamic> && decoded['data'] != null
          ? decoded['data']
          : decoded;
      if (data is Map<String, dynamic>) {
        return SessionPatientsData.fromJson(data);
      }
    }
    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal memuat daftar pasien sesi');
  }

  /// Legacy alias: GET /api/v1/schedules/booked-patients
  Future<List<BookedPatient>> fetchBookedPatients({
    String? date,
    String? scheduleId,
  }) async {
    if (scheduleId != null && scheduleId.isNotEmpty) {
      try {
        final SessionPatientsData data = await fetchSessionPatients(scheduleId);
        return data.patients;
      } catch (_) {}
    }
    final Uri uri = Uri.parse('$_baseUrl/api/v1/schedules/booked-patients')
        .replace(
      queryParameters:
          date != null && date.isNotEmpty ? <String, String>{'date': date} : null,
    );
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

  /// PATCH /api/v1/appointments/:appointmentId/call (Aksi 1: Panggil Pasien)
  Future<Map<String, dynamic>> callPatient(String appointmentId) async {
    final Uri uri =
        Uri.parse('$_baseUrl/api/v1/appointments/$appointmentId/call');
    final http.Response response = await _patch(uri);
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
    throw const AmanahScheduleException('Gagal memanggil pasien');
  }

  /// PATCH /api/v1/appointments/:appointmentId/complete (Aksi 2: Selesaikan Pemeriksaan)
  Future<Map<String, dynamic>> completeConsultation(String appointmentId) async {
    final Uri uri =
        Uri.parse('$_baseUrl/api/v1/appointments/$appointmentId/complete');
    final http.Response response = await _patch(uri);
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
    throw const AmanahScheduleException('Gagal menyelesaikan pemeriksaan');
  }

  /// PATCH /api/v1/appointments/:appointmentId/cancel (Aksi 3: Batalkan Janji Temu)
  Future<Map<String, dynamic>> cancelAppointment(
    String appointmentId, {
    required String reason,
  }) async {
    final Uri uri =
        Uri.parse('$_baseUrl/api/v1/appointments/$appointmentId/cancel');
    final Map<String, dynamic> body = <String, dynamic>{'reason': reason};
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
    throw const AmanahScheduleException('Gagal membatalkan janji temu pasien');
  }

  // ==========================================
  // 5. CANONICAL RESCHEDULE SYSTEM
  // ==========================================

  /// GET /api/v1/schedules/sessions/:sessionId/reschedule-eligibility
  Future<RescheduleEligibilityData> checkRescheduleEligibility({
    required String sessionId,
    String? targetDate,
    String? targetStartTime,
    String? targetEndTime,
    String? targetRoomId,
    String? doctorId,
  }) async {
    final Map<String, String> qp = <String, String>{};
    if (targetDate != null && targetDate.isNotEmpty) {
      qp['targetDate'] = targetDate;
    }
    if (targetStartTime != null && targetStartTime.isNotEmpty) {
      qp['targetStartTime'] = targetStartTime;
    }
    if (targetEndTime != null && targetEndTime.isNotEmpty) {
      qp['targetEndTime'] = targetEndTime;
    }
    if (targetRoomId != null && targetRoomId.isNotEmpty) {
      qp['targetRoomId'] = targetRoomId;
    }

    final String path = (doctorId != null && doctorId.isNotEmpty)
        ? '$_baseUrl/api/v1/admin/doctor-schedules/$doctorId/sessions/$sessionId/reschedule-eligibility'
        : '$_baseUrl/api/v1/schedules/sessions/$sessionId/reschedule-eligibility';
    final Uri uri = Uri.parse(path).replace(queryParameters: qp.isNotEmpty ? qp : null);

    final http.Response response = await _get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return RescheduleEligibilityData.fromJson(decoded);
      }
    }
    _handleHttpError(response);
    throw const AmanahScheduleException('Gagal memeriksa kelayakan reschedule');
  }

  /// POST /api/v1/schedules/sessions/:sessionId/reschedule
  Future<Map<String, dynamic>> rescheduleSession({
    required String sessionId,
    required String targetDate,
    required String targetStartTime,
    String? targetEndTime,
    String? targetRoomId,
    String? targetScheduleContextId,
    String? notes,
    String? reason,
    bool rescheduleActiveAppointments = true,
    String? doctorId,
  }) async {
    final String path = (doctorId != null && doctorId.isNotEmpty)
        ? '$_baseUrl/api/v1/admin/doctor-schedules/$doctorId/sessions/$sessionId/reschedule'
        : '$_baseUrl/api/v1/schedules/sessions/$sessionId/reschedule';
    final Uri uri = Uri.parse(path);
    final Map<String, dynamic> body = <String, dynamic>{
      'targetDate': targetDate,
      'targetStartTime': targetStartTime,
      if (targetEndTime != null && targetEndTime.isNotEmpty)
        'targetEndTime': targetEndTime,
      if (targetRoomId != null && targetRoomId.isNotEmpty)
        'targetRoomId': targetRoomId,
      if (targetScheduleContextId != null && targetScheduleContextId.isNotEmpty)
        'targetScheduleContextId': targetScheduleContextId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
      'rescheduleActiveAppointments': rescheduleActiveAppointments,
    };

    final http.Response response = await _post(uri, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{'success': true};
    }
    _handleHttpError(response);
    throw const AmanahScheduleException(
        'Gagal melakukan reschedule sesi praktik');
  }
}
