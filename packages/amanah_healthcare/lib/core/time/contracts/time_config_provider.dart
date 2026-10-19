import 'package:amanah_healthcare/core/time/models/clinic_time_config.dart';

/// Contract for providing and refreshing clinic time configuration.
///
/// Decouples time consumers from network/database transport mechanisms.
abstract interface class TimeConfigProvider {
  /// Current in-memory cached configuration (falls back to [ClinicTimeConfig.defaultConfig]).
  ClinicTimeConfig get currentConfig;

  /// Broadcast stream notifying listeners when clinic time configuration changes.
  Stream<ClinicTimeConfig> get configStream;

  /// Refreshes configuration from remote/local authority and returns the updated state.
  Future<ClinicTimeConfig> fetchConfig();

  /// Updates current in-memory configuration and notifies active listeners.
  void updateConfig(ClinicTimeConfig newConfig);
}
