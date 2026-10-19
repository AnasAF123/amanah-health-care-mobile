import 'package:flutter/foundation.dart';

/// Identifier representing an event or intent for audible feedback.
///
/// Designed as a class (not an enum) so features can declare domain-specific
/// cues without modifying core layers.
@immutable
class SoundCue {
  const SoundCue(this.id);

  /// Namespaced cue identifier (e.g., 'core.success', 'presence.check_in').
  final String id;

  @override
  bool operator ==(Object other) => other is SoundCue && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SoundCue($id)';
}
