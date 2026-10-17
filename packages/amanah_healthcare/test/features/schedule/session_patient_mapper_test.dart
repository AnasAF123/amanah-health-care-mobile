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

      const SessionPatientDto dtoWaiting = SessionPatientDto(
        id: '2',
        appointmentId: '2',
        fullName: 'Test',
        medicalRecordNumber: 'RM-2',
        age: '20',
        gender: 'L',
        queueNumber: '2',
        sessionTitle: 'Pagi',
        room: 'R1',
        status: 'WAITING',
        statusBadge: 'Menunggu',
      );
      expect(
        SessionPatientMapper.fromDto(dtoWaiting).badgeVariant,
        AmanahBadgeVariant.primary,
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

    test('correctly parses admin appointments payload and checks isCompleted / etaDisplay', () {
      final Map<String, dynamic> adminAppointmentJson = <String, dynamic>{
        'id': 'ff880d35-c83d-4279-984d-6e96dbbf23da',
        'bookingCode': 'BOOK-MVC49HZ4-32',
        'patientName': 'Riza',
        'poliklinikName': 'Poli Umum',
        'roomName': 'Ruang Poli Umum 1',
        'queueNumber': 'USG-S001',
        'status': 'BOOKED',
        'sessionName': 'Sesi SIANG',
        'etaRange': '18:00 - 18:30 WIB',
        'actualStartedAt': null,
        'actualCompletedAt': null,
      };

      final SessionPatientDto dto = SessionPatientDto.fromJson(adminAppointmentJson);
      expect(dto.fullName, 'Riza');
      expect(dto.poliklinikName, 'Poli Umum');
      expect(dto.room, 'Ruang Poli Umum 1');
      expect(dto.queueNumber, 'USG-S001');
      expect(dto.etaRange, '18:00 - 18:30 WIB');
      expect(dto.status, 'BOOKED');

      final SessionPatient entity = SessionPatientMapper.fromDto(dto);
      expect(entity.etaRange, '18:00 - 18:30 WIB');
      expect(entity.poliklinikName, 'Poli Umum');

      final BookedPatient bp = entity.toBookedPatient();
      expect(bp.isCompleted, isFalse);
      expect(bp.etaDisplay, '18:00 - 18:30 WIB');
      expect(bp.poliklinikName, 'Poli Umum');

      final BookedPatient completedBp = bp.copyWith(status: 'COMPLETED');
      expect(completedBp.isCompleted, isTrue);
    });

    test('verifies Dr. Zikri 2 patients exact status resolution via AppointmentStatusDescriptor', () {
      // Patient 1: Riza (BOOKED) -> 'Sudah Buat Janji'
      final SessionPatientDto rizaDto = SessionPatientDto.fromJson(<String, dynamic>{
        'id': 'ff880d35-c83d-4279-984d-6e96dbbf23da',
        'patientName': 'Riza',
        'status': 'BOOKED',
        'queueNumber': 'USG-S001',
      });
      expect(rizaDto.statusBadge, 'Sudah Buat Janji');
      final SessionPatient rizaEntity = SessionPatientMapper.fromDto(rizaDto);
      expect(rizaEntity.badgeVariant, AmanahBadgeVariant.primary);
      expect(rizaEntity.statusBadge, 'Sudah Buat Janji');

      // Patient 2: Siti Aminah (WAITING) -> 'Menunggu'
      final SessionPatientDto sitiDto = SessionPatientDto.fromJson(<String, dynamic>{
        'id': 'a1b2c3d4-e5f6-4a1b-8c2d-3e4f5a6b7c8d',
        'patientName': 'Siti Aminah Updated',
        'status': 'WAITING',
        'queueNumber': 'S002',
      });
      expect(sitiDto.statusBadge, 'Menunggu');
      final SessionPatient sitiEntity = SessionPatientMapper.fromDto(sitiDto);
      expect(sitiEntity.badgeVariant, AmanahBadgeVariant.primary);
      expect(sitiEntity.statusBadge, 'Menunggu');

      // IN_SERVICE -> 'Sedang Diperiksa'
      final SessionPatient inService = SessionPatientMapper.fromDto(
        const SessionPatientDto(
          id: '3',
          appointmentId: '3',
          fullName: 'Test',
          medicalRecordNumber: 'RM-3',
          age: '20',
          gender: 'L',
          queueNumber: '3',
          sessionTitle: 'Pagi',
          room: 'R1',
          status: 'IN_SERVICE',
          statusBadge: '',
        ),
      );
      expect(inService.statusBadge, 'Sedang Diperiksa');
      expect(inService.badgeVariant, AmanahBadgeVariant.trend);

      // LATE -> 'Terlambat'
      final SessionPatient latePatient = SessionPatientMapper.fromDto(
        const SessionPatientDto(
          id: '4',
          appointmentId: '4',
          fullName: 'Test',
          medicalRecordNumber: 'RM-4',
          age: '20',
          gender: 'L',
          queueNumber: '4',
          sessionTitle: 'Pagi',
          room: 'R1',
          status: 'LATE',
          statusBadge: '',
        ),
      );
      expect(latePatient.statusBadge, 'Terlambat');
      expect(latePatient.badgeVariant, AmanahBadgeVariant.warning);
    });
  });
}
