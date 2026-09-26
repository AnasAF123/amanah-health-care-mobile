import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/schedule_tab_views/schedule_sessions_view.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/amanah_doctor_session_card.dart';

class _MockTokenStorage extends AmanahAuthTokenStorage {
  const _MockTokenStorage([this._token = 'test-token']);
  final String? _token;

  @override
  Future<String?> getToken() async => _token;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Doctor Daily Interval Slots & Session View Alignment Tests', () {
    // Generate synthetic backend response matching GET /api/v1/admin/doctor-schedules/:doctorId
    Map<String, dynamic> buildBackendAdminResponse({required String date}) {
      final List<Map<String, dynamic>> intervals = <Map<String, dynamic>>[];

      // 1. Early morning: 12 unscheduled past intervals
      for (int i = 0; i < 12; i++) {
        final int h = i ~/ 2;
        final int m = (i % 2) * 30;
        final int hNext = (i + 1) ~/ 2;
        final int mNext = ((i + 1) % 2) * 30;
        final String start =
            '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        final String end =
            '${hNext.toString().padLeft(2, '0')}:${mNext.toString().padLeft(2, '0')}';
        intervals.add(<String, dynamic>{
          'intervalId': 'early_morning:$start-$end',
          'slotId': 'early_morning:$start-$end',
          'startTime': start,
          'endTime': end,
          'timeRange': '$start - $end WIB',
          'availabilityState': 'UNSCHEDULED',
          'effectiveStatus': 'UNSCHEDULED',
          'temporalState': 'PAST',
          'uiStatus': 'UNSCHEDULED_PAST',
          'uiLabel': 'Belum Terjadwal',
          'sessionId': null,
        });
      }

      // 2. Morning: 12 intervals (9 PAST, 1 CURRENT, 1 CLOSED_CLINIC, 1 FUTURE)
      for (int i = 0; i < 12; i++) {
        final int totalM = 6 * 60 + i * 30;
        final int startH = totalM ~/ 60;
        final int startMin = totalM % 60;
        final int endM = totalM + 30;
        final int endH = endM ~/ 60;
        final int endMin = endM % 60;
        final String start =
            '${startH.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}';
        final String end =
            '${endH.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';

        if (i < 9) {
          // Past morning slots (06:00 - 10:30)
          intervals.add(<String, dynamic>{
            'intervalId': 'morning:$start-$end',
            'slotId': 'morning:$start-$end',
            'startTime': start,
            'endTime': end,
            'timeRange': '$start - $end WIB',
            'availabilityState': 'AVAILABLE',
            'effectiveStatus': 'EXPIRED',
            'temporalState': 'PAST',
            'uiStatus': 'COMPLETED',
            'uiLabel': 'Selesai',
            'sessionId': 'session-morning-macro',
          });
        } else if (i == 9) {
          // Current slot (10:30 - 11:00)
          intervals.add(<String, dynamic>{
            'intervalId': 'morning:$start-$end',
            'slotId': 'morning:$start-$end',
            'startTime': start,
            'endTime': end,
            'timeRange': '$start - $end WIB',
            'availabilityState': 'AVAILABLE',
            'effectiveStatus': 'AVAILABLE',
            'temporalState': 'CURRENT',
            'uiStatus': 'AVAILABLE',
            'uiLabel': 'Tersedia',
            'sessionId': 'session-morning-macro',
          });
        } else if (i == 10) {
          // Closed clinic slot (11:00 - 11:30)
          intervals.add(<String, dynamic>{
            'intervalId': 'morning:$start-$end',
            'slotId': 'morning:$start-$end',
            'startTime': start,
            'endTime': end,
            'timeRange': '$start - $end WIB',
            'availabilityState': 'CLOSED',
            'effectiveStatus': 'CLOSED',
            'temporalState': 'FUTURE',
            'uiStatus': 'CLOSED_CLINIC',
            'uiLabel': 'Ditutup: Rapat Koordinasi Komite Medik',
            'sessionId': 'session-morning-macro',
            'closureInfo': <String, dynamic>{
              'reasonText': 'Rapat Koordinasi Komite Medik',
              'category': 'OTHER',
            },
          });
        } else {
          // Future slot (11:30 - 12:00)
          intervals.add(<String, dynamic>{
            'intervalId': 'morning:$start-$end',
            'slotId': 'morning:$start-$end',
            'startTime': start,
            'endTime': end,
            'timeRange': '$start - $end WIB',
            'availabilityState': 'AVAILABLE',
            'effectiveStatus': 'AVAILABLE',
            'temporalState': 'FUTURE',
            'uiStatus': 'AVAILABLE',
            'uiLabel': 'Tersedia',
            'sessionId': 'session-morning-macro',
          });
        }
      }

      // 3. Afternoon: 12 intervals (all FUTURE AVAILABLE)
      for (int i = 0; i < 12; i++) {
        final int totalM = 12 * 60 + i * 30;
        final int startH = totalM ~/ 60;
        final int startMin = totalM % 60;
        final int endM = totalM + 30;
        final int endH = endM ~/ 60;
        final int endMin = endM % 60;
        final String start =
            '${startH.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}';
        final String end =
            '${endH.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
        intervals.add(<String, dynamic>{
          'intervalId': 'afternoon:$start-$end',
          'slotId': 'afternoon:$start-$end',
          'startTime': start,
          'endTime': end,
          'timeRange': '$start - $end WIB',
          'availabilityState': 'AVAILABLE',
          'effectiveStatus': 'AVAILABLE',
          'temporalState': 'FUTURE',
          'uiStatus': 'AVAILABLE',
          'uiLabel': 'Tersedia',
          'sessionId': 'session-afternoon-macro',
        });
      }

      // 4. Night: 12 intervals (2 FUTURE AVAILABLE: 19:00 & 20:00, 10 UNSCHEDULED)
      for (int i = 0; i < 12; i++) {
        final int totalM = 18 * 60 + i * 30;
        final int startH = totalM ~/ 60;
        final int startMin = totalM % 60;
        final int endM = totalM + 30;
        final int endH = endM ~/ 60;
        final int endMin = endM % 60;
        final String start =
            '${startH.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}';
        final String end =
            '${endH.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';

        if (start == '19:00') {
          intervals.add(<String, dynamic>{
            'intervalId': 'night:$start-$end',
            'slotId': 'night:$start-$end',
            'startTime': start,
            'endTime': end,
            'timeRange': '$start - $end WIB',
            'availabilityState': 'AVAILABLE',
            'effectiveStatus': 'AVAILABLE',
            'temporalState': 'FUTURE',
            'uiStatus': 'AVAILABLE',
            'uiLabel': 'Tersedia',
            'sessionId': 'session-night-1',
          });
        } else if (start == '20:00') {
          intervals.add(<String, dynamic>{
            'intervalId': 'night:$start-$end',
            'slotId': 'night:$start-$end',
            'startTime': start,
            'endTime': end,
            'timeRange': '$start - $end WIB',
            'availabilityState': 'AVAILABLE',
            'effectiveStatus': 'AVAILABLE',
            'temporalState': 'FUTURE',
            'uiStatus': 'AVAILABLE',
            'uiLabel': 'Tersedia',
            'sessionId': 'session-night-2',
          });
        } else {
          intervals.add(<String, dynamic>{
            'intervalId': 'night:$start-$end',
            'slotId': 'night:$start-$end',
            'startTime': start,
            'endTime': end,
            'timeRange': '$start - $end WIB',
            'availabilityState': 'UNSCHEDULED',
            'effectiveStatus': 'UNSCHEDULED',
            'temporalState': 'FUTURE',
            'uiStatus': 'UNSCHEDULED',
            'uiLabel': 'Belum Terjadwal',
            'sessionId': null,
          });
        }
      }

      return <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'id': 'doctor-uuid',
          'practitioner_id': 'doctor-uuid',
          'nama_dokter': 'dr. Ahmadamikom Zikri',
          'spesialisasi': 'Spesialis Penyakit Dalam',
          'ruang_praktik': 'Ruang Praktik 1',
          'timeline_intervals': intervals,
        },
      };
    }

    test('fetchDoctorDailyIntervalSlots parses exactly 17 active cards (excludes 22 unscheduled & 9 expired)', () async {
      final Map<String, dynamic> adminData =
          buildBackendAdminResponse(date: '2026-09-26');

      final MockClient client = MockClient((http.Request request) async {
        if (request.url.path.contains('/api/v1/admin/doctor-schedules/')) {
          return http.Response(jsonEncode(adminData), 200, headers: <String, String>{
            'content-type': 'application/json; charset=utf-8',
          });
        }
        return http.Response('{"error":"not found"}', 404);
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://api.amanah.id',
        tokenStorage: const _MockTokenStorage(),
        httpClient: client,
      );

      final List<DoctorSchedule> slots =
          await repo.fetchDoctorDailyIntervalSlots(
        doctorId: 'doctor-uuid',
        date: '2026-09-26',
      );

      // Exactly 17 slots: 3 pagi, 12 siang, 2 malam
      expect(slots.length, 17);

      final List<DoctorSchedule> pagi =
          slots.where((DoctorSchedule s) => s.sessionShift == 'morning').toList();
      final List<DoctorSchedule> siang =
          slots.where((DoctorSchedule s) => s.sessionShift == 'afternoon').toList();
      final List<DoctorSchedule> malam =
          slots.where((DoctorSchedule s) => s.sessionShift == 'night').toList();

      expect(pagi.length, 3);
      expect(siang.length, 12);
      expect(malam.length, 2);

      // Check slot 10:30 (Tersedia)
      expect(pagi[0].startTime, '10:30');
      expect(pagi[0].badge, 'Buka');
      expect(pagi[0].badgeVariant, AmanahBadgeVariant.success);
      expect(pagi[0].isAvailable, isTrue);

      // Check slot 11:00 (Ditutup: Rapat Koordinasi Komite Medik)
      expect(pagi[1].startTime, '11:00');
      expect(pagi[1].badge, 'Tutup');
      expect(pagi[1].badgeVariant, AmanahBadgeVariant.warning);
      expect(pagi[1].isAvailable, isFalse);
      expect(pagi[1].notes, 'Rapat Koordinasi Komite Medik');

      // Check slot 11:30 (Tersedia)
      expect(pagi[2].startTime, '11:30');
      expect(pagi[2].badge, 'Buka');
      expect(pagi[2].badgeVariant, AmanahBadgeVariant.success);

      // Verify night slots
      expect(malam[0].startTime, '19:00');
      expect(malam[1].startTime, '20:00');
    });

    testWidgets('AmanahScheduleSessionsView renders 17 cards when provided 17 interval slots', (WidgetTester tester) async {
      final Map<String, dynamic> adminData =
          buildBackendAdminResponse(date: '2026-09-26');

      final MockClient client = MockClient((http.Request request) async {
        return http.Response(jsonEncode(adminData), 200, headers: <String, String>{
          'content-type': 'application/json; charset=utf-8',
        });
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://api.amanah.id',
        tokenStorage: const _MockTokenStorage(),
        httpClient: client,
      );

      final List<DoctorSchedule> intervalSlots =
          await repo.fetchDoctorDailyIntervalSlots(
        doctorId: 'doctor-uuid',
        date: '2026-09-26',
      );

      final DayScheduleSetting daySetting = DayScheduleSetting(
        scheduleDate: '2026-09-26',
        targetQuota: 8,
        isCuti: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AmanahScheduleSessionsView(
                selectedDate: DateTime(2026, 9, 26),
                daySetting: daySetting,
                isCuti: false,
                schedules: intervalSlots,
                dark: false,
                onTapDetail: (_) {},
                onTapEdit: (_) {},
                onTapDelete: (_) {},
                onOpenAddSchedule: () {},
              ),
            ),
          ),
        ),
      );

      // 17 cards must be rendered
      expect(find.byType(AmanahDoctorSessionCard), findsNWidgets(17));

      // Slot 10:30, 11:00, 11:30, 19:00, 20:00 are rendered
      expect(find.text('10:30'), findsWidgets);
      expect(find.text('11:00'), findsWidgets);
      expect(find.text('11:30'), findsWidgets);
      expect(find.text('19:00'), findsWidgets);
      expect(find.text('20:00'), findsWidgets);

      // Unscheduled slots like 00:00 or 18:30 (which is unscheduled at night) are NOT rendered
      expect(find.text('00:00'), findsNothing);
      expect(find.text('18:30'), findsNothing);
    });
  });
}
