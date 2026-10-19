import 'dart:async';
import 'package:amanah_healthcare/core/time/contracts/time_config_provider.dart';
import 'package:amanah_healthcare/core/time/models/clinic_time_config.dart';

/// Default in-memory implementation of [TimeConfigProvider].
///
/// Starts with authoritative defaults matching backend PostgreSQL `clinic_setting`
/// and allows dynamic runtime updates from remote API or WebSocket sync.
class DefaultTimeConfigProvider implements TimeConfigProvider {
  ClinicTimeConfig _config;
  final StreamController<ClinicTimeConfig> _controller =
      StreamController<ClinicTimeConfig>.broadcast();

  DefaultTimeConfigProvider({ClinicTimeConfig? initialConfig})
      : _config = initialConfig ?? ClinicTimeConfig.defaultConfig;

  @override
  ClinicTimeConfig get currentConfig => _config;

  @override
  Stream<ClinicTimeConfig> get configStream => _controller.stream;

  @override
  Future<ClinicTimeConfig> fetchConfig() async {
    // In default standalone mode, returns the current in-memory cached configuration.
    // Can be overridden or injected with a remote HTTP fetcher in the data layer.
    return _config;
  }

  @override
  void updateConfig(ClinicTimeConfig newConfig) {
    _config = newConfig;
    if (!_controller.isClosed) {
      _controller.add(_config);
    }
  }

  void dispose() {
    _controller.close();
  }
}
