import 'package:amanah_healthcare/features/permission/data/dto/eligible_session_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/leave_request_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/replacement_item_dto.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/schedule/domain/helpers/clinical_session_resolver.dart';

abstract final class PermissionMapper {
  /// Resolves raw backend session keys (e.g. "session.morning", "session.afternoon")
  /// into canonical Indonesian labels ("Sesi Pagi", "Sesi Siang", "Sesi Malam").
  static String _resolveSessionLabel({
    required String? rawLabel,
    String? sessionCode,
  }) {
    if (rawLabel != null && rawLabel.trim().isNotEmpty) {
      final String sanitized = ClinicalSessionResolver.sanitize(rawLabel);
      if (sanitized != rawLabel) {
        return sanitized;
      }
    }
    return ClinicalSessionResolver.resolveSessionName(
      sessionShift: sessionCode,
      sessionLabel: rawLabel,
    );
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
      sessionLabel: _resolveSessionLabel(
        rawLabel: dto.sessionLabel,
        sessionCode: dto.sessionCode,
      ),
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
      sessionLabel: _resolveSessionLabel(
        rawLabel: dto.sessionLabel,
        sessionCode: dto.sessionCode,
      ),
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
      cancelledAt: dto.cancelledAt != null
          ? DateTime.tryParse(dto.cancelledAt!)
          : null,
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
      claimedAt:
          dto.claimedAt != null ? DateTime.tryParse(dto.claimedAt!) : null,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      sessionCode: dto.sessionCode,
      sessionLabel: _resolveSessionLabel(
        rawLabel: dto.sessionLabel,
        sessionCode: dto.sessionCode,
      ),
      startTime: dto.startTime,
      endTime: dto.endTime,
      leaveReason: dto.leaveReason,
    );
  }
}
