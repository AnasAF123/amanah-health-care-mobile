import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/domain/failures/intake_failure.dart';
import 'package:amanah_healthcare/features/patient_record/domain/repositories/intake_repository.dart';
import 'package:amanah_healthcare/features/patient_record/domain/usecases/get_appointment_intake_use_case.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/state/patient_intake_controller.dart';

class MockIntakeRepository implements IntakeRepository {
  MockIntakeRepository({this.recordToReturn, this.failureToThrow});

  PatientIntakeRecord? recordToReturn;
  Exception? failureToThrow;
  List<MaternalTimelineItem>? timelineToReturn;

  @override
  Future<PatientIntakeRecord> getIntakeByAppointmentId(String appointmentId) async {
    if (failureToThrow != null) {
      throw failureToThrow!;
    }
    return recordToReturn ??
        const PatientIntakeRecord(appointmentId: 'apt-1', flow: 'regular', type: 'regular');
  }

  @override
  Future<List<MaternalTimelineItem>> getMaternalHistory(String patientId) async {
    if (failureToThrow != null) {
      throw failureToThrow!;
    }
    return timelineToReturn ?? const <MaternalTimelineItem>[];
  }
}

void main() {
  group('PatientIntakeController', () {
    test('initial state is correct', () {
      final repo = MockIntakeRepository();
      final useCase = GetAppointmentIntakeUseCase(repo);
      final controller = PatientIntakeController(getIntakeUseCase: useCase);

      expect(controller.status, IntakeStateStatus.initial);
      expect(controller.isLoading, isFalse);
      expect(controller.isEmpty, isFalse);
      expect(controller.intake, isNull);
      expect(controller.errorMessage, isNull);
    });

    test('loadIntake success transitions to loaded state', () async {
      final record = const PatientIntakeRecord(
        appointmentId: 'apt-test-123',
        flow: 'regular',
        type: 'regular',
        regular: RegularIntakeData(fullName: 'Budi Santoso', complaint: 'Sakit Kepala'),
      );
      final repo = MockIntakeRepository(recordToReturn: record);
      final useCase = GetAppointmentIntakeUseCase(repo);
      final controller = PatientIntakeController(getIntakeUseCase: useCase);

      await controller.loadIntake('apt-test-123');

      expect(controller.status, IntakeStateStatus.loaded);
      expect(controller.isLoading, isFalse);
      expect(controller.isEmpty, isFalse);
      expect(controller.intake, isNotNull);
      expect(controller.intake?.appointmentId, 'apt-test-123');
      expect(controller.intake?.regular?.fullName, 'Budi Santoso');
      expect(controller.errorMessage, isNull);
    });

    test(
      'loadIntake with 404 IntakeNotFoundFailure transitions to empty state gracefully',
      () async {
        final repo = MockIntakeRepository(
          failureToThrow: const IntakeNotFoundFailure('Formulir belum tersedia'),
        );
        final useCase = GetAppointmentIntakeUseCase(repo);
        final controller = PatientIntakeController(getIntakeUseCase: useCase);

        await controller.loadIntake('apt-not-found');

        expect(controller.status, IntakeStateStatus.empty);
        expect(controller.isLoading, isFalse);
        expect(controller.isEmpty, isTrue);
        expect(controller.intake, isNull);
        expect(controller.errorMessage, isNull);
      },
    );

    test('loadIntake with unexpected server error transitions to error state', () async {
      final repo = MockIntakeRepository(
        failureToThrow: const IntakeFailure('Server internal error', code: 'SERVER_ERROR'),
      );
      final useCase = GetAppointmentIntakeUseCase(repo);
      final controller = PatientIntakeController(getIntakeUseCase: useCase);

      await controller.loadIntake('apt-error');

      expect(controller.status, IntakeStateStatus.error);
      expect(controller.isLoading, isFalse);
      expect(controller.isEmpty, isFalse);
      expect(controller.intake, isNull);
      expect(controller.errorMessage, contains('Server internal error'));
    });

    test('RegularIntakeData relationshipDisplay formats contextual relationship correctly', () {
      const dataWithContext = RegularIntakeData(
        relationshipContext: 'Anak dari Lexguard Didier',
        relationshipType: 'child',
      );
      expect(dataWithContext.relationshipDisplay, 'Anak dari Lexguard Didier');

      const dataWithAccountHolder = RegularIntakeData(
        accountHolderName: 'Lexguard Didier',
        relationshipType: 'child',
      );
      expect(dataWithAccountHolder.relationshipDisplay, 'Anak dari Lexguard Didier');

      const dataSpouse = RegularIntakeData(
        accountHolderName: 'Lexguard Didier',
        relationshipType: 'spouse',
      );
      expect(dataSpouse.relationshipDisplay, 'Pasangan dari Lexguard Didier');

      const dataSelf = RegularIntakeData(relationshipType: 'self');
      expect(dataSelf.relationshipDisplay, 'Akun Utama (Diri Sendiri)');
    });
  });
}
