import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class AmanahScheduleStore extends ChangeNotifier {
  AmanahScheduleStore._() {
    _schedulesMap = <String, List<DoctorSchedule>>{};
    _daySettingsMap = <String, DayScheduleSetting>{};
  }

  static final AmanahScheduleStore instance = AmanahScheduleStore._();

  static final DateTime baseToday = DateTime(2026, 8, 26);

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

  DayScheduleSetting getDaySettingForDate(DateTime date) {
    final String key = formatDateKey(date);
    return _daySettingsMap[key] ??
        DayScheduleSetting(
          targetQuota: 8,
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

  int getCapacityPercentage(DateTime date) {
    final DayScheduleSetting setting = getDaySettingForDate(date);
    if (setting.isCuti || setting.targetQuota <= 0) {
      return 0;
    }
    final int bookedCount = getAllBookedPatientsForDate(date).length;
    return ((bookedCount / setting.targetQuota) * 100).round().clamp(0, 100);
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
