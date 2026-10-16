import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/presentation/state/calendar_sheet_controller.dart';

class _FakeCalendarRepo implements ScheduleRepository {
  List<MyScheduleSession> sessions = <MyScheduleSession>[];
  Map<String, List<SessionPatient>> sessionPatientsMap =
      <String, List<SessionPatient>>{};

  @override
  Future<List<MyScheduleSession>> getMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  }) async =>
      sessions;

  @override
  Future<List<SessionPatient>> getSessionPatients(
    String sessionId, {
    String? date,
  }) async =>
      sessionPatientsMap[sessionId] ?? <SessionPatient>[];

  @override
  Future<List<SessionPatient>> getBookedPatients(String date) async =>
      const <SessionPatient>[];

  @override
  Future<List<CalendarDaySummary>> getCalendarSummary(String month) async =>
      const <CalendarDaySummary>[];

  @override
  Future<DoctorRoster> getDoctorRoster() async => throw UnimplementedError();

  @override
  Future<DoctorRoster> resetDoctorRoster() async => throw UnimplementedError();

  @override
  Future<void> toggleDayStatus(
    String date, {
    required bool isClosed,
    String? notes,
  }) async {}

  @override
  Future<DoctorRoster> updateDoctorRoster(
    List<Map<String, dynamic>> assignments, {
    String? reason,
  }) async =>
      throw UnimplementedError();
}

void main() {
  late _FakeCalendarRepo repo;
  late CalendarSheetController controller;

  setUp(() {
    repo = _FakeCalendarRepo();
    controller = CalendarSheetController(
      selectedDate: DateTime(2026, 10, 17),
      repository: repo,
    );
  });

  group('CalendarSheetController', () {
    test('loadSessions filters active/open sessions', () async {
      repo.sessions = <MyScheduleSession>[
        const MyScheduleSession(
          id: '1',
          sessionId: 's-open',
          sessionShift: 'morning',
          sessionLabel: 'Sesi Pagi',
          scheduleDate: '2026-10-17',
          status: 'OPEN',
          isAvailable: true,
          bookedCount: 3,
        ),
        const MyScheduleSession(
          id: '2',
          sessionId: 's-closed',
          sessionShift: 'night',
          sessionLabel: 'Sesi Malam',
          scheduleDate: '2026-10-17',
          status: 'CLOSED',
          isAvailable: false,
          bookedCount: 0,
        ),
      ];

      await controller.loadSessions();

      expect(controller.activeSessions.length, 1);
      expect(controller.activeSessions.first.sessionId, 's-open');
    });

    test('toggleSessionExpanded expands and lazy-loads patients', () async {
      repo.sessions = <MyScheduleSession>[
        const MyScheduleSession(
          id: '1',
          sessionId: 's-open',
          sessionShift: 'morning',
          sessionLabel: 'Sesi Pagi',
          scheduleDate: '2026-10-17',
          status: 'OPEN',
          isAvailable: true,
          bookedCount: 1,
        ),
      ];
      repo.sessionPatientsMap['s-open'] = <SessionPatient>[
        const SessionPatient(
          id: 'p1',
          appointmentId: 'a1',
          fullName: 'Ahmad',
          medicalRecordNumber: 'RM-01',
          age: '40',
          gender: 'L',
          queueNumber: '01',
          sessionTitle: 'Sesi Pagi',
          room: 'Ruang 1',
          status: 'REGISTERED',
          statusBadge: 'Terdaftar',
        ),
      ];

      await controller.loadSessions();
      expect(controller.isExpanded('s-open'), false);

      await controller.toggleSessionExpanded('s-open');
      expect(controller.isExpanded('s-open'), true);
      expect(controller.getPatientsForSession('s-open')?.length, 1);
      expect(controller.getPatientsForSession('s-open')?.first.fullName, 'Ahmad');

      // Collapsing
      await controller.toggleSessionExpanded('s-open');
      expect(controller.isExpanded('s-open'), false);
    });
  });
}
