import 'package:amanah_healthcare/core/sound/models/sound_cue.dart';
import 'package:amanah_healthcare/core/sound/models/sound_definition.dart';

/// Contract responsible for resolving a [SoundCue] to its designated [SoundDefinition].
abstract interface class SoundCatalog {
  /// Resolves a [SoundCue].
  ///
  /// Returns `null` if the cue is unmapped. This is not an exceptional state:
  /// the service decides policy for unmapped cues.
  SoundDefinition? resolve(SoundCue cue);
}
