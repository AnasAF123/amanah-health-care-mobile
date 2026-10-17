/// Domain entity representing a practitioner clinical session / shift.
class QueueSessionInfo {
  const QueueSessionInfo({
    required this.sessionId,
    required this.sessionShift,
    required this.sessionLabel,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    required this.roomName,
    required this.poliklinikName,
    required this.bookedCount,
    required this.isAvailable,
  });

  final String sessionId;
  final String sessionShift;
  final String sessionLabel;
  final String scheduleDate;
  final String startTime;
  final String endTime;
  final String roomName;
  final String poliklinikName;
  final int bookedCount;
  final bool isAvailable;

  String get timeRange => '$startTime - $endTime';
}
