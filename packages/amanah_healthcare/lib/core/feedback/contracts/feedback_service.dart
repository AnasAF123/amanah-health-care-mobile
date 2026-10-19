import 'package:amanah_healthcare/core/feedback/models/feedback_variant.dart';

/// Authoritative application contract for multi-sensory feedback (sound + vibration).
abstract interface class FeedbackService {
  /// Emits sensory feedback with the specified [soundVariant] and optional [needVibration].
  Future<void> emit({
    required FeedbackSoundVariant soundVariant,
    bool needVibration = true,
  });

  /// Emits general system notification feedback (uses system sound).
  Future<void> notifySystem({bool needVibration = true});

  /// Emits general success feedback (uses object-sound-succes.wav).
  Future<void> notifySuccess({bool needVibration = true});

  /// Emits exception / error feedback (uses exception sound).
  Future<void> notifyException({bool needVibration = true});
}
