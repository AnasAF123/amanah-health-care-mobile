import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/sound/models/sound_cue.dart';
import 'package:amanah_healthcare/core/sound/models/sound_settings.dart';

/// Application-wide authoritative contract for sound policy and cue playback.
abstract interface class SoundService {
  /// Reactive single source of truth for audio enabled state and master volume.
  ValueListenable<SoundSettings> get settings;

  /// Optional warm-up for a collection of cues.
  ///
  /// Failure of one cue does not prevent others from preparing. Idempotent.
  Future<void> preload(Iterable<SoundCue> cues);

  /// Triggers audible feedback for [cue].
  ///
  /// Completes as soon as playback initiates (does NOT wait for sound to finish).
  /// NEVER throws an exception to caller.
  Future<void> play(SoundCue cue);

  /// Sets global master enabled state.
  void setEnabled(bool enabled);

  /// Sets global master volume clamped between 0.0 and 1.0.
  void setVolume(double volume);

  /// Idempotent service disposal. Subsequent [play] calls become harmless no-ops.
  Future<void> dispose();
}
