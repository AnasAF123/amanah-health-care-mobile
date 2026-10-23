import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/domain/repositories/intake_repository.dart';
import 'package:amanah_healthcare/features/patient_record/domain/usecases/get_maternal_history_use_case.dart';

class MockMaternalHistoryRepository implements IntakeRepository {
  MockMaternalHistoryRepository({this.historyToReturn = const <MaternalTimelineItem>[]});

  final List<MaternalTimelineItem> historyToReturn;

  @override
  Future<PatientIntakeRecord> getIntakeByAppointmentId(String appointmentId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MaternalTimelineItem>> getMaternalHistory(String patientId) async {
    return historyToReturn;
  }
}

void main() {
  group('GetMaternalHistoryUseCase', () {
    test('fetches maternal timeline items and formats GPA correctly', () async {
      const item1 = MaternalTimelineItem(
        id: 'mat-1',
        appointmentId: 'apt-1',
        gestationalAgeFormatted: '27 minggu 4 hari',
        hpht: '2026-04-12',
        estimatedDueDate: '2027-01-17',
        partnerName: 'Himawan Wardaya',
        gravidaCount: 2,
        parityCount: 1,
        abortionCount: 0,
        livingChildrenCount: 1,
        createdAt: '2026-10-23 00:05:34.520146+07',
      );

      final repo = MockMaternalHistoryRepository(historyToReturn: <MaternalTimelineItem>[item1]);
      final useCase = GetMaternalHistoryUseCase(repo);

      final result = await useCase('patient-uuid-123');

      expect(result.length, 1);
      expect(result.first.id, 'mat-1');
      expect(result.first.gestationalAgeFormatted, '27 minggu 4 hari');
      expect(result.first.gpa, 'G2 P1 A0 Ah1');
      expect(result.first.partnerName, 'Himawan Wardaya');
    });

    test('returns null for GPA when gravidaCount is null', () {
      const itemNoGpa = MaternalTimelineItem(id: 'mat-2', gestationalAgeFormatted: '12 minggu');
      expect(itemNoGpa.gpa, isNull);
    });
  });
}
