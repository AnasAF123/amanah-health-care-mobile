/// Authoritative domain schedule policy representing clinic shift and consultation time boundaries.
///
/// Mirrors backend [ClinicSchedulePolicyData] schema from `clinic-config.types.ts`.
class ClinicSchedulePolicy {
  final String id;
  final String code;
  final int defaultConsultationDurationMinutes;
  final int defaultStartPrecisionMinutes;
  final String earlyMorningStart;
  final String earlyMorningEnd;
  final String morningStart;
  final String morningEnd;
  final String afternoonStart;
  final String afternoonEnd;
  final String nightStart;
  final String nightEnd;
  final int checkInWindowHours;

  const ClinicSchedulePolicy({
    required this.id,
    required this.code,
    required this.defaultConsultationDurationMinutes,
    required this.defaultStartPrecisionMinutes,
    required this.earlyMorningStart,
    required this.earlyMorningEnd,
    required this.morningStart,
    required this.morningEnd,
    required this.afternoonStart,
    required this.afternoonEnd,
    required this.nightStart,
    required this.nightEnd,
    required this.checkInWindowHours,
  });

  /// Canonical default policy matching backend `DEFAULT_SCHEDULE_POLICY`.
  static const ClinicSchedulePolicy defaultPolicy = ClinicSchedulePolicy(
    id: 'default',
    code: 'default',
    defaultConsultationDurationMinutes: 30,
    defaultStartPrecisionMinutes: 1,
    earlyMorningStart: '00:00',
    earlyMorningEnd: '06:00',
    morningStart: '06:00',
    morningEnd: '12:00',
    afternoonStart: '12:00',
    afternoonEnd: '18:00',
    nightStart: '18:00',
    nightEnd: '24:00',
    checkInWindowHours: 24,
  );

  factory ClinicSchedulePolicy.fromJson(Map<String, dynamic> json) {
    return ClinicSchedulePolicy(
      id: json['id'] as String? ?? defaultPolicy.id,
      code: json['code'] as String? ?? defaultPolicy.code,
      defaultConsultationDurationMinutes:
          (json['defaultConsultationDurationMinutes'] as num?)?.toInt() ??
              defaultPolicy.defaultConsultationDurationMinutes,
      defaultStartPrecisionMinutes:
          (json['defaultStartPrecisionMinutes'] as num?)?.toInt() ??
              defaultPolicy.defaultStartPrecisionMinutes,
      earlyMorningStart:
          json['earlyMorningStart'] as String? ?? defaultPolicy.earlyMorningStart,
      earlyMorningEnd:
          json['earlyMorningEnd'] as String? ?? defaultPolicy.earlyMorningEnd,
      morningStart:
          json['morningStart'] as String? ?? defaultPolicy.morningStart,
      morningEnd:
          json['morningEnd'] as String? ?? defaultPolicy.morningEnd,
      afternoonStart:
          json['afternoonStart'] as String? ?? defaultPolicy.afternoonStart,
      afternoonEnd:
          json['afternoonEnd'] as String? ?? defaultPolicy.afternoonEnd,
      nightStart:
          json['nightStart'] as String? ?? defaultPolicy.nightStart,
      nightEnd:
          json['nightEnd'] as String? ?? defaultPolicy.nightEnd,
      checkInWindowHours:
          (json['checkInWindowHours'] as num?)?.toInt() ??
              defaultPolicy.checkInWindowHours,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'defaultConsultationDurationMinutes': defaultConsultationDurationMinutes,
      'defaultStartPrecisionMinutes': defaultStartPrecisionMinutes,
      'earlyMorningStart': earlyMorningStart,
      'earlyMorningEnd': earlyMorningEnd,
      'morningStart': morningStart,
      'morningEnd': morningEnd,
      'afternoonStart': afternoonStart,
      'afternoonEnd': afternoonEnd,
      'nightStart': nightStart,
      'nightEnd': nightEnd,
      'checkInWindowHours': checkInWindowHours,
    };
  }
}
