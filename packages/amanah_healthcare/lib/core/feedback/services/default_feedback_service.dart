import 'dart:async';
import 'package:amanah_healthcare/core/feedback/contracts/feedback_service.dart';
import 'package:amanah_healthcare/core/feedback/contracts/haptics_engine.dart';
import 'package:amanah_healthcare/core/feedback/adapters/device_haptics_engine.dart';
import 'package:amanah_healthcare/core/feedback/models/feedback_variant.dart';
import 'package:amanah_healthcare/core/sound/sound.dart';

/// Production implementation of [FeedbackService] coordinating sound and vibration.
class DefaultFeedbackService implements FeedbackService {
  const DefaultFeedbackService({
    required SoundService soundService,
    required HapticsEngine hapticsEngine,
  })  : _soundService = soundService,
        _hapticsEngine = hapticsEngine;

  final SoundService _soundService;
  final HapticsEngine _hapticsEngine;

  static FeedbackService? _instance;

  /// Global shared instance for application-wide sensory feedback.
  static FeedbackService get instance {
    return _instance ??= createDefault();
  }

  /// Sets or overrides the active instance (e.g., for testing or custom composition).
  static set instance(FeedbackService service) {
    _instance = service;
  }

  /// Creates a standard production feedback service using default sound and haptics engines.
  static DefaultFeedbackService createDefault({
    SoundService? soundService,
    HapticsEngine? hapticsEngine,
  }) {
    final SoundCatalog catalog = DefaultSoundCatalog.merge(<Map<SoundCue, SoundDefinition>>[
      AppSoundCues.definitions,
    ]);

    final SoundService sound = soundService ??
        DefaultSoundService(
          catalog: catalog,
          engine: AudioplayersSoundEngine(),
        );

    final HapticsEngine haptics = hapticsEngine ?? const DeviceHapticsEngine();

    return DefaultFeedbackService(
      soundService: sound,
      hapticsEngine: haptics,
    );
  }

  @override
  Future<void> emit({
    required FeedbackSoundVariant soundVariant,
    bool needVibration = true,
  }) async {
    try {
      final SoundCue cue = _mapVariantToCue(soundVariant);

      // Audio playback is unawaited so zero latency is introduced to caller
      unawaited(_soundService.play(cue).catchError((_) {}));

      if (needVibration) {
        await _triggerHaptics(soundVariant);
      }
    } catch (_) {
      // Feedback emission must never disrupt business flows
    }
  }

  @override
  Future<void> notifySystem({bool needVibration = true}) =>
      emit(soundVariant: FeedbackSoundVariant.system, needVibration: needVibration);

  @override
  Future<void> notifySuccess({bool needVibration = true}) =>
      emit(soundVariant: FeedbackSoundVariant.success, needVibration: needVibration);

  @override
  Future<void> notifyException({bool needVibration = true}) =>
      emit(soundVariant: FeedbackSoundVariant.exception, needVibration: needVibration);

  SoundCue _mapVariantToCue(FeedbackSoundVariant variant) {
    switch (variant) {
      case FeedbackSoundVariant.success:
        return AppSoundCues.success;
      case FeedbackSoundVariant.exception:
        return AppSoundCues.error;
      case FeedbackSoundVariant.system:
        return AppSoundCues.system;
    }
  }

  Future<void> _triggerHaptics(FeedbackSoundVariant variant) async {
    try {
      switch (variant) {
        case FeedbackSoundVariant.success:
          await _hapticsEngine.success();
        case FeedbackSoundVariant.exception:
          await _hapticsEngine.error();
        case FeedbackSoundVariant.system:
          await _hapticsEngine.light();
      }
    } catch (_) {
      // Hardware haptic errors safely suppressed
    }
  }
}
