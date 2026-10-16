import 'package:amanah_healthcare/features/schedule/data/dto/session_patient_dto.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';

abstract final class SessionPatientMapper {
  static SessionPatient fromDto(SessionPatientDto dto) {
    return SessionPatient(
      id: dto.id,
      appointmentId: dto.appointmentId,
      fullName: dto.fullName,
      medicalRecordNumber: dto.medicalRecordNumber,
      age: dto.age,
      gender: dto.gender,
      queueNumber: dto.queueNumber,
      sessionTitle: dto.sessionTitle,
      room: dto.room,
      guardian: dto.guardian,
      complaint: dto.complaint,
      status: dto.status,
      statusBadge: dto.statusBadge,
      avatarUrl: dto.avatarUrl,
      estimatedStartAt: dto.estimatedStartAt,
      estimatedEndAt: dto.estimatedEndAt,
      badgeVariant: _resolveBadgeVariant(dto.status),
    );
  }

  static AmanahBadgeVariant _resolveBadgeVariant(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'SELESAI':
        return AmanahBadgeVariant.success;
      case 'SERVING':
      case 'EXAMINING':
        return AmanahBadgeVariant.trend;
      case 'CALLED':
      case 'DIPANGGIL':
        return AmanahBadgeVariant.live;
      case 'CANCELLED':
      case 'BATAL':
        return AmanahBadgeVariant.warning;
      case 'REGISTERED':
      case 'WAITING':
      default:
        return AmanahBadgeVariant.primary;
    }
  }
}
