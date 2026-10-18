class LeaveSessionRefDto {
  const LeaveSessionRefDto({
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

  factory LeaveSessionRefDto.fromJson(Map<String, dynamic> json) {
    return LeaveSessionRefDto(
      id: json['id']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      sessionCode: json['sessionCode']?.toString(),
      sessionLabel: json['sessionLabel']?.toString(),
      workDate: json['workDate']?.toString() ?? '',
    );
  }
}

class LeaveRequestDto {
  const LeaveRequestDto({
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
    this.sessions = const <LeaveSessionRefDto>[],
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
  final String scope;
  final String decisionSource;
  final String status;
  final String? approvedBy;
  final String? approvalNotes;
  final String? cancelledAt;
  final List<LeaveSessionRefDto> sessions;
  final String createdAt;
  final String updatedAt;

  factory LeaveRequestDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawSessions = json['sessions'] as List<dynamic>?;
    final List<LeaveSessionRefDto> parsedSessions = rawSessions != null
        ? rawSessions
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> e) => LeaveSessionRefDto.fromJson(e))
            .toList()
        : <LeaveSessionRefDto>[];

    return LeaveRequestDto(
      id: json['id']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? json['staffProfileId']?.toString() ?? '',
      practitionerId: json['practitionerId']?.toString(),
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 1,
      reason: json['reason']?.toString() ?? '',
      type: json['type']?.toString() ?? json['requestType']?.toString() ?? 'other',
      scope: json['scope']?.toString() ?? 'full_day',
      decisionSource: json['decisionSource']?.toString() ?? 'admin',
      status: json['status']?.toString() ?? 'pending',
      approvedBy: json['approvedBy']?.toString() ?? json['reviewedBy']?.toString(),
      approvalNotes: json['approvalNotes']?.toString() ?? json['reviewerNotes']?.toString(),
      cancelledAt: json['cancelledAt']?.toString(),
      sessions: parsedSessions,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
