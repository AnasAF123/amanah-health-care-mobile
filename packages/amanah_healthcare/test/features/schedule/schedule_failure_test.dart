import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/failures/schedule_failure.dart';

void main() {
  group('ScheduleFailure', () {
    test('ScheduleServerFailure has default and custom messages', () {
      const ScheduleServerFailure failure1 = ScheduleServerFailure();
      expect(
        failure1.message,
        'Terjadi kendala pada server jadwal. Silakan coba beberapa saat lagi.',
      );

      const ScheduleServerFailure failure2 =
          ScheduleServerFailure('Custom server error', 'SRV_ERR');
      expect(failure2.message, 'Custom server error');
      expect(failure2.code, 'SRV_ERR');
      expect(failure2.toString(), 'Custom server error');
    });

    test('ScheduleNetworkFailure has network code and message', () {
      const ScheduleNetworkFailure failure = ScheduleNetworkFailure();
      expect(
        failure.message,
        'Koneksi internet bermasalah. Periksa jaringan Anda.',
      );
      expect(failure.code, 'NETWORK_ERROR');
    });

    test('ScheduleNotFoundFailure has not found code', () {
      const ScheduleNotFoundFailure failure = ScheduleNotFoundFailure();
      expect(failure.message, 'Data jadwal atau sesi tidak ditemukan.');
      expect(failure.code, 'NOT_FOUND');
    });

    test('ScheduleUnauthorizedFailure has unauthorized code', () {
      const ScheduleUnauthorizedFailure failure = ScheduleUnauthorizedFailure();
      expect(failure.code, 'UNAUTHORIZED');
    });

    test('ScheduleValidationFailure has validation error code', () {
      const ScheduleValidationFailure failure =
          ScheduleValidationFailure('Slot waktu tidak valid');
      expect(failure.message, 'Slot waktu tidak valid');
      expect(failure.code, 'VALIDATION_ERROR');
    });
  });
}
