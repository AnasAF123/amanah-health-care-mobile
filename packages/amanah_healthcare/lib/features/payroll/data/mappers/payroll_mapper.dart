import 'package:amanah_healthcare/features/payroll/data/dto/payroll_period_dto.dart';
import 'package:amanah_healthcare/features/payroll/data/dto/staff_payroll_summary_dto.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/monthly_payroll_group.dart';
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
      sourceType: dto.sourceType,
      quantityHours: dto.quantityHours,
      hourlyRate: dto.hourlyRate,
      amount: dto.amount,
      description: dto.description,
      checkInAt: dto.checkInAt,
      checkOutAt: dto.checkOutAt,
      isEarlyDeparture: dto.isEarlyDeparture,
      notes: dto.notes,
      createdAt: dto.createdAt,
    );
  }

  static StaffPayrollSummary toSummary(StaffPayrollSummaryDto dto) {
    return StaffPayrollSummary(
      staffId: dto.staffId,
      staffCode: dto.staffCode,
      fullName: dto.fullName,
      staffType: dto.staffType,
      positionTitle: dto.positionTitle,
      departmentName: dto.departmentName,
      practitionerId: dto.practitionerId,
      periodId: dto.periodId,
      periodName: dto.periodName,
      periodStart: dto.periodStart,
      periodEnd: dto.periodEnd,
      periodStatus: dto.periodStatus,
      monthLabel: dto.monthLabel,
      calculatedAt: dto.calculatedAt,
      baseHours: dto.baseHours,
      deductionHours: dto.deductionHours,
      additionHours: dto.additionHours,
      baseEarnings: dto.baseEarnings,
      grossEarnings: dto.grossEarnings,
      leaveDeductions: dto.leaveDeductions,
      replacementAdditions: dto.replacementAdditions,
      netPayroll: dto.netPayroll,
      entries: dto.entries.map(toEntry).toList(),
    );
  }

  static MonthlyPayrollGroup toMonthlyGroup(MonthlyPayrollGroupDto dto) {
    return MonthlyPayrollGroup(
      periodId: dto.periodId,
      periodName: dto.periodName,
      periodStart: dto.periodStart,
      periodEnd: dto.periodEnd,
      periodStatus: dto.periodStatus,
      monthLabel: dto.monthLabel,
      totalNet: dto.totalNet,
      totalGross: dto.totalGross,
      totalDeductions: dto.totalDeductions,
      totalHours: dto.totalHours,
      entries: dto.entries.map(toEntry).toList(),
    );
  }
}
