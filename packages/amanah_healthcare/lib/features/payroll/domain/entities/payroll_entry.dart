class PayrollEntry {
  const PayrollEntry({
    required this.id,
    required this.entryType, // 'base_scheduled' | 'leave_deduction' | 'replacement_addition' | 'overtime_addition'
    required this.quantityHours,
    required this.hourlyRate,
    required this.amount,
    this.description,
  });

  final String id;
  final String entryType;
  final double quantityHours;
  final double hourlyRate;
  final double amount;
  final String? description;

  bool get isBase => entryType == 'base_scheduled';
  bool get isDeduction => entryType == 'leave_deduction';
  bool get isAddition =>
      entryType == 'replacement_addition' || entryType == 'overtime_addition';
}
