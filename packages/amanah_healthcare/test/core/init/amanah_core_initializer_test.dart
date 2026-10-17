import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/init/amanah_core_initializer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CoreInitializationResult', () {
    test('reports isHealthy when required core subsystems are ready', () {
      const CoreInitializationResult result = CoreInitializationResult(
        authEnvironmentReady: true,
        betterAuthReady: true,
        cameraReady: true,
        pushNotificationsReady: true,
      );

      expect(result.isHealthy, isTrue);
      expect(result.authEnvironmentReady, isTrue);
      expect(result.betterAuthReady, isTrue);
      expect(result.pushNotificationsReady, isTrue);
    });

    test('reports !isHealthy when critical subsystem fails', () {
      const CoreInitializationResult degraded = CoreInitializationResult(
        authEnvironmentReady: false,
        betterAuthReady: true,
        cameraReady: true,
        pushNotificationsReady: true,
      );

      expect(degraded.isHealthy, isFalse);
    });
  });
}
