class ReplacementItemDto {
  const ReplacementItemDto({
    required this.id,
    required this.leaveRequestId,
    required this.sessionId,
    required this.workDate,
    required this.originalStaffProfileId,
    this.originalPractitionerId,
    this.originalStaffName,
    this.originalStaffRole,
    this.originalStaffType,
    this.originalStaffAvatarUrl,
    this.claimedByStaffProfileId,
    this.claimedByPractitionerId,
    this.claimedByName,
    this.claimedByRole,
    this.claimedByAvatarUrl,
    required this.status,
    this.claimedAt,
    this.createdAt = '',
    this.sessionCode,
    this.sessionLabel,
    this.startTime,
    this.endTime,
    this.leaveReason,
  });

  final String id;
  final String leaveRequestId;
  final String sessionId;
  final String workDate;
  final String originalStaffProfileId;
  final String? originalPractitionerId;
  final String? originalStaffName;
  final String? originalStaffRole;
  final String? originalStaffType;
  final String? originalStaffAvatarUrl;
  final String? leaveReason;
  final String? claimedByStaffProfileId;
  final String? claimedByPractitionerId;
  final String? claimedByName;
  final String? claimedByRole;
  final String? claimedByAvatarUrl;
  final String status;
  final String? claimedAt;
  final String createdAt;
  final String? sessionCode;
  final String? sessionLabel;
  final String? startTime;
  final String? endTime;

  factory ReplacementItemDto.fromJson(Map<String, dynamic> json) {
    return ReplacementItemDto(
      id: json['id']?.toString() ?? '',
      leaveRequestId: json['leaveRequestId']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      workDate: json['workDate']?.toString() ?? '',
      originalStaffProfileId: json['originalStaffProfileId']?.toString() ?? '',
      originalPractitionerId: json['originalPractitionerId']?.toString(),
      originalStaffName: json['originalStaffName']?.toString(),
      originalStaffRole: json['originalStaffRole']?.toString(),
      originalStaffType: json['originalStaffType']?.toString(),
      originalStaffAvatarUrl: json['originalStaffAvatarUrl']?.toString(),
      leaveReason: json['leaveReason']?.toString(),
      claimedByStaffProfileId: json['claimedByStaffProfileId']?.toString(),
      claimedByPractitionerId: json['claimedByPractitionerId']?.toString(),
      claimedByName: json['claimedByName']?.toString(),
      claimedByRole: json['claimedByRole']?.toString(),
      claimedByAvatarUrl: json['claimedByAvatarUrl']?.toString(),
      status: json['status']?.toString() ?? 'open',
      claimedAt: json['claimedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      sessionCode: json['sessionCode']?.toString(),
      sessionLabel: json['sessionLabel']?.toString(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
    );
  }
}
