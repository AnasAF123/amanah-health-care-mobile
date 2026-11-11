import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/pregnancy_calculator/domain/services/pregnancy_calculator_service.dart';
import 'package:amanah_healthcare/features/pregnancy_calculator/domain/entities/pregnancy_calculation_result.dart';

void main() {
  group('PregnancyCalculatorService', () {
    const PregnancyCalculatorService service = PregnancyCalculatorService();

    test('calculates correct EDD (280 days after LMP) and gestational age', () {
      final DateTime lmp = DateTime.utc(2026, 1, 1);
      final DateTime referenceDate = DateTime.utc(2026, 3, 26); // 84 days after LMP = 12 weeks 0 days

      final PregnancyCalculationResult result = service.calculate(
        lmp: lmp,
        referenceDate: referenceDate,
      );

      // EDD should be 2026-01-01 + 280 days = 2026-10-08
      expect(result.edd, equals(DateTime.utc(2026, 10, 8)));
      expect(result.gestationalWeeks, equals(12));
      expect(result.gestationalDays, equals(0));
      expect(result.trimester, equals(1));
      expect(result.daysRemaining, equals(196));
      expect(result.gestationalAgeFormatted, equals('12 minggu 0 hari'));
    });

    test('correctly assigns trimester 2 and 3 based on gestational weeks', () {
      final DateTime lmp = DateTime.utc(2026, 1, 1);

      // 20 weeks -> Trimester 2
      final PregnancyCalculationResult t2 = service.calculate(
        lmp: lmp,
        referenceDate: DateTime.utc(2026, 5, 21),
      );
      expect(t2.trimester, equals(2));

      // 30 weeks -> Trimester 3
      final PregnancyCalculationResult t3 = service.calculate(
        lmp: lmp,
        referenceDate: DateTime.utc(2026, 7, 30),
      );
      expect(t3.trimester, equals(3));
    });
  });
}
