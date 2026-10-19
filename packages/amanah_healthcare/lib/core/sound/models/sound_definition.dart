import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/sound/models/sound_source.dart';

/// Policy for handling rapid successive triggers of the same sound.
enum SoundOverlap {
  /// Stop currently playing sound and restart from beginning.
  restart,

  /// Ignore new trigger if sound is already actively playing.
  ignoreIfPlaying,
}

/// Metadata and playback parameters assigned to a [SoundCue].
@immutable
class SoundDefinition {
  const SoundDefinition({
    required this.source,
    this.volume = 1.0,
    this.overlap = SoundOverlap.restart,
  });

  /// The audio asset or source.
  final SoundSource source;

  /// Relative volume multiplier (0.0 to 1.0). Multiplied by master volume.
  final double volume;

  /// Overlap resolution policy.
  final SoundOverlap overlap;
}
