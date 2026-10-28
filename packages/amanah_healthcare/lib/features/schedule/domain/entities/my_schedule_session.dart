class MyScheduleSession {
  const MyScheduleSession({
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
