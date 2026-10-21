import 'package:amanah_healthcare/features/payroll/domain/entities/monthly_payroll_group.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';

abstract interface class PayrollRepository {
  Future<StaffPayrollSummary> getMyPayroll({String? periodId});
  Future<List<MonthlyPayrollGroup>> getMyPayrollHistory();
  Future<List<PayrollPeriod>> getPayrollPeriods();
}
