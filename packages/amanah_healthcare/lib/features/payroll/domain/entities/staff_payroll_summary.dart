import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';

class StaffPayrollSummary {
  const StaffPayrollSummary({
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
    this.entries = const <PayrollEntry>[],
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
  final List<PayrollEntry> entries;
}
