import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/sound/sound.dart';

class FakeSoundEngine implements SoundEngine {
  final List<SoundSource> preparedSources = <SoundSource>[];
  final List<SoundSource> playedSources = <SoundSource>[];
  bool throwOnPlay = false;
  int playCount = 0;
  int prepareCount = 0;
  int disposeCount = 0;

  @override
  Future<void> prepare(SoundSource source) async {
    prepareCount++;
    preparedSources.add(source);
  }

  @override
  Future<void> play(
    SoundSource source, {
    required double volume,
    required SoundOverlap overlap,
  }) async {
    if (throwOnPlay) {
      throw Exception('Simulated audio engine failure');
    }
    playCount++;
    playedSources.add(source);
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DefaultSoundCatalog', () {
    test('resolves defined cues accurately', () {
      final SoundCatalog catalog = DefaultSoundCatalog.merge(<Map<SoundCue, SoundDefinition>>[
        AppSoundCues.definitions,
      ]);

      expect(catalog.resolve(AppSoundCues.success), isNotNull);
      expect(catalog.resolve(AppSoundCues.error), isNotNull);
      expect(catalog.resolve(AppSoundCues.system), isNotNull);
      expect(catalog.resolve(const SoundCue('unregistered.cue')), isNull);
    });

    test('throws StateError on duplicate cue registration at startup', () {
      const SoundCue testCue = SoundCue('test.duplicate');
      const SoundDefinition def1 = SoundDefinition(source: AssetSoundSource('sounds/a.wav'));
      const SoundDefinition def2 = SoundDefinition(source: AssetSoundSource('sounds/b.wav'));

      expect(
        () => DefaultSoundCatalog.merge(<Map<SoundCue, SoundDefinition>>[
          <SoundCue, SoundDefinition>{testCue: def1},
          <SoundCue, SoundDefinition>{testCue: def2},
        ]),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('DefaultSoundService', () {
    late FakeSoundEngine engine;
    late SoundCatalog catalog;
    late DefaultSoundService service;

    setUp(() {
      engine = FakeSoundEngine();
      catalog = DefaultSoundCatalog.merge(<Map<SoundCue, SoundDefinition>>[
        AppSoundCues.definitions,
      ]);
      service = DefaultSoundService(
        catalog: catalog,
        engine: engine,
      );
    });

    tearDown(() async {
      await service.dispose();
    });

    test('unregistered cue does not throw and does not call engine', () async {
      await expectLater(
        service.play(const SoundCue('non_existent.cue')),
        completes,
      );
      expect(engine.playCount, 0);
    });

    test('engine failure during play is safely caught and does not throw', () async {
      engine.throwOnPlay = true;
      await expectLater(
        service.play(AppSoundCues.success),
        completes,
      );
    });

    test('when enabled is false, play does not invoke engine', () async {
      service.setEnabled(false);
      expect(service.settings.value.enabled, isFalse);

      await service.play(AppSoundCues.success);
      expect(engine.playCount, 0);
    });

    test('preload successfully prepares resources for registered cues', () async {
      await service.preload(<SoundCue>[AppSoundCues.success, AppSoundCues.error]);
      expect(engine.prepareCount, 2);
    });

    test('dispose is idempotent and post-dispose play is no-op', () async {
      await service.dispose();
      await service.dispose();
      expect(engine.disposeCount, 1);

      await service.play(AppSoundCues.success);
      expect(engine.playCount, 0);
    });

    test('volume is clamped between 0.0 and 1.0', () {
      service.setVolume(1.5);
      expect(service.settings.value.volume, 1.0);

      service.setVolume(-0.5);
      expect(service.settings.value.volume, 0.0);

      service.setVolume(0.75);
      expect(service.settings.value.volume, 0.75);
    });
  });
}
