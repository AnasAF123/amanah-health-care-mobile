import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/helpers/clinical_session_resolver.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

class AmanahScheduleStore extends ChangeNotifier {
  AmanahScheduleStore._({TimeService? timeService})
      : _timeService = timeService ?? DefaultTimeService() {
    _schedulesMap = <String, List<DoctorSchedule>>{};
    _daySettingsMap = <String, DayScheduleSetting>{};
  }

  static final AmanahScheduleStore instance = AmanahScheduleStore._();

  final TimeService _timeService;

  static DateTime get baseToday => DefaultTimeService().today();

  late Map<String, List<DoctorSchedule>> _schedulesMap;
  late Map<String, DayScheduleSetting> _daySettingsMap;

  Map<String, List<DoctorSchedule>> get schedulesMap => _schedulesMap;
  Map<String, DayScheduleSetting> get daySettingsMap => _daySettingsMap;

  static String formatDateKey(DateTime date) => formatIsoDateString(date);

  List<DoctorSchedule> getSchedulesForDate(DateTime date) {
    final String key = formatDateKey(date);
    return _schedulesMap[key] ?? const <DoctorSchedule>[];
  }

  void setSchedulesForDate(DateTime date, List<DoctorSchedule> list) {
    final String key = formatDateKey(date);
    _schedulesMap[key] = list;
    notifyListeners();
  }

  Future<void> syncTodaySchedules({
    ScheduleRepository? repository,
    TimeService? timeService,
  }) async {
    final TimeService ts = timeService ?? _timeService;
    final DateTime today = ts.today();
    final String dateStr = formatIsoDateString(today);
    final ScheduleRepository repo = repository ?? ScheduleRepositoryImpl();
    final List<MyScheduleSession> sessions =
        await repo.getMySchedules(date: dateStr);

    final List<DoctorSchedule> mapped = await Future.wait(
      sessions.map((MyScheduleSession s) async {
        final String targetSessionId =
            s.sessionId.isNotEmpty ? s.sessionId : s.id;
        final List<SessionPatient> sessionPatients = targetSessionId.isNotEmpty
            ? await repo.getSessionPatients(targetSessionId, date: dateStr)
            : const <SessionPatient>[];

        final List<BookedPatient> booked = sessionPatients
            .map((SessionPatient p) => p.toBookedPatient())
            .toList();

        final String sessionType = ClinicalSessionResolver.resolveShiftName(
          sessionShift: s.sessionShift,
          sessionLabel: s.sessionLabel,
        );

        final int patientCount =
            booked.isNotEmpty ? booked.length : s.bookedCount;

        return DoctorSchedule(
          id: s.id,
          title: s.sessionLabel,
          date: dateStr,
          time: s.timeRange ?? '${s.startTime ?? ''} - ${s.endTime ?? ''}',
          poli: s.poliklinikName,
          room: s.roomName,
          badge: '$patientCount Pasien',
          badgeVariant: patientCount > 0
              ? AmanahBadgeVariant.live
              : AmanahBadgeVariant.primary,
          sessionType: sessionType,
          bookedPatients: booked,
        );
      }),
    );

    setSchedulesForDate(today, mapped);
  }

  DayScheduleSetting getDaySettingForDate(DateTime date) {
    final String key = formatDateKey(date);
    return _daySettingsMap[key] ??
        DayScheduleSetting(
          isCuti: date.weekday == DateTime.sunday,
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

  void reset() {
    _schedulesMap = <String, List<DoctorSchedule>>{};
    _daySettingsMap = <String, DayScheduleSetting>{};
    notifyListeners();
  }
}
