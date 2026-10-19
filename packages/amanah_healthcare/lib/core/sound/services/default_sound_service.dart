import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/logging/app_logger.dart';
import 'package:amanah_healthcare/core/logging/log_category.dart';
import 'package:amanah_healthcare/core/sound/contracts/sound_catalog.dart';
import 'package:amanah_healthcare/core/sound/contracts/sound_engine.dart';
import 'package:amanah_healthcare/core/sound/contracts/sound_service.dart';
import 'package:amanah_healthcare/core/sound/models/sound_cue.dart';
import 'package:amanah_healthcare/core/sound/models/sound_definition.dart';
import 'package:amanah_healthcare/core/sound/models/sound_settings.dart';

/// Production implementation of [SoundService] orchestrating catalog resolution,
/// policy enforcement, and playback engine delegation.
class DefaultSoundService implements SoundService {
  DefaultSoundService({
    required SoundCatalog catalog,
    required SoundEngine engine,
    AppLogger? logger,
    SoundSettings initialSettings = const SoundSettings(),
  })  : _catalog = catalog,
        _engine = engine,
        _logger = logger ?? AppLog.instance,
        _settingsNotifier = ValueNotifier<SoundSettings>(initialSettings);

  final SoundCatalog _catalog;
  final SoundEngine _engine;
  final AppLogger _logger;
  final ValueNotifier<SoundSettings> _settingsNotifier;

  bool _isDisposed = false;
  final Set<String> _unmappedCueWarnings = <String>{};

  @override
  ValueListenable<SoundSettings> get settings => _settingsNotifier;

  @override
  Future<void> preload(Iterable<SoundCue> cues) async {
    if (_isDisposed || !_settingsNotifier.value.enabled) return;

    for (final SoundCue cue in cues) {
      final SoundDefinition? definition = _catalog.resolve(cue);
      if (definition == null) continue;

      try {
        await _engine.prepare(definition.source);
      } catch (e, st) {
        _logger.warning(
          '[SOUND] Failed to preload sound cue: "${cue.id}"',
          category: LogCategory.system,
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  @override
  Future<void> play(SoundCue cue) async {
    if (_isDisposed) return;

    final SoundSettings currentSettings = _settingsNotifier.value;
    if (!currentSettings.enabled) return;

    final SoundDefinition? definition = _catalog.resolve(cue);
    if (definition == null) {
      if (_unmappedCueWarnings.add(cue.id)) {
        _logger.warning(
          '[SOUND] Unmapped sound cue: "${cue.id}". Playback skipped.',
          category: LogCategory.system,
        );
      }
      return;
    }

    final double effectiveVolume =
        (definition.volume * currentSettings.volume).clamp(0.0, 1.0);

    try {
      await _engine.play(
        definition.source,
        volume: effectiveVolume,
        overlap: definition.overlap,
      );
    } catch (e, st) {
      _logger.warning(
        '[SOUND] Playback failed for cue: "${cue.id}"',
        category: LogCategory.system,
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  void setEnabled(bool enabled) {
    if (_isDisposed) return;
    _settingsNotifier.value = _settingsNotifier.value.copyWith(enabled: enabled);
  }

  @override
  void setVolume(double volume) {
    if (_isDisposed) return;
    _settingsNotifier.value = _settingsNotifier.value.copyWith(volume: volume);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _settingsNotifier.dispose();

    try {
      await _engine.dispose();
    } catch (e, st) {
      _logger.warning(
        '[SOUND] Error disposing sound engine',
        category: LogCategory.system,
        error: e,
        stackTrace: st,
      );
    }
  }
}
