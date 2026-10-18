import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';
import 'package:amanah_healthcare/features/payroll/domain/repositories/payroll_repository.dart';

class GetMyPayrollUseCase {
  const GetMyPayrollUseCase(this._repository);

  final PayrollRepository _repository;

  Future<StaffPayrollSummary> execute({String? periodId}) {
    return _repository.getMyPayroll(periodId: periodId);
  }
}
