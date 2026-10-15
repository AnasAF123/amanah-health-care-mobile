import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/logging/app_logger.dart';
import 'package:amanah_healthcare/core/network/client/observable_http_client.dart';
import 'package:amanah_healthcare/core/network/observability/http_observability_config.dart';

/// Centralized HTTP client composition root.
///
/// Ensures all repositories and services automatically inherit HTTP observability
/// and correlation tracing without manual logging in feature code.
class AmanahHttpClient {
  const AmanahHttpClient._();

  static http.Client? _overrideClient;
  static ObservableHttpClient? _defaultObservableClient;

  /// Default application HTTP client equipped with full observability pipeline.
  static http.Client get instance {
    if (_overrideClient != null) {
      return _overrideClient!;
    }
    _defaultObservableClient ??= ObservableHttpClient();
    return _defaultObservableClient!;
  }

  /// Creates a new configured [ObservableHttpClient] wrapping a specific base [http.Client].
  static ObservableHttpClient create({
    http.Client? innerClient,
    AppLogger? logger,
    HttpObservabilityConfig? config,
  }) {
    return ObservableHttpClient(
      innerClient: innerClient,
      logger: logger,
      config: config,
    );
  }

  /// Sets an override client (primarily used in testing).
  static void setOverrideClient(http.Client? client) {
    _overrideClient = client;
  }

  /// Resets instance state.
  static void reset() {
    _overrideClient = null;
    _defaultObservableClient = null;
  }
}
