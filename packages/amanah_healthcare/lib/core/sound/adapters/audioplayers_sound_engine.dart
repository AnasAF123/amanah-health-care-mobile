import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:amanah_healthcare/core/sound/contracts/sound_engine.dart';
import 'package:amanah_healthcare/core/sound/models/sound_definition.dart';
import 'package:amanah_healthcare/core/sound/models/sound_source.dart';

/// Concrete [SoundEngine] adapter backed by `package:audioplayers`.
///
/// Enforces single AudioPlayer per [SoundSource] reuse, low-latency mode,
/// and non-interruptive audio focus policies.
class AudioplayersSoundEngine implements SoundEngine {
  AudioplayersSoundEngine();

  final Map<SoundSource, AudioPlayer> _players = <SoundSource, AudioPlayer>{};
  final Map<SoundSource, Future<void>> _inFlightPrepares =
      <SoundSource, Future<void>>{};

  bool _isDisposed = false;

  @override
  Future<void> prepare(SoundSource source) async {
    if (_isDisposed) return;
    if (_players.containsKey(source)) return;

    final Future<void>? inFlight = _inFlightPrepares[source];
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final Completer<void> completer = Completer<void>();
    completer.future.ignore();
    _inFlightPrepares[source] = completer.future;

    try {
      final AudioPlayer player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const <AVAudioSessionOptions>{
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );

      if (source is AssetSoundSource) {
        await player.setSource(AssetSource(source.path));
      }

      if (_isDisposed) {
        await player.dispose();
      } else {
        _players[source] = player;
      }
      completer.complete();
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _inFlightPrepares.remove(source);
    }
  }

  @override
  Future<void> play(
    SoundSource source, {
    required double volume,
    required SoundOverlap overlap,
  }) async {
    if (_isDisposed) return;

    if (!_players.containsKey(source)) {
      await prepare(source);
    }

    final AudioPlayer? player = _players[source];
    if (player == null || _isDisposed) return;

    if (overlap == SoundOverlap.ignoreIfPlaying &&
        player.state == PlayerState.playing) {
      return;
    }

    await player.setVolume(volume);

    if (source is AssetSoundSource) {
      if (overlap == SoundOverlap.restart) {
        await player.stop();
      }
      await player.play(
        AssetSource(source.path),
        volume: volume,
      );
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    final List<AudioPlayer> playersToDispose = _players.values.toList();
    _players.clear();
    _inFlightPrepares.clear();

    for (final AudioPlayer player in playersToDispose) {
      try {
        await player.dispose();
      } catch (_) {
        // Suppress individual player dispose errors
      }
    }
  }
}
