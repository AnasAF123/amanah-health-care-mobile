/// Configuration for attendance and presence validation timing.
///
/// Mirrors backend `getAttendanceConfig()` from `clinic-config.service.ts`.
class ClinicAttendanceTimeConfig {
  final int checkInWindowMinutesBefore;
  final int checkInWindowMinutesAfter;
  final int lateToleranceMinutes;
  final int qrRotationSeconds;
  final bool overtimeEnabled;

  const ClinicAttendanceTimeConfig({
    required this.checkInWindowMinutesBefore,
    required this.checkInWindowMinutesAfter,
    required this.lateToleranceMinutes,
    required this.qrRotationSeconds,
    required this.overtimeEnabled,
  });

  /// Canonical defaults matching backend PostgreSQL `clinic_setting` defaults.
  static const ClinicAttendanceTimeConfig defaultConfig =
      ClinicAttendanceTimeConfig(
    checkInWindowMinutesBefore: 60,
    checkInWindowMinutesAfter: 30,
    lateToleranceMinutes: 15,
    qrRotationSeconds: 30,
    overtimeEnabled: true,
  );

  factory ClinicAttendanceTimeConfig.fromJson(Map<String, dynamic> json) {
    return ClinicAttendanceTimeConfig(
      checkInWindowMinutesBefore:
          (json['checkInWindowMinutesBefore'] as num?)?.toInt() ??
              defaultConfig.checkInWindowMinutesBefore,
      checkInWindowMinutesAfter:
          (json['checkInWindowMinutesAfter'] as num?)?.toInt() ??
              defaultConfig.checkInWindowMinutesAfter,
      lateToleranceMinutes:
          (json['lateToleranceMinutes'] as num?)?.toInt() ??
              defaultConfig.lateToleranceMinutes,
      qrRotationSeconds:
          (json['qrRotationSeconds'] as num?)?.toInt() ??
              defaultConfig.qrRotationSeconds,
      overtimeEnabled:
          json['overtimeEnabled'] as bool? ?? defaultConfig.overtimeEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'checkInWindowMinutesBefore': checkInWindowMinutesBefore,
      'checkInWindowMinutesAfter': checkInWindowMinutesAfter,
      'lateToleranceMinutes': lateToleranceMinutes,
      'qrRotationSeconds': qrRotationSeconds,
      'overtimeEnabled': overtimeEnabled,
    };
  }
}
