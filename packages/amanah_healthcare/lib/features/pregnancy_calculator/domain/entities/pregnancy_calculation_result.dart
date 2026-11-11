class PregnancyCalculationResult {
  const PregnancyCalculationResult({
    required this.lmp,
    required this.edd,
    required this.gestationalWeeks,
    required this.gestationalDays,
    required this.totalGestationalDays,
    required this.daysRemaining,
    required this.trimester,
    required this.progressPercentage,
  });

  final DateTime lmp;
  final DateTime edd;
  final int gestationalWeeks;
  final int gestationalDays;
  final int totalGestationalDays;
  final int daysRemaining;
  final int trimester;
  final double progressPercentage;

  String get gestationalAgeFormatted => '$gestationalWeeks minggu $gestationalDays hari';
}
