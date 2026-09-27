part of 'amanah_schedule_repository.dart';

extension AmanahScheduleRepositoryDoctor on AmanahScheduleRepository {
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

              if (availState == 'UNSCHEDULED' ||
                  effStatus == 'UNSCHEDULED' ||
                  sessionId == null ||
                  sessionId.isEmpty) {
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
                  isPast: isExpired,
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
}
