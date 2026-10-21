import 'package:amanah_healthcare/features/payroll/domain/entities/monthly_payroll_group.dart';
import 'package:amanah_healthcare/features/payroll/domain/repositories/payroll_repository.dart';

class GetMyPayrollHistoryUseCase {
  const GetMyPayrollHistoryUseCase(this._repository);

  final PayrollRepository _repository;

  Future<List<MonthlyPayrollGroup>> execute() {
    return _repository.getMyPayrollHistory();
  }
}
