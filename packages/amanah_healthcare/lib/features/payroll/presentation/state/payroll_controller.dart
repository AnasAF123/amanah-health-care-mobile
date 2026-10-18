import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_toaster.dart';
import 'package:amanah_healthcare/features/payroll/data/repositories/payroll_repository_impl.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';
import 'package:amanah_healthcare/features/payroll/domain/repositories/payroll_repository.dart';
import 'package:amanah_healthcare/features/payroll/domain/usecases/get_my_payroll_usecase.dart';
import 'package:amanah_healthcare/features/payroll/domain/usecases/get_payroll_periods_usecase.dart';

class PayrollController extends ChangeNotifier {
  PayrollController({
    PayrollRepository? repository,
    GetMyPayrollUseCase? getMyPayrollUseCase,
    GetPayrollPeriodsUseCase? getPayrollPeriodsUseCase,
  })  : _getMyPayrollUseCase = getMyPayrollUseCase ??
            GetMyPayrollUseCase(repository ?? PayrollRepositoryImpl()),
        _getPayrollPeriodsUseCase = getPayrollPeriodsUseCase ??
            GetPayrollPeriodsUseCase(repository ?? PayrollRepositoryImpl());

  final GetMyPayrollUseCase _getMyPayrollUseCase;
  final GetPayrollPeriodsUseCase _getPayrollPeriodsUseCase;

  StaffPayrollSummary? _summary;
  List<PayrollPeriod> _periods = const <PayrollPeriod>[];
  PayrollPeriod? _selectedPeriod;

  bool _isLoading = false;
  String? _errorMessage;

  StaffPayrollSummary? get summary => _summary;
  List<PayrollPeriod> get periods => _periods;
  PayrollPeriod? get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInitialData({BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _periods = await _getPayrollPeriodsUseCase.execute();
      if (_periods.isNotEmpty && _selectedPeriod == null) {
        _selectedPeriod = _periods.first;
      }

      _summary = await _getMyPayrollUseCase.execute(
        periodId: _selectedPeriod?.id,
      );
    } catch (e) {
      _errorMessage = e.toString();
      if (context != null && context.mounted) {
        AmanahToaster.error(context, message: _errorMessage!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPeriod(PayrollPeriod period, {BuildContext? context}) async {
    _selectedPeriod = period;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _getMyPayrollUseCase.execute(
        periodId: period.id,
      );
    } catch (e) {
      _errorMessage = e.toString();
      if (context != null && context.mounted) {
        AmanahToaster.error(context, message: _errorMessage!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
