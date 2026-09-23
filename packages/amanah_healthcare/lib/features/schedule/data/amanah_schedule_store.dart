import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class AmanahScheduleStore extends ChangeNotifier {
  AmanahScheduleStore._({AmanahScheduleRepository? repository})
      : _repository = repository ?? const AmanahScheduleRepository() {
    _schedulesMap = <String, List<DoctorSchedule>>{};
    _daySettingsMap = <String, DayScheduleSetting>{};
  }

  static final AmanahScheduleStore instance = AmanahScheduleStore._();

  static DateTime? _customBaseToday;
  static DateTime get baseToday {
    if (_customBaseToday != null) {
      return _customBaseToday!;
    }
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @visibleForTesting
  static void setCustomBaseToday(DateTime? date) {
    _customBaseToday = date;
  }

  AmanahScheduleRepository _repository;
  void setRepository(AmanahScheduleRepository repository) {
    _repository = repository;
  }

  late Map<String, List<DoctorSchedule>> _schedulesMap;
  late Map<String, DayScheduleSetting> _daySettingsMap;
  final Map<String, CalendarDaySummary> _calendarSummariesMap = <String, CalendarDaySummary>{};
  List<ScheduleContext> _scheduleContexts = const <ScheduleContext>[];
  ScheduleProjection? _currentProjection;

  bool _isLoading = false;
  String? _errorMessage;
  AmanahScheduleConflictException? _lastConflict;

  Map<String, List<DoctorSchedule>> get schedulesMap => _schedulesMap;
  Map<String, DayScheduleSetting> get daySettingsMap => _daySettingsMap;
  Map<String, CalendarDaySummary> get calendarSummariesMap => _calendarSummariesMap;
  List<ScheduleContext> get scheduleContexts => _scheduleContexts;
  ScheduleProjection? get currentProjection => _currentProjection;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AmanahScheduleConflictException? get lastConflict => _lastConflict;

  static String formatDateKey(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<DoctorSchedule> getSchedulesForDate(DateTime date) {
    final String key = formatDateKey(date);
    return _schedulesMap[key] ?? const <DoctorSchedule>[];
  }

  DayScheduleSetting getDaySettingForDate(DateTime date) {
    final String key = formatDateKey(date);
    return _daySettingsMap[key] ??
        DayScheduleSetting(
          targetQuota: 8,
          isCuti: date.weekday == DateTime.sunday,
          scheduleDate: key,
        );
  }

  List<({BookedPatient patient, DoctorSchedule schedule})>
      getAllBookedPatientsForDate(DateTime date) {
    final List<DoctorSchedule> schedules = getSchedulesForDate(date);
    final List<({BookedPatient patient, DoctorSchedule schedule})> list =
        <({BookedPatient patient, DoctorSchedule schedule})>[];
    for (final DoctorSchedule sch in schedules) {
      for (final BookedPatient p in sch.bookedPatients) {
        list.add((patient: p, schedule: sch));
      }
    }
    return list;
  }

  int getCapacityPercentage(DateTime date) {
    final String key = formatDateKey(date);
    final CalendarDaySummary? summary = _calendarSummariesMap[key];
    if (summary != null) {
      return summary.capacityPercentage;
    }

    final DayScheduleSetting setting = getDaySettingForDate(date);
    if (setting.isCuti || setting.targetQuota <= 0) {
      return 0;
    }
    final int bookedCount = getAllBookedPatientsForDate(date).length;
    return ((bookedCount / setting.targetQuota) * 100).round().clamp(0, 100);
  }

  // --- Synchronous methods for UI instant updates and backwards compatibility ---

  void addSchedule(DateTime date, DoctorSchedule schedule) {
    final String key = formatDateKey(date);
    final List<DoctorSchedule> current =
        List<DoctorSchedule>.from(_schedulesMap[key] ?? <DoctorSchedule>[]);
    current.add(schedule);
    _schedulesMap[key] = current;
    notifyListeners();
  }

  void updateSchedule(DateTime date, DoctorSchedule schedule) {
    final String key = formatDateKey(date);
    final List<DoctorSchedule> current =
        List<DoctorSchedule>.from(_schedulesMap[key] ?? <DoctorSchedule>[]);
    final int index = current.indexWhere((DoctorSchedule s) => s.id == schedule.id);
    if (index >= 0) {
      current[index] = schedule;
      _schedulesMap[key] = current;
      notifyListeners();
    }
  }

  void deleteSchedule(DateTime date, String scheduleId) {
    final String key = formatDateKey(date);
    final List<DoctorSchedule> current =
        List<DoctorSchedule>.from(_schedulesMap[key] ?? <DoctorSchedule>[]);
    current.removeWhere((DoctorSchedule s) => s.id == scheduleId);
    _schedulesMap[key] = current;
    notifyListeners();
  }

  void setDayCuti(DateTime date, bool isCuti, {String? cutiReason}) {
    final String key = formatDateKey(date);
    final DayScheduleSetting current = getDaySettingForDate(date);
    _daySettingsMap[key] = current.copyWith(
      isCuti: isCuti,
      cutiReason: cutiReason ?? (isCuti ? 'Dokter Cuti Praktik' : null),
    );
    notifyListeners();
  }

  // --- Asynchronous backend-connected methods ---

  Future<List<DoctorSchedule>> loadSchedulesForDate(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final String dateStr = formatDateKey(date);
    _isLoading = true;
    _errorMessage = null;
    await Future<void>.value();
    notifyListeners();

    try {
      final List<DoctorSchedule> backendSchedules =
          await _repository.fetchMySchedules(date: dateStr);

      // Also enrich with booked patients for that date
      final List<BookedPatient> allPatients =
          await _repository.fetchBookedPatients(date: dateStr);

      final List<DoctorSchedule> enriched = backendSchedules.map((DoctorSchedule s) {
        final List<BookedPatient> sessionPatients = allPatients.where((BookedPatient p) {
          if (p.appointmentId != null && s.bookedPatients.any((BookedPatient bp) => bp.id == p.id)) {
            return true;
          }
          if (p.sessionTitle != null && p.sessionTitle!.toLowerCase().contains(s.sessionType.toLowerCase())) {
            return true;
          }
          return false;
        }).toList();

        final List<BookedPatient> finalPatients =
            sessionPatients.isNotEmpty ? sessionPatients : s.bookedPatients;

        return s.copyWith(
          bookedPatients: finalPatients,
          slotCount: finalPatients.length.toString(),
          slotText: '${finalPatients.length} Pasien Booking',
        );
      }).toList();

      _schedulesMap[dateStr] = enriched;
      _isLoading = false;
      notifyListeners();
      return _schedulesMap[dateStr] ?? const <DoctorSchedule>[];
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return getSchedulesForDate(date);
    }
  }

  Future<CalendarSummaryResponse?> loadCalendarSummary(String month) async {
    try {
      final CalendarSummaryResponse res = await _repository.fetchCalendarSummary(month);
      for (final CalendarDaySummary day in res.days) {
        _calendarSummariesMap[day.date] = day;
        final DayScheduleSetting existing = _daySettingsMap[day.date] ??
            DayScheduleSetting(
              targetQuota: day.targetQuota,
              isCuti: day.isCuti,
              cutiReason: day.cutiReason,
              scheduleDate: day.date,
              totalBookedPatients: day.bookedPatientCount,
              capacityPercentage: day.capacityPercentage,
            );
        _daySettingsMap[day.date] = existing.copyWith(
          targetQuota: day.targetQuota,
          isCuti: day.isCuti,
          cutiReason: day.cutiReason,
          totalBookedPatients: day.bookedPatientCount,
          capacityPercentage: day.capacityPercentage,
        );
      }
      notifyListeners();
      return res;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<DayScheduleSetting> loadDaySettings(DateTime date) async {
    final String dateStr = formatDateKey(date);
    try {
      final DayScheduleSetting setting = await _repository.fetchDaySettings(dateStr);
      _daySettingsMap[dateStr] = setting;
      notifyListeners();
      return setting;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return getDaySettingForDate(date);
    }
  }

  Future<DoctorSchedule> saveSchedule(
    DateTime date,
    DoctorSchedule schedule, {
    String? roomId,
    String? poliklinikId,
    String? serviceId,
    int? capacity,
    String? notes,
  }) async {
    final String dateStr = formatDateKey(date);
    _isLoading = true;
    _errorMessage = null;
    _lastConflict = null;
    await Future<void>.value();
    notifyListeners();

    try {
      DoctorSchedule result;
      // If schedule ID starts with 'ses-' and is not a uuid, it's either an initial local ID or newly created.
      final bool isExistingPersisted = schedule.id.isNotEmpty &&
          !schedule.id.startsWith('ses-');

      if (isExistingPersisted) {
        result = await _repository.updateSchedule(
          schedule.id,
          session: schedule.sessionType,
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          capacity: capacity ?? schedule.capacity,
          roomId: roomId ?? schedule.roomId,
          poliklinikId: poliklinikId ?? schedule.poliklinikId,
          serviceId: serviceId ?? schedule.serviceId,
          status: schedule.badge,
          isAvailable: schedule.isAvailable,
          notes: notes ?? schedule.notes,
        );
        updateSchedule(date, result);
      } else {
        result = await _repository.createSchedule(
          date: dateStr,
          session: schedule.sessionType,
          startTime: schedule.startTime ?? '08:00',
          endTime: schedule.endTime ?? '12:00',
          roomId: roomId ?? schedule.roomId,
          poliklinikId: poliklinikId ?? schedule.poliklinikId,
          serviceId: serviceId ?? schedule.serviceId,
          capacity: capacity ?? schedule.capacity,
          isAvailable: schedule.isAvailable,
          notes: notes ?? schedule.notes,
        );
        addSchedule(date, result);
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } on AmanahScheduleConflictException catch (e) {
      _isLoading = false;
      _lastConflict = e;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      // Keep optimistic local update
      if (schedule.id.isNotEmpty) {
        updateSchedule(date, schedule);
      } else {
        addSchedule(date, schedule);
      }
      return schedule;
    }
  }

  Future<void> removeSchedule(DateTime date, String scheduleId) async {
    _isLoading = true;
    _errorMessage = null;
    _lastConflict = null;
    await Future<void>.value();
    notifyListeners();

    try {
      if (!scheduleId.startsWith('ses-')) {
        await _repository.deleteSchedule(scheduleId);
      }
      deleteSchedule(date, scheduleId);
      _isLoading = false;
      notifyListeners();
    } on AmanahScheduleConflictException catch (e) {
      _isLoading = false;
      _lastConflict = e;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      deleteSchedule(date, scheduleId);
      notifyListeners();
    }
  }

  Future<void> updateDayCuti(
    DateTime date,
    bool isCuti, {
    String? cutiReason,
    int? targetQuota,
  }) async {
    final String dateStr = formatDateKey(date);
    setDayCuti(date, isCuti, cutiReason: cutiReason);

    try {
      await _repository.updateDaySettings(
        date: dateStr,
        isCuti: isCuti,
        cutiReason: cutiReason,
        targetQuota: targetQuota,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> toggleScheduleAvailability(
    DateTime date,
    String scheduleId,
    bool isAvailable,
  ) async {
    final String key = formatDateKey(date);
    final List<DoctorSchedule> current =
        List<DoctorSchedule>.from(_schedulesMap[key] ?? <DoctorSchedule>[]);
    final int index = current.indexWhere((DoctorSchedule s) => s.id == scheduleId);
    if (index >= 0) {
      current[index] = current[index].copyWith(
        isAvailable: isAvailable,
        badge: isAvailable ? 'Buka' : 'Tutup',
        badgeVariant: isAvailable ? AmanahBadgeVariant.success : AmanahBadgeVariant.warning,
      );
      _schedulesMap[key] = current;
      notifyListeners();
    }

    try {
      if (!scheduleId.startsWith('ses-')) {
        await _repository.toggleAvailability(scheduleId, isAvailable);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<List<ClinicRoomReference>> loadRooms({
    DateTime? date,
    String? startTime,
    String? endTime,
  }) async {
    try {
      return await _repository.fetchReferenceRooms(
        date: date != null ? formatDateKey(date) : null,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (_) {
      return const <ClinicRoomReference>[];
    }
  }

  Future<List<ClinicPoliklinikReference>> loadPolikliniks() async {
    try {
      return await _repository.fetchReferencePolikliniks();
    } catch (_) {
      return const <ClinicPoliklinikReference>[];
    }
  }

  Future<ClinicScheduleOptionsReference?> loadScheduleOptions() async {
    try {
      return await _repository.fetchReferenceOptions();
    } catch (_) {
      return null;
    }
  }

  Future<List<ScheduleContext>> loadScheduleContexts(DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    await Future<void>.value();
    notifyListeners();

    try {
      final List<ScheduleContext> contexts =
          await _repository.fetchScheduleContexts(date: formatDateKey(date));
      _scheduleContexts = contexts;
      _isLoading = false;
      notifyListeners();
      return contexts;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return _scheduleContexts;
    }
  }

  void clearProjection() {
    _currentProjection = null;
    notifyListeners();
  }

  Future<ScheduleProjection?> loadProjection({
    required DateTime date,
    required String scheduleContextId,
    required String startTime,
    String? roomId,
    String? serviceId,
  }) async {
    try {
      final ScheduleProjection projection = await _repository.fetchProjection(
        date: formatDateKey(date),
        scheduleContextId: scheduleContextId,
        startTime: startTime,
        roomId: roomId,
        serviceId: serviceId,
      );
      _currentProjection = projection;
      notifyListeners();
      return projection;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<DoctorSchedule> createAvailability({
    required DateTime date,
    required String scheduleContextId,
    required String startTime,
    String? roomId,
    String? poliklinikId,
    String? serviceId,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _lastConflict = null;
    await Future<void>.value();
    notifyListeners();

    try {
      final DoctorSchedule schedule = await _repository.createAvailability(
        date: formatDateKey(date),
        scheduleContextId: scheduleContextId,
        startTime: startTime,
        roomId: roomId,
        poliklinikId: poliklinikId,
        serviceId: serviceId,
        notes: notes,
      );

      await loadSchedulesForDate(date, forceRefresh: true);
      _isLoading = false;
      notifyListeners();
      return schedule;
    } on AmanahScheduleConflictException catch (e) {
      _isLoading = false;
      _lastConflict = e;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void reset() {
    _schedulesMap = <String, List<DoctorSchedule>>{};
    _daySettingsMap = <String, DayScheduleSetting>{};
    _calendarSummariesMap.clear();
    _scheduleContexts = const <ScheduleContext>[];
    _currentProjection = null;
    _customBaseToday = null;
    _isLoading = false;
    _errorMessage = null;
    _lastConflict = null;
    notifyListeners();
  }
}
