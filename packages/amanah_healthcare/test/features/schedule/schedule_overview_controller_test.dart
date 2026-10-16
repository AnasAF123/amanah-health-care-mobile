import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/presentation/state/schedule_overview_controller.dart';

class _FakeOverviewRepo implements ScheduleRepository {
  List<SessionPatient> patients = <SessionPatient>[];
  List<CalendarDaySummary> summaries = <CalendarDaySummary>[];

  @override
  Future<List<SessionPatient>> getBookedPatients(String date) async => patients;

  @override
  Future<List<CalendarDaySummary>> getCalendarSummary(String month) async =>
      summaries;

  @override
  Future<DoctorRoster> getDoctorRoster() async => throw UnimplementedError();

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
  late _FakeOverviewRepo repo;
  late ScheduleOverviewController controller;

  setUp(() {
    repo = _FakeOverviewRepo();
    controller = ScheduleOverviewController(
      repository: repo,
      initialDate: DateTime(2026, 10, 17),
    );
  });

  group('ScheduleOverviewController', () {
    test('initializes and loads booked patients and summary', () async {
      repo.patients = <SessionPatient>[
        const SessionPatient(
          id: 'p1',
          appointmentId: 'a1',
          fullName: 'Budi',
          medicalRecordNumber: 'RM-1',
          age: '30',
          gender: 'L',
          queueNumber: '01',
          sessionTitle: 'Pagi',
          room: 'R1',
          status: 'REGISTERED',
          statusBadge: 'Terdaftar',
        ),
      ];
      repo.summaries = <CalendarDaySummary>[
        const CalendarDaySummary(
          date: '2026-10-17',
          hasSchedule: true,
          isOnLeave: false,
        ),
      ];

      await controller.initialize();

      expect(controller.bookedPatients.length, 1);
      expect(controller.bookedPatients.first.fullName, 'Budi');
      expect(controller.hasSchedulesForDate(DateTime(2026, 10, 17)), true);
      expect(controller.isCutiForDate(DateTime(2026, 10, 17)), false);
    });

    test('selectDate updates selectedDate and triggers fetch', () async {
      final DateTime newDate = DateTime(2026, 10, 18);
      controller.selectDate(newDate);

      expect(controller.selectedDate, newDate);
    });
  });
}
