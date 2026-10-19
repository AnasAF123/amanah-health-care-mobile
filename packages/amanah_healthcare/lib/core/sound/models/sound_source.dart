/// Sealed hierarchy representing audio resource locations.
sealed class SoundSource {
  const SoundSource();
}

/// Sound source loaded from local Flutter asset bundle.
final class AssetSoundSource extends SoundSource {
  const AssetSoundSource(this.path);

  /// Path within asset bundle, e.g. 'sounds/object-sound-succes.wav'
  final String path;

  @override
  bool operator ==(Object other) =>
      other is AssetSoundSource && other.path == path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'AssetSoundSource($path)';
}
