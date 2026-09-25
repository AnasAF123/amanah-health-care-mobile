import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class _MockTokenStorage extends AmanahAuthTokenStorage {
  const _MockTokenStorage();
  final String _token = 'test-token';

  @override
  Future<String?> getToken() async => _token;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<String, dynamic> sampleBootstrapJson = <String, dynamic>{
    'doctor': <String, dynamic>{
      'id': 'doc-123',
      'name': 'drg. Sarah Jenkins, Sp.KG',
      'defaultRoomId': 'room-01',
      'defaultRoomName': 'Ruang Poli Gigi 1',
      'defaultPoliklinikId': 'poli-01',
      'defaultPoliklinikName': 'Poli Gigi & Mulut',
    },
    'rooms': <dynamic>[
      <String, dynamic>{
        'id': 'room-01',
        'name': 'Ruang Poli Gigi 1',
        'isOccupied': false,
      },
      <String, dynamic>{
        'id': 'room-02',
        'name': 'Ruang Poli Gigi 2',
        'isOccupied': true,
      },
    ],
    'polikliniks': <dynamic>[
      <String, dynamic>{
        'id': 'poli-01',
        'name': 'Poli Gigi & Mulut',
      },
    ],
    'shifts': <dynamic>[
      <String, dynamic>{
        'id': 'pagi',
        'code': 'PAGI',
        'name': 'Sesi Pagi',
        'startTime': '08:00',
        'endTime': '11:30',
        'isPast': false,
        'existingSchedule': <String, dynamic>{
          'id': 'sched-existing-1',
          'startTime': '08:00',
          'endTime': '11:00',
          'status': 'Buka',
          'roomName': 'Ruang Poli Gigi 1',
        },
      },
      <String, dynamic>{
        'id': 'siang',
        'code': 'SIANG',
        'name': 'Sesi Siang',
        'startTime': '13:00',
        'endTime': '16:30',
        'isPast': false,
      },
    ],
  };

  final Map<String, dynamic> sampleAvailabilityJson = <String, dynamic>{
    'date': '2026-09-25',
    'shift': 'pagi',
    'roomId': 'room-01',
    'slots': <dynamic>[
      <String, dynamic>{
        'slotIndex': 0,
        'time': '08:00',
        'endTime': '08:30',
        'status': 'AVAILABLE',
        'isAvailable': true,
        'displayLabel': '08:00 - 08:30',
      },
      <String, dynamic>{
        'slotIndex': 1,
        'time': '08:30',
        'endTime': '09:00',
        'status': 'OCCUPIED_BY_OTHER',
        'isAvailable': false,
        'displayLabel': '08:30 - 09:00 (Terisi)',
        'conflict': <String, dynamic>{
          'type': 'ROOM_OCCUPIED',
          'occupantName': 'drg. Budi Santoso',
          'reason': 'Ruangan digunakan oleh drg. Budi Santoso',
        },
      },
    ],
  };

  group('ScheduleFormBootstrapData & ScheduleSlotAvailabilityData DTOs', () {
    test('ScheduleFormBootstrapData deserializes doctor defaults, rooms, and shifts', () {
      final ScheduleFormBootstrapData data =
          ScheduleFormBootstrapData.fromJson(sampleBootstrapJson);

      expect(data.doctor.defaultRoomId, 'room-01');
      expect(data.doctor.defaultRoomName, 'Ruang Poli Gigi 1');
      expect(data.doctor.defaultPoliklinikId, 'poli-01');
      expect(data.doctor.defaultPoliklinikName, 'Poli Gigi & Mulut');

      expect(data.rooms.length, 2);
      expect(data.rooms[0].name, 'Ruang Poli Gigi 1');
      expect(data.rooms[1].isOccupied, isTrue);

      expect(data.polikliniks.length, 1);
      expect(data.polikliniks[0].name, 'Poli Gigi & Mulut');

      expect(data.shifts.length, 2);
      expect(data.shifts[0].id, 'pagi');
      expect(data.shifts[0].isPast, isFalse);
      expect(data.shifts[0].existingSchedule?.id, 'sched-existing-1');
      expect(data.shifts[0].existingSchedule?.startTime, '08:00');
    });

    test('ScheduleSlotAvailabilityData deserializes slots with status and conflict metadata', () {
      final ScheduleSlotAvailabilityData data =
          ScheduleSlotAvailabilityData.fromJson(sampleAvailabilityJson);

      expect(data.date, '2026-09-25');
      expect(data.shift, 'pagi');
      expect(data.roomId, 'room-01');
      expect(data.slots.length, 2);

      final ScheduleSlotAvailabilityItem slot0 = data.slots[0];
      expect(slot0.time, '08:00');
      expect(slot0.status, 'AVAILABLE');
      expect(slot0.isAvailable, isTrue);
      expect(slot0.conflict, isNull);

      final ScheduleSlotAvailabilityItem slot1 = data.slots[1];
      expect(slot1.time, '08:30');
      expect(slot1.status, 'OCCUPIED_BY_OTHER');
      expect(slot1.isAvailable, isFalse);
      expect(slot1.conflict?.occupantName, 'drg. Budi Santoso');
      expect(slot1.conflict?.reason, contains('drg. Budi Santoso'));
    });
  });

  group('AmanahScheduleRepository - Form Bootstrap & Slot Availability Endpoints', () {
    test('fetchFormBootstrap sends correct query parameters and decodes response', () async {
      final MockClient client = MockClient((http.Request request) async {
        expect(request.url.path, '/api/v1/schedules/form-bootstrap');
        expect(request.url.queryParameters['date'], '2026-09-25');
        expect(request.url.queryParameters['scheduleId'], 'sched-edit-55');
        return http.Response(jsonEncode(sampleBootstrapJson), 200);
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      final ScheduleFormBootstrapData result = await repo.fetchFormBootstrap(
        date: '2026-09-25',
        scheduleId: 'sched-edit-55',
      );

      expect(result.doctor.name, 'drg. Sarah Jenkins, Sp.KG');
      expect(result.rooms.first.id, 'room-01');
    });

    test('fetchSlotAvailability sends correct query parameters and decodes response', () async {
      final MockClient client = MockClient((http.Request request) async {
        expect(request.url.path, '/api/v1/schedules/slot-availability');
        expect(request.url.queryParameters['date'], '2026-09-25');
        expect(request.url.queryParameters['shift'], 'pagi');
        expect(request.url.queryParameters['roomId'], 'room-01');
        return http.Response(jsonEncode(sampleAvailabilityJson), 200);
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      final ScheduleSlotAvailabilityData result = await repo.fetchSlotAvailability(
        date: '2026-09-25',
        shift: 'pagi',
        roomId: 'room-01',
      );

      expect(result.slots.length, 2);
      expect(result.slots[1].conflict?.type, 'ROOM_OCCUPIED');
    });
  });

  group('AmanahScheduleStore - Bootstrap & Slot Availability Integration', () {
    test('loadFormBootstrap and loadSlotAvailability populate store projections', () async {
      final MockClient client = MockClient((http.Request request) async {
        if (request.url.path.contains('form-bootstrap')) {
          return http.Response(jsonEncode(sampleBootstrapJson), 200);
        }
        if (request.url.path.contains('slot-availability')) {
          return http.Response(jsonEncode(sampleAvailabilityJson), 200);
        }
        return http.Response('{"error": "not found"}', 404);
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      final AmanahScheduleStore store = AmanahScheduleStore.instance;
      store.setRepository(repo);

      final ScheduleFormBootstrapData? bootstrap = await store.loadFormBootstrap(
        date: DateTime(2026, 9, 25),
      );

      expect(bootstrap, isNotNull);
      expect(store.formBootstrap?.doctor.defaultRoomName, 'Ruang Poli Gigi 1');

      final ScheduleSlotAvailabilityData? availability = await store.loadSlotAvailability(
        date: DateTime(2026, 9, 25),
        shift: 'pagi',
        roomId: 'room-01',
      );

      expect(availability, isNotNull);
      expect(store.slotAvailability?.shift, 'pagi');
      expect(store.slotAvailability?.slots.length, 2);
    });
  });
}
