import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class _MockTokenStorage extends AmanahAuthTokenStorage {
  const _MockTokenStorage([this._token = 'test-token']);
  final String? _token;

  @override
  Future<String?> getToken() async => _token;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cancelled Patient Exclusion & Schedule Slot Status Tests', () {
    test('BookedPatient isActive returns false for cancelled status', () {
      const BookedPatient cancelled = BookedPatient(
        id: 'p1',
        patientName: 'Dewi',
        patientRm: 'RM1',
        patientAge: '30',
        patientComplaint: 'Flu',
        queueNumber: '1',
        timeSlot: '08:00',
        badge: 'Dibatalkan',
        badgeVariant: AmanahBadgeVariant.warning,
        status: 'cancelled',
      );
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.isActive, isFalse);

      const BookedPatient active = BookedPatient(
        id: 'p2',
        patientName: 'Budi',
        patientRm: 'RM2',
        patientAge: '40',
        patientComplaint: 'Demam',
        queueNumber: '2',
        timeSlot: '08:30',
        badge: 'Booked',
        badgeVariant: AmanahBadgeVariant.primary,
        status: 'booked',
      );
      expect(active.isCancelled, isFalse);
      expect(active.isActive, isTrue);
    });

    test('DoctorSchedule.fromJson ignores cancelled patients when calculating availableSlots and badge', () {
      final DoctorSchedule schedule = DoctorSchedule.fromJson(<String, dynamic>{
        'id': 'ses-1',
        'sessionLabel': 'Pagi',
        'startTime': '06:00',
        'endTime': '12:00',
        'capacity': 12,
        'bookedPatients': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'apt-1',
            'fullName': 'Dewi Lestari',
            'status': 'cancelled',
          },
          <String, dynamic>{
            'id': 'apt-2',
            'fullName': 'Eka Kuswandari',
            'status': 'cancelled',
          },
        ],
      });

      expect(schedule.bookedPatientCount, equals(0));
      expect(schedule.availableSlots, equals(12));
      expect(schedule.badge, equals('Buka'));
      expect(schedule.badgeVariant, equals(AmanahBadgeVariant.success));
      expect(schedule.bookedPatients.length, equals(2));
      expect(schedule.bookedPatients[0].isCancelled, isTrue);
      expect(schedule.bookedPatients[1].isCancelled, isTrue);
    });

    test('AmanahScheduleStore keeps session status as Buka and bookedPatientCount as 0 when all patients are cancelled', () async {
      final MockClient client = MockClient((http.Request request) async {
        final String path = request.url.path;
        if (path.contains('schedules/my-schedules')) {
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'session-pagi-1',
                'session': 'PAGI',
                'sessionLabel': 'Pagi',
                'sessionShift': 'morning',
                'startTime': '06:00',
                'endTime': '12:00',
                'timeRange': '06:00 - 12:00 WIB',
                'capacity': 12,
                'availableSlots': 12,
                'bookedPatientCount': 0,
                'status': 'OPEN',
                'rawStatus': 'open',
                'isAvailable': true,
              },
            ]),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        if (path.contains('schedules/booked-patients')) {
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'patient-dewi',
                'appointmentId': 'apt-dewi',
                'fullName': 'Dewi Lestari',
                'medicalRecordNumber': 'RM-2026-0001',
                'age': '31 Thn',
                'gender': 'Perempuan',
                'queueNumber': 'UM-101',
                'timeSlot': '08:00 - 08:30 WIB',
                'sessionTitle': 'Sesi Pagi',
                'room': 'Ruang Poli Umum 1',
                'complaint': 'Kontrol tensi',
                'status': 'cancelled',
                'statusBadge': 'Dibatalkan',
              },
              <String, dynamic>{
                'id': 'patient-eka',
                'appointmentId': 'apt-eka',
                'fullName': 'Eka Kuswandari',
                'medicalRecordNumber': 'RM-2026-0002',
                'age': '36 Thn',
                'gender': 'Perempuan',
                'queueNumber': 'UM-102',
                'timeSlot': '08:30 - 09:00 WIB',
                'sessionTitle': 'Sesi Pagi',
                'room': 'Ruang Poli Umum 1',
                'complaint': 'Alergi',
                'status': 'cancelled',
                'statusBadge': 'Dibatalkan',
              },
            ]),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        return http.Response('[]', 200, headers: <String, String>{'content-type': 'application/json'});
      });

      final AmanahScheduleRepository repo = AmanahScheduleRepository(
        baseUrl: 'http://localhost:3001',
        httpClient: client,
        tokenStorage: const _MockTokenStorage('test-jwt'),
      );

      final AmanahScheduleStore store = AmanahScheduleStore.instance;
      store.reset();
      store.setRepository(repo);

      final DateTime targetDate = DateTime(2026, 9, 26);
      final List<DoctorSchedule> schedules =
          await store.loadSchedulesForDate(targetDate);

      expect(schedules, hasLength(1));
      final DoctorSchedule session = schedules.first;

      // Status must remain 'Buka' (not 'Terisi')
      expect(session.badge, equals('Buka'));
      expect(session.badgeVariant, equals(AmanahBadgeVariant.success));

      // Active booked patients count must be 0
      expect(session.bookedPatientCount, equals(0));
      expect(session.availableSlots, equals(12));

      // Cancelled patients are preserved in bookedPatients for audit trail in detail drawer
      expect(session.bookedPatients, hasLength(2));
      expect(session.bookedPatients.every((BookedPatient p) => p.isCancelled), isTrue);

      // getCapacityPercentage must be 0% since active bookings are 0
      final int capacityPct = store.getCapacityPercentage(targetDate);
      expect(capacityPct, equals(0));

      // getActiveBookedPatientsForDate must return empty
      final List<({BookedPatient patient, DoctorSchedule schedule})> activeList =
          store.getActiveBookedPatientsForDate(targetDate);
      expect(activeList, isEmpty);

      // getAllBookedPatientsForDate returns historical records with cancelled status
      final List<({BookedPatient patient, DoctorSchedule schedule})> allList =
          store.getAllBookedPatientsForDate(targetDate);
      expect(allList, hasLength(2));
      expect(allList.every((item) => item.patient.isCancelled), isTrue);
    });
  });
}
