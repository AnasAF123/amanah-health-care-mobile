/// Authoritative domain policy representing clinic consultation parameters.
class ClinicConsultationPolicy {
  final String id;
  final String code;
  final int defaultConsultationDurationMinutes;
  final int defaultStartPrecisionMinutes;
  final int checkInWindowHours;

  const ClinicConsultationPolicy({
    required this.id,
    required this.code,
    required this.defaultConsultationDurationMinutes,
    required this.defaultStartPrecisionMinutes,
    required this.checkInWindowHours,
  });

  /// Canonical default consultation parameters.
  static const ClinicConsultationPolicy defaultConsultationPolicy =
      ClinicConsultationPolicy(
    id: 'default',
    code: 'default',
    defaultConsultationDurationMinutes: 30,
    defaultStartPrecisionMinutes: 1,
    checkInWindowHours: 24,
  );

  factory ClinicConsultationPolicy.fromJson(Map<String, dynamic> json) {
    return ClinicConsultationPolicy(
      id: json['id'] as String? ?? defaultConsultationPolicy.id,
      code: json['code'] as String? ?? defaultConsultationPolicy.code,
      defaultConsultationDurationMinutes:
          (json['defaultConsultationDurationMinutes'] as num?)?.toInt() ??
              defaultConsultationPolicy.defaultConsultationDurationMinutes,
      defaultStartPrecisionMinutes:
          (json['defaultStartPrecisionMinutes'] as num?)?.toInt() ??
              defaultConsultationPolicy.defaultStartPrecisionMinutes,
      checkInWindowHours:
          (json['checkInWindowHours'] as num?)?.toInt() ??
              defaultConsultationPolicy.checkInWindowHours,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'defaultConsultationDurationMinutes': defaultConsultationDurationMinutes,
      'defaultStartPrecisionMinutes': defaultStartPrecisionMinutes,
      'checkInWindowHours': checkInWindowHours,
    };
  }
}
