import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/data/schedule_store_day_mixin.dart';
import 'package:amanah_healthcare/features/schedule/data/schedule_store_projection_mixin.dart';
import 'package:amanah_healthcare/features/schedule/data/schedule_store_session_mixin.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

class AmanahScheduleStore extends ChangeNotifier
    with
        ScheduleStoreProjectionMixin,
        ScheduleStoreSessionMixin,
        ScheduleStoreDayMixin {
  AmanahScheduleStore._({AmanahScheduleRepository? repository})
      : _repository = repository ?? const AmanahScheduleRepository() {
    _schedulesMap = <String, List<DoctorSchedule>>{};
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

  static bool get hasCustomBaseToday => _customBaseToday != null;
  static DateTime? get customBaseToday => _customBaseToday;

  @visibleForTesting
  static void setCustomBaseToday(DateTime? date) {
    _customBaseToday = date;
  }

  AmanahScheduleRepository _repository;
  @override
  AmanahScheduleRepository get repository => _repository;

  void setRepository(AmanahScheduleRepository repository) {
    _repository = repository;
  }

  late Map<String, List<DoctorSchedule>> _schedulesMap;
  Map<String, List<DoctorSchedule>> _intervalSchedulesMap =
      <String, List<DoctorSchedule>>{};
  String? _activeDoctorId;

  String? get activeDoctorId => _activeDoctorId;

  void setActiveDoctorId(String? id, {bool notify = false}) {
    if (_activeDoctorId != id) {
      _activeDoctorId = id;
      if (notify) {
        notifyListeners();
      }
    }
  }

  bool _isLoading = false;
  String? _errorMessage;
  AmanahScheduleConflictException? _lastConflict;

  @override
  Map<String, List<DoctorSchedule>> get schedulesMap => _schedulesMap;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AmanahScheduleConflictException? get lastConflict => _lastConflict;

  @override
  void setLoading(bool loading) {
    _isLoading = loading;
  }

  @override
  void setErrorMessage(String? error) {
    _errorMessage = error;
  }

  @override
  void setLastConflict(AmanahScheduleConflictException? conflict) {
    _lastConflict = conflict;
  }

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

  List<DoctorSchedule> getIntervalSchedulesForDate(DateTime date) {
    final String key = formatDateKey(date);
    return List<DoctorSchedule>.unmodifiable(
      _intervalSchedulesMap[key] ?? const <DoctorSchedule>[],
    );
  }

  @override
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

  List<({BookedPatient patient, DoctorSchedule schedule})>
      getActiveBookedPatientsForDate(DateTime date) {
    return getAllBookedPatientsForDate(date).where((item) {
      if (item.patient.isCompleted || item.patient.isCancelled) {
        return false;
      }
      final bool isExpired = isTemporalSlotPast(
        scheduleDateStr: item.schedule.scheduleDate ?? item.schedule.date,
        timeSlotOrEndTime: item.patient.timeSlot,
      );
      return !isExpired;
    }).toList();
  }

  List<({BookedPatient patient, DoctorSchedule schedule})>
      getCompletedPatientsForDate(DateTime date) {
    return getAllBookedPatientsForDate(date).where((item) {
      if (item.patient.isCompleted || item.patient.isCancelled) {
        return true;
      }
      return isTemporalSlotPast(
        scheduleDateStr: item.schedule.scheduleDate ?? item.schedule.date,
        timeSlotOrEndTime: item.patient.timeSlot,
      );
    }).toList();
  }

  List<({BookedPatient patient, DoctorSchedule schedule})>
      getAllHistoricalPatients() {
    final List<({BookedPatient patient, DoctorSchedule schedule})> list =
        <({BookedPatient patient, DoctorSchedule schedule})>[];
    for (final List<DoctorSchedule> schedules in _schedulesMap.values) {
      for (final DoctorSchedule sch in schedules) {
        for (final BookedPatient p in sch.bookedPatients) {
          final bool isPast = p.isCompleted ||
              p.isCancelled ||
              isTemporalSlotPast(
                scheduleDateStr: sch.scheduleDate ?? sch.date,
                timeSlotOrEndTime: p.timeSlot,
              );
          if (isPast) {
            list.add((patient: p, schedule: sch));
          }
        }
      }
    }
    return list;
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
    final int index =
        current.indexWhere((DoctorSchedule s) => s.id == schedule.id);
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

  // --- Asynchronous backend-connected methods ---

  @override
  Future<List<DoctorSchedule>> loadSchedulesForDate(
    DateTime date, {
    String? doctorId,
    bool forceRefresh = false,
  }) async {
    final String dateStr = formatDateKey(date);
    _isLoading = true;
    _errorMessage = null;
    await Future<void>.value();
    notifyListeners();

    try {
      final String resolvedDoctorId = (doctorId != null && doctorId.isNotEmpty)
          ? doctorId
          : (_activeDoctorId != null && _activeDoctorId!.isNotEmpty)
              ? _activeDoctorId!
              : _schedulesMap[dateStr]
                      ?.where((DoctorSchedule s) => s.doctorId.isNotEmpty)
                      .firstOrNull
                      ?.doctorId ??
                  _schedulesMap.values
                      .expand((List<DoctorSchedule> list) => list)
                      .where((DoctorSchedule s) => s.doctorId.isNotEmpty)
                      .firstOrNull
                      ?.doctorId ??
                  '';

      List<DoctorSchedule> backendSchedules = const <DoctorSchedule>[];
      try {
        backendSchedules = await _repository.fetchMySchedules(date: dateStr);
      } catch (_) {
        if (resolvedDoctorId.isNotEmpty) {
          backendSchedules = await _repository.fetchDoctorDailySchedules(
            doctorId: resolvedDoctorId,
            date: dateStr,
          );
        } else {
          rethrow;
        }
      }

      List<BookedPatient> allPatients = const <BookedPatient>[];
      try {
        allPatients = await _repository.fetchBookedPatients(date: dateStr);
      } catch (_) {}

      final List<DoctorSchedule> enriched =
          backendSchedules.map((DoctorSchedule s) {
        final List<BookedPatient> sessionPatients =
            allPatients.where((BookedPatient p) {
          if (p.appointmentId != null &&
              s.bookedPatients.any((BookedPatient bp) => bp.id == p.id)) {
            return true;
          }
          if (p.sessionTitle != null &&
              p.sessionTitle!
                  .toLowerCase()
                  .contains(s.sessionType.toLowerCase())) {
            return true;
          }
          return false;
        }).toList();

        final List<BookedPatient> finalPatients =
            sessionPatients.isNotEmpty ? sessionPatients : s.bookedPatients;
        final int activePatientCount =
            finalPatients.where((BookedPatient p) => !p.isCancelled).length;
        final int finalCount = sessionPatients.isNotEmpty
            ? activePatientCount
            : s.bookedPatientCount;
        final int availableSlots =
            (s.capacity - finalCount).clamp(0, s.capacity);

        final String badge;
        final AmanahBadgeVariant badgeVariant;
        if (!s.isAvailable ||
            s.badge == ScheduleFormConstants.statusTutup ||
            s.badge == ScheduleFormConstants.statusCuti) {
          badge = s.badge;
          badgeVariant = s.badgeVariant;
        } else if (availableSlots == 0) {
          badge = ScheduleFormConstants.badgePenuh;
          badgeVariant = AmanahBadgeVariant.primary;
        } else if (finalCount > 0) {
          badge = ScheduleFormConstants.badgeTerisi;
          badgeVariant = AmanahBadgeVariant.primary;
        } else {
          badge = ScheduleFormConstants.statusBuka;
          badgeVariant = AmanahBadgeVariant.success;
        }

        return s.copyWith(
          bookedPatients: finalPatients,
          bookedPatientCount: finalCount,
          availableSlots: availableSlots,
          badge: badge,
          badgeVariant: badgeVariant,
          slotCount: finalCount.toString(),
          slotText: '$finalCount Pasien Booking',
        );
      }).toList();

      _schedulesMap[dateStr] = enriched;

      final String effectiveDoctorId = resolvedDoctorId.isNotEmpty
          ? resolvedDoctorId
          : (enriched.where((DoctorSchedule s) => s.doctorId.isNotEmpty).firstOrNull?.doctorId ??
              enriched.where((DoctorSchedule s) => (s.practitionerId ?? '').isNotEmpty).firstOrNull?.practitionerId ??
              '');

      if (effectiveDoctorId.isNotEmpty) {
        try {
          final List<DoctorSchedule> intervalSlots =
              await _repository.fetchDoctorDailyIntervalSlots(
            doctorId: effectiveDoctorId,
            date: dateStr,
          );
          if (intervalSlots.isNotEmpty) {
            _intervalSchedulesMap[dateStr] = intervalSlots;
          }
        } catch (_) {}
      }

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
      final bool isExistingPersisted =
          schedule.id.isNotEmpty && !schedule.id.startsWith('ses-');

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
          status: schedule.mutationStatus,
          isAvailable: schedule.isAvailable,
          notes: notes ?? schedule.notes,
        );
        updateSchedule(date, result);
      } else {
        final CanonicalShift shift =
            CanonicalShift.tryResolve(schedule.sessionType) ??
                CanonicalShift.morning;
        result = await _repository.createSchedule(
          date: dateStr,
          session: schedule.sessionType,
          startTime: schedule.startTime ?? shift.defaultStartTime,
          endTime: schedule.endTime ?? shift.defaultEndTime,
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

  Future<void> toggleScheduleAvailability(
    DateTime date,
    String scheduleId,
    bool isAvailable,
  ) async {
    final String key = formatDateKey(date);
    final List<DoctorSchedule> current =
        List<DoctorSchedule>.from(_schedulesMap[key] ?? <DoctorSchedule>[]);
    final int index =
        current.indexWhere((DoctorSchedule s) => s.id == scheduleId);
    if (index >= 0) {
      current[index] = current[index].copyWith(
        isAvailable: isAvailable,
        badge: isAvailable
            ? ScheduleFormConstants.statusBuka
            : ScheduleFormConstants.statusTutup,
        badgeVariant: isAvailable
            ? AmanahBadgeVariant.success
            : AmanahBadgeVariant.warning,
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

  /// Authoritative full synchronization across all schedule subsystems:
  /// - Doctor sessions (`/api/v1/schedules/my-schedules?date=...`)
  /// - Monthly calendar summaries & status dots (`/api/v1/schedules/calendar-summary?month=...`)
  /// - Daily operational quota & setting (`/api/v1/schedules/day-settings?date=...`)
  /// - Clinic room & interval occupancy (`/api/v1/schedules/occupancy-overview?date=...`)
  Future<void> syncAll(
    DateTime date, {
    String? doctorId,
    bool forceRefresh = true,
  }) async {
    final String monthKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}';
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait(<Future<dynamic>>[
        loadSchedulesForDate(
          date,
          doctorId: doctorId,
          forceRefresh: forceRefresh,
        ),
        loadCalendarSummary(monthKey),
        loadDaySettings(date),
        loadOccupancyOverview(date: date),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _schedulesMap = <String, List<DoctorSchedule>>{};
    _intervalSchedulesMap = <String, List<DoctorSchedule>>{};
    _activeDoctorId = null;
    resetDayState();
    resetProjectionState();
    resetSessionState();
    _customBaseToday = null;
    _isLoading = false;
    _errorMessage = null;
    _lastConflict = null;
    notifyListeners();
  }
}
