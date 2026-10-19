import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:amanah_healthcare/core/feedback/contracts/haptics_engine.dart';

/// Concrete [HapticsEngine] adapter utilizing device vibration hardware
/// with graceful fallback to system haptic feedback.
class DeviceHapticsEngine implements HapticsEngine {
  const DeviceHapticsEngine();

  @override
  Future<void> success() => _pulse(duration: 200);

  @override
  Future<void> error() => _pulse(pattern: const <int>[0, 150, 100, 150]);

  @override
  Future<void> light() => HapticFeedback.selectionClick();

  Future<void> _pulse({int? duration, List<int>? pattern}) async {
    try {
      final bool hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        if (pattern != null) {
          await Vibration.vibrate(pattern: pattern);
        } else if (duration != null) {
          await Vibration.vibrate(duration: duration);
        }
        return;
      }
    } catch (_) {
      // Hardware motor fallback
    }

    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
