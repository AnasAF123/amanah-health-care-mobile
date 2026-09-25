import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_saver.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';

class _MockTokenStorage extends AmanahAuthTokenStorage {
  const _MockTokenStorage();
  @override
  Future<String?> getToken() async => 'test-token';
}

void main() {
  group('AmanahScheduleRepository - updateSchedule payload sanitization', () {
    test('Normalizes status to canonical OPEN/CLOSED and strips WIB from times',
        () async {
      late Map<String, dynamic> sentBody;
      final MockClient client = MockClient((http.Request request) async {
        if (request.method == 'PATCH' &&
            request.url.path.contains('/api/v1/schedules/sched-123')) {
          sentBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'id': 'sched-123',
              'title': 'Sesi Pagi',
              'date': '2026-09-25',
              'startTime': '08:00',
              'endTime': '12:00',
              'isAvailable': false,
              'status': 'closed',
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 200,
            headers: <String, String>{'content-type': 'application/json'});
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      await repo.updateSchedule(
        'sched-123',
        status: 'Tutup',
        startTime: '08:00 WIB',
        endTime: '12:00 WIB',
        roomId: 'Pilih Ruang Praktik',
        poliklinikId: 'Pilih Poliklinik',
        session: 'Dini Hari',
        isAvailable: false,
      );

      expect(sentBody['status'], 'CLOSED');
      expect(sentBody['startTime'], '08:00');
      expect(sentBody['endTime'], '12:00');
      expect(sentBody['isAvailable'], isFalse);
      expect(sentBody.containsKey('roomId'), isFalse);
      expect(sentBody.containsKey('poliklinikId'), isFalse);
      expect(sentBody['session'], 'DINI_HARI');
      expect(sentBody['sessionType'], 'Dini Hari');
    });

    test('Passes valid session enum for DINI_HARI, PAGI, SIANG, MALAM', () async {
      late Map<String, dynamic> sentBody;
      final MockClient client = MockClient((http.Request request) async {
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode(<String, dynamic>{
            'id': 'sched-456',
            'status': 'open',
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      await repo.updateSchedule(
        'sched-456',
        status: 'Buka',
        session: 'Pagi',
        isAvailable: true,
      );

      expect(sentBody['status'], 'OPEN');
      expect(sentBody['session'], 'PAGI');
      expect(sentBody['sessionType'], 'Pagi');
      expect(sentBody['isAvailable'], isTrue);
    });
  });

  group('AmanahScheduleStore - syncAll Integration', () {
    test('syncAll concurrently refreshes schedules, summary, day settings, and occupancy',
        () async {
      final List<String> requestedPaths = <String>[];
      final MockClient client = MockClient((http.Request request) async {
        requestedPaths.add(request.url.path);
        if (request.url.path.contains('my-schedules')) {
          return http.Response('[]', 200,
              headers: <String, String>{'content-type': 'application/json'});
        }
        if (request.url.path.contains('calendar-summary')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'month': '2026-09',
              'days': <dynamic>[],
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        if (request.url.path.contains('day-settings')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'targetQuota': 10,
              'isCuti': false,
              'status': 'OPEN',
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        if (request.url.path.contains('occupancy-overview')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'data': <String, dynamic>{
                'date': '2026-09-25',
                'intervals': <dynamic>[],
              },
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        return http.Response('[]', 200,
            headers: <String, String>{'content-type': 'application/json'});
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      final AmanahScheduleStore store = AmanahScheduleStore.instance;
      store.setRepository(repo);

      final DateTime targetDate = DateTime(2026, 9, 25);
      await store.syncAll(targetDate, forceRefresh: true);

      expect(
        requestedPaths.any((String p) => p.contains('my-schedules')),
        isTrue,
      );
      expect(
        requestedPaths.any((String p) => p.contains('calendar-summary')),
        isTrue,
      );
      expect(
        requestedPaths.any((String p) => p.contains('day-settings')),
        isTrue,
      );
      expect(
        requestedPaths.any((String p) => p.contains('occupancy-overview')),
        isTrue,
      );
    });
  });

  group('ScheduleFormSaver.save - Status change persistence and syncAll', () {
    testWidgets(
        'When editing with status Tutup, toggles availability to false, updates day status, and calls syncAll',
        (WidgetTester tester) async {
      final List<String> actions = <String>[];
      final MockClient client = MockClient((http.Request request) async {
        actions.add('${request.method} ${request.url.path}');
        if (request.method == 'PATCH' && request.url.path.contains('availability')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'id': 'sched-edit-1',
              'isAvailable': false,
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        if (request.method == 'PATCH' && request.url.path.contains('days/')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'success': true,
              'data': <String, dynamic>{'status': 'CLOSED'},
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        if (request.method == 'PATCH' && request.url.path.endsWith('/sched-edit-1')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'id': 'sched-edit-1',
              'status': 'closed',
              'isAvailable': false,
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        if (request.url.path.contains('my-schedules')) {
          return http.Response(
            jsonEncode(<dynamic>[
              <String, dynamic>{
                'id': 'sched-edit-1',
                'title': 'Sesi Pagi',
                'date': '2026-09-25',
                'startTime': '08:00',
                'endTime': '12:00',
                'isAvailable': false,
                'badge': 'Tutup',
                'status': 'closed',
              }
            ]),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 200,
            headers: <String, String>{'content-type': 'application/json'});
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      final AmanahScheduleStore store = AmanahScheduleStore.instance;
      store.setRepository(repo);

      final DoctorSchedule scheduleToEdit = DoctorSchedule(
        id: 'sched-edit-1',
        title: 'Sesi Pagi',
        date: '2026-09-25',
        time: '08:00 - 12:00 WIB',
        startTime: '08:00',
        endTime: '12:00',
        sessionType: 'Pagi',
        sessionShift: 'pagi',
        poli: 'Poli Umum',
        room: 'Ruang 101',
        slotCount: '0',
        slotText: '0 Pasien Booking',
        isAvailable: true,
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
      );

      DateTime? savedDate;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    await ScheduleFormSaver.save(
                      context: context,
                      selectedDate: DateTime(2026, 9, 25),
                      status: 'Tutup',
                      sessions: const <ScheduleFormSession>[],
                      rooms: const <ClinicRoomReference>[],
                      polis: const <ClinicPoliklinikReference>[],
                      scheduleToEdit: scheduleToEdit,
                      onSavedDate: (DateTime d) => savedDate = d,
                    );
                  },
                  child: const Text('Save'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedDate, DateTime(2026, 9, 25));
      expect(
        actions.any((String a) => a.contains('PATCH') && a.contains('availability')),
        isTrue,
      );
      expect(
        actions.any((String a) => a.contains('PATCH') && a.contains('days/2026-09-25')),
        isTrue,
      );
      expect(
        actions.any((String a) => a.contains('my-schedules')),
        isTrue,
      );
    });
  });
}
