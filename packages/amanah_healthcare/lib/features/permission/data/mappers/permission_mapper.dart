import 'package:amanah_healthcare/features/permission/data/dto/eligible_session_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/leave_request_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/replacement_item_dto.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';

abstract final class PermissionMapper {
  /// Maps pure domain permission type to canonical backend API enum string.
  static String mapPermissionTypeToApi(AmanahPermissionType type) {
    switch (type) {
      case AmanahPermissionType.cutiTahunan:
        return 'annual_leave';
      case AmanahPermissionType.izinSakit:
        return 'sick_leave';
      case AmanahPermissionType.seminarSimposium:
        return 'seminar_symposium';
      case AmanahPermissionType.urusanKeluarga:
        return 'family_matter';
      case AmanahPermissionType.tugasLuarRS:
        return 'external_assignment';
      case AmanahPermissionType.lainnya:
        return 'other';
    }
  }

  /// Maps canonical backend API enum string to domain permission type.
  static AmanahPermissionType mapApiToPermissionType(String apiValue) {
    switch (apiValue) {
      case 'annual_leave':
        return AmanahPermissionType.cutiTahunan;
      case 'sick_leave':
        return AmanahPermissionType.izinSakit;
      case 'seminar_symposium':
        return AmanahPermissionType.seminarSimposium;
      case 'family_matter':
        return AmanahPermissionType.urusanKeluarga;
      case 'external_assignment':
        return AmanahPermissionType.tugasLuarRS;
      case 'other':
      default:
        return AmanahPermissionType.lainnya;
    }
  }

  /// Maps pure domain permission status to canonical backend API status string.
  static String mapPermissionStatusToApi(AmanahPermissionStatus status) {
    switch (status) {
      case AmanahPermissionStatus.menunggu:
        return 'pending';
      case AmanahPermissionStatus.disetujui:
        return 'approved';
      case AmanahPermissionStatus.ditolak:
        return 'rejected';
      case AmanahPermissionStatus.dibatalkan:
        return 'cancelled';
    }
  }

  /// Maps canonical backend API status string to domain permission status.
  static AmanahPermissionStatus mapApiToPermissionStatus(String apiValue) {
    switch (apiValue) {
      case 'approved':
        return AmanahPermissionStatus.disetujui;
      case 'rejected':
        return AmanahPermissionStatus.ditolak;
      case 'cancelled':
        return AmanahPermissionStatus.dibatalkan;
      case 'pending':
      default:
        return AmanahPermissionStatus.menunggu;
    }
  }

  /// Maps LeaveRequestEntity directly to presentation AmanahPermissionRecord.
  static AmanahPermissionRecord toPermissionRecord(
    LeaveRequestEntity entity, {
    String doctorName = 'Staf Amanah',
    String doctorRole = 'Staf Klinik',
    String? avatarUrl,
  }) {
    return AmanahPermissionRecord(
      id: entity.id,
      userId: entity.staffId,
      userName: doctorName.isNotEmpty ? doctorName : 'Staf Amanah',
      userRole: doctorRole.isNotEmpty ? doctorRole : 'Staf Klinik',
      userAvatarUrl: avatarUrl ?? '',
      startDate: entity.startDate,
      endDate: entity.endDate,
      durationDays: entity.durationDays,
      type: mapApiToPermissionType(entity.type),
      reason: entity.reason,
      status: mapApiToPermissionStatus(entity.status),
      createdAt: entity.createdAt.toIso8601String(),
      reviewerNotes: entity.approvalNotes,
      cancelledAt: entity.cancelledAt?.toIso8601String(),
      substituteStaffProfileId: entity.substituteStaffProfileId,
      substituteStaffName: entity.substituteStaffName,
    );
  }

  /// Resolves raw backend session keys (e.g. "session.morning", "session.afternoon")
  /// into canonical Indonesian labels ("Sesi Pagi", "Sesi Siang", "Sesi Malam").
  static String _resolveSessionLabel({required String? rawLabel, String? sessionCode}) {
    if (rawLabel != null && rawLabel.trim().isNotEmpty) {
      return rawLabel.trim();
    }
    if (sessionCode != null && sessionCode.trim().isNotEmpty) {
      return sessionCode.trim();
    }
    return 'Sesi Praktik';
  }

  /// Normalizes "06:00:00" to "06:00".
  static String _formatTime(String rawTime) {
    final String trimmed = rawTime.trim();
    if (trimmed.length >= 5 && trimmed.contains(':')) {
      return trimmed.substring(0, 5);
    }
    return trimmed;
  }

  static EligibleSession toEligibleSession(EligibleSessionDto dto) {
    return EligibleSession(
      sessionId: dto.sessionId,
      sessionCode: dto.sessionCode,
      sessionLabel: _resolveSessionLabel(rawLabel: dto.sessionLabel, sessionCode: dto.sessionCode),
      startsAt: _formatTime(dto.startsAt),
      endsAt: _formatTime(dto.endsAt),
      workDate: dto.workDate,
    );
  }

  static LeaveSessionRef toLeaveSessionRef(LeaveSessionRefDto dto) {
    return LeaveSessionRef(
      id: dto.id,
      sessionId: dto.sessionId,
      sessionCode: dto.sessionCode,
      sessionLabel: _resolveSessionLabel(rawLabel: dto.sessionLabel, sessionCode: dto.sessionCode),
      workDate: dto.workDate,
    );
  }

  static LeaveRequestEntity toLeaveRequestEntity(LeaveRequestDto dto) {
    return LeaveRequestEntity(
      id: dto.id,
      staffId: dto.staffId,
      practitionerId: dto.practitionerId,
      startDate: dto.startDate,
      endDate: dto.endDate,
      durationDays: dto.durationDays,
      reason: dto.reason,
      type: dto.type,
      scope: dto.scope,
      decisionSource: dto.decisionSource,
      status: dto.status,
      approvedBy: dto.approvedBy,
      approvalNotes: dto.approvalNotes,
      cancelledAt: dto.cancelledAt != null ? DateTime.tryParse(dto.cancelledAt!) : null,
      substituteStaffProfileId: dto.substituteStaffProfileId,
      substituteStaffName: dto.substituteStaffName,
      sessions: dto.sessions.map(toLeaveSessionRef).toList(),
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(dto.updatedAt) ?? DateTime.now(),
    );
  }

  static ReplacementItem toReplacementItem(ReplacementItemDto dto) {
    return ReplacementItem(
      id: dto.id,
      leaveRequestId: dto.leaveRequestId,
      sessionId: dto.sessionId,
      workDate: dto.workDate,
      originalStaffProfileId: dto.originalStaffProfileId,
      originalPractitionerId: dto.originalPractitionerId,
      originalStaffName: dto.originalStaffName,
      originalStaffRole: dto.originalStaffRole,
      originalStaffAvatarUrl: dto.originalStaffAvatarUrl,
      claimedByStaffProfileId: dto.claimedByStaffProfileId,
      claimedByPractitionerId: dto.claimedByPractitionerId,
      claimedByName: dto.claimedByName,
      claimedByRole: dto.claimedByRole,
      claimedByAvatarUrl: dto.claimedByAvatarUrl,
      status: dto.status,
      claimedAt: dto.claimedAt != null ? DateTime.tryParse(dto.claimedAt!) : null,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      sessionCode: dto.sessionCode,
      sessionLabel: _resolveSessionLabel(rawLabel: dto.sessionLabel, sessionCode: dto.sessionCode),
      startTime: dto.startTime,
      endTime: dto.endTime,
      leaveReason: dto.leaveReason,
    );
  }
}
