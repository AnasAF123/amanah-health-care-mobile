import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';

abstract interface class ScheduleRepository {
  /// Fetches the logged-in doctor's 7-day weekly roster
  Future<DoctorRoster> getDoctorRoster();

  /// Updates doctor's roster assignment overrides
  Future<DoctorRoster> updateDoctorRoster(
    List<Map<String, dynamic>> assignments, {
    String? reason,
  });

  /// Resets doctor's roster overrides to clinic weekly master template
  Future<DoctorRoster> resetDoctorRoster();

  /// Fetches monthly calendar summary for the doctor (YYYY-MM)
  Future<List<CalendarDaySummary>> getCalendarSummary(String month);

  /// Fetches all booked patients on a specific date (YYYY-MM-DD)
  Future<List<SessionPatient>> getBookedPatients(String date);

  /// Fetches registered patients for a specific session shift ID
  Future<List<SessionPatient>> getSessionPatients(
    String sessionId, {
    String? date,
  });

  /// Fetches effective scheduled sessions for a date or date range
  Future<List<MyScheduleSession>> getMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  });

  /// Closes or re-opens all practice sessions on a given date (YYYY-MM-DD)
  Future<void> toggleDayStatus(
    String date, {
    required bool isClosed,
    String? notes,
  });
}
