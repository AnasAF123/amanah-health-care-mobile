import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_home_data.dart';
import 'package:amanah_healthcare/features/home/services/amanah_doctor_id_card_warm_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const AmanahDoctorProfile testProfile1 = AmanahDoctorProfile(
    name: 'dr. Andika Perkasa, Sp.A',
    role: 'Dokter Spesialis Anak',
    hospital: 'RS AMANAH SEHAT',
    sip: '503/442.1/SIP-D/2026',
    avatarAsset: 'assets/images/doctors/man-doctor-1.png',
    greeting: 'Selamat Pagi',
    unreadNotifications: 2,
  );

  const AmanahDoctorProfile testProfile2 = AmanahDoctorProfile(
    name: 'dr. Amelia Cantika, Sp.A',
    role: 'Dokter Spesialis Anak',
    hospital: 'RS AMANAH SEHAT',
    sip: '503/442.2/SIP-D/2026',
    avatarAsset: 'assets/images/doctors/woman-doctor-4.png',
    greeting: 'Selamat Siang',
    unreadNotifications: 0,
  );

  group('AmanahDoctorIdCardWarmService Tests', () {
    final AmanahDoctorIdCardWarmService service =
        AmanahDoctorIdCardWarmService.instance;

    setUp(() {
      service.reset();
    });

    tearDown(() {
      service.reset();
    });

    test('initial state has no controller and is not ready', () {
      expect(service.controller, isNull);
      expect(service.isReady, isFalse);
      expect(service.isWarming, isFalse);
      expect(service.isReadyNotifier.value, isFalse);
    });

    test('lifecycle pause and resume calls do not throw when not initialized', () {
      expect(() => service.pauseAnimation(), returnsNormally);
      expect(() => service.resumeAnimation(), returnsNormally);
      expect(() => service.onCardOpened(testProfile1), returnsNormally);
      expect(() => service.onCardClosed(), returnsNormally);
      expect(() => service.updateProfile(testProfile2), returnsNormally);
    });

    test('reset clears all state cleanly', () {
      service.onCardOpened(testProfile1);
      service.reset();

      expect(service.controller, isNull);
      expect(service.isReady, isFalse);
      expect(service.isWarming, isFalse);
      expect(service.isReadyNotifier.value, isFalse);
    });
  });
}
