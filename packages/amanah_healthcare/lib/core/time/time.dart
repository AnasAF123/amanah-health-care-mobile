// Public API barrel for Core Time and Clinic Time Configuration subsystem.

// Contracts
export 'contracts/time_config_provider.dart';
export 'contracts/time_service.dart';

// Models & Value Objects
export 'models/calendar_date_range.dart';
export 'models/clinic_attendance_time_config.dart';
export 'models/clinic_schedule_policy.dart';
export 'models/clinic_time_config.dart';
export 'models/time_of_day_range.dart';

// Pure Functions
export 'functions/calculate_inclusive_day_count.dart';
export 'functions/calculate_overtime_minutes.dart';
export 'functions/format_iso_date_string.dart';
export 'functions/format_localized_date.dart';
export 'functions/format_localized_time.dart';
export 'functions/is_same_calendar_day.dart';
export 'functions/is_within_tolerance_window.dart';
export 'functions/normalize_to_calendar_date.dart';
export 'functions/parse_iso_date_string.dart';

// Services
export 'services/default_time_config_provider.dart';
export 'services/default_time_service.dart';
