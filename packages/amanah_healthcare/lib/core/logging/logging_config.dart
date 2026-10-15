import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/logging/log_level.dart';

/// Centralized configuration for the logging subsystem.
class LoggingConfig {
  const LoggingConfig({
    this.enabled = true,
    this.minLevel = LogLevel.debug,
    this.enabledCategories,
    this.enableFileOutput = true,
    this.enableConsoleOutput = false, // Keep false to avoid spamming the main stream
    this.customLogFilePath,
    this.maxFileSizeBytes = 2 * 1024 * 1024, // 2MB
    this.maxBackupFiles = 3,
    this.redactSensitiveData = true,
    this.additionalSensitiveKeys,
  });

  /// Master switch for logging.
  final bool enabled;

  /// Minimum level threshold.
  final LogLevel minLevel;

  /// Optional whitelist of enabled categories (e.g. only {LogCategory.http, LogCategory.api}).
  /// If null, all categories are active.
  final Set<LogCategory>? enabledCategories;

  /// Whether logs are dumped to disk in a dedicated log file.
  final bool enableFileOutput;

  /// Whether logs are printed to main console stream. Default is false.
  final bool enableConsoleOutput;

  /// Custom path for the log file (e.g. for testing or isolated debugging).
  final String? customLogFilePath;

  /// Maximum file size before rotation triggers.
  final int maxFileSizeBytes;

  /// Number of rotated backup files to retain.
  final int maxBackupFiles;

  /// Whether passwords, tokens, auth headers, and secrets are redacted.
  final bool redactSensitiveData;

  /// Additional application-specific sensitive keys to redact.
  final Set<String>? additionalSensitiveKeys;

  /// Determines if a category is currently active.
  bool isCategoryEnabled(LogCategory category) {
    if (!enabled) return false;
    if (enabledCategories == null) return true;
    return enabledCategories!.contains(category);
  }

  /// Determines if a log level satisfies the minimum threshold.
  bool isLevelEnabled(LogLevel level) {
    if (!enabled) return false;
    return level >= minLevel;
  }

  LoggingConfig copyWith({
    bool? enabled,
    LogLevel? minLevel,
    Set<LogCategory>? enabledCategories,
    bool? enableFileOutput,
    bool? enableConsoleOutput,
    String? customLogFilePath,
    int? maxFileSizeBytes,
    int? maxBackupFiles,
    bool? redactSensitiveData,
    Set<String>? additionalSensitiveKeys,
  }) {
    return LoggingConfig(
      enabled: enabled ?? this.enabled,
      minLevel: minLevel ?? this.minLevel,
      enabledCategories: enabledCategories ?? this.enabledCategories,
      enableFileOutput: enableFileOutput ?? this.enableFileOutput,
      enableConsoleOutput: enableConsoleOutput ?? this.enableConsoleOutput,
      customLogFilePath: customLogFilePath ?? this.customLogFilePath,
      maxFileSizeBytes: maxFileSizeBytes ?? this.maxFileSizeBytes,
      maxBackupFiles: maxBackupFiles ?? this.maxBackupFiles,
      redactSensitiveData: redactSensitiveData ?? this.redactSensitiveData,
      additionalSensitiveKeys:
          additionalSensitiveKeys ?? this.additionalSensitiveKeys,
    );
  }
}
