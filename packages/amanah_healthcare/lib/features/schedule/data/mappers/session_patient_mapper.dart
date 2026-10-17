import 'package:amanah_healthcare/features/schedule/data/dto/session_patient_dto.dart';
import 'package:amanah_healthcare/features/schedule/domain/constants/appointment_status_dictionary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';

abstract final class SessionPatientMapper {
  static SessionPatient fromDto(SessionPatientDto dto) {
    final AppointmentStatusDescriptor descriptor =
        AppointmentStatusDescriptor.resolve(dto.status);

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
      statusBadge: dto.statusBadge.isNotEmpty ? dto.statusBadge : descriptor.badge,
      avatarUrl: dto.avatarUrl,
      estimatedStartAt: dto.estimatedStartAt,
      estimatedEndAt: dto.estimatedEndAt,
      badgeVariant: descriptor.badgeVariant,
      poliklinikName: dto.poliklinikName,
      etaRange: dto.etaRange,
      actualStartedAt: dto.actualStartedAt,
      actualCompletedAt: dto.actualCompletedAt,
      consultationDurationFormatted: dto.consultationDurationFormatted,
      scheduledStartTime: dto.scheduledStartTime,
      scheduledEndTime: dto.scheduledEndTime,
    );
  }
}
