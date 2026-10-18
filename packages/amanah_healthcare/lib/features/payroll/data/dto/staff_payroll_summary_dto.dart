class PayrollEntryDto {
  const PayrollEntryDto({
    required this.id,
    required this.entryType,
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

  factory PayrollEntryDto.fromJson(Map<String, dynamic> json) {
    return PayrollEntryDto(
      id: json['id']?.toString() ?? '',
      entryType: json['entryType']?.toString() ?? '',
      quantityHours: (json['quantityHours'] is num)
          ? (json['quantityHours'] as num).toDouble()
          : double.tryParse(json['quantityHours']?.toString() ?? '0') ?? 0.0,
      hourlyRate: (json['hourlyRate'] is num)
          ? (json['hourlyRate'] as num).toDouble()
          : double.tryParse(json['hourlyRate']?.toString() ?? '0') ?? 0.0,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString(),
    );
  }
}

class StaffPayrollSummaryDto {
  const StaffPayrollSummaryDto({
    required this.staffId,
    required this.fullName,
    required this.staffType,
    this.positionTitle,
    this.practitionerId,
    required this.baseHours,
    required this.baseEarnings,
    required this.leaveDeductions,
    required this.replacementAdditions,
    required this.netPayroll,
    this.entries = const <PayrollEntryDto>[],
  });

  final String staffId;
  final String fullName;
  final String staffType;
  final String? positionTitle;
  final String? practitionerId;
  final double baseHours;
  final double baseEarnings;
  final double leaveDeductions;
  final double replacementAdditions;
  final double netPayroll;
  final List<PayrollEntryDto> entries;

  factory StaffPayrollSummaryDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawEntries = json['entries'] as List<dynamic>?;
    final List<PayrollEntryDto> parsedEntries = rawEntries != null
        ? rawEntries
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> e) => PayrollEntryDto.fromJson(e))
            .toList()
        : <PayrollEntryDto>[];

    double toDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '0') ?? 0.0;
    }

    return StaffPayrollSummaryDto(
      staffId: json['staffId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      staffType: json['staffType']?.toString() ?? '',
      positionTitle: json['positionTitle']?.toString(),
      practitionerId: json['practitionerId']?.toString(),
      baseHours: toDouble(json['baseHours']),
      baseEarnings: toDouble(json['baseEarnings']),
      leaveDeductions: toDouble(json['leaveDeductions']),
      replacementAdditions: toDouble(json['replacementAdditions']),
      netPayroll: toDouble(json['netPayroll']),
      entries: parsedEntries,
    );
  }
}
