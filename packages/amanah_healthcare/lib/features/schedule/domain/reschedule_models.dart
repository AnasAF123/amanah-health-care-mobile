import 'package:amanah_healthcare/features/schedule/domain/schedule_shift_constants.dart';

class RescheduleSourceSession {
  final String id;
  final String scheduleDate;
  final String startTime;
  final String endTime;
  final String timeRange;
  final String status;
  final String statusLabel;
  final String sessionLabel;
  final String sessionShift;
  final String? roomName;
  final int activeAppointmentsCount;
  final bool isSourceEligible;
  final String? rejectionReason;

  const RescheduleSourceSession({
    required this.id,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    required this.timeRange,
    required this.status,
    required this.statusLabel,
    required this.sessionLabel,
    required this.sessionShift,
    this.roomName,
    this.activeAppointmentsCount = 0,
    this.isSourceEligible = true,
    this.rejectionReason,
  });

  factory RescheduleSourceSession.fromJson(Map<String, dynamic> json) {
    return RescheduleSourceSession(
      id: json['id'] as String? ?? '',
      scheduleDate: json['scheduleDate'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      timeRange: json['timeRange'] as String? ?? '',
      status: json['status'] as String? ?? ScheduleCanonicalStatus.open.toLowerCase(),
      statusLabel: json['statusLabel'] as String? ?? ScheduleCanonicalStatus.open,
      sessionLabel: json['sessionLabel'] as String? ?? CanonicalShift.morning.label,
      sessionShift: json['sessionShift'] as String? ?? CanonicalShift.morning.code,
      roomName: json['roomName'] as String?,
      activeAppointmentsCount: json['activeAppointmentsCount'] as int? ?? 0,
      isSourceEligible: json['isSourceEligible'] as bool? ?? true,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'scheduleDate': scheduleDate,
        'startTime': startTime,
        'endTime': endTime,
        'timeRange': timeRange,
        'status': status,
        'statusLabel': statusLabel,
        'sessionLabel': sessionLabel,
        'sessionShift': sessionShift,
        if (roomName != null) 'roomName': roomName,
        'activeAppointmentsCount': activeAppointmentsCount,
        'isSourceEligible': isSourceEligible,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      };
}

class RescheduleTargetValidation {
  final bool evaluated;
  final String? targetDate;
  final String? targetStartTime;
  final String? projectedEndTime;
  final String? targetRoomId;
  final String? targetRoomName;
  final bool isTargetEligible;
  final String? conflictCode;
  final String? conflictMessage;
  final dynamic conflictMetadata;

  const RescheduleTargetValidation({
    required this.evaluated,
    this.targetDate,
    this.targetStartTime,
    this.projectedEndTime,
    this.targetRoomId,
    this.targetRoomName,
    required this.isTargetEligible,
    this.conflictCode,
    this.conflictMessage,
    this.conflictMetadata,
  });

  factory RescheduleTargetValidation.fromJson(Map<String, dynamic> json) {
    return RescheduleTargetValidation(
      evaluated: json['evaluated'] as bool? ?? false,
      targetDate: json['targetDate'] as String?,
      targetStartTime: json['targetStartTime'] as String?,
      projectedEndTime: json['projectedEndTime'] as String?,
      targetRoomId: json['targetRoomId'] as String?,
      targetRoomName: json['targetRoomName'] as String?,
      isTargetEligible: json['isTargetEligible'] as bool? ??
          json['is_target_eligible'] as bool? ??
          false,
      conflictCode: json['conflictCode'] as String?,
      conflictMessage: json['conflictMessage'] as String?,
      conflictMetadata: json['conflictMetadata'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'evaluated': evaluated,
    if (targetDate != null) 'targetDate': targetDate,
    if (targetStartTime != null) 'targetStartTime': targetStartTime,
    if (projectedEndTime != null) 'projectedEndTime': projectedEndTime,
    if (targetRoomId != null) 'targetRoomId': targetRoomId,
    if (targetRoomName != null) 'targetRoomName': targetRoomName,
    'isTargetEligible': isTargetEligible,
    if (conflictCode != null) 'conflictCode': conflictCode,
    if (conflictMessage != null) 'conflictMessage': conflictMessage,
  };
}

class RescheduleEligibilityData {
  final String sessionId;
  final String? practitionerId;
  final String? practitionerName;
  final bool isEligible;
  final String? ineligibilityReason;
  final String? actionableGuidance;
  final RescheduleSourceSession? sourceSession;
  final RescheduleTargetValidation? targetValidation;

  const RescheduleEligibilityData({
    required this.sessionId,
    this.practitionerId,
    this.practitionerName,
    required this.isEligible,
    this.ineligibilityReason,
    this.actionableGuidance,
    this.sourceSession,
    this.targetValidation,
  });

  factory RescheduleEligibilityData.fromJson(Map<String, dynamic> json) {
    final dynamic payload =
        json['data'] != null && json['data'] is Map<String, dynamic>
            ? json['data']
            : json;

    return RescheduleEligibilityData(
      sessionId: payload['sessionId'] as String? ?? payload['id'] as String? ?? '',
      practitionerId: payload['practitionerId'] as String? ?? payload['doctorId'] as String?,
      practitionerName: payload['practitionerName'] as String?,
      isEligible: payload['isEligible'] as bool? ?? payload['is_eligible'] as bool? ?? false,
      ineligibilityReason: payload['ineligibilityReason'] as String? ?? payload['ineligibility_reason'] as String?,
      actionableGuidance: payload['actionableGuidance'] as String? ?? payload['actionable_guidance'] as String?,
      sourceSession: payload['sourceSession'] != null && payload['sourceSession'] is Map<String, dynamic>
          ? RescheduleSourceSession.fromJson(payload['sourceSession'] as Map<String, dynamic>)
          : null,
      targetValidation: payload['targetValidation'] != null && payload['targetValidation'] is Map<String, dynamic>
          ? RescheduleTargetValidation.fromJson(payload['targetValidation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'sessionId': sessionId,
    if (practitionerId != null) 'practitionerId': practitionerId,
    if (practitionerName != null) 'practitionerName': practitionerName,
    'isEligible': isEligible,
    if (ineligibilityReason != null) 'ineligibilityReason': ineligibilityReason,
    if (actionableGuidance != null) 'actionableGuidance': actionableGuidance,
    if (sourceSession != null) 'sourceSession': sourceSession!.toJson(),
    if (targetValidation != null) 'targetValidation': targetValidation!.toJson(),
  };
}

class RescheduleExecutionResult {
  final String sessionId;
  final String message;
  final int rescheduledAppointmentsCount;
  final String? newDate;
  final String? newStartTime;
  final String? newEndTime;

  const RescheduleExecutionResult({
    required this.sessionId,
    required this.message,
    required this.rescheduledAppointmentsCount,
    this.newDate,
    this.newStartTime,
    this.newEndTime,
  });

  factory RescheduleExecutionResult.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    final dynamic rescheduled = data['rescheduledSchedule'];

    return RescheduleExecutionResult(
      sessionId: data['sessionId'] as String? ?? '',
      message: json['message'] as String? ?? 'Jadwal dokter berhasil dijadwalkan ulang',
      rescheduledAppointmentsCount: data['rescheduledAppointmentsCount'] as int? ?? 0,
      newDate: rescheduled is Map<String, dynamic> ? rescheduled['scheduleDate'] as String? : null,
      newStartTime: rescheduled is Map<String, dynamic> ? rescheduled['startTime'] as String? : null,
      newEndTime: rescheduled is Map<String, dynamic> ? rescheduled['endTime'] as String? : null,
    );
  }
}
