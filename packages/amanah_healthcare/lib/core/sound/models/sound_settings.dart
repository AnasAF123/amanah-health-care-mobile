import 'package:flutter/foundation.dart';

/// Immutable settings governing overall application audio behavior.
@immutable
class SoundSettings {
  const SoundSettings({
    this.enabled = true,
    double volume = 1.0,
  }) : volume = volume < 0.0 ? 0.0 : (volume > 1.0 ? 1.0 : volume);

  /// Global master mute/unmute switch.
  final bool enabled;

  /// Global master volume clamped between 0.0 and 1.0.
  final double volume;

  SoundSettings copyWith({
    bool? enabled,
    double? volume,
  }) {
    return SoundSettings(
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SoundSettings &&
      other.enabled == enabled &&
      other.volume == volume;

  @override
  int get hashCode => Object.hash(enabled, volume);

  @override
  String toString() => 'SoundSettings(enabled: $enabled, volume: $volume)';
}
