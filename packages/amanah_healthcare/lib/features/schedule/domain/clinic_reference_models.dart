class ClinicRoomReference {
  const ClinicRoomReference({
    required this.id,
    required this.code,
    required this.name,
    this.location,
    this.floor,
    this.isOccupied = false,
    this.occupiedBy,
  });

  factory ClinicRoomReference.fromJson(Map<String, dynamic> json) {
    return ClinicRoomReference(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String?,
      floor: json['floor'] as String?,
      isOccupied: json['isOccupied'] as bool? ?? false,
      occupiedBy: json['occupiedBy'] as String?,
    );
  }

  final String id;
  final String code;
  final String name;
  final String? location;
  final String? floor;
  final bool isOccupied;
  final String? occupiedBy;
}

class ClinicPoliklinikReference {
  const ClinicPoliklinikReference({
    required this.id,
    required this.code,
    required this.name,
    this.location,
  });

  factory ClinicPoliklinikReference.fromJson(Map<String, dynamic> json) {
    return ClinicPoliklinikReference(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String?,
    );
  }

  final String id;
  final String code;
  final String name;
  final String? location;
}

class ClinicShiftReference {
  const ClinicShiftReference({
    required this.id,
    required this.label,
    required this.shift,
    required this.startTime,
    required this.endTime,
  });

  factory ClinicShiftReference.fromJson(Map<String, dynamic> json) {
    return ClinicShiftReference(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      shift: json['shift'] as String? ?? 'morning',
      startTime: json['startTime'] as String? ?? '06:00',
      endTime: json['endTime'] as String? ?? '12:00',
    );
  }

  final String id;
  final String label;
  final String shift;
  final String startTime;
  final String endTime;
}

class ClinicStatusReference {
  const ClinicStatusReference({
    required this.id,
    required this.label,
  });

  factory ClinicStatusReference.fromJson(Map<String, dynamic> json) {
    return ClinicStatusReference(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  final String id;
  final String label;
}

class ClinicScheduleOptionsReference {
  const ClinicScheduleOptionsReference({
    required this.shifts,
    required this.statuses,
    required this.timeIntervals,
    this.effectiveConsultationDurationMinutes = 30,
    this.durationSource = 'CLINIC_CONFIG',
  });

  factory ClinicScheduleOptionsReference.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawShifts = json['shifts'] as List<dynamic>?;
    final List<ClinicShiftReference> shifts = rawShifts != null
        ? rawShifts
            .whereType<Map<String, dynamic>>()
            .map(ClinicShiftReference.fromJson)
            .toList()
        : const <ClinicShiftReference>[];

    final List<dynamic>? rawStatuses = json['statuses'] as List<dynamic>?;
    final List<ClinicStatusReference> statuses = rawStatuses != null
        ? rawStatuses
            .whereType<Map<String, dynamic>>()
            .map(ClinicStatusReference.fromJson)
            .toList()
        : const <ClinicStatusReference>[];

    final List<dynamic>? rawIntervals = json['timeSlotIntervals'] as List<dynamic>?;
    final List<int> intervals = rawIntervals != null
        ? rawIntervals.whereType<num>().map((num n) => n.toInt()).toList()
        : const <int>[30];

    return ClinicScheduleOptionsReference(
      shifts: shifts,
      statuses: statuses,
      timeIntervals: intervals,
      effectiveConsultationDurationMinutes:
          json['effectiveConsultationDurationMinutes'] as int? ?? 30,
      durationSource: json['durationSource'] as String? ?? 'CLINIC_CONFIG',
    );
  }

  final List<ClinicShiftReference> shifts;
  final List<ClinicStatusReference> statuses;
  final List<int> timeIntervals;
  final int effectiveConsultationDurationMinutes;
  final String durationSource;
}
