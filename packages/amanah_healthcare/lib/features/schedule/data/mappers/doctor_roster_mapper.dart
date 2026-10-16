import 'package:amanah_healthcare/features/schedule/data/dto/doctor_roster_dto.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';

abstract final class DoctorRosterMapper {
  static DoctorRoster fromDto(DoctorRosterOverviewDto dto) {
    return DoctorRoster(
      doctorId: dto.doctorId,
      doctorName: dto.doctorName,
      specialization: dto.specialization,
      hasAnyOverride: dto.hasAnyOverride,
      days: dto.days.map(_mapDay).toList(),
    );
  }

  static DoctorRosterDay _mapDay(DoctorRosterDayDto dto) {
    return DoctorRosterDay(
      dow: dto.dow,
      dayCode: dto.dayCode,
      dayName: dto.dayName,
      sortOrder: dto.sortOrder,
      isWeekend: dto.isWeekend,
      isOperatingDay: dto.isOperatingDay,
      isDoctorActive: dto.isDoctorActive,
      hasOverride: dto.hasOverride,
      sessions: dto.sessions.map(_mapSession).toList(),
    );
  }

  static DoctorRosterSession _mapSession(DoctorRosterSessionDto dto) {
    return DoctorRosterSession(
      sessionId: dto.sessionId,
      sessionCode: dto.sessionCode,
      sessionLabel: dto.sessionLabel,
      timeRange: dto.timeRange,
      isActive: dto.isActive,
      isTemplateActive: dto.isTemplateActive,
      preferredRoomId: dto.preferredRoomId,
      preferredRoomName: dto.preferredRoomName,
    );
  }
}
