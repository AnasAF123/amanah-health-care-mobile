import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';

class StaffPayrollSummary {
  const StaffPayrollSummary({
    required this.staffId,
    this.staffCode,
    required this.fullName,
    this.roleId,
    this.roleCode,
    this.roleName,
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
    this.entries = const <PayrollEntry>[],
  });

  final String staffId;
  final String? staffCode;
  final String fullName;
  final String? roleId;
  final String? roleCode;
  final String? roleName;
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
  final List<PayrollEntry> entries;

  List<PayrollEntry> get earningsEntries =>
      entries.where((PayrollEntry e) => e.isBase || e.isAddition).toList(growable: false);

  List<PayrollEntry> get deductionEntries =>
      entries.where((PayrollEntry e) => e.isDeduction).toList(growable: false);
}
