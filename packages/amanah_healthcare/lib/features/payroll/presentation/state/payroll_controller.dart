import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_toaster.dart';
import 'package:amanah_healthcare/features/payroll/data/repositories/payroll_repository_impl.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/monthly_payroll_group.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';
import 'package:amanah_healthcare/features/payroll/domain/repositories/payroll_repository.dart';
import 'package:amanah_healthcare/features/payroll/domain/usecases/get_my_payroll_history_usecase.dart';
import 'package:amanah_healthcare/features/payroll/domain/usecases/get_my_payroll_usecase.dart';
import 'package:amanah_healthcare/features/payroll/domain/usecases/get_payroll_periods_usecase.dart';

class PayrollController extends ChangeNotifier {
  PayrollController({
    PayrollRepository? repository,
    GetMyPayrollUseCase? getMyPayrollUseCase,
    GetPayrollPeriodsUseCase? getPayrollPeriodsUseCase,
    GetMyPayrollHistoryUseCase? getMyPayrollHistoryUseCase,
  }) : _getMyPayrollUseCase =
           getMyPayrollUseCase ?? GetMyPayrollUseCase(repository ?? PayrollRepositoryImpl()),
       _getPayrollPeriodsUseCase =
           getPayrollPeriodsUseCase ??
           GetPayrollPeriodsUseCase(repository ?? PayrollRepositoryImpl()),
       _getMyPayrollHistoryUseCase =
           getMyPayrollHistoryUseCase ??
           GetMyPayrollHistoryUseCase(repository ?? PayrollRepositoryImpl());

  final GetMyPayrollUseCase _getMyPayrollUseCase;
  final GetPayrollPeriodsUseCase _getPayrollPeriodsUseCase;
  final GetMyPayrollHistoryUseCase _getMyPayrollHistoryUseCase;

  StaffPayrollSummary? _summary;
  List<PayrollPeriod> _periods = const <PayrollPeriod>[];
  List<MonthlyPayrollGroup> _historyGroups = const <MonthlyPayrollGroup>[];
  PayrollPeriod? _selectedPeriod;

  bool _isLoading = false;
  bool _isHistoryLoading = false;
  String? _errorMessage;

  StaffPayrollSummary? get summary => _summary;
  List<PayrollPeriod> get periods => _periods;
  List<MonthlyPayrollGroup> get historyGroups => _historyGroups;
  PayrollPeriod? get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  bool get isHistoryLoading => _isHistoryLoading;
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

      _summary = await _getMyPayrollUseCase.execute(periodId: _selectedPeriod?.id);
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

  Future<void> loadHistoryLedger({BuildContext? context}) async {
    _isHistoryLoading = true;
    notifyListeners();

    try {
      final List<dynamic> results = await Future.wait<dynamic>([
        _getMyPayrollHistoryUseCase.execute(),
        _getPayrollPeriodsUseCase.execute(),
      ]);
      _historyGroups = results[0] as List<MonthlyPayrollGroup>;
      _periods = results[1] as List<PayrollPeriod>;
    } catch (e) {
      if (context != null && context.mounted) {
        AmanahToaster.error(context, message: e.toString());
      }
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPeriod(PayrollPeriod period, {BuildContext? context}) async {
    _selectedPeriod = period;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _getMyPayrollUseCase.execute(periodId: period.id);
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
