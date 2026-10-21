class PayrollEntryDto {
  const PayrollEntryDto({
    required this.id,
    required this.entryType,
    this.sourceType,
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

  factory PayrollEntryDto.fromJson(Map<String, dynamic> json) {
    return PayrollEntryDto(
      id: json['id']?.toString() ?? '',
      entryType: json['entryType']?.toString() ?? '',
      sourceType: json['sourceType']?.toString(),
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
      checkInAt: json['checkInAt']?.toString(),
      checkOutAt: json['checkOutAt']?.toString(),
      isEarlyDeparture: json['isEarlyDeparture'] == true,
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class StaffPayrollSummaryDto {
  const StaffPayrollSummaryDto({
    required this.staffId,
    this.staffCode,
    required this.fullName,
    required this.staffType,
    this.positionTitle,
    this.departmentName,
    this.practitionerId,
    this.periodId,
    this.periodName,
    this.periodStart,
    this.periodEnd,
    this.periodStatus,
    this.monthLabel,
    this.calculatedAt,
    required this.baseHours,
    this.deductionHours = 0.0,
    this.additionHours = 0.0,
    required this.baseEarnings,
    this.grossEarnings = 0.0,
    required this.leaveDeductions,
    required this.replacementAdditions,
    required this.netPayroll,
    this.entries = const <PayrollEntryDto>[],
  });

  final String staffId;
  final String? staffCode;
  final String fullName;
  final String staffType;
  final String? positionTitle;
  final String? departmentName;
  final String? practitionerId;
  final String? periodId;
  final String? periodName;
  final String? periodStart;
  final String? periodEnd;
  final String? periodStatus;
  final String? monthLabel;
  final String? calculatedAt;
  final double baseHours;
  final double deductionHours;
  final double additionHours;
  final double baseEarnings;
  final double grossEarnings;
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

    final double baseEarnings = toDouble(json['baseEarnings']);
    final double replacementAdditions = toDouble(json['replacementAdditions']);
    final double rawGross = toDouble(json['grossEarnings']);
    final double grossEarnings = rawGross > 0 ? rawGross : (baseEarnings + replacementAdditions);

    return StaffPayrollSummaryDto(
      staffId: json['staffId']?.toString() ?? '',
      staffCode: json['staffCode']?.toString(),
      fullName: json['fullName']?.toString() ?? '',
      staffType: json['staffType']?.toString() ?? '',
      positionTitle: json['positionTitle']?.toString(),
      departmentName: json['departmentName']?.toString(),
      practitionerId: json['practitionerId']?.toString(),
      periodId: json['periodId']?.toString(),
      periodName: json['periodName']?.toString(),
      periodStart: json['periodStart']?.toString(),
      periodEnd: json['periodEnd']?.toString(),
      periodStatus: json['periodStatus']?.toString(),
      monthLabel: json['monthLabel']?.toString(),
      calculatedAt: json['calculatedAt']?.toString(),
      baseHours: toDouble(json['baseHours']),
      deductionHours: toDouble(json['deductionHours']),
      additionHours: toDouble(json['additionHours']),
      baseEarnings: baseEarnings,
      grossEarnings: grossEarnings,
      leaveDeductions: toDouble(json['leaveDeductions']),
      replacementAdditions: replacementAdditions,
      netPayroll: toDouble(json['netPayroll']),
      entries: parsedEntries,
    );
  }
}

class MonthlyPayrollGroupDto {
  const MonthlyPayrollGroupDto({
    required this.periodId,
    required this.periodName,
    required this.periodStart,
    required this.periodEnd,
    required this.periodStatus,
    required this.monthLabel,
    required this.totalNet,
    required this.totalGross,
    required this.totalDeductions,
    required this.totalHours,
    this.entries = const <PayrollEntryDto>[],
  });

  final String periodId;
  final String periodName;
  final String periodStart;
  final String periodEnd;
  final String periodStatus;
  final String monthLabel;
  final double totalNet;
  final double totalGross;
  final double totalDeductions;
  final double totalHours;
  final List<PayrollEntryDto> entries;

  factory MonthlyPayrollGroupDto.fromJson(Map<String, dynamic> json) {
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

    return MonthlyPayrollGroupDto(
      periodId: json['periodId']?.toString() ?? '',
      periodName: json['periodName']?.toString() ?? '',
      periodStart: json['periodStart']?.toString() ?? '',
      periodEnd: json['periodEnd']?.toString() ?? '',
      periodStatus: json['periodStatus']?.toString() ?? '',
      monthLabel: json['monthLabel']?.toString() ?? '',
      totalNet: toDouble(json['totalNet']),
      totalGross: toDouble(json['totalGross']),
      totalDeductions: toDouble(json['totalDeductions']),
      totalHours: toDouble(json['totalHours']),
      entries: parsedEntries,
    );
  }
}
