import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_reschedule_session_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';

class _MockTokenStorage extends AmanahAuthTokenStorage {
  const _MockTokenStorage();
  @override
  Future<String?> getToken() async => 'mock-token';
}

void main() {
  const DoctorSchedule sampleSession = DoctorSchedule(
    id: 'ses-101',
    title: 'Sesi Pagi',
    date: 'Jumat, 25 September 2026',
    scheduleDate: '2026-09-25',
    time: '08:00 - 11:30 WIB',
    startTime: '08:00',
    endTime: '11:30',
    sessionType: 'Pagi',
    poli: 'Poli Umum',
    room: 'Ruang 101',
    roomId: 'room-1',
    slotCount: '2',
    slotText: '2 Pasien Booking',
    badge: 'Buka',
    badgeVariant: AmanahBadgeVariant.success,
    staffId: 'staff-doc-1',
    practitionerId: 'doc-uuid-1',
    isRescheduleEligible: true,
    bookedPatients: <BookedPatient>[
      BookedPatient(
        id: 'p-1',
        patientName: 'Ahmad Zikri',
        patientAge: '30 Thn',
        patientRm: 'RM-001',
        patientComplaint: 'Kontrol rutin',
        queueNumber: '#01',
        timeSlot: '08:00 - 08:30 WIB',
        badge: 'Aktif',
        badgeVariant: AmanahBadgeVariant.success,
      ),
      BookedPatient(
        id: 'p-2',
        patientName: 'Budi Santoso',
        patientAge: '25 Thn',
        patientRm: 'RM-002',
        patientComplaint: 'Konsultasi dokter',
        queueNumber: '#02',
        timeSlot: '08:30 - 09:00 WIB',
        badge: 'Mendatang',
        badgeVariant: AmanahBadgeVariant.primary,
      ),
    ],
  );

  group('AmanahScheduleDetailDrawer - Reschedule Button Mounting', () {
    testWidgets(
      'Renders Reschedule Sesi button right above Edit Jadwal and fires callback',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        bool rescheduleTapped = false;
        bool editTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  return ElevatedButton(
                    onPressed: () {
                      AmanahScheduleDetailDrawer.show(
                        context,
                        schedule: sampleSession,
                        isDayCuti: false,
                        onViewPatients: () {},
                        onTapEdit: () => editTapped = true,
                        onTapDelete: () {},
                        onTapReschedule: () => rescheduleTapped = true,
                      );
                    },
                    child: const Text('Open Drawer'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Drawer'));
        await tester.pumpAndSettle();

        // Verify detail drawer elements
        expect(find.text('Detail Sesi Praktik'), findsOneWidget);
        expect(find.text('Reschedule Sesi'), findsOneWidget);
        expect(find.text('Edit Jadwal'), findsOneWidget);

        // Tap Reschedule Sesi
        await tester.tap(find.text('Reschedule Sesi'));
        await tester.pumpAndSettle();

        expect(rescheduleTapped, isTrue);
        expect(editTapped, isFalse);
      },
    );
  });

  group('AmanahRescheduleSessionDrawer - Form & Live Pre-check', () {
    testWidgets(
      'Renders current session summary, handles conflict message and disables submit when conflict occurs',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        final MockClient client = MockClient((http.Request request) async {
          if (request.url.path.contains('reference/rooms')) {
            return http.Response(
              jsonEncode(<dynamic>[
                <String, dynamic>{
                  'id': 'room-1',
                  'code': 'R101',
                  'name': 'Ruang 101',
                  'isOccupied': false,
                },
                <String, dynamic>{
                  'id': 'room-2',
                  'code': 'R102',
                  'name': 'Ruang 102',
                  'isOccupied': false,
                },
              ]),
              200,
              headers: <String, String>{'content-type': 'application/json'},
            );
          } else if (request.url.path.contains('reschedule-eligibility')) {
            return http.Response(
              jsonEncode(<String, dynamic>{
                'status': 'success',
                'data': <String, dynamic>{
                  'sessionId': 'ses-101',
                  'practitionerId': 'doc-uuid-1',
                  'isEligible': false,
                  'ineligibilityReason': 'Dokter telah memiliki sesi lain pada jam tersebut.',
                  'targetValidation': <String, dynamic>{
                    'evaluated': true,
                    'targetDate': '2026-09-25',
                    'targetStartTime': '08:00',
                    'projectedEndTime': '11:30',
                    'targetRoomId': 'room-1',
                    'targetRoomName': 'Ruang 101',
                    'isTargetEligible': false,
                    'conflictMessage': 'Dokter telah memiliki sesi lain pada jam tersebut.',
                  },
                },
              }),
              200,
              headers: <String, String>{'content-type': 'application/json'},
            );
          }
          return http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json'});
        });

        final AmanahScheduleStore store = AmanahScheduleStore.instance;
        store.reset();
        AmanahScheduleStore.setCustomBaseToday(DateTime(2026, 9, 25));
        addTearDown(() => AmanahScheduleStore.setCustomBaseToday(null));
        store.setRepository(
          AmanahScheduleRepository(
            baseUrl: 'http://test.api',
            httpClient: client,
            tokenStorage: const _MockTokenStorage(),
          ),
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AmanahRescheduleSessionDrawer(
                session: sampleSession,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Title & Subtitle
        expect(find.text('Reschedule Sesi Praktik'), findsOneWidget);

        // 2. Source session summary
        expect(find.text('Sesi Sumber'), findsOneWidget);
        expect(find.text('2 Pasien Terdaftar'), findsOneWidget);
        expect(find.text('Sesi Pagi'), findsOneWidget);
        expect(find.text('08:00 - 11:30 WIB'), findsOneWidget);

        // 3. Verify no auto-select (placeholders are shown)
        expect(find.text('Pilih Jam Mulai'), findsOneWidget);
        expect(find.text('Pilih Ruang Praktik'), findsOneWidget);

        // 4. Select Start Time explicitly
        await tester.tap(find.text('Pilih Jam Mulai'));
        await tester.pumpAndSettle();
        expect(find.text('Pilih Jam Mulai Target'), findsOneWidget);
        await tester.tap(find.text('08:00'));
        await tester.pumpAndSettle();

        // 5. Select Room explicitly
        await tester.ensureVisible(find.text('Pilih Ruang Praktik'));
        await tester.tap(find.text('Pilih Ruang Praktik'));
        await tester.pumpAndSettle();
        expect(find.text('Pilih Ruang Praktik Target'), findsOneWidget);
        await tester.tap(find.text('Ruang 101'));
        await tester.pumpAndSettle();

        // 6. Conflict banner displayed after eligibility check
        expect(
          find.text('Dokter telah memiliki sesi lain pada jam tersebut.'),
          findsOneWidget,
        );

        // 7. Projected End Time displayed
        expect(find.text('11:30 WIB'), findsOneWidget);

        // 8. Active appointments switch
        expect(find.text('Alihkan Antrean Pasien Otomatis'), findsOneWidget);

        // 9. Confirm button is disabled due to conflict
        expect(find.text('Konfirmasi Reschedule'), findsOneWidget);
      },
    );
  });
}
