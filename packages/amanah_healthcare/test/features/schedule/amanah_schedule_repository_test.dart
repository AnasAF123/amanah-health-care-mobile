import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class _MockTokenStorage extends AmanahAuthTokenStorage {
  const _MockTokenStorage([this._token = 'test-bearer-token-123']);
  final String? _token;

  @override
  Future<String?> getToken() async => _token;
}

void main() {
  group('AmanahScheduleRepository - Authentication & Headers', () {
    test('Injects Authorization Bearer token into headers when token exists', () async {
      late http.Request capturedRequest;
      final MockClient client = MockClient((http.Request request) async {
        capturedRequest = request;
        return http.Response('[]', 200, headers: <String, String>{'content-type': 'application/json'});
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage('jwt-token-xyz'),
      );

      await repo.fetchMySchedules(date: '2026-08-26');

      expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token-xyz');
      expect(capturedRequest.headers['Content-Type'], 'application/json');
      expect(capturedRequest.headers['Accept'], 'application/json');
    });

    test('Omits Authorization header when token is null or empty', () async {
      late http.Request capturedRequest;
      final MockClient client = MockClient((http.Request request) async {
        capturedRequest = request;
        return http.Response('[]', 200, headers: <String, String>{'content-type': 'application/json'});
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(null),
      );

      await repo.fetchMySchedules(date: '2026-08-26');

      expect(capturedRequest.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('AmanahScheduleRepository - Error Handling & 409 Conflict Exceptions', () {
    test('Throws AmanahScheduleConflictException with SCHEDULE_HAS_ACTIVE_BOOKINGS on HTTP 409', () async {
      final MockClient client = MockClient((http.Request request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'statusCode': 409,
            'code': 'SCHEDULE_HAS_ACTIVE_BOOKINGS',
            'message': 'Jadwal memiliki 3 pasien terdaftar yang masih aktif.',
          }),
          409,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      try {
        await repo.deleteSchedule('sched-active-123');
        fail('Expected AmanahScheduleConflictException to be thrown');
      } on AmanahScheduleConflictException catch (e) {
        expect(e.code, 'SCHEDULE_HAS_ACTIVE_BOOKINGS');
        expect(e.hasActiveBookings, isTrue);
        expect(e.message, contains('3 pasien'));
      }
    });

    test('Throws AmanahScheduleConflictException with ROOM_ALREADY_OCCUPIED on HTTP 409', () async {
      final MockClient client = MockClient((http.Request request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'statusCode': 409,
            'code': 'ROOM_ALREADY_OCCUPIED',
            'message': 'Ruangan telah dipakai oleh dokter lain pada jam tersebut.',
          }),
          409,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      try {
        await repo.createSchedule(
          date: '2026-08-26',
          session: 'Pagi',
          startTime: '08:00',
          endTime: '11:00',
          roomId: 'room-101',
        );
        fail('Expected AmanahScheduleConflictException to be thrown');
      } on AmanahScheduleConflictException catch (e) {
        expect(e.code, 'ROOM_ALREADY_OCCUPIED');
        expect(e.isRoomOccupied, isTrue);
      }
    });

    test('Throws AmanahScheduleException with UNAUTHORIZED on HTTP 401', () async {
      final MockClient client = MockClient((http.Request request) async {
        return http.Response('{"message": "Unauthorized"}', 401);
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      expect(
        () => repo.fetchMySchedules(),
        throwsA(isA<AmanahScheduleException>().having((AmanahScheduleException e) => e.code, 'code', 'UNAUTHORIZED')),
      );
    });

    test('Throws AmanahScheduleException with FORBIDDEN on HTTP 403', () async {
      final MockClient client = MockClient((http.Request request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'code': 'FORBIDDEN_DOCTOR_ACCESS',
            'message': 'Anda tidak berhak mengakses jadwal dokter lain.',
          }),
          403,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      expect(
        () => repo.fetchBookedPatients(scheduleId: 'other-doc-schedule'),
        throwsA(isA<AmanahScheduleException>().having((AmanahScheduleException e) => e.code, 'code', 'FORBIDDEN_DOCTOR_ACCESS')),
      );
    });
  });

  group('AmanahScheduleRepository - CRUD Endpoints & Serialization', () {
    test('fetchMySchedules successfully decodes backend JSON response', () async {
      final MockClient client = MockClient((http.Request request) async {
        expect(request.url.queryParameters['date'], '2026-08-26');
        return http.Response(
          jsonEncode(<dynamic>[
            <String, dynamic>{
              'id': 'sched-uuid-001',
              'scheduleDate': '2026-08-26',
              'sessionShift': 'morning',
              'sessionLabel': 'Pagi',
              'startTime': '08:00',
              'endTime': '12:00',
              'timeRange': '08:00 - 12:00 WIB',
              'poliklinikId': 'poli-01',
              'poliklinikName': 'Poli Gigi & Mulut',
              'roomId': 'room-201',
              'roomName': 'Ruang 201',
              'capacity': 10,
              'bookedPatientCount': 2,
              'isAvailable': true,
              'status': 'Buka',
              'bookedPatients': <dynamic>[
                <String, dynamic>{
                  'id': 'pt-1',
                  'appointmentId': 'apt-1',
                  'fullName': 'Ahmad Dahlan',
                  'medicalRecordNumber': 'RM-2026-001',
                  'age': '30 Thn',
                  'complaint': 'Pemeriksaan rutin gigi',
                  'queueNumber': '#01',
                  'timeSlot': '08:30 - 09:00 WIB',
                  'status': 'checked_in',
                  'statusBadge': 'Check In',
                },
              ],
            },
          ]),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      final List<DoctorSchedule> schedules = await repo.fetchMySchedules(date: '2026-08-26');
      expect(schedules.length, 1);
      expect(schedules.first.id, 'sched-uuid-001');
      expect(schedules.first.title, 'Sesi Pagi');
      expect(schedules.first.poli, 'Poli Gigi & Mulut');
      expect(schedules.first.room, 'Ruang 201');
      expect(schedules.first.bookedPatients.length, 1);
      expect(schedules.first.bookedPatients.first.patientName, 'Ahmad Dahlan');
      expect(schedules.first.bookedPatients.first.patientRm, 'RM-2026-001');
    });

    test('fetchCalendarSummary successfully decodes month summary', () async {
      final MockClient client = MockClient((http.Request request) async {
        expect(request.url.queryParameters['month'], '2026-08');
        return http.Response(
          jsonEncode(<String, dynamic>{
            'month': '2026-08',
            'days': <dynamic>[
              <String, dynamic>{
                'date': '2026-08-26',
                'hasSchedule': true,
                'isCuti': false,
                'sessionCount': 2,
                'targetQuota': 8,
                'bookedPatientCount': 4,
                'capacityPercentage': 50,
              },
              <String, dynamic>{
                'date': '2026-08-30',
                'hasSchedule': false,
                'isCuti': true,
                'cutiReason': 'Hari Libur',
                'sessionCount': 0,
                'targetQuota': 0,
                'bookedPatientCount': 0,
                'capacityPercentage': 0,
              },
            ],
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

      final CalendarSummaryResponse summary = await repo.fetchCalendarSummary('2026-08');
      expect(summary.month, '2026-08');
      expect(summary.days.length, 2);
      expect(summary.days.first.date, '2026-08-26');
      expect(summary.days.first.capacityPercentage, 50);
      expect(summary.days.last.isCuti, isTrue);
      expect(summary.days.last.cutiReason, 'Hari Libur');
    });

    test('createSchedule sends correct POST payload and decodes response', () async {
      late Map<String, dynamic> sentPayload;
      final MockClient client = MockClient((http.Request request) async {
        expect(request.method, 'POST');
        sentPayload = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode(<String, dynamic>{
            'id': 'sched-created-789',
            'scheduleDate': '2026-08-27',
            'sessionShift': 'afternoon',
            'sessionLabel': 'Siang',
            'startTime': '13:00',
            'endTime': '17:00',
            'timeRange': '13:00 - 17:00 WIB',
            'poliklinikId': 'poli-konservasi',
            'poliklinikName': 'Klinik Spesialis Konservasi',
            'roomId': 'room-204',
            'roomName': 'Ruang 204',
            'capacity': 8,
            'bookedPatientCount': 0,
            'isAvailable': true,
            'status': 'Buka',
          }),
          201,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      final DoctorSchedule created = await repo.createSchedule(
        date: '2026-08-27',
        session: 'Siang',
        startTime: '13:00',
        endTime: '17:00',
        roomId: 'room-204',
        poliklinikId: 'poli-konservasi',
        capacity: 8,
      );

      expect(sentPayload['date'], '2026-08-27');
      expect(sentPayload['session'], 'SIANG');
      expect(sentPayload['startTime'], '13:00');
      expect(sentPayload['endTime'], '17:00');
      expect(sentPayload['roomId'], 'room-204');
      expect(created.id, 'sched-created-789');
      expect(created.title, 'Sesi Siang');
      expect(created.poli, 'Klinik Spesialis Konservasi');
    });

    test('fetchReferenceRooms and fetchReferencePolikliniks successfully decode', () async {
      final MockClient client = MockClient((http.Request request) async {
        if (request.url.path.contains('reference/rooms')) {
          return http.Response(
            jsonEncode(<dynamic>[
              <String, dynamic>{
                'id': 'room-1',
                'code': 'R101',
                'name': 'Ruang 101',
                'isOccupied': true,
                'occupiedBy': 'dr. Pratama',
              },
              <String, dynamic>{
                'id': 'room-2',
                'code': 'R201',
                'name': 'Ruang 201',
                'isOccupied': false,
              },
            ]),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        } else {
          return http.Response(
            jsonEncode(<dynamic>[
              <String, dynamic>{
                'id': 'poli-1',
                'code': 'P-GIGI',
                'name': 'Poli Gigi & Mulut',
              },
            ]),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      final List<ClinicRoomReference> rooms = await repo.fetchReferenceRooms(date: '2026-08-26');
      expect(rooms.length, 2);
      expect(rooms.first.isOccupied, isTrue);
      expect(rooms.first.occupiedBy, 'dr. Pratama');
      expect(rooms.last.isOccupied, isFalse);

      final List<ClinicPoliklinikReference> polis = await repo.fetchReferencePolikliniks();
      expect(polis.length, 1);
      expect(polis.first.name, 'Poli Gigi & Mulut');
    });

    test('fetchReferenceOptions successfully decodes shifts, statuses, and intervals', () async {
      final MockClient client = MockClient((http.Request request) async {
        expect(request.url.path, '/api/v1/schedules/reference/options');
        return http.Response(
          jsonEncode(<String, dynamic>{
            'shifts': <dynamic>[
              <String, dynamic>{
                'id': 'PAGI',
                'label': 'Pagi',
                'shift': 'morning',
                'startTime': '07:00',
                'endTime': '12:00',
              },
              <String, dynamic>{
                'id': 'SIANG',
                'label': 'Siang',
                'shift': 'afternoon',
                'startTime': '12:00',
                'endTime': '17:00',
              },
            ],
            'statuses': <dynamic>[
              <String, dynamic>{'id': 'open', 'label': 'Buka'},
              <String, dynamic>{'id': 'closed', 'label': 'Tutup'},
            ],
            'timeSlotIntervals': <int>[15, 30, 45, 60],
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

      final ClinicScheduleOptionsReference options = await repo.fetchReferenceOptions();
      expect(options.shifts.length, 2);
      expect(options.shifts.first.label, 'Pagi');
      expect(options.shifts.first.startTime, '07:00');
      expect(options.statuses.length, 2);
      expect(options.statuses.first.label, 'Buka');
      expect(options.timeIntervals, <int>[15, 30, 45, 60]);
    });
  });


  group('AmanahScheduleStore - Integrated Operations', () {
    test('AmanahScheduleStore.loadSchedulesForDate populates schedules and enriches patients', () async {
      final MockClient client = MockClient((http.Request request) async {
        if (request.url.path.contains('my-schedules')) {
          return http.Response(
            jsonEncode(<dynamic>[
              <String, dynamic>{
                'id': 'sched-store-1',
                'scheduleDate': '2026-09-01',
                'sessionShift': 'morning',
                'sessionLabel': 'Pagi',
                'startTime': '08:00',
                'endTime': '12:00',
                'poliklinikName': 'Poli Anak',
                'roomName': 'Ruang 105',
                'capacity': 8,
                'bookedPatientCount': 1,
                'isAvailable': true,
                'bookedPatients': <dynamic>[
                  <String, dynamic>{
                    'id': 'pt-store-1',
                    'fullName': 'Dewi Sartika',
                    'medicalRecordNumber': 'RM-9901',
                    'age': '5 Thn',
                    'complaint': 'Demam tinggi',
                    'queueNumber': '#01',
                    'timeSlot': '08:30 - 09:00 WIB',
                  },
                ],
              },
            ]),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        } else {
          return http.Response('[]', 200, headers: <String, String>{'content-type': 'application/json'});
        }
      });

      final AmanahScheduleStore store = AmanahScheduleStore.instance;
      store.setRepository(
        AmanahScheduleRepository(
          baseUrl: 'http://test.api',
          httpClient: client,
          tokenStorage: const _MockTokenStorage(),
        ),
      );

      final DateTime targetDate = DateTime(2026, 9, 1);
      final List<DoctorSchedule> result = await store.loadSchedulesForDate(targetDate, forceRefresh: true);

      expect(result.length, 1);
      expect(result.first.id, 'sched-store-1');
      expect(result.first.bookedPatients.first.patientName, 'Dewi Sartika');
      expect(store.getSchedulesForDate(targetDate).length, 1);
    });

    test('fetchScheduleContexts and fetchProjection with arbitrary start time 08:45', () async {
      final MockClient client = MockClient((http.Request request) async {
        if (request.url.path.contains('contexts')) {
          expect(request.url.queryParameters['date'], '2026-09-24');
          return http.Response(
            jsonEncode(<dynamic>[
              <String, dynamic>{
                'contextId': 'ctx-morning',
                'contextLabel': 'Pagi',
                'sessionShift': 'morning',
                'date': '2026-09-24',
                'boundaryStartTime': '06:00',
                'boundaryEndTime': '12:00',
                'effectiveConsultationDurationMinutes': 30,
                'allowedStartPrecisionMinutes': 1,
                'durationEditableByCurrentUser': false,
              },
            ]),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        } else if (request.url.path.contains('projection')) {
          expect(request.url.queryParameters['startTime'], '08:45');
          expect(request.url.queryParameters['scheduleContextId'], 'ctx-morning');
          return http.Response(
            jsonEncode(<String, dynamic>{
              'date': '2026-09-24',
              'scheduleContextId': 'ctx-morning',
              'contextLabel': 'Pagi',
              'selectedStartTime': '08:45',
              'projectedEndTime': '11:45',
              'effectiveConsultationDurationMinutes': 30,
              'capacity': 6,
              'intervals': <dynamic>[
                <String, dynamic>{
                  'intervalIndex': 1,
                  'startTime': '08:45',
                  'endTime': '09:15',
                  'status': 'OPEN',
                  'displayLabel': 'Buka',
                  'isOccupied': false,
                },
                <String, dynamic>{
                  'intervalIndex': 2,
                  'startTime': '09:15',
                  'endTime': '09:45',
                  'status': 'OCCUPIED',
                  'displayLabel': 'Terisi',
                  'isOccupied': true,
                  'appointmentRef': <String, dynamic>{
                    'appointmentId': 'apt-101',
                    'queueNumber': '#01',
                    'status': 'confirmed',
                  },
                },
              ],
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json'});
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://test.api',
        httpClient: client,
        tokenStorage: const _MockTokenStorage(),
      );

      final List<ScheduleContext> contexts = await repo.fetchScheduleContexts(date: '2026-09-24');
      expect(contexts.length, 1);
      expect(contexts.first.contextId, 'ctx-morning');
      expect(contexts.first.effectiveConsultationDurationMinutes, 30);
      expect(contexts.first.durationEditableByCurrentUser, isFalse);

      final ScheduleProjection projection = await repo.fetchProjection(
        date: '2026-09-24',
        scheduleContextId: 'ctx-morning',
        startTime: '08:45',
      );
      expect(projection.selectedStartTime, '08:45');
      expect(projection.capacity, 6);
      expect(projection.intervals.length, 2);
      expect(projection.intervals.first.startTime, '08:45');
      expect(projection.intervals.first.endTime, '09:15');
      expect(projection.intervals.first.status, ScheduleIntervalStatus.open);
      expect(projection.intervals[1].isOccupied, isTrue);
      expect(projection.intervals[1].appointmentRef?.queueNumber, '#01');
    });

    test('createAvailability creates schedule and updates store without fake optimistic local fallbacks on error', () async {
      bool failWithConflict = false;
      final MockClient client = MockClient((http.Request request) async {
        if (request.url.path.contains('availability') && request.method == 'POST') {
          if (failWithConflict) {
            return http.Response(
              jsonEncode(<String, dynamic>{
                'statusCode': 409,
                'code': 'START_OUTSIDE_BOUNDARY',
                'message': 'Jam mulai berada di luar batas waktu shift yang dipilih.',
              }),
              409,
              headers: <String, String>{'content-type': 'application/json'},
            );
          }
          return http.Response(
            jsonEncode(<String, dynamic>{
              'id': 'sched-v2-1',
              'scheduleDate': '2026-09-24',
              'sessionShift': 'morning',
              'sessionLabel': 'Pagi',
              'startTime': '08:45',
              'endTime': '11:45',
              'timeRange': '08:45 - 11:45 WIB',
              'poliklinikId': 'poli-1',
              'poliklinikName': 'Poli Umum',
              'roomId': 'room-1',
              'roomName': 'Ruang 101',
              'capacity': 6,
              'bookedPatientCount': 0,
              'isAvailable': true,
              'status': 'Buka',
            }),
            201,
            headers: <String, String>{'content-type': 'application/json'},
          );
        } else if (request.url.path.contains('my-schedules')) {
          return http.Response(
            jsonEncode(<dynamic>[
              <String, dynamic>{
                'id': 'sched-v2-1',
                'scheduleDate': '2026-09-24',
                'sessionShift': 'morning',
                'sessionLabel': 'Pagi',
                'startTime': '08:45',
                'endTime': '11:45',
                'poliklinikName': 'Poli Umum',
                'roomName': 'Ruang 101',
                'capacity': 6,
                'bookedPatientCount': 0,
                'isAvailable': true,
                'status': 'Buka',
              },
            ]),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        return http.Response('[]', 200, headers: <String, String>{'content-type': 'application/json'});
      });

      final AmanahScheduleStore store = AmanahScheduleStore.instance;
      store.reset();
      store.setRepository(
        AmanahScheduleRepository(
          baseUrl: 'http://test.api',
          httpClient: client,
          tokenStorage: const _MockTokenStorage(),
        ),
      );

      final DateTime targetDate = DateTime(2026, 9, 24);
      final DoctorSchedule created = await store.createAvailability(
        date: targetDate,
        scheduleContextId: 'ctx-morning',
        startTime: '08:45',
        roomId: 'room-1',
        poliklinikId: 'poli-1',
      );

      expect(created.id, 'sched-v2-1');
      expect(created.startTime, '08:45');
      expect(store.getSchedulesForDate(targetDate).length, 1);

      // Now test conflict handling
      failWithConflict = true;
      try {
        await store.createAvailability(
          date: targetDate,
          scheduleContextId: 'ctx-morning',
          startTime: '05:00',
        );
        fail('Should throw conflict exception');
      } on AmanahScheduleConflictException catch (e) {
        expect(e.code, 'START_OUTSIDE_BOUNDARY');
        expect(store.lastConflict?.code, 'START_OUTSIDE_BOUNDARY');
      }
    });
  });

  group('AmanahScheduleRepository - Reschedule API V2 Endpoints & DTOs', () {
    test('checkRescheduleEligibility successfully decodes eligibility and projectedEndTime', () async {
      final MockClient client = MockClient((http.Request request) async {
        expect(
          request.url.path,
          '/api/v1/admin/doctor-schedules/doc-uuid-1/sessions/sess-uuid-1/reschedule-eligibility',
        );
        expect(request.url.queryParameters['targetDate'], '2026-09-25');
        expect(request.url.queryParameters['targetStartTime'], '09:00');
        expect(request.url.queryParameters['targetRoomId'], 'room-101');

        return http.Response(
          jsonEncode(<String, dynamic>{
            'status': 'success',
            'data': <String, dynamic>{
              'sessionId': 'sess-uuid-1',
              'practitionerId': 'doc-uuid-1',
              'isEligible': true,
              'ineligibilityReason': null,
              'actionableGuidance': null,
              'targetValidation': <String, dynamic>{
                'evaluated': true,
                'targetDate': '2026-09-25',
                'targetStartTime': '09:00',
                'projectedEndTime': '12:00',
                'targetRoomId': 'room-101',
                'targetRoomName': 'Ruang 101',
                'isTargetEligible': true,
                'conflictMessage': null,
              },
            },
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

      final RescheduleEligibilityData eligibility =
          await repo.checkRescheduleEligibility(
        doctorId: 'doc-uuid-1',
        sessionId: 'sess-uuid-1',
        targetDate: '2026-09-25',
        targetStartTime: '09:00',
        targetRoomId: 'room-101',
      );

      expect(eligibility.sessionId, 'sess-uuid-1');
      expect(eligibility.practitionerId, 'doc-uuid-1');
      expect(eligibility.isEligible, isTrue);
      expect(eligibility.targetValidation, isNotNull);
      expect(eligibility.targetValidation!.evaluated, isTrue);
      expect(eligibility.targetValidation!.projectedEndTime, '12:00');
      expect(eligibility.targetValidation!.targetRoomName, 'Ruang 101');
      expect(eligibility.targetValidation!.isTargetEligible, isTrue);
    });

    test('rescheduleSession sends correct payload and parses response', () async {
      late Map<String, dynamic> sentBody;
      final MockClient client = MockClient((http.Request request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/admin/doctor-schedules/doc-uuid-1/sessions/sess-uuid-1/reschedule',
        );
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;

        return http.Response(
          jsonEncode(<String, dynamic>{
            'status': 'success',
            'message': 'Sesi berhasil di-reschedule',
            'data': <String, dynamic>{
              'newSessionId': 'sess-uuid-2',
              'targetDate': '2026-09-25',
              'startTime': '09:00',
              'endTime': '12:00',
              'transferredAppointmentsCount': 2,
            },
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

      final Map<String, dynamic> result = await repo.rescheduleSession(
        doctorId: 'doc-uuid-1',
        sessionId: 'sess-uuid-1',
        targetDate: '2026-09-25',
        targetStartTime: '09:00',
        targetRoomId: 'room-101',
        notes: 'Pindah karena rapat',
        rescheduleActiveAppointments: true,
      );

      expect(sentBody['targetDate'], '2026-09-25');
      expect(sentBody['targetStartTime'], '09:00');
      expect(sentBody['targetRoomId'], 'room-101');
      expect(sentBody['notes'], 'Pindah karena rapat');
      expect(sentBody['rescheduleActiveAppointments'], isTrue);
      expect(result['status'], 'success');
      expect(result['data']['newSessionId'], 'sess-uuid-2');
    });

    test('Reschedule DTOs correctly handle round-trip toJson and fromJson', () {
      const RescheduleTargetValidation targetVal = RescheduleTargetValidation(
        evaluated: true,
        targetDate: '2026-09-25',
        targetStartTime: '10:00',
        projectedEndTime: '13:00',
        targetRoomId: 'room-abc',
        targetRoomName: 'Ruang Cempaka',
        isTargetEligible: false,
        conflictMessage: 'Ruangan sudah terisi oleh dokter lain',
      );

      final Map<String, dynamic> targetJson = targetVal.toJson();
      final RescheduleTargetValidation fromTargetJson =
          RescheduleTargetValidation.fromJson(targetJson);

      expect(fromTargetJson.evaluated, isTrue);
      expect(fromTargetJson.targetDate, '2026-09-25');
      expect(fromTargetJson.projectedEndTime, '13:00');
      expect(fromTargetJson.isTargetEligible, isFalse);
      expect(fromTargetJson.conflictMessage, contains('terisi'));

      final RescheduleEligibilityData eligibility = RescheduleEligibilityData(
        sessionId: 'sess-123',
        practitionerId: 'doc-456',
        isEligible: false,
        ineligibilityReason: 'Sesi memiliki antrean aktif',
        actionableGuidance: 'Pilih opsi alihkan antrean pasien',
        targetValidation: targetVal,
      );

      final Map<String, dynamic> eligJson = eligibility.toJson();
      final RescheduleEligibilityData fromEligJson =
          RescheduleEligibilityData.fromJson(eligJson);

      expect(fromEligJson.sessionId, 'sess-123');
      expect(fromEligJson.practitionerId, 'doc-456');
      expect(fromEligJson.isEligible, isFalse);
      expect(fromEligJson.ineligibilityReason, contains('antrean'));
      expect(fromEligJson.targetValidation?.targetRoomName, 'Ruang Cempaka');
    });

    test('updateDayStatus sends canonical PATCH /api/v1/admin/doctor-schedules/:doctorId/days/:date', () async {
      late Map<String, dynamic> sentBody;
      final MockClient client = MockClient((http.Request request) async {
        expect(request.method, 'PATCH');
        expect(
          request.url.path,
          '/api/v1/admin/doctor-schedules/doc-uuid-1/days/2026-09-24',
        );
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;

        return http.Response(
          jsonEncode(<String, dynamic>{
            'success': true,
            'data': <String, dynamic>{
              'status': 'CLOSED',
              'notes': 'Jadwal ditutup oleh dokter',
            },
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

      final Map<String, dynamic> result = await repo.updateDayStatus(
        doctorId: 'doc-uuid-1',
        date: '2026-09-24',
        status: 'Tutup',
        notes: 'Jadwal ditutup oleh dokter',
      );

      expect(sentBody['status'], 'CLOSED');
      expect(sentBody['notes'], 'Jadwal ditutup oleh dokter');
      expect(result['success'], isTrue);
    });
  });
}
