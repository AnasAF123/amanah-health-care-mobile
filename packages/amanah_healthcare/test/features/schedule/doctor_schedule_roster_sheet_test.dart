import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/presentation/organisms/doctor_schedule_roster_sheet.dart';
import 'package:amanah_healthcare/features/schedule/presentation/state/schedule_roster_controller.dart';

class _FakeSheetRepo implements ScheduleRepository {
  _FakeSheetRepo(this.roster);

  DoctorRoster roster;

  @override
  Future<DoctorRoster> getDoctorRoster() async => roster;

  @override
  Future<DoctorRoster> updateDoctorRoster(
    List<Map<String, dynamic>> assignments, {
    String? reason,
  }) async =>
      roster;

  @override
  Future<DoctorRoster> resetDoctorRoster() async => roster;

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
  testWidgets('DoctorScheduleRosterSheet renders days and toggles',
      (WidgetTester tester) async {
    const DoctorRoster testRoster = DoctorRoster(
      doctorId: 'doc-1',
      doctorName: 'dr. Budi Setiawan',
      specialization: 'Dokter Umum',
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
              sessionId: 's-1',
              sessionCode: 'morning',
              sessionLabel: 'Sesi Pagi',
              timeRange: '08:00 - 12:00',
              isActive: true,
              isTemplateActive: true,
            ),
          ],
        ),
      ],
    );

    final _FakeSheetRepo repo = _FakeSheetRepo(testRoster);
    final ScheduleRosterController controller =
        ScheduleRosterController(repository: repo);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DoctorScheduleRosterSheet(controller: controller),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pengaturan Jadwal Shift'), findsOneWidget);
    expect(find.text('dr. Budi Setiawan • Dokter Umum'), findsOneWidget);
    expect(find.text('Senin'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);

    // Tap calendar button opens the date picker
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    // Verify date picker is opened
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
