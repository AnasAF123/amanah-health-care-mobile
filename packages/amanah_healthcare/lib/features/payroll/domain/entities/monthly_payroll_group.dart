import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';

class MonthlyPayrollGroup {
  const MonthlyPayrollGroup({
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
    required this.entries,
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
  final List<PayrollEntry> entries;
}
