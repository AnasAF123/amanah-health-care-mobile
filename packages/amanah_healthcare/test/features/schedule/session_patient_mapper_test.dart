import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/session_patient_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/mappers/session_patient_mapper.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';

void main() {
  group('SessionPatientMapper', () {
    test('maps SessionPatientDto to SessionPatient and converts to BookedPatient', () {
      const SessionPatientDto dto = SessionPatientDto(
        id: 'pat-1',
        appointmentId: 'app-1',
        fullName: 'Budi Santoso',
        medicalRecordNumber: 'RM-001',
        age: '32 thn',
        gender: 'L',
        queueNumber: 'A-01',
        sessionTitle: 'Sesi Pagi',
        room: 'Ruang 1',
        guardian: 'Siti',
        complaint: 'Demam dan batuk',
        status: 'COMPLETED',
        statusBadge: 'Selesai',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final SessionPatient entity = SessionPatientMapper.fromDto(dto);

      expect(entity.id, 'pat-1');
      expect(entity.fullName, 'Budi Santoso');
      expect(entity.medicalRecordNumber, 'RM-001');
      expect(entity.badgeVariant, AmanahBadgeVariant.success);

      final BookedPatient bp = entity.toBookedPatient();
      expect(bp.id, 'pat-1');
      expect(bp.patientName, 'Budi Santoso');
      expect(bp.patientRm, 'RM-001');
      expect(bp.queueNumber, 'A-01');
      expect(bp.badge, 'Selesai');
      expect(bp.badgeVariant, AmanahBadgeVariant.success);
      expect(bp.patientGuardian, 'Siti');
    });

    test('correctly maps status string variants to AmanahBadgeVariant', () {
      const SessionPatientDto dtoServing = SessionPatientDto(
        id: '1',
        appointmentId: '1',
        fullName: 'Test',
        medicalRecordNumber: 'RM-1',
        age: '20',
        gender: 'L',
        queueNumber: '1',
        sessionTitle: 'Pagi',
        room: 'R1',
        status: 'SERVING',
        statusBadge: 'Diperiksa',
      );
      expect(
        SessionPatientMapper.fromDto(dtoServing).badgeVariant,
        AmanahBadgeVariant.trend,
      );

      const SessionPatientDto dtoCalled = SessionPatientDto(
        id: '2',
        appointmentId: '2',
        fullName: 'Test',
        medicalRecordNumber: 'RM-2',
        age: '20',
        gender: 'L',
        queueNumber: '2',
        sessionTitle: 'Pagi',
        room: 'R1',
        status: 'CALLED',
        statusBadge: 'Dipanggil',
      );
      expect(
        SessionPatientMapper.fromDto(dtoCalled).badgeVariant,
        AmanahBadgeVariant.live,
      );

      const SessionPatientDto dtoCancelled = SessionPatientDto(
        id: '3',
        appointmentId: '3',
        fullName: 'Test',
        medicalRecordNumber: 'RM-3',
        age: '20',
        gender: 'L',
        queueNumber: '3',
        sessionTitle: 'Pagi',
        room: 'R1',
        status: 'CANCELLED',
        statusBadge: 'Batal',
      );
      expect(
        SessionPatientMapper.fromDto(dtoCancelled).badgeVariant,
        AmanahBadgeVariant.warning,
      );
    });
  });
}
