import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

mixin ScheduleStoreDayMixin on ChangeNotifier {
  AmanahScheduleRepository get repository;
  void setLoading(bool loading);
  void setErrorMessage(String? error);
  Map<String, List<DoctorSchedule>> get schedulesMap;
  Future<List<DoctorSchedule>> loadSchedulesForDate(
    DateTime date, {
    String? doctorId,
    bool forceRefresh = false,
  });
  List<({BookedPatient patient, DoctorSchedule schedule})>
      getAllBookedPatientsForDate(DateTime date);

  String _formatDateKey(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  final Map<String, DayScheduleSetting> _daySettingsMap =
      <String, DayScheduleSetting>{};
  final Map<String, CalendarDaySummary> _calendarSummariesMap =
      <String, CalendarDaySummary>{};

  Map<String, DayScheduleSetting> get daySettingsMap => _daySettingsMap;
  Map<String, CalendarDaySummary> get calendarSummariesMap =>
      _calendarSummariesMap;

  void resetDayState() {
    _daySettingsMap.clear();
    _calendarSummariesMap.clear();
  }

  DayScheduleSetting getDaySettingForDate(DateTime date) {
    final String key = _formatDateKey(date);
    final CalendarDaySummary? summary = _calendarSummariesMap[key];
    final DayScheduleSetting? existing = _daySettingsMap[key];

    final List<DoctorSchedule>? daySchedules = schedulesMap[key];
    final bool allSchedulesClosed = daySchedules != null &&
        daySchedules.isNotEmpty &&
        daySchedules.every((DoctorSchedule s) =>
            !s.isAvailable ||
            s.badge == ScheduleFormConstants.statusTutup ||
            s.badge == ScheduleFormConstants.statusCuti);

    final bool isClosed = (existing?.isClosed ?? false) ||
        (summary?.isClosed ?? false) ||
        allSchedulesClosed ||
        (date.weekday == DateTime.sunday);

    final String status = isClosed
        ? ScheduleCanonicalStatus.closed
        : (existing?.status ?? summary?.status ?? ScheduleCanonicalStatus.open);

    if (existing != null) {
      final bool effectiveClosed = existing.isClosed ||
          (summary?.isClosed ?? false) ||
          allSchedulesClosed;
      return existing.copyWith(
        isClosed: effectiveClosed,
        status: effectiveClosed ? ScheduleCanonicalStatus.closed : existing.status,
      );
    }

    return DayScheduleSetting(
      targetQuota: summary?.targetQuota ?? 0,
      isCuti: summary?.isCuti ?? (date.weekday == DateTime.sunday),
      cutiReason: summary?.cutiReason,
      scheduleDate: key,
      status: status,
      isClosed: isClosed,
      notes: summary?.notes,
    );
  }

  int getCapacityPercentage(DateTime date) {
    final String key = _formatDateKey(date);
    final DayScheduleSetting setting = getDaySettingForDate(date);
    if (setting.isCuti) {
      return 0;
    }

    // Single source of truth: total created schedule capacity for the day
    final List<DoctorSchedule>? daySchedules = schedulesMap[key];
    final int totalSessionCapacity = daySchedules?.fold<int>(
          0,
          (int sum, DoctorSchedule s) => sum + s.capacity,
        ) ??
        0;

    final int effectiveCapacity = totalSessionCapacity > 0
        ? totalSessionCapacity
        : setting.targetQuota;

    if (effectiveCapacity <= 0) {
      final CalendarDaySummary? summary = _calendarSummariesMap[key];
      return summary?.capacityPercentage ?? 0;
    }

    final int bookedCount = getAllBookedPatientsForDate(date).length;
    return ((bookedCount / effectiveCapacity) * 100).round().clamp(0, 100);
  }

  void setDayCuti(DateTime date, bool isCuti, {String? cutiReason}) {
    final String key = _formatDateKey(date);
    final DayScheduleSetting current = getDaySettingForDate(date);
    _daySettingsMap[key] = current.copyWith(
      isCuti: isCuti,
      cutiReason: cutiReason ?? (isCuti ? 'Dokter Cuti Praktik' : null),
      status: isCuti ? ScheduleCanonicalStatus.closed : ScheduleCanonicalStatus.open,
      isClosed: isCuti,
    );
    notifyListeners();
  }

  Future<CalendarSummaryResponse?> loadCalendarSummary(String month) async {
    try {
      final CalendarSummaryResponse res =
          await repository.fetchCalendarSummary(month);
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
              status: day.status,
              isClosed: day.isClosed,
              notes: day.notes,
            );
        _daySettingsMap[day.date] = existing.copyWith(
          targetQuota: day.targetQuota,
          isCuti: day.isCuti,
          cutiReason: day.cutiReason,
          totalBookedPatients: day.bookedPatientCount,
          capacityPercentage: day.capacityPercentage,
          status: day.status,
          isClosed: day.isClosed,
          notes: day.notes,
        );
      }
      notifyListeners();
      return res;
    } catch (e) {
      setErrorMessage(e.toString());
      notifyListeners();
      return null;
    }
  }

  Future<DayScheduleSetting> loadDaySettings(DateTime date) async {
    final String dateStr = _formatDateKey(date);
    try {
      final DayScheduleSetting setting =
          await repository.fetchDaySettings(dateStr);
      final DayScheduleSetting current = getDaySettingForDate(date);
      final CalendarDaySummary? summary = _calendarSummariesMap[dateStr];
      final List<DoctorSchedule>? daySchedules = schedulesMap[dateStr];
      final bool allSchedulesClosed = daySchedules != null &&
          daySchedules.isNotEmpty &&
          daySchedules.every((DoctorSchedule s) =>
              !s.isAvailable ||
              s.badge == ScheduleFormConstants.statusTutup ||
              s.badge == ScheduleFormConstants.statusCuti);

      final bool effectiveClosed = setting.isClosed ||
          current.isClosed ||
          (summary?.isClosed ?? false) ||
          allSchedulesClosed;

      final DayScheduleSetting merged = setting.copyWith(
        isClosed: effectiveClosed,
        status: effectiveClosed ? ScheduleCanonicalStatus.closed : setting.status,
        scheduleDate: dateStr,
      );
      _daySettingsMap[dateStr] = merged;
      notifyListeners();
      return merged;
    } catch (e) {
      setErrorMessage(e.toString());
      notifyListeners();
      return getDaySettingForDate(date);
    }
  }

  Future<void> updateDayCuti(
    DateTime date,
    bool isCuti, {
    String? cutiReason,
    int? targetQuota,
  }) async {
    final String dateStr = _formatDateKey(date);
    setDayCuti(date, isCuti, cutiReason: cutiReason);

    try {
      await repository.updateDaySettings(
        date: dateStr,
        isCuti: isCuti,
        cutiReason: cutiReason,
        targetQuota: targetQuota,
      );
    } catch (e) {
      setErrorMessage(e.toString());
    }
  }

  Future<void> updateDayStatus({
    String? doctorId,
    required DateTime date,
    required String status,
    String? notes,
  }) async {
    final String dateStr = _formatDateKey(date);
    final String upper = status.toUpperCase();
    final String canonicalStatus =
        (upper == ScheduleCanonicalStatus.buka || upper == ScheduleCanonicalStatus.open)
            ? ScheduleCanonicalStatus.open
            : ScheduleCanonicalStatus.closed;
    final bool isClosed = canonicalStatus == ScheduleCanonicalStatus.closed;

    final String resolvedDoctorId = (doctorId != null && doctorId.isNotEmpty)
        ? doctorId
        : (schedulesMap[dateStr]
                ?.where((DoctorSchedule s) => s.doctorId.isNotEmpty)
                .firstOrNull
                ?.doctorId ??
            schedulesMap.values
                .expand((List<DoctorSchedule> l) => l)
                .where((DoctorSchedule s) => s.doctorId.isNotEmpty)
                .firstOrNull
                ?.doctorId ??
            '');

    setLoading(true);
    setErrorMessage(null);
    notifyListeners();

    try {
      await repository.updateDayStatus(
        doctorId: resolvedDoctorId,
        date: dateStr,
        status: canonicalStatus,
        notes: notes,
      );

      final DayScheduleSetting current = getDaySettingForDate(date);
      _daySettingsMap[dateStr] = current.copyWith(
        status: canonicalStatus,
        isClosed: isClosed,
        notes: notes,
      );

      if (_calendarSummariesMap.containsKey(dateStr)) {
        final CalendarDaySummary prev = _calendarSummariesMap[dateStr]!;
        _calendarSummariesMap[dateStr] = CalendarDaySummary(
          date: prev.date,
          hasSchedule: prev.hasSchedule,
          isCuti: prev.isCuti,
          cutiReason: prev.cutiReason,
          sessionCount: prev.sessionCount,
          targetQuota: prev.targetQuota,
          bookedPatientCount: prev.bookedPatientCount,
          capacityPercentage: prev.capacityPercentage,
          status: canonicalStatus,
          isClosed: isClosed,
          notes: notes,
        );
      }

      if (schedulesMap.containsKey(dateStr)) {
        schedulesMap[dateStr] =
            schedulesMap[dateStr]!.map((DoctorSchedule s) {
          return s.copyWith(
            isAvailable: !isClosed,
            availableSlots: isClosed ? 0 : s.capacity,
            badge: isClosed ? ScheduleFormConstants.statusTutup : ScheduleFormConstants.statusBuka,
            badgeVariant: isClosed
                ? AmanahBadgeVariant.warning
                : AmanahBadgeVariant.success,
          );
        }).toList();
      }

      await Future.wait(<Future<dynamic>>[
        loadSchedulesForDate(date, forceRefresh: true),
        loadCalendarSummary(
          '${date.year}-${date.month.toString().padLeft(2, '0')}',
        ),
        loadDaySettings(date),
      ]);

      setLoading(false);
      notifyListeners();
    } catch (e) {
      setLoading(false);
      setErrorMessage(e.toString());
      notifyListeners();
      rethrow;
    }
  }
}
