import 'package:amanah_healthcare/core/time/models/clinic_attendance_time_config.dart';
import 'package:amanah_healthcare/core/time/models/clinic_schedule_policy.dart';

/// Aggregated, service-agnostic configuration for all clinic time policies.
///
/// Serves as the single source of truth (SSOT) consumed by time services,
/// formatters, calculators, and domain use cases.
class ClinicTimeConfig {
  final String timezone;
  final String locale;
  final String dateFormatStyle;
  final String timeFormatStyle;
  final ClinicSchedulePolicy schedulePolicy;
  final ClinicAttendanceTimeConfig attendanceConfig;

  const ClinicTimeConfig({
    required this.timezone,
    required this.locale,
    required this.dateFormatStyle,
    required this.timeFormatStyle,
    required this.schedulePolicy,
    required this.attendanceConfig,
  });

  /// Canonical defaults matching backend `ClinicConfigService` fallback values.
  static const ClinicTimeConfig defaultConfig = ClinicTimeConfig(
    timezone: 'Asia/Jakarta',
    locale: 'id-ID',
    dateFormatStyle: 'human_full',
    timeFormatStyle: '24h',
    schedulePolicy: ClinicSchedulePolicy.defaultPolicy,
    attendanceConfig: ClinicAttendanceTimeConfig.defaultConfig,
  );

  ClinicTimeConfig copyWith({
    String? timezone,
    String? locale,
    String? dateFormatStyle,
    String? timeFormatStyle,
    ClinicSchedulePolicy? schedulePolicy,
    ClinicAttendanceTimeConfig? attendanceConfig,
  }) {
    return ClinicTimeConfig(
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      dateFormatStyle: dateFormatStyle ?? this.dateFormatStyle,
      timeFormatStyle: timeFormatStyle ?? this.timeFormatStyle,
      schedulePolicy: schedulePolicy ?? this.schedulePolicy,
      attendanceConfig: attendanceConfig ?? this.attendanceConfig,
    );
  }

  factory ClinicTimeConfig.fromJson(Map<String, dynamic> json) {
    return ClinicTimeConfig(
      timezone: json['timezone'] as String? ?? defaultConfig.timezone,
      locale: json['locale'] as String? ?? defaultConfig.locale,
      dateFormatStyle:
          json['dateFormatStyle'] as String? ?? defaultConfig.dateFormatStyle,
      timeFormatStyle:
          json['timeFormatStyle'] as String? ?? defaultConfig.timeFormatStyle,
      schedulePolicy: json['schedulePolicy'] != null
          ? ClinicSchedulePolicy.fromJson(
              json['schedulePolicy'] as Map<String, dynamic>,
            )
          : defaultConfig.schedulePolicy,
      attendanceConfig: json['attendanceConfig'] != null
          ? ClinicAttendanceTimeConfig.fromJson(
              json['attendanceConfig'] as Map<String, dynamic>,
            )
          : defaultConfig.attendanceConfig,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'timezone': timezone,
      'locale': locale,
      'dateFormatStyle': dateFormatStyle,
      'timeFormatStyle': timeFormatStyle,
      'schedulePolicy': schedulePolicy.toJson(),
      'attendanceConfig': attendanceConfig.toJson(),
    };
  }
}
