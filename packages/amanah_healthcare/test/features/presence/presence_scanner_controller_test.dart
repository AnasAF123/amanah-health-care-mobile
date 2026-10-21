import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/repositories/attendance_repository.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/checkout_attendance_usecase.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/record_attendance_usecase.dart';
import 'package:amanah_healthcare/features/presence/presentation/services/scanner_feedback_service.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';

class _MockFailingAttendanceRepository implements AttendanceRepository {
  @override
  Future<AttendanceCheckInResult> recordScan({
    required String qrToken,
    String? shift,
    String? deviceInfo,
  }) async {
    throw Exception('Staf sudah melakukan presensi masuk untuk tanggal ini.');
  }

  @override
  Future<AttendanceCheckInResult> recordCheckout({
    String? qrToken,
    String? checkoutTicket,
    String? notes,
  }) async {
    if (notes == 'EARLY_ERROR') {
      throw Exception('Catatan alasan kepulangan lebih awal (early departure) wajib diisi.');
    }
    throw Exception('Presensi pulang sudah tercatat sebelumnya untuk hari ini.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFeedbackService implements IScannerFeedbackService {
  @override
  Future<void> onScanSuccess() async {}

  @override
  Future<void> onScanError() async {}

  @override
  Future<void> onButtonTap() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PresenceScannerController', () {
    late PresenceScannerController controller;

    setUp(() {
      final repo = _MockFailingAttendanceRepository();
      controller = PresenceScannerController(
        recordAttendanceUseCase: RecordAttendanceUseCase(repo),
        checkoutAttendanceUseCase: CheckoutAttendanceUseCase(repo),
        feedbackService: _FakeFeedbackService(),
      );
    });

    test(
      'preserves errorMessage upon submission error and formats duplicate error clearly',
      () async {
        expect(controller.errorMessage, isNull);
        expect(controller.isFlowActive, isFalse);

        final result = await controller.submitAttendance('TEST-TOKEN');

        expect(result, isNull);
        expect(controller.flowState, equals(AttendanceFlowState.error));
        expect(controller.errorMessage, isNotNull);
        expect(controller.errorMessage, equals('Anda sudah melakukan presensi masuk hari ini.'));

        controller.clearError();
        expect(controller.errorMessage, isNull);
        expect(controller.isFlowActive, isFalse);
      },
    );

    test('detects early departure notes requirement upon checkout error', () async {
      controller.setScanMode(AttendanceScanMode.checkOut);
      final result = await controller.submitCheckout(qrToken: 'TOKEN_123', notes: 'EARLY_ERROR');

      expect(result, isNull);
      expect(controller.requiresEarlyDepartureNotes, isTrue);
      expect(controller.pendingCheckoutToken, equals('TOKEN_123'));
      expect(controller.errorMessage, equals('Catatan alasan kepulangan lebih awal wajib diisi.'));

      controller.clearPendingEarlyDeparture();
      expect(controller.requiresEarlyDepartureNotes, isFalse);
      expect(controller.pendingCheckoutToken, isNull);
    });
  });
}
