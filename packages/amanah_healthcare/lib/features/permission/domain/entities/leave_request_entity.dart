class LeaveSessionRef {
  const LeaveSessionRef({
    required this.id,
    required this.sessionId,
    this.sessionCode,
    this.sessionLabel,
    required this.workDate,
  });

  final String id;
  final String sessionId;
  final String? sessionCode;
  final String? sessionLabel;
  final String workDate;
}

class LeaveRequestEntity {
  const LeaveRequestEntity({
    required this.id,
    required this.staffId,
    this.practitionerId,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.reason,
    required this.type,
    required this.scope,
    required this.decisionSource,
    required this.status,
    this.approvedBy,
    this.approvalNotes,
    this.cancelledAt,
    this.substituteStaffProfileId,
    this.substituteStaffName,
    this.sessions = const <LeaveSessionRef>[],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String staffId;
  final String? practitionerId;
  final String startDate;
  final String endDate;
  final int durationDays;
  final String reason;
  final String type;
  final String scope; // 'session' | 'full_day'
  final String decisionSource; // 'admin' | 'auto'
  final String status; // 'pending' | 'approved' | 'rejected' | 'cancelled'
  final String? approvedBy;
  final String? approvalNotes;
  final String? substituteStaffProfileId;
  final String? substituteStaffName;
  final DateTime? cancelledAt;
  final List<LeaveSessionRef> sessions;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
}
