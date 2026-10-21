import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/presence/data/datasources/attendance_remote_data_source.dart';
import 'package:amanah_healthcare/features/presence/data/repositories/attendance_repository_impl.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/history/presence_timeline_item.dart';

class _FakeAttendanceRemoteDataSource implements AttendanceRemoteDataSource {
  _FakeAttendanceRemoteDataSource(this._historyResponse);

  final List<dynamic> _historyResponse;

  @override
  Future<List<dynamic>> getMyHistory() async => _historyResponse;

  @override
  Future<Map<String, dynamic>> submitScan({
    required String qrToken,
    String? shift,
    String? deviceInfo,
  }) async => <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> submitCheckout({
    String? qrToken,
    String? checkoutTicket,
    String? notes,
  }) async => <String, dynamic>{};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttendanceRecord Entity', () {
    test('computes dayName, checkInTimeFormatted, and checkOutTimeFormatted accurately', () {
      final checkIn = DateTime(2026, 10, 20, 14, 0); // Tuesday
      final checkOut = DateTime(2026, 10, 20, 21, 30);

      final record = AttendanceRecord(
        id: 'rec-1',
        date: '20 Okt',
        dayNumber: 20,
        time: '14:00 WIB',
        title: 'Shift Siang',
        status: AttendanceStatus.hadir,
        attendanceDate: DateTime(2026, 10, 20),
        checkInAt: checkIn,
        checkOutAt: checkOut,
        validatedDurationHours: 7.5,
        notes: 'Praktek lancar',
      );

      expect(record.dayName, equals('Selasa'));
      expect(record.checkInTimeFormatted, equals('14:00 WIB'));
      expect(record.checkOutTimeFormatted, equals('21:30 WIB'));
      expect(record.location, isEmpty);
      expect(record.validatedDurationHours, equals(7.5));
      expect(record.notes, equals('Praktek lancar'));
    });

    test('returns null for checkOutTimeFormatted when checkOutAt is null', () {
      final checkIn = DateTime(2026, 10, 18, 13, 40);

      final record = AttendanceRecord(
        id: 'rec-2',
        date: '18 Okt',
        dayNumber: 18,
        time: '13:40 WIB',
        title: 'Shift Siang',
        status: AttendanceStatus.telat,
        attendanceDate: DateTime(2026, 10, 18),
        checkInAt: checkIn,
        checkOutAt: null,
      );

      expect(record.checkInTimeFormatted, equals('13:40 WIB'));
      expect(record.checkOutTimeFormatted, isNull);
    });
  });

  group('AttendanceRepositoryImpl.getMyHistory()', () {
    test('maps canonical backend shift into Indonesian shift title without word Dinas', () async {
      final fakeDataSource = _FakeAttendanceRemoteDataSource(<dynamic>[
        <String, dynamic>{
          'id': 'rec-afternoon',
          'shift': 'afternoon',
          'status': 'late',
          'checkInAt': '2026-10-20T07:00:00.000Z',
          'checkOutAt': '2026-10-20T14:00:00.000Z',
          'attendanceDate': '2026-10-20',
          'validatedDurationHours': 7.0,
          'isReplacement': false,
          'notes': 'Izin dinas luar',
        },
        <String, dynamic>{
          'id': 'rec-night',
          'shift': 'night',
          'status': 'present',
          'checkInAt': '2026-10-19T14:00:00.000Z',
          'checkOutAt': '2026-10-19T21:00:00.000Z',
          'attendanceDate': '2026-10-19',
          'validatedDurationHours': 7.0,
          'isReplacement': false,
        },
        <String, dynamic>{
          'id': 'rec-morning-replacement',
          'shift': 'morning',
          'status': 'present',
          'checkInAt': '2026-10-18T01:00:00.000Z',
          'checkOutAt': null,
          'attendanceDate': '2026-10-18',
          'isReplacement': true,
        },
      ]);

      final repo = AttendanceRepositoryImpl(remoteDataSource: fakeDataSource);
      final records = await repo.getMyHistory();

      expect(records.length, equals(3));

      // 1. Afternoon -> Shift Siang (NO "Dinas Shift afternoon")
      expect(records[0].title, equals('Shift Siang'));
      expect(records[0].title, isNot(contains('Dinas')));
      expect(records[0].title, isNot(contains('afternoon')));
      expect(records[0].location, isNot(equals('Klinik Pratama Amanah')));
      expect(records[0].validatedDurationHours, equals(7.0));
      expect(records[0].notes, equals('Izin dinas luar'));

      // 2. Night -> Shift Malam
      expect(records[1].title, equals('Shift Malam'));
      expect(records[1].title, isNot(contains('Dinas')));
      expect(records[1].title, isNot(contains('night')));

      // 3. Morning Replacement -> Shift Pagi (Pengganti)
      expect(records[2].title, equals('Shift Pagi (Pengganti)'));
      expect(records[2].checkOutAt, isNull);
    });
  });

  group('PresenceTimelineItem Widget', () {
    testWidgets(
      'renders shift title, date, day name, and both check-in/out milestones when present',
      (WidgetTester tester) async {
        final checkIn = DateTime(2026, 10, 20, 14, 0);
        final checkOut = DateTime(2026, 10, 20, 21, 30);

        final record = AttendanceRecord(
          id: 'rec-full',
          date: '20 Okt',
          dayNumber: 20,
          time: '14:00 WIB',
          title: 'Shift Siang',
          status: AttendanceStatus.hadir,
          isLatest: true,
          attendanceDate: DateTime(2026, 10, 20),
          checkInAt: checkIn,
          checkOutAt: checkOut,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PresenceTimelineItem(
                item: record,
                isLast: false,
                dark: false,
                textColor: Colors.black,
                subtextColor: Colors.grey,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Shift title
        expect(find.text('Shift Siang'), findsOneWidget);
        expect(find.textContaining('Dinas'), findsNothing);

        // Left date & dayName
        expect(find.text('20 Okt'), findsOneWidget);
        expect(find.text('Selasa'), findsOneWidget);

        // Milestone check-in & check-out
        expect(find.text('14:00 WIB Masuk'), findsOneWidget);
        expect(find.text('21:30 WIB Keluar'), findsOneWidget);

        // Must NOT contain dummy string
        expect(find.textContaining('Klinik Pratama Amanah'), findsNothing);
      },
    );

    testWidgets('renders check-in without check-out or dummy placeholder when check-out is null', (
      WidgetTester tester,
    ) async {
      final checkIn = DateTime(2026, 10, 18, 13, 40);

      final record = AttendanceRecord(
        id: 'rec-ongoing',
        date: '18 Okt',
        dayNumber: 18,
        time: '13:40 WIB',
        title: 'Shift Siang',
        status: AttendanceStatus.telat,
        isLatest: false,
        attendanceDate: DateTime(2026, 10, 18),
        checkInAt: checkIn,
        checkOutAt: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresenceTimelineItem(
              item: record,
              isLast: true,
              dark: false,
              textColor: Colors.black,
              subtextColor: Colors.grey,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shift Siang'), findsOneWidget);
      expect(find.text('18 Okt'), findsOneWidget);
      expect(find.text('13:40 WIB Masuk'), findsOneWidget);

      // Must NOT render check out or dummy text
      expect(find.textContaining('Keluar'), findsNothing);
      expect(find.textContaining('belum'), findsNothing);
      expect(find.textContaining('Klinik Pratama Amanah'), findsNothing);
    });
  });
}
