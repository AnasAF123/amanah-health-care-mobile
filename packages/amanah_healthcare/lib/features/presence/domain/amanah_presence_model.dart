enum AttendanceStatus { hadir, telat, missed, cuti }

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.date,
    required this.dayNumber,
    required this.time,
    required this.title,
    required this.location,
    required this.status,
    this.isLatest = false,
    this.reason,
    this.lateDuration,
  });

  final String id;
  final String date;
  final int dayNumber;
  final String time;
  final String title;
  final String location;
  final AttendanceStatus status;
  final bool isLatest;
  final String? reason;
  final String? lateDuration;
}

class AttendanceFilterOption<T> {
  const AttendanceFilterOption({
    required this.label,
    required this.value,
  });

  final String label;
  final T value;
}
