import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_card.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

class _FakeStoreRepo implements ScheduleRepository {
  _FakeStoreRepo({required this.sessions, required this.patients});

  final List<MyScheduleSession> sessions;
  final List<SessionPatient> patients;

  @override
  Future<List<MyScheduleSession>> getMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  }) async =>
      sessions;

  @override
  Future<List<SessionPatient>> getBookedPatients(String date) async => patients;

  @override
  Future<DoctorRoster> getDoctorRoster() => throw UnimplementedError();

  @override
  Future<DoctorRoster> updateDoctorRoster(
    List<Map<String, dynamic>> assignments, {
    String? reason,
  }) =>
      throw UnimplementedError();

  @override
  Future<DoctorRoster> resetDoctorRoster() => throw UnimplementedError();

  @override
  Future<List<CalendarDaySummary>> getCalendarSummary(String month) =>
      throw UnimplementedError();

  @override
  Future<List<SessionPatient>> getSessionPatients(
    String sessionId, {
    String? date,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> toggleDayStatus(
    String date, {
    required bool isClosed,
    String? notes,
  }) =>
      throw UnimplementedError();
}

void main() {
  group('AmanahScheduleStore SSOT & Room Hardening Tests', () {
    test('syncTodaySchedules updates store and notifies listeners without dummy room fallback', () async {
      final AmanahScheduleStore store = AmanahScheduleStore.instance;

      int notifyCount = 0;
      void listener() => notifyCount++;
      store.addListener(listener);

      final _FakeStoreRepo fakeRepo = _FakeStoreRepo(
        sessions: const <MyScheduleSession>[
          MyScheduleSession(
            id: 's-1',
            sessionId: 'sess-pagi',
            sessionShift: 'morning',
            sessionLabel: 'Sesi Pagi',
            scheduleDate: '2026-10-17',
            status: 'OPEN',
            isAvailable: true,
            roomName: null, // Doctor NOT yet assigned to a room
            poliklinikName: null,
            bookedCount: 0,
          ),
        ],
        patients: const <SessionPatient>[],
      );

      await store.syncTodaySchedules(repository: fakeRepo);

      expect(notifyCount, greaterThan(0));
      final List<DoctorSchedule> today =
          store.getSchedulesForDate(AmanahScheduleStore.baseToday);
      expect(today.length, 1);
      expect(today.first.title, 'Sesi Pagi');
      expect(today.first.room, isNull);
      expect(today.first.poli, isNull);

      store.removeListener(listener);
    });

    testWidgets('AmanahScheduleCard does not render room or poli when null/unassigned',
        (WidgetTester tester) async {
      const DoctorSchedule scheduleWithoutRoom = DoctorSchedule(
        id: 'sch-1',
        title: 'Sesi Pagi',
        date: 'Sabtu, 17 Okt 2026',
        time: '08:00 - 12:00',
        room: null, // No assigned room
        poli: null, // No assigned poli
        badge: '0 Pasien',
        badgeVariant: AmanahBadgeVariant.primary,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahScheduleCard(
              schedule: scheduleWithoutRoom,
              onDismiss: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify schedule title and time are present
      expect(find.text('Sesi Pagi'), findsOneWidget);
      expect(find.text('08:00 - 12:00'), findsOneWidget);

      // Verify dummy placeholders ARE NOT rendered
      expect(find.text('Ruang Praktik'), findsNothing);
      expect(find.text('Ruang Poli'), findsNothing);
      expect(find.text('Poliklinik'), findsNothing);
    });

    testWidgets('AmanahScheduleCard renders room and poli when explicitly assigned',
        (WidgetTester tester) async {
      const DoctorSchedule scheduleWithRoom = DoctorSchedule(
        id: 'sch-2',
        title: 'Sesi Siang',
        date: 'Sabtu, 17 Okt 2026',
        time: '13:00 - 16:00',
        room: 'Ruang Poli Gigi 2',
        poli: 'Poliklinik Gigi & Mulut',
        badge: '3 Pasien',
        badgeVariant: AmanahBadgeVariant.live,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahScheduleCard(
              schedule: scheduleWithRoom,
              onDismiss: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify explicit room and poli are rendered
      expect(find.text('Ruang Poli Gigi 2'), findsOneWidget);
      expect(find.text('Poliklinik Gigi & Mulut'), findsOneWidget);
    });
  });
}
