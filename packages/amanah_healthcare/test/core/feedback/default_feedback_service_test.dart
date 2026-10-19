import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/feedback/feedback.dart';
import 'package:amanah_healthcare/core/sound/sound.dart';

class FakeSoundService implements SoundService {
  final List<SoundCue> playedCues = <SoundCue>[];

  @override
  ValueListenable<SoundSettings> get settings =>
      ValueNotifier<SoundSettings>(const SoundSettings());

  @override
  Future<void> dispose() async {}

  @override
  Future<void> play(SoundCue cue) async {
    playedCues.add(cue);
  }

  @override
  Future<void> preload(Iterable<SoundCue> cues) async {}

  @override
  void setEnabled(bool enabled) {}

  @override
  void setVolume(double volume) {}
}

class FakeHapticsEngine implements HapticsEngine {
  int successCount = 0;
  int errorCount = 0;
  int lightCount = 0;

  @override
  Future<void> success() async {
    successCount++;
  }

  @override
  Future<void> error() async {
    errorCount++;
  }

  @override
  Future<void> light() async {
    lightCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DefaultFeedbackService', () {
    late FakeSoundService fakeSound;
    late FakeHapticsEngine fakeHaptics;
    late DefaultFeedbackService feedbackService;

    setUp(() {
      fakeSound = FakeSoundService();
      fakeHaptics = FakeHapticsEngine();
      feedbackService = DefaultFeedbackService(
        soundService: fakeSound,
        hapticsEngine: fakeHaptics,
      );
    });

    test('notifySuccess emits success sound cue and haptic vibration when needVibration is true', () async {
      await feedbackService.notifySuccess(needVibration: true);

      expect(fakeSound.playedCues, contains(AppSoundCues.success));
      expect(fakeHaptics.successCount, 1);
      expect(fakeHaptics.errorCount, 0);
    });

    test('notifySuccess suppresses vibration when needVibration is false', () async {
      await feedbackService.notifySuccess(needVibration: false);

      expect(fakeSound.playedCues, contains(AppSoundCues.success));
      expect(fakeHaptics.successCount, 0);
    });

    test('notifyException emits error sound cue and error pattern vibration', () async {
      await feedbackService.notifyException(needVibration: true);

      expect(fakeSound.playedCues, contains(AppSoundCues.error));
      expect(fakeHaptics.errorCount, 1);
      expect(fakeHaptics.successCount, 0);
    });

    test('notifyException suppresses vibration when needVibration is false', () async {
      await feedbackService.notifyException(needVibration: false);

      expect(fakeSound.playedCues, contains(AppSoundCues.error));
      expect(fakeHaptics.errorCount, 0);
    });

    test('notifySystem emits system sound cue and light haptic feedback', () async {
      await feedbackService.notifySystem(needVibration: true);

      expect(fakeSound.playedCues, contains(AppSoundCues.system));
      expect(fakeHaptics.lightCount, 1);
    });

    test('notifySystem suppresses vibration when needVibration is false', () async {
      await feedbackService.notifySystem(needVibration: false);

      expect(fakeSound.playedCues, contains(AppSoundCues.system));
      expect(fakeHaptics.lightCount, 0);
    });
  });
}
