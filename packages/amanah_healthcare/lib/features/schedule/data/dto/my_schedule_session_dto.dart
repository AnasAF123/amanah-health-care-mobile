
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
  });

  factory MyScheduleSessionDto.fromJson(Map<String, dynamic> json) {
    final String resolvedCode =
        json['sessionCode'] as String? ?? json['session']?.toString() ?? '';
    final String resolvedLabel =
        json['sessionLabel'] as String? ?? json['title'] as String? ?? (resolvedCode.isNotEmpty ? resolvedCode : 'Sesi Praktik');

    return MyScheduleSessionDto(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? json['id'] as String? ?? '',
      sessionCode: resolvedCode,
      sessionLabel: resolvedLabel,
      scheduleDate: json['scheduleDate'] as String? ??
          json['specificDate'] as String? ??
          '',
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      timeRange: json['timeRange'] as String? ??
          '${json['startTime'] ?? ''} - ${json['endTime'] ?? ''}',
      roomName: json['roomName'] as String? ?? json['room'] as String?,
      poliklinikName: json['poliklinikName'] as String? ?? json['poli'] as String?,
      status: json['status'] as String? ??
          json['effectiveStatus'] as String? ??
          'OPEN',
      isAvailable: json['isAvailable'] as bool? ?? true,
      bookedCount: json['bookedCount'] as int? ??
          json['totalBookedPatients'] as int? ??
          0,
      maxQuota: json['maxQuota'] as int? ?? 0,
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
}
