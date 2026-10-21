import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/features/payroll/data/datasources/payroll_remote_data_source.dart';
import 'package:amanah_healthcare/features/payroll/data/dto/payroll_period_dto.dart';
import 'package:amanah_healthcare/features/payroll/data/dto/staff_payroll_summary_dto.dart';
import 'package:amanah_healthcare/features/payroll/data/mappers/payroll_mapper.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/monthly_payroll_group.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';
import 'package:amanah_healthcare/features/payroll/domain/failures/payroll_failure.dart';
import 'package:amanah_healthcare/features/payroll/domain/repositories/payroll_repository.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  PayrollRepositoryImpl({PayrollRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? PayrollRemoteDataSourceImpl();

  final PayrollRemoteDataSource _remoteDataSource;

  Never _handleError(Object error) {
    if (error is NetworkException) {
      throw PayrollNetworkFailure(error.message);
    }
    if (error is UnauthorizedException) {
      throw const PayrollServerFailure('Sesi Anda telah kedaluwarsa. Silakan masuk kembali.');
    }
    if (error is NotFoundException) {
      throw PayrollNotFoundFailure(error.message);
    }
    if (error is ServerException) {
      throw PayrollServerFailure(error.message, error.code);
    }
    if (error is AmanahPayrollException) {
      throw error;
    }
    throw PayrollServerFailure(error.toString());
  }

  @override
  Future<StaffPayrollSummary> getMyPayroll({String? periodId}) async {
    try {
      final StaffPayrollSummaryDto dto = await _remoteDataSource.getMyPayroll(periodId: periodId);
      return PayrollMapper.toSummary(dto);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<MonthlyPayrollGroup>> getMyPayrollHistory() async {
    try {
      final List<MonthlyPayrollGroupDto> dtos = await _remoteDataSource.getMyPayrollHistory();
      return dtos.map(PayrollMapper.toMonthlyGroup).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<PayrollPeriod>> getPayrollPeriods() async {
    try {
      final List<PayrollPeriodDto> dtos = await _remoteDataSource.getPayrollPeriods();
      return dtos.map(PayrollMapper.toPeriod).toList();
    } catch (e) {
      _handleError(e);
    }
  }
}
