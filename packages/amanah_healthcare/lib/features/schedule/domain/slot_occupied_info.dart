class SlotOccupiedInfo {
  final String time;
  final String? timeRange;
  final String statusLabel;
  final String occupiedBy;
  final String? poliName;
  final String? roomName;
  final String reason;
  final int? bookedPatientsCount;

  const SlotOccupiedInfo({
    required this.time,
    this.timeRange,
    this.statusLabel = 'Telah Digunakan',
    required this.occupiedBy,
    this.poliName,
    this.roomName,
    required this.reason,
    this.bookedPatientsCount,
  });
}
