import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_endpoints.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_status.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_copywriting.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/doctor_queue_appointment.dart';

void main() {
  test('DoctorQueueEndpoints should produce correct paths', () {
    expect(DoctorQueueEndpoints.dailyQueue, '/api/v1/appointments/queue/daily');
    expect(DoctorQueueEndpoints.call('123'), '/api/v1/appointments/123/call');
    expect(DoctorQueueEndpoints.respond('123'), '/api/v1/appointments/123/respond');
    expect(DoctorQueueEndpoints.noShow('123'), '/api/v1/appointments/123/no-show');
    expect(DoctorQueueEndpoints.complete('123'), '/api/v1/appointments/123/complete');
    expect(DoctorQueueEndpoints.queryPoliklinikId, 'poliklinikId');
    expect(DoctorQueueEndpoints.queryDate, 'date');
    expect(DoctorQueueEndpoints.querySession, 'session');
  });

  test('DoctorQueueStatus enum should map canonical backend strings', () {
    expect(DoctorQueueStatus.fromString('waiting'), DoctorQueueStatus.waiting);
    expect(DoctorQueueStatus.fromString('called'), DoctorQueueStatus.called);
    expect(DoctorQueueStatus.fromString('in_consultation'), DoctorQueueStatus.inConsultation);
    expect(DoctorQueueStatus.fromString('completed'), DoctorQueueStatus.completed);
    expect(DoctorQueueStatus.fromString('no_show'), DoctorQueueStatus.noShow);
    expect(DoctorQueueStatus.fromString('unknown_status'), DoctorQueueStatus.waiting);
  });

  test('DoctorQueueCopywriting provides non-empty UI strings', () {
    expect(DoctorQueueCopywriting.headerTitle.isNotEmpty, isTrue);
    expect(DoctorQueueCopywriting.pullCardToCall.isNotEmpty, isTrue);
    expect(DoctorQueueCopywriting.actionCallAgain.isNotEmpty, isTrue);
    expect(DoctorQueueCopywriting.actionPatientEntered.isNotEmpty, isTrue);
    expect(DoctorQueueCopywriting.actionSkipNoShow.isNotEmpty, isTrue);
    expect(DoctorQueueCopywriting.actionFinishConsultation.isNotEmpty, isTrue);
  });

  test('DoctorQueueAppointment entity holds immutability and default values', () {
    const appointment = DoctorQueueAppointment(
      id: 'app-1',
      queueNumber: 'U-001',
      status: DoctorQueueStatus.waiting,
      callCount: 0,
      patientName: 'Ahmad Amikom',
      patientPhone: '08123456789',
      appointmentDate: '2026-09-27',
      session: 'Pagi',
      estimatedDurationMinutes: 30,
    );
    expect(appointment.id, 'app-1');
    expect(appointment.canBeCalled, isTrue);
    expect(appointment.isInConsultation, isFalse);
    expect(appointment.isCalled, isFalse);

    const calledAppointment = DoctorQueueAppointment(
      id: 'app-1',
      queueNumber: 'U-001',
      status: DoctorQueueStatus.called,
      callCount: 2,
      patientName: 'Ahmad Amikom',
      appointmentDate: '2026-09-27',
      session: 'Pagi',
    );
    expect(calledAppointment.canBeCalled, isTrue);
    expect(calledAppointment.isCalled, isTrue);

    const maxCalledAppointment = DoctorQueueAppointment(
      id: 'app-1',
      queueNumber: 'U-001',
      status: DoctorQueueStatus.called,
      callCount: 3,
      patientName: 'Ahmad Amikom',
      appointmentDate: '2026-09-27',
      session: 'Pagi',
    );
    expect(maxCalledAppointment.canBeCalled, isFalse);
  });
}
