import 'package:amanah_healthcare/core/sound/models/sound_definition.dart';
import 'package:amanah_healthcare/core/sound/models/sound_source.dart';

/// Low-level audio playback engine port.
///
/// Decouples higher-level sound services from concrete media player frameworks.
abstract interface class SoundEngine {
  /// Prepares and warms up internal media player resources for [source].
  ///
  /// Must be idempotent and safe to invoke concurrently.
  Future<void> prepare(SoundSource source);

  /// Executes playback of [source] applying [volume] and [overlap] rules.
  Future<void> play(
    SoundSource source, {
    required double volume,
    required SoundOverlap overlap,
  });

  /// Releases all allocated system and media player resources.
  ///
  /// Must be idempotent.
  Future<void> dispose();
}
