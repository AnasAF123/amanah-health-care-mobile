import 'package:amanah_healthcare/features/schedule/domain/clinic_reference_models.dart';

class ScheduleDoctorReference {
  const ScheduleDoctorReference({
    required this.id,
    required this.name,
    this.defaultRoomId,
    this.defaultRoomName,
    this.defaultPoliklinikId,
    this.defaultPoliklinikName,
    this.consultationDurationMinutes = 30,
  });

  factory ScheduleDoctorReference.fromJson(Map<String, dynamic> json) {
    return ScheduleDoctorReference(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      defaultRoomId: json['defaultRoomId'] as String?,
      defaultRoomName: json['defaultRoomName'] as String?,
      defaultPoliklinikId: json['defaultPoliklinikId'] as String?,
      defaultPoliklinikName: json['defaultPoliklinikName'] as String?,
      consultationDurationMinutes:
          json['consultationDurationMinutes'] as int? ?? 30,
    );
  }

  final String id;
  final String name;
  final String? defaultRoomId;
  final String? defaultRoomName;
  final String? defaultPoliklinikId;
  final String? defaultPoliklinikName;
  final int consultationDurationMinutes;
}

class ScheduleBootstrapExistingSchedule {
  const ScheduleBootstrapExistingSchedule({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.roomId,
    this.roomName,
  });

  factory ScheduleBootstrapExistingSchedule.fromJson(Map<String, dynamic> json) {
    return ScheduleBootstrapExistingSchedule(
      id: json['id'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: json['status'] as String? ?? '',
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
    );
  }

  final String id;
  final String startTime;
  final String endTime;
  final String status;
  final String? roomId;
  final String? roomName;
}

class ScheduleBootstrapShift {
  const ScheduleBootstrapShift({
    required this.id,
    required this.code,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.isPast,
    this.existingSchedule,
  });

  factory ScheduleBootstrapShift.fromJson(Map<String, dynamic> json) {
    return ScheduleBootstrapShift(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      isPast: json['isPast'] as bool? ?? false,
      existingSchedule: json['existingSchedule'] is Map<String, dynamic>
          ? ScheduleBootstrapExistingSchedule.fromJson(
              json['existingSchedule'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String id;
  final String code;
  final String name;
  final String startTime;
  final String endTime;
  final bool isPast;
  final ScheduleBootstrapExistingSchedule? existingSchedule;
}

class ScheduleFormBootstrapData {
  const ScheduleFormBootstrapData({
    required this.doctor,
    required this.rooms,
    required this.polikliniks,
    required this.shifts,
  });

  factory ScheduleFormBootstrapData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> doctorJson =
        json['doctor'] is Map<String, dynamic>
            ? json['doctor'] as Map<String, dynamic>
            : const <String, dynamic>{};
    final List<dynamic>? rawRooms = json['rooms'] as List<dynamic>?;
    final List<dynamic>? rawPolis = json['polikliniks'] as List<dynamic>?;
    final List<dynamic>? rawShifts = json['shifts'] as List<dynamic>?;

    return ScheduleFormBootstrapData(
      doctor: ScheduleDoctorReference.fromJson(doctorJson),
      rooms: rawRooms != null
          ? rawRooms
              .whereType<Map<String, dynamic>>()
              .map(ClinicRoomReference.fromJson)
              .toList()
          : const <ClinicRoomReference>[],
      polikliniks: rawPolis != null
          ? rawPolis
              .whereType<Map<String, dynamic>>()
              .map(ClinicPoliklinikReference.fromJson)
              .toList()
          : const <ClinicPoliklinikReference>[],
      shifts: rawShifts != null
          ? rawShifts
              .whereType<Map<String, dynamic>>()
              .map(ScheduleBootstrapShift.fromJson)
              .toList()
          : const <ScheduleBootstrapShift>[],
    );
  }

  final ScheduleDoctorReference doctor;
  final List<ClinicRoomReference> rooms;
  final List<ClinicPoliklinikReference> polikliniks;
  final List<ScheduleBootstrapShift> shifts;
}

class ScheduleSlotConflictDetail {
  const ScheduleSlotConflictDetail({
    required this.type,
    this.occupantName,
    this.reason,
  });

  factory ScheduleSlotConflictDetail.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotConflictDetail(
      type: json['type'] as String? ?? '',
      occupantName: json['occupantName'] as String?,
      reason: json['reason'] as String?,
    );
  }

  final String type;
  final String? occupantName;
  final String? reason;
}

class ScheduleSlotAvailabilityItem {
  const ScheduleSlotAvailabilityItem({
    required this.slotIndex,
    required this.time,
    required this.endTime,
    required this.isAvailable,
    required this.status,
    required this.displayLabel,
    this.conflict,
  });

  factory ScheduleSlotAvailabilityItem.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotAvailabilityItem(
      slotIndex: json['slotIndex'] as int? ?? 0,
      time: json['time'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      status: json['status'] as String? ?? 'AVAILABLE',
      displayLabel: json['displayLabel'] as String? ?? 'Tersedia',
      conflict: json['conflict'] is Map<String, dynamic>
          ? ScheduleSlotConflictDetail.fromJson(
              json['conflict'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final int slotIndex;
  final String time;
  final String endTime;
  final bool isAvailable;
  final String status;
  final String displayLabel;
  final ScheduleSlotConflictDetail? conflict;
}

class ScheduleSlotAvailabilityData {
  const ScheduleSlotAvailabilityData({
    required this.date,
    required this.shift,
    this.roomId,
    this.roomName,
    required this.totalSlots,
    required this.availableSlots,
    required this.occupiedSlots,
    required this.slots,
  });

  factory ScheduleSlotAvailabilityData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? roomJson =
        json['room'] is Map<String, dynamic>
            ? json['room'] as Map<String, dynamic>
            : null;
    final Map<String, dynamic>? summaryJson =
        json['summary'] is Map<String, dynamic>
            ? json['summary'] as Map<String, dynamic>
            : null;
    final List<dynamic>? rawSlots = json['slots'] as List<dynamic>?;

    final List<ScheduleSlotAvailabilityItem> parsedSlots = rawSlots != null
        ? rawSlots
            .whereType<Map<String, dynamic>>()
            .map(ScheduleSlotAvailabilityItem.fromJson)
            .toList()
        : const <ScheduleSlotAvailabilityItem>[];

    return ScheduleSlotAvailabilityData(
      date: json['date'] as String? ?? '',
      shift: json['shift'] as String? ?? '',
      roomId: roomJson != null
          ? roomJson['id'] as String?
          : json['roomId'] as String?,
      roomName: roomJson != null
          ? roomJson['name'] as String?
          : json['roomName'] as String?,
      totalSlots: summaryJson != null
          ? summaryJson['totalSlots'] as int? ?? parsedSlots.length
          : parsedSlots.length,
      availableSlots: summaryJson != null
          ? summaryJson['availableSlots'] as int? ??
              parsedSlots.where((ScheduleSlotAvailabilityItem s) => s.isAvailable).length
          : parsedSlots.where((ScheduleSlotAvailabilityItem s) => s.isAvailable).length,
      occupiedSlots: summaryJson != null
          ? summaryJson['occupiedSlots'] as int? ??
              parsedSlots.where((ScheduleSlotAvailabilityItem s) => !s.isAvailable).length
          : parsedSlots.where((ScheduleSlotAvailabilityItem s) => !s.isAvailable).length,
      slots: parsedSlots,
    );
  }

  final String date;
  final String shift;
  final String? roomId;
  final String? roomName;
  final int totalSlots;
  final int availableSlots;
  final int occupiedSlots;
  final List<ScheduleSlotAvailabilityItem> slots;
}
