class MyScheduleSessionDto {
  const MyScheduleSessionDto({
    required this.id,
    required this.sessionId,
    required this.sessionCode,
    required this.sessionLabel,
    required this.scheduleDate,
    this.startTime,
    this.endTime,
    this.timeRange,
    this.roomName,
    this.poliklinikName,
    required this.status,
    required this.isAvailable,
    this.bookedCount = 0,
    this.maxQuota = 0,
    this.isReplacement = false,
    this.replacedStaffName,
    this.notes,
    this.attendanceStatus,
    this.attendanceStatusLabel,
  });

  factory MyScheduleSessionDto.fromJson(Map<String, dynamic> json) {
    final String sessionShift = (json['sessionShift'] ?? json['sessionCode'] ?? '') as String;
    final String sessionLabel =
        (json['sessionLabel'] ?? (sessionShift.isNotEmpty ? sessionShift : 'Sesi Praktik'))
            as String;

    return MyScheduleSessionDto(
      id: (json['id'] ?? '') as String,
      sessionId: (json['sessionId'] ?? json['id'] ?? '') as String,
      sessionCode: sessionShift,
      sessionLabel: sessionLabel,
      scheduleDate: (json['scheduleDate'] ?? json['specificDate'] ?? '') as String,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      timeRange: json['timeRange'] as String?,
      roomName: (json['roomName'] ?? json['room']) as String?,
      poliklinikName: (json['poliklinikName'] ?? json['poli']) as String?,
      status: (json['status'] ?? json['effectiveStatus'] ?? '') as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      bookedCount: (json['bookedCount'] ?? 0) as int,
      maxQuota: (json['maxQuota'] ?? 0) as int,
      isReplacement: json['isReplacement'] as bool? ?? false,
      replacedStaffName: json['replacedStaffName'] as String?,
      notes: json['notes'] as String?,
      attendanceStatus: json['attendanceStatus'] as String?,
      attendanceStatusLabel: json['attendanceStatusLabel'] as String?,
    );
  }

  final String id;
  final String sessionId;
  final String sessionCode;
  final String sessionLabel;
  final String scheduleDate;
  final String? startTime;
  final String? endTime;
  final String? timeRange;
  final String? roomName;
  final String? poliklinikName;
  final String status;
  final bool isAvailable;
  final int bookedCount;
  final int maxQuota;
  final bool isReplacement;
  final String? replacedStaffName;
  final String? notes;
  final String? attendanceStatus;
  final String? attendanceStatusLabel;
}
