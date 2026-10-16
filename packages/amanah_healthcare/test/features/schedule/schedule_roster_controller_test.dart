import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/presentation/state/schedule_roster_controller.dart';

class _FakeRosterRepo implements ScheduleRepository {
  _FakeRosterRepo(this.roster);

  DoctorRoster roster;
  List<Map<String, dynamic>>? savedAssignments;

  @override
  Future<DoctorRoster> getDoctorRoster() async => roster;

  @override
  Future<DoctorRoster> updateDoctorRoster(
    List<Map<String, dynamic>> assignments, {
    String? reason,
  }) async {
    savedAssignments = assignments;
    roster = roster.copyWith(hasAnyOverride: true);
    return roster;
  }

  @override
  Future<DoctorRoster> resetDoctorRoster() async {
    roster = roster.copyWith(hasAnyOverride: false);
    return roster;
  }

  @override
  Future<List<CalendarDaySummary>> getCalendarSummary(String month) async =>
      const <CalendarDaySummary>[];

  @override
  Future<List<SessionPatient>> getBookedPatients(String date) async =>
      const <SessionPatient>[];

  @override
  Future<List<MyScheduleSession>> getMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  }) async =>
      const <MyScheduleSession>[];

  @override
  Future<List<SessionPatient>> getSessionPatients(
    String sessionId, {
    String? date,
  }) async =>
      const <SessionPatient>[];

  @override
  Future<void> toggleDayStatus(
    String date, {
    required bool isClosed,
    String? notes,
  }) async {}
}

void main() {
  late DoctorRoster sampleRoster;
  late _FakeRosterRepo repo;
  late ScheduleRosterController controller;

  setUp(() {
    sampleRoster = const DoctorRoster(
      doctorId: 'doc-1',
      doctorName: 'dr. Test',
      specialization: 'Umum',
      hasAnyOverride: false,
      days: <DoctorRosterDay>[
        DoctorRosterDay(
          dow: 1,
          dayCode: 'monday',
          dayName: 'Senin',
          sortOrder: 1,
          isWeekend: false,
          isOperatingDay: true,
          isDoctorActive: true,
          hasOverride: false,
          sessions: <DoctorRosterSession>[
            DoctorRosterSession(
              sessionId: 's-morning',
              sessionCode: 'morning',
              sessionLabel: 'Sesi Pagi',
              timeRange: '08:00 - 12:00',
              isActive: true,
              isTemplateActive: true,
            ),
            DoctorRosterSession(
              sessionId: 's-afternoon',
              sessionCode: 'afternoon',
              sessionLabel: 'Sesi Siang',
              timeRange: '13:00 - 16:00',
              isActive: false,
              isTemplateActive: false,
            ),
          ],
        ),
      ],
    );
    repo = _FakeRosterRepo(sampleRoster);
    controller = ScheduleRosterController(repository: repo);
  });

  group('ScheduleRosterController', () {
    test('loadRoster populates draft and template assignments', () async {
      await controller.loadRoster();

      expect(controller.isLoading, false);
      expect(controller.roster, isNotNull);
      expect(controller.isSessionActive(1, 's-morning'), true);
      expect(controller.isSessionActive(1, 's-afternoon'), false);
      expect(controller.hasUnsavedChanges, false);
    });

    test('toggleSession toggles state and marks unsaved changes', () async {
      await controller.loadRoster();

      controller.toggleSession(1, 's-afternoon');
      expect(controller.isSessionActive(1, 's-afternoon'), true);
      expect(controller.hasUnsavedChanges, true);

      controller.toggleSession(1, 's-afternoon');
      expect(controller.isSessionActive(1, 's-afternoon'), false);
      expect(controller.hasUnsavedChanges, false);
    });

    test('toggleDay toggles all sessions on day', () async {
      await controller.loadRoster();

      // Currently active -> toggling day deactivates all sessions on that day
      controller.toggleDay(1);
      expect(controller.isDayActive(1), false);
      expect(controller.isSessionActive(1, 's-morning'), false);

      // Inactive -> toggling day reactivates according to template
      controller.toggleDay(1);
      expect(controller.isDayActive(1), true);
      expect(controller.isSessionActive(1, 's-morning'), true);
    });

    test('resetDayToTemplate restores day to template', () async {
      await controller.loadRoster();

      controller.toggleSession(1, 's-afternoon');
      expect(controller.hasDayDiffFromTemplate(1), true);

      controller.resetDayToTemplate(1);
      expect(controller.isSessionActive(1, 's-afternoon'), false);
      expect(controller.hasDayDiffFromTemplate(1), false);
    });
  });
}
