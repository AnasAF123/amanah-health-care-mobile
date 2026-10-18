import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';

abstract interface class PayrollRepository {
  Future<StaffPayrollSummary> getMyPayroll({String? periodId});
  Future<List<PayrollPeriod>> getPayrollPeriods();
}
