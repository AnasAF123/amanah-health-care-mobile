import 'package:amanah_healthcare/features/schedule/domain/schedule_shift_constants.dart';

class ScheduleSlotConflictInfo {
  final String type;
  final String message;
  final String? sessionId;
  final String? practitionerId;
  final String? practitionerName;
  final String? roomId;
  final String? roomName;

  const ScheduleSlotConflictInfo({
    required this.type,
    required this.message,
    this.sessionId,
    this.practitionerId,
    this.practitionerName,
    this.roomId,
    this.roomName,
  });

  factory ScheduleSlotConflictInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotConflictInfo(
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      sessionId: json['sessionId'] as String?,
      practitionerId: json['practitionerId'] as String?,
      practitionerName: json['practitionerName'] as String?,
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'message': message,
    if (sessionId != null) 'sessionId': sessionId,
    if (practitionerId != null) 'practitionerId': practitionerId,
    if (practitionerName != null) 'practitionerName': practitionerName,
    if (roomId != null) 'roomId': roomId,
    if (roomName != null) 'roomName': roomName,
  };
}

class ScheduleShiftSlot {
  final int slotIndex;
  final String startTime;
  final String endTime;
  final String timeRange;
  final bool isAvailable;
  final String status;
  final String displayLabel;
  final ScheduleSlotConflictInfo? conflictInfo;

  const ScheduleShiftSlot({
    required this.slotIndex,
    required this.startTime,
    required this.endTime,
    required this.timeRange,
    required this.isAvailable,
    required this.status,
    required this.displayLabel,
    this.conflictInfo,
  });

  factory ScheduleShiftSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleShiftSlot(
      slotIndex: json['slotIndex'] as int? ?? 0,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      timeRange: json['timeRange'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      status: json['status'] as String? ?? ScheduleCanonicalStatus.available,
      displayLabel: json['displayLabel'] as String? ?? '',
      conflictInfo: json['conflictInfo'] != null
          ? ScheduleSlotConflictInfo.fromJson(json['conflictInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'slotIndex': slotIndex,
    'startTime': startTime,
    'endTime': endTime,
    'timeRange': timeRange,
    'isAvailable': isAvailable,
    'status': status,
    'displayLabel': displayLabel,
    if (conflictInfo != null) 'conflictInfo': conflictInfo!.toJson(),
  };
}

class ScheduleShiftOccupancy {
  final String shift;
  final String shiftLabel;
  final String timeRange;
  final String boundaryStartTime;
  final String boundaryEndTime;
  final int slotDurationMinutes;
  final int totalSlots;
  final int availableSlotsCount;
  final int occupiedSlotsCount;
  final List<ScheduleShiftSlot> slots;

  const ScheduleShiftOccupancy({
    required this.shift,
    required this.shiftLabel,
    required this.timeRange,
    required this.boundaryStartTime,
    required this.boundaryEndTime,
    required this.slotDurationMinutes,
    required this.totalSlots,
    required this.availableSlotsCount,
    required this.occupiedSlotsCount,
    required this.slots,
  });

  factory ScheduleShiftOccupancy.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawSlots = json['slots'] as List<dynamic>?;
    final List<ScheduleShiftSlot> parsedSlots = rawSlots != null
        ? rawSlots
            .whereType<Map<String, dynamic>>()
            .map(ScheduleShiftSlot.fromJson)
            .toList()
        : <ScheduleShiftSlot>[];

    final String shiftCode = json['sessionShift'] as String? ??
        json['contextId'] as String? ??
        json['shift'] as String? ??
        '';
    final CanonicalShift canonicalShift =
        CanonicalShift.tryResolve(shiftCode) ?? CanonicalShift.morning;
    final String label = json['contextLabel'] as String? ??
        json['shiftLabel'] as String? ??
        json['label'] as String? ??
        canonicalShift.label;
    final String boundaryStart = json['boundaryStartTime'] as String? ??
        canonicalShift.defaultStartTime;
    final String boundaryEnd = json['boundaryEndTime'] as String? ??
        canonicalShift.defaultEndTime;
    final String timeRange = json['timeRange'] as String? ??
        '$boundaryStart - $boundaryEnd WIB';

    return ScheduleShiftOccupancy(
      shift: shiftCode,
      shiftLabel: label,
      timeRange: timeRange,
      boundaryStartTime: boundaryStart,
      boundaryEndTime: boundaryEnd,
      slotDurationMinutes: json['slotDurationMinutes'] as int? ?? 30,
      totalSlots: json['totalSlots'] as int? ?? parsedSlots.length,
      availableSlotsCount: json['availableSlotsCount'] as int? ??
          parsedSlots.where((ScheduleShiftSlot s) => s.isAvailable).length,
      occupiedSlotsCount: json['occupiedSlotsCount'] as int? ??
          parsedSlots.where((ScheduleShiftSlot s) => !s.isAvailable).length,
      slots: parsedSlots,
    );
  }
}

class ScheduleOccupancySummary {
  final int totalShifts;
  final int totalSlots;
  final int availableSlots;
  final int occupiedSlots;

  const ScheduleOccupancySummary({
    required this.totalShifts,
    required this.totalSlots,
    required this.availableSlots,
    required this.occupiedSlots,
  });

  factory ScheduleOccupancySummary.fromJson(Map<String, dynamic> json) {
    return ScheduleOccupancySummary(
      totalShifts: json['totalShifts'] as int? ?? 0,
      totalSlots: json['totalSlots'] as int? ?? 0,
      availableSlots: json['availableSlots'] as int? ?? 0,
      occupiedSlots:
          json['occupiedSlotsCount'] as int? ?? json['occupiedSlots'] as int? ?? 0,
    );
  }
}

class ScheduleOccupancyOverviewData {
  final String date;
  final String? roomId;
  final String? roomName;
  final String? practitionerId;
  final String? practitionerName;
  final int effectiveConsultationDurationMinutes;
  final ScheduleOccupancySummary summary;
  final List<ScheduleShiftOccupancy> shifts;

  const ScheduleOccupancyOverviewData({
    required this.date,
    this.roomId,
    this.roomName,
    this.practitionerId,
    this.practitionerName,
    this.effectiveConsultationDurationMinutes = 30,
    required this.summary,
    required this.shifts,
  });

  factory ScheduleOccupancyOverviewData.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawShifts = json['shifts'] as List<dynamic>?;
    final List<ScheduleShiftOccupancy> parsedShifts = rawShifts != null
        ? rawShifts
            .whereType<Map<String, dynamic>>()
            .map(ScheduleShiftOccupancy.fromJson)
            .toList()
        : <ScheduleShiftOccupancy>[];

    return ScheduleOccupancyOverviewData(
      date: json['date'] as String? ?? '',
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
      practitionerId: json['practitionerId'] as String?,
      practitionerName: json['practitionerName'] as String?,
      effectiveConsultationDurationMinutes:
          json['effectiveConsultationDurationMinutes'] as int? ?? 30,
      summary: json['summary'] is Map<String, dynamic>
          ? ScheduleOccupancySummary.fromJson(json['summary'] as Map<String, dynamic>)
          : ScheduleOccupancySummary(
              totalShifts: parsedShifts.length,
              totalSlots: parsedShifts.fold(
                0,
                (int acc, ScheduleShiftOccupancy s) => acc + s.totalSlots,
              ),
              availableSlots: parsedShifts.fold(
                0,
                (int acc, ScheduleShiftOccupancy s) => acc + s.availableSlotsCount,
              ),
              occupiedSlots: parsedShifts.fold(
                0,
                (int acc, ScheduleShiftOccupancy s) => acc + s.occupiedSlotsCount,
              ),
            ),
      shifts: parsedShifts,
    );
  }
}
