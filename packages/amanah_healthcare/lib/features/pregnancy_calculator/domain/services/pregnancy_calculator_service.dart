import '../entities/pregnancy_calculation_result.dart';

class PregnancyCalculatorService {
  const PregnancyCalculatorService();

  static const int gestationDays = 280;

  PregnancyCalculationResult calculate({
    required DateTime lmp,
    DateTime? referenceDate,
  }) {
    final DateTime lmpUtc = DateTime.utc(lmp.year, lmp.month, lmp.day);
    final DateTime ref = referenceDate != null
        ? DateTime.utc(referenceDate.year, referenceDate.month, referenceDate.day)
        : DateTime.now().toUtc();

    final DateTime edd = lmpUtc.add(const Duration(days: gestationDays));
    final int daysUntilEdd = edd.difference(ref).inDays;
    final int totalDays = gestationDays - daysUntilEdd;

    if (totalDays < 0) {
      return PregnancyCalculationResult(
        lmp: lmpUtc,
        edd: edd,
        gestationalWeeks: 0,
        gestationalDays: 0,
        totalGestationalDays: 0,
        daysRemaining: gestationDays,
        trimester: 1,
        progressPercentage: 0.0,
      );
    }

    final int weeks = totalDays ~/ 7;
    final int days = totalDays % 7;
    final int daysRemaining = daysUntilEdd < 0 ? 0 : daysUntilEdd;

    int trimester = 1;
    if (weeks >= 28) {
      trimester = 3;
    } else if (weeks >= 14) {
      trimester = 2;
    }

    final double progress = (totalDays / gestationDays).clamp(0.0, 1.0);

    return PregnancyCalculationResult(
      lmp: lmpUtc,
      edd: edd,
      gestationalWeeks: weeks,
      gestationalDays: days,
      totalGestationalDays: totalDays,
      daysRemaining: daysRemaining,
      trimester: trimester,
      progressPercentage: progress,
    );
  }
}
