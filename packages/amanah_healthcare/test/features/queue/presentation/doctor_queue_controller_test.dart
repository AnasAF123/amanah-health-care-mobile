import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_status.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/doctor_queue_appointment.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/doctor_queue_repository.dart';
import 'package:amanah_healthcare/features/queue/presentation/controllers/doctor_queue_controller.dart';

class FakeDoctorQueueRepository implements DoctorQueueRepository {
  List<DoctorQueueAppointment> queue = [];

  @override
  Future<List<DoctorQueueAppointment>> getDailyQueue({
    required String poliklinikId,
    required String date,
    String? session,
  }) async {
    return queue;
  }

  @override
  Future<DoctorQueueAppointment> callPatient(String id) async {
    return DoctorQueueAppointment(
      id: id,
      queueNumber: 'U-001',
      status: DoctorQueueStatus.called,
      callCount: 1,
      patientName: 'Ahmad Amikom',
      appointmentDate: '2026-09-27',
      session: 'Pagi',
    );
  }

  @override
  Future<DoctorQueueAppointment> respondPatient(String id) async {
    return DoctorQueueAppointment(
      id: id,
      queueNumber: 'U-001',
      status: DoctorQueueStatus.inConsultation,
      callCount: 1,
      patientName: 'Ahmad Amikom',
      appointmentDate: '2026-09-27',
      session: 'Pagi',
    );
  }

  @override
  Future<DoctorQueueAppointment> noShowPatient(String id) async {
    return DoctorQueueAppointment(
      id: id,
      queueNumber: 'U-001',
      status: DoctorQueueStatus.waiting,
      callCount: 1,
      patientName: 'Ahmad Amikom',
      appointmentDate: '2026-09-27',
      session: 'Pagi',
    );
  }

  @override
  Future<DoctorQueueAppointment> completeAppointment(String id) async {
    return DoctorQueueAppointment(
      id: id,
      queueNumber: 'U-001',
      status: DoctorQueueStatus.completed,
      callCount: 1,
      patientName: 'Ahmad Amikom',
      appointmentDate: '2026-09-27',
      session: 'Pagi',
    );
  }
}

void main() {
  test('DoctorQueueController loads queue and manages active patient lifecycle',
      () async {
    final repo = FakeDoctorQueueRepository();
    repo.queue = [
      const DoctorQueueAppointment(
        id: '1',
        queueNumber: 'U-001',
        status: DoctorQueueStatus.waiting,
        callCount: 0,
        patientName: 'Ahmad Amikom',
        appointmentDate: '2026-09-27',
        session: 'Pagi',
      )
    ];

    final controller = DoctorQueueController(repository: repo);
    expect(controller.isLoading, isFalse);

    await controller.loadQueue(poliklinikId: 'poli-1', date: '2026-09-27');
    expect(controller.queue.length, 1);
    expect(controller.activeAppointment, isNull);

    await controller.callPatient('1');
    expect(controller.activeAppointment?.status, DoctorQueueStatus.called);
    expect(controller.activeAppointment?.callCount, 1);

    await controller.patientRespond('1');
    expect(
        controller.activeAppointment?.status, DoctorQueueStatus.inConsultation);

    await controller.completeConsultation('1');
    expect(controller.activeAppointment, isNull);
  });
}
