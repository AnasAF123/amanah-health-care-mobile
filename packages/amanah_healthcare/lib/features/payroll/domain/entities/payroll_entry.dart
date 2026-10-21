class PayrollEntry {
  const PayrollEntry({
    required this.id,
    required this.entryType, // 'base_scheduled' | 'leave_deduction' | 'replacement_addition' | 'overtime_addition'
    this.sourceType, // 'roster' | 'leave_request' | 'replacement_claim' | 'attendance' | 'manual'
    required this.quantityHours,
    required this.hourlyRate,
    required this.amount,
    this.description,
    this.checkInAt,
    this.checkOutAt,
    this.isEarlyDeparture = false,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String entryType;
  final String? sourceType;
  final double quantityHours;
  final double hourlyRate;
  final double amount;
  final String? description;
  final String? checkInAt;
  final String? checkOutAt;
  final bool isEarlyDeparture;
  final String? notes;
  final String? createdAt;

  bool get isBase => entryType == 'base_scheduled';
  bool get isDeduction => entryType == 'leave_deduction';
  bool get isAddition => entryType == 'replacement_addition' || entryType == 'overtime_addition';
}
