import 'package:amanah_healthcare/features/schedule/domain/schedule_shift_constants.dart';

class ScheduleContext {
  final String contextId;
  final String contextLabel;
  final String sessionShift;
  final String date;
  final String boundaryStartTime;
  final String boundaryEndTime;
  final int effectiveConsultationDurationMinutes;
  final int allowedStartPrecisionMinutes;
  final bool durationEditableByCurrentUser;

  const ScheduleContext({
    required this.contextId,
    required this.contextLabel,
    required this.sessionShift,
    required this.date,
    required this.boundaryStartTime,
    required this.boundaryEndTime,
    required this.effectiveConsultationDurationMinutes,
    required this.allowedStartPrecisionMinutes,
    required this.durationEditableByCurrentUser,
  });

  factory ScheduleContext.fromJson(Map<String, dynamic> json) {
    return ScheduleContext(
      contextId: json['contextId'] as String? ?? json['id'] as String? ?? '',
      contextLabel: json['contextLabel'] as String? ?? json['label'] as String? ?? '',
      sessionShift: json['sessionShift'] as String? ?? json['shift'] as String? ?? CanonicalShift.morning.code,
      date: json['date'] as String? ?? '',
      boundaryStartTime: json['boundaryStartTime'] as String? ?? json['startTime'] as String? ?? '',
      boundaryEndTime: json['boundaryEndTime'] as String? ?? json['endTime'] as String? ?? '',
      effectiveConsultationDurationMinutes:
          json['effectiveConsultationDurationMinutes'] as int? ?? 30,
      allowedStartPrecisionMinutes:
          json['allowedStartPrecisionMinutes'] as int? ?? 1,
      durationEditableByCurrentUser:
          json['durationEditableByCurrentUser'] as bool? ?? false,
    );
  }
}

enum ScheduleIntervalStatus {
  open(ScheduleCanonicalStatus.open, ScheduleFormConstants.statusBuka),
  occupied(ScheduleCanonicalStatus.occupied, ScheduleFormConstants.labelTerisi),
  closed(ScheduleCanonicalStatus.closed, ScheduleFormConstants.statusTutup);

  final String code;
  final String label;
  const ScheduleIntervalStatus(this.code, this.label);

  static ScheduleIntervalStatus fromCode(String code) {
    final String upper = code.toUpperCase();
    if (upper == ScheduleCanonicalStatus.occupied || upper == ScheduleCanonicalStatus.terisi) {
      return ScheduleIntervalStatus.occupied;
    }
    if (upper == ScheduleCanonicalStatus.closed || upper == ScheduleCanonicalStatus.tutup) {
      return ScheduleIntervalStatus.closed;
    }
    return ScheduleIntervalStatus.open;
  }
}

class AppointmentRef {
  final String appointmentId;
  final String? queueNumber;
  final String status;

  const AppointmentRef({
    required this.appointmentId,
    this.queueNumber,
    required this.status,
  });

  factory AppointmentRef.fromJson(Map<String, dynamic> json) {
    return AppointmentRef(
      appointmentId: json['appointmentId'] as String? ?? '',
      queueNumber: json['queueNumber'] as String?,
      status: json['status'] as String? ?? 'booked',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'appointmentId': appointmentId,
    if (queueNumber != null) 'queueNumber': queueNumber,
    'status': status,
  };
}

class ScheduleInterval {
  final int intervalIndex;
  final String startTime;
  final String endTime;
  final ScheduleIntervalStatus status;
  final String displayLabel;
  final bool isOccupied;
  final AppointmentRef? appointmentRef;
  final String? closedReason;

  const ScheduleInterval({
    required this.intervalIndex,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.displayLabel,
    required this.isOccupied,
    this.appointmentRef,
    this.closedReason,
  });

  factory ScheduleInterval.fromJson(Map<String, dynamic> json) {
    return ScheduleInterval(
      intervalIndex: json['intervalIndex'] as int? ?? 0,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: ScheduleIntervalStatus.fromCode(json['status'] as String? ?? ScheduleCanonicalStatus.open),
      displayLabel: json['displayLabel'] as String? ?? '',
      isOccupied: json['isOccupied'] as bool? ?? false,
      appointmentRef: json['appointmentRef'] != null
          ? AppointmentRef.fromJson(json['appointmentRef'] as Map<String, dynamic>)
          : null,
      closedReason: json['closedReason'] as String?,
    );
  }
}

class ScheduleProjection {
  final String? scheduleId;
  final String date;
  final String scheduleContextId;
  final String contextLabel;
  final String selectedStartTime;
  final String projectedEndTime;
  final int effectiveConsultationDurationMinutes;
  final int capacity;
  final List<ScheduleInterval> intervals;
  final String? version;

  const ScheduleProjection({
    this.scheduleId,
    required this.date,
    required this.scheduleContextId,
    required this.contextLabel,
    required this.selectedStartTime,
    required this.projectedEndTime,
    required this.effectiveConsultationDurationMinutes,
    required this.capacity,
    required this.intervals,
    this.version,
  });

  factory ScheduleProjection.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawIntervals = json['intervals'] as List<dynamic>?;
    final List<ScheduleInterval> parsedIntervals = rawIntervals != null
        ? rawIntervals
            .whereType<Map<String, dynamic>>()
            .map(ScheduleInterval.fromJson)
            .toList()
        : <ScheduleInterval>[];

    return ScheduleProjection(
      scheduleId: json['scheduleId'] as String?,
      date: json['date'] as String? ?? '',
      scheduleContextId: json['scheduleContextId'] as String? ?? '',
      contextLabel: json['contextLabel'] as String? ?? '',
      selectedStartTime: json['selectedStartTime'] as String? ?? '',
      projectedEndTime: json['projectedEndTime'] as String? ?? '',
      effectiveConsultationDurationMinutes:
          json['effectiveConsultationDurationMinutes'] as int? ?? 30,
      capacity: json['capacity'] as int? ?? parsedIntervals.length,
      intervals: parsedIntervals,
      version: json['version'] as String?,
    );
  }
}
