import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_status.dart';
import 'package:amanah_healthcare/features/queue/data/models/doctor_queue_appointment_model.dart';
import 'package:amanah_healthcare/features/queue/data/datasources/doctor_queue_remote_data_source.dart';
import 'package:amanah_healthcare/features/queue/data/repositories/doctor_queue_repository_impl.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';

class MockDoctorQueueRemoteDataSource implements DoctorQueueRemoteDataSource {
  DoctorQueueAppointmentModel? lastCalledModel;
  DoctorQueueAppointmentModel? lastRespondedModel;
  DoctorQueueAppointmentModel? lastNoShowModel;
  DoctorQueueAppointmentModel? lastCompletedModel;
  List<DoctorQueueAppointmentModel> queueList = [];

  @override
  Future<List<DoctorQueueAppointmentModel>> getDailyQueue({
    required String poliklinikId,
    required String date,
    String? session,
    required String authToken,
  }) async {
    return queueList;
  }

  @override
  Future<DoctorQueueAppointmentModel> callPatient(
      String appointmentId, String authToken) async {
    return lastCalledModel!;
  }

  @override
  Future<DoctorQueueAppointmentModel> respondPatient(
      String appointmentId, String authToken) async {
    return lastRespondedModel!;
  }

  @override
  Future<DoctorQueueAppointmentModel> noShowPatient(
      String appointmentId, String authToken) async {
    return lastNoShowModel!;
  }

  @override
  Future<DoctorQueueAppointmentModel> completeAppointment(
      String appointmentId, String authToken) async {
    return lastCompletedModel!;
  }
}

class FakeAuthTokenStorage extends AmanahAuthTokenStorage {
  String? fakeToken = 'mock_jwt_token';

  @override
  Future<String?> getToken() async => fakeToken;
}

void main() {
  test('DoctorQueueAppointmentModel parses backend queue response correctly', () {
    final json = {
      'id': 'app-99',
      'queueNumber': 'U-001',
      'status': 'called',
      'callCount': 1,
      'patient': {
        'fullName': 'Ahmad Amikom',
        'phoneNumber': '08123456789'
      },
      'appointmentDate': '2026-09-27',
      'session': 'Pagi',
      'estimatedDurationMinutes': 30,
      'lastCalledAt': '2026-09-27T08:00:00.000Z'
    };

    final model = DoctorQueueAppointmentModel.fromJson(json);
    expect(model.id, 'app-99');
    expect(model.queueNumber, 'U-001');
    expect(model.status, DoctorQueueStatus.called);
    expect(model.callCount, 1);
    expect(model.patientName, 'Ahmad Amikom');
    expect(model.patientPhone, '08123456789');
    expect(model.lastCalledAt != null, isTrue);
  });

  test('DoctorQueueRepositoryImpl fetches daily queue using auth token', () async {
    final mockDs = MockDoctorQueueRemoteDataSource();
    final fakeStorage = FakeAuthTokenStorage();
    final repo = DoctorQueueRepositoryImpl(
      remoteDataSource: mockDs,
      tokenStorage: fakeStorage,
    );

    mockDs.queueList = [
      const DoctorQueueAppointmentModel(
        id: 'app-1',
        queueNumber: 'U-001',
        status: DoctorQueueStatus.waiting,
        callCount: 0,
        patientName: 'Ahmad Amikom',
        appointmentDate: '2026-09-27',
        session: 'Pagi',
      )
    ];

    final result = await repo.getDailyQueue(
      poliklinikId: 'poli-umum',
      date: '2026-09-27',
      session: 'Pagi',
    );

    expect(result.length, 1);
    expect(result.first.patientName, 'Ahmad Amikom');
  });

  test('DoctorQueueRepositoryImpl throws error if token missing', () async {
    final mockDs = MockDoctorQueueRemoteDataSource();
    final fakeStorage = FakeAuthTokenStorage();
    fakeStorage.fakeToken = null;
    final repo = DoctorQueueRepositoryImpl(
      remoteDataSource: mockDs,
      tokenStorage: fakeStorage,
    );

    expect(
      () => repo.getDailyQueue(
        poliklinikId: 'poli-umum',
        date: '2026-09-27',
      ),
      throwsA(isA<StateError>()),
    );
  });
}
