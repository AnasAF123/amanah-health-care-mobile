import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/repositories/payroll_repository.dart';

class GetPayrollPeriodsUseCase {
  const GetPayrollPeriodsUseCase(this._repository);

  final PayrollRepository _repository;

  Future<List<PayrollPeriod>> execute() {
    return _repository.getPayrollPeriods();
  }
}
