import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

class AmanahScheduleStore extends ChangeNotifier {
  AmanahScheduleStore._() {
    _schedulesMap = <String, List<DoctorSchedule>>{};
    _daySettingsMap = <String, DayScheduleSetting>{};
  }

  static final AmanahScheduleStore instance = AmanahScheduleStore._();

  static DateTime get baseToday {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  late Map<String, List<DoctorSchedule>> _schedulesMap;
  late Map<String, DayScheduleSetting> _daySettingsMap;

  Map<String, List<DoctorSchedule>> get schedulesMap => _schedulesMap;
  Map<String, DayScheduleSetting> get daySettingsMap => _daySettingsMap;

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

  void setSchedulesForDate(DateTime date, List<DoctorSchedule> list) {
    final String key = formatDateKey(date);
    _schedulesMap[key] = list;
    notifyListeners();
  }

  Future<void> syncTodaySchedules({ScheduleRepository? repository}) async {
    final DateTime now = DateTime.now();
    final String dateStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      final ScheduleRepository repo = repository ?? ScheduleRepositoryImpl();
      final List<MyScheduleSession> sessions =
          await repo.getMySchedules(date: dateStr);
      final List<SessionPatient> patients =
          await repo.getBookedPatients(dateStr);

      final List<DoctorSchedule> mapped = sessions.map((MyScheduleSession s) {
        final List<BookedPatient> sessionPatients = patients
            .where((SessionPatient p) =>
                p.sessionTitle.toLowerCase().contains(s.sessionShift.toLowerCase()) ||
                p.sessionTitle.toLowerCase().contains(s.sessionLabel.toLowerCase()))
            .map((SessionPatient p) => p.toBookedPatient())
            .toList();

        final String sessionType = switch (s.sessionShift) {
          'morning' => 'Pagi',
          'afternoon' => 'Siang',
          'night' => 'Malam',
          'early_morning' => 'Dini Hari',
          _ => s.sessionLabel,
        };

        return DoctorSchedule(
          id: s.id,
          title: s.sessionLabel,
          date: dateStr,
          time: s.timeRange ?? '${s.startTime ?? ''} - ${s.endTime ?? ''}',
          poli: s.poliklinikName,
          room: s.roomName,
          badge:
              '${sessionPatients.isNotEmpty ? sessionPatients.length : s.bookedCount} Pasien',
          badgeVariant: (sessionPatients.isNotEmpty || s.bookedCount > 0)
              ? AmanahBadgeVariant.live
              : AmanahBadgeVariant.primary,
          sessionType: sessionType,
          bookedPatients: sessionPatients,
        );
      }).toList();

      setSchedulesForDate(baseToday, mapped);
    } catch (_) {
      // Graceful fallback
    }
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
