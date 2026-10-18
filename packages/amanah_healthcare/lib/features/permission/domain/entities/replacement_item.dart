class ReplacementItem {
  const ReplacementItem({
    required this.id,
    required this.leaveRequestId,
    required this.sessionId,
    required this.workDate,
    required this.originalStaffProfileId,
    this.originalPractitionerId,
    this.claimedByStaffProfileId,
    this.claimedByPractitionerId,
    required this.status, // 'open' | 'claimed' | 'cancelled'
    this.claimedAt,
    required this.createdAt,
    this.sessionCode,
    this.sessionLabel,
  });

  final String id;
  final String leaveRequestId;
  final String sessionId;
  final String workDate;
  final String originalStaffProfileId;
  final String? originalPractitionerId;
  final String? claimedByStaffProfileId;
  final String? claimedByPractitionerId;
  final String status;
  final DateTime? claimedAt;
  final DateTime createdAt;
  final String? sessionCode;
  final String? sessionLabel;

  bool get isOpen => status == 'open';
  bool get isClaimed => status == 'claimed';
}
