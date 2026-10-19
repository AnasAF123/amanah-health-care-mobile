import 'package:amanah_healthcare/core/sound/models/sound_cue.dart';
import 'package:amanah_healthcare/core/sound/models/sound_definition.dart';
import 'package:amanah_healthcare/core/sound/models/sound_source.dart';

/// Core application sound cues and their canonical sound definitions.
abstract final class AppSoundCues {
  static const SoundCue success = SoundCue('core.success');
  static const SoundCue error = SoundCue('core.error');
  static const SoundCue system = SoundCue('core.system');

  static final Map<SoundCue, SoundDefinition> definitions =
      <SoundCue, SoundDefinition>{
    success: const SoundDefinition(
      source: AssetSoundSource('sounds/object-sound-succes.wav'),
      volume: 1.0,
      overlap: SoundOverlap.restart,
    ),
    error: const SoundDefinition(
      source: AssetSoundSource('sounds/object-sound-exeption.wav'),
      volume: 1.0,
      overlap: SoundOverlap.restart,
    ),
    system: const SoundDefinition(
      source: AssetSoundSource('sounds/object-sound-system.wav'),
      volume: 1.0,
      overlap: SoundOverlap.restart,
    ),
  };
}
