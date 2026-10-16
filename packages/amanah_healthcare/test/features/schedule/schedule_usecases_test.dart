import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_booked_patients.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_calendar_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_my_schedules.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_session_patients.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/reset_doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/toggle_day_status.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/update_doctor_roster.dart';

class _FakeScheduleRepository implements ScheduleRepository {
  DoctorRoster dummyRoster = const DoctorRoster(
    doctorId: 'd1',
    doctorName: 'dr. Test',
    specialization: 'Umum',
    hasAnyOverride: false,
    days: <DoctorRosterDay>[],
  );

  List<Map<String, dynamic>>? lastUpdatedAssignments;
  String? lastUpdatedReason;
  bool resetCalled = false;
  String? lastToggledDate;
  bool? lastToggledIsClosed;

  @override
  Future<DoctorRoster> getDoctorRoster() async => dummyRoster;

  @override
  Future<DoctorRoster> updateDoctorRoster(
    List<Map<String, dynamic>> assignments, {
    String? reason,
  }) async {
    lastUpdatedAssignments = assignments;
    lastUpdatedReason = reason;
    return dummyRoster;
  }

  @override
  Future<DoctorRoster> resetDoctorRoster() async {
    resetCalled = true;
    return dummyRoster;
  }

  @override
  Future<List<CalendarDaySummary>> getCalendarSummary(String month) async {
    return <CalendarDaySummary>[
      CalendarDaySummary(
        date: '$month-15',
        hasSchedule: true,
        isOnLeave: false,
      ),
    ];
  }

  @override
  Future<List<SessionPatient>> getBookedPatients(String date) async {
    return <SessionPatient>[
      const SessionPatient(
        id: 'p1',
        appointmentId: 'a1',
        fullName: 'Pasien Test',
        medicalRecordNumber: 'RM1',
        age: '25',
        gender: 'L',
        queueNumber: '01',
        sessionTitle: 'Pagi',
        room: 'R1',
        status: 'REGISTERED',
        statusBadge: 'Terdaftar',
      ),
    ];
  }

  @override
  Future<List<SessionPatient>> getSessionPatients(
    String sessionId, {
    String? date,
  }) async {
    return <SessionPatient>[
      SessionPatient(
        id: 'p2',
        appointmentId: 'a2',
        fullName: 'Pasien Sesi $sessionId',
        medicalRecordNumber: 'RM2',
        age: '30',
        gender: 'P',
        queueNumber: '02',
        sessionTitle: 'Siang',
        room: 'R2',
        status: 'REGISTERED',
        statusBadge: 'Terdaftar',
      ),
    ];
  }

  @override
  Future<List<MyScheduleSession>> getMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  }) async {
    return <MyScheduleSession>[
      const MyScheduleSession(
        id: 'sch1',
        sessionId: 'sess1',
        sessionShift: 'morning',
        sessionLabel: 'Sesi Pagi',
        scheduleDate: '2026-10-17',
        status: 'OPEN',
        isAvailable: true,
      ),
    ];
  }

  @override
  Future<void> toggleDayStatus(
    String date, {
    required bool isClosed,
    String? notes,
  }) async {
    lastToggledDate = date;
    lastToggledIsClosed = isClosed;
  }
}

void main() {
  late _FakeScheduleRepository repo;

  setUp(() {
    repo = _FakeScheduleRepository();
  });

  group('Schedule Use Cases', () {
    test('GetDoctorRosterUseCase delegates to repository', () async {
      final GetDoctorRosterUseCase usecase = GetDoctorRosterUseCase(repo);
      final DoctorRoster res = await usecase(const NoParams());
      expect(res.doctorId, 'd1');
    });

    test('UpdateDoctorRosterUseCase passes assignments and reason', () async {
      final UpdateDoctorRosterUseCase usecase = UpdateDoctorRosterUseCase(repo);
      final List<Map<String, dynamic>> assignments = <Map<String, dynamic>>[
        <String, dynamic>{'dow': 1, 'sessionId': 's1', 'isActive': true},
      ];
      await usecase(
        UpdateDoctorRosterParams(
          assignments: assignments,
          reason: 'Test reason',
        ),
      );
      expect(repo.lastUpdatedAssignments, assignments);
      expect(repo.lastUpdatedReason, 'Test reason');
    });

    test('ResetDoctorRosterUseCase invokes reset', () async {
      final ResetDoctorRosterUseCase usecase = ResetDoctorRosterUseCase(repo);
      await usecase(const NoParams());
      expect(repo.resetCalled, true);
    });

    test('GetCalendarSummaryUseCase calls repository with month', () async {
      final GetCalendarSummaryUseCase usecase = GetCalendarSummaryUseCase(repo);
      final List<CalendarDaySummary> res =
          await usecase(const GetCalendarSummaryParams(month: '2026-10'));
      expect(res.length, 1);
      expect(res.first.date, '2026-10-15');
    });

    test('GetBookedPatientsUseCase calls repository with date', () async {
      final GetBookedPatientsUseCase usecase = GetBookedPatientsUseCase(repo);
      final List<SessionPatient> res =
          await usecase(const GetBookedPatientsParams(date: '2026-10-17'));
      expect(res.length, 1);
      expect(res.first.id, 'p1');
    });

    test('GetSessionPatientsUseCase calls repository with sessionId', () async {
      final GetSessionPatientsUseCase usecase = GetSessionPatientsUseCase(repo);
      final List<SessionPatient> res = await usecase(
        const GetSessionPatientsParams(sessionId: 'sess-abc'),
      );
      expect(res.first.fullName, 'Pasien Sesi sess-abc');
    });

    test('GetMySchedulesUseCase calls repository with date params', () async {
      final GetMySchedulesUseCase usecase = GetMySchedulesUseCase(repo);
      final List<MyScheduleSession> res = await usecase(
        const GetMySchedulesParams(date: '2026-10-17'),
      );
      expect(res.first.sessionId, 'sess1');
    });

    test('ToggleDayStatusUseCase delegates toggle action', () async {
      final ToggleDayStatusUseCase usecase = ToggleDayStatusUseCase(repo);
      await usecase(
        const ToggleDayStatusParams(date: '2026-10-20', isClosed: true),
      );
      expect(repo.lastToggledDate, '2026-10-20');
      expect(repo.lastToggledIsClosed, true);
    });
  });
}
