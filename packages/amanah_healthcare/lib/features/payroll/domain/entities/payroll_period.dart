class PayrollPeriod {
  const PayrollPeriod({
    required this.id,
    required this.periodName,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.totalPayout,
    this.notes,
  });

  final String id;
  final String periodName;
  final String periodStart;
  final String periodEnd;
  final String status;
  final double totalPayout;
  final String? notes;
}
