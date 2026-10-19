import 'package:amanah_healthcare/core/sound/contracts/sound_catalog.dart';
import 'package:amanah_healthcare/core/sound/models/sound_cue.dart';
import 'package:amanah_healthcare/core/sound/models/sound_definition.dart';

/// Immutable, deterministic sound catalog.
///
/// Fails fast with [StateError] at startup if duplicate cues are registered.
class DefaultSoundCatalog implements SoundCatalog {
  DefaultSoundCatalog(Map<SoundCue, SoundDefinition> definitions)
      : _definitions = Map<SoundCue, SoundDefinition>.unmodifiable(definitions);

  final Map<SoundCue, SoundDefinition> _definitions;

  /// Merges multiple definition maps across modules into a single immutable catalog.
  ///
  /// Throws [StateError] immediately if duplicate cues are encountered.
  factory DefaultSoundCatalog.merge(
    Iterable<Map<SoundCue, SoundDefinition>> maps,
  ) {
    final Map<SoundCue, SoundDefinition> combined = <SoundCue, SoundDefinition>{};
    for (final Map<SoundCue, SoundDefinition> map in maps) {
      for (final MapEntry<SoundCue, SoundDefinition> entry in map.entries) {
        if (combined.containsKey(entry.key)) {
          throw StateError(
            'Duplicate SoundCue detected in catalog: "${entry.key.id}". '
            'Each SoundCue must be uniquely registered.',
          );
        }
        combined[entry.key] = entry.value;
      }
    }
    return DefaultSoundCatalog(combined);
  }

  @override
  SoundDefinition? resolve(SoundCue cue) => _definitions[cue];
}
