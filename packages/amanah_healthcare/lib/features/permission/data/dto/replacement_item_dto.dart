class ReplacementItemDto {
  const ReplacementItemDto({
    required this.id,
    required this.leaveRequestId,
    required this.sessionId,
    required this.workDate,
    required this.originalStaffProfileId,
    this.originalPractitionerId,
    this.claimedByStaffProfileId,
    this.claimedByPractitionerId,
    required this.status,
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
  final String? claimedAt;
  final String createdAt;
  final String? sessionCode;
  final String? sessionLabel;

  factory ReplacementItemDto.fromJson(Map<String, dynamic> json) {
    return ReplacementItemDto(
      id: json['id']?.toString() ?? '',
      leaveRequestId: json['leaveRequestId']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      workDate: json['workDate']?.toString() ?? '',
      originalStaffProfileId:
          json['originalStaffProfileId']?.toString() ?? '',
      originalPractitionerId: json['originalPractitionerId']?.toString(),
      claimedByStaffProfileId: json['claimedByStaffProfileId']?.toString(),
      claimedByPractitionerId: json['claimedByPractitionerId']?.toString(),
      status: json['status']?.toString() ?? 'open',
      claimedAt: json['claimedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      sessionCode: json['sessionCode']?.toString(),
      sessionLabel: json['sessionLabel']?.toString(),
    );
  }
}
