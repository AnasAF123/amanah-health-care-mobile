/// Pure Dart domain entity representing attendance scan or checkout confirmation.
class AttendanceCheckInResult {
  const AttendanceCheckInResult({
    required this.id,
    required this.staffId,
    required this.shift,
    required this.status,
    required this.checkInAt,
    required this.timeFormatted,
    this.checkOutAt,
    this.validatedDurationHours,
    this.isReplacement = false,
    this.replacedStaffName,
    this.isEarlyDeparture = false,
    this.notes,
  });

  final String id;
  final String staffId;
  final String shift;
  final String status;
  final DateTime checkInAt;
  final String timeFormatted;
  final DateTime? checkOutAt;
  final double? validatedDurationHours;
  final bool isReplacement;
  final String? replacedStaffName;
  final bool isEarlyDeparture;
  final String? notes;
}
