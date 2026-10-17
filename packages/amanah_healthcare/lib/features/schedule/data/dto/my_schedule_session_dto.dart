import 'package:amanah_healthcare/features/schedule/domain/helpers/clinical_session_resolver.dart';

class MyScheduleSessionDto {
  const MyScheduleSessionDto({
    required this.id,
    required this.sessionId,
    required this.sessionShift,
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
    final ClinicalSessionShift shift = ClinicalSessionResolver.resolveShift(
      session: json['session']?.toString(),
      sessionShift: json['sessionShift'] as String?,
      sessionLabel: json['sessionLabel'] as String?,
      fallback: json['title'] as String?,
    );

    return MyScheduleSessionDto(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? json['id'] as String? ?? '',
      sessionShift: shift.code,
      sessionLabel: shift.displaySessionName,
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
  final String sessionShift;
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
