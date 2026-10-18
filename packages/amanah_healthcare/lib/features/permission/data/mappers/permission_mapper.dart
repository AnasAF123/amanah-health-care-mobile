import 'package:amanah_healthcare/features/permission/data/dto/eligible_session_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/leave_request_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/replacement_item_dto.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';

abstract final class PermissionMapper {
  static EligibleSession toEligibleSession(EligibleSessionDto dto) {
    return EligibleSession(
      sessionId: dto.sessionId,
      sessionCode: dto.sessionCode,
      sessionLabel: dto.sessionLabel,
      startsAt: dto.startsAt,
      endsAt: dto.endsAt,
      workDate: dto.workDate,
    );
  }

  static LeaveSessionRef toLeaveSessionRef(LeaveSessionRefDto dto) {
    return LeaveSessionRef(
      id: dto.id,
      sessionId: dto.sessionId,
      sessionCode: dto.sessionCode,
      sessionLabel: dto.sessionLabel,
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
      claimedByStaffProfileId: dto.claimedByStaffProfileId,
      claimedByPractitionerId: dto.claimedByPractitionerId,
      status: dto.status,
      claimedAt:
          dto.claimedAt != null ? DateTime.tryParse(dto.claimedAt!) : null,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      sessionCode: dto.sessionCode,
      sessionLabel: dto.sessionLabel,
    );
  }
}
