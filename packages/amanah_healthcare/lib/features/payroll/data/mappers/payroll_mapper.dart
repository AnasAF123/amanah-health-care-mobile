import 'package:amanah_healthcare/features/payroll/data/dto/payroll_period_dto.dart';
import 'package:amanah_healthcare/features/payroll/data/dto/staff_payroll_summary_dto.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';

abstract final class PayrollMapper {
  static PayrollPeriod toPeriod(PayrollPeriodDto dto) {
    return PayrollPeriod(
      id: dto.id,
      periodName: dto.periodName,
      periodStart: dto.periodStart,
      periodEnd: dto.periodEnd,
      status: dto.status,
      totalPayout: dto.totalPayout,
      notes: dto.notes,
    );
  }

  static PayrollEntry toEntry(PayrollEntryDto dto) {
    return PayrollEntry(
      id: dto.id,
      entryType: dto.entryType,
      quantityHours: dto.quantityHours,
      hourlyRate: dto.hourlyRate,
      amount: dto.amount,
      description: dto.description,
    );
  }

  static StaffPayrollSummary toSummary(StaffPayrollSummaryDto dto) {
    return StaffPayrollSummary(
      staffId: dto.staffId,
      fullName: dto.fullName,
      staffType: dto.staffType,
      positionTitle: dto.positionTitle,
      practitionerId: dto.practitionerId,
      baseHours: dto.baseHours,
      baseEarnings: dto.baseEarnings,
      leaveDeductions: dto.leaveDeductions,
      replacementAdditions: dto.replacementAdditions,
      netPayroll: dto.netPayroll,
      entries: dto.entries.map(toEntry).toList(),
    );
  }
}
