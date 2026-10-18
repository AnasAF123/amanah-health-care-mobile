import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_toaster.dart';
import 'package:amanah_healthcare/features/permission/data/repositories/permission_repository_impl.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';
import 'package:amanah_healthcare/features/permission/domain/usecases/cancel_leave_usecase.dart';
import 'package:amanah_healthcare/features/permission/domain/usecases/claim_replacement_usecase.dart';
import 'package:amanah_healthcare/features/permission/domain/usecases/get_available_replacements_usecase.dart';
import 'package:amanah_healthcare/features/permission/domain/usecases/get_eligible_sessions_usecase.dart';
import 'package:amanah_healthcare/features/permission/domain/usecases/get_my_leaves_usecase.dart';
import 'package:amanah_healthcare/features/permission/domain/usecases/request_leave_usecase.dart';

class PermissionController extends ChangeNotifier {
  PermissionController({
    PermissionRepository? repository,
    GetMyLeavesUseCase? getMyLeavesUseCase,
    GetEligibleSessionsUseCase? getEligibleSessionsUseCase,
    RequestLeaveUseCase? requestLeaveUseCase,
    CancelLeaveUseCase? cancelLeaveUseCase,
    GetAvailableReplacementsUseCase? getAvailableReplacementsUseCase,
    ClaimReplacementUseCase? claimReplacementUseCase,
  })  : _getMyLeavesUseCase = getMyLeavesUseCase ??
            GetMyLeavesUseCase(repository ?? PermissionRepositoryImpl()),
        _getEligibleSessionsUseCase = getEligibleSessionsUseCase ??
            GetEligibleSessionsUseCase(repository ?? PermissionRepositoryImpl()),
        _requestLeaveUseCase = requestLeaveUseCase ??
            RequestLeaveUseCase(repository ?? PermissionRepositoryImpl()),
        _cancelLeaveUseCase = cancelLeaveUseCase ??
            CancelLeaveUseCase(repository ?? PermissionRepositoryImpl()),
        _getAvailableReplacementsUseCase = getAvailableReplacementsUseCase ??
            GetAvailableReplacementsUseCase(
                repository ?? PermissionRepositoryImpl()),
        _claimReplacementUseCase = claimReplacementUseCase ??
            ClaimReplacementUseCase(repository ?? PermissionRepositoryImpl());

  final GetMyLeavesUseCase _getMyLeavesUseCase;
  final GetEligibleSessionsUseCase _getEligibleSessionsUseCase;
  final RequestLeaveUseCase _requestLeaveUseCase;
  final CancelLeaveUseCase _cancelLeaveUseCase;
  final GetAvailableReplacementsUseCase _getAvailableReplacementsUseCase;
  final ClaimReplacementUseCase _claimReplacementUseCase;

  List<LeaveRequestEntity> _myLeaves = const <LeaveRequestEntity>[];
  List<ReplacementItem> _availableReplacements = const <ReplacementItem>[];
  List<EligibleSession> _eligibleSessions = const <EligibleSession>[];

  bool _isLoading = false;
  bool _isLoadingSessions = false;
  String? _errorMessage;

  List<LeaveRequestEntity> get myLeaves => _myLeaves;
  List<ReplacementItem> get availableReplacements => _availableReplacements;
  List<EligibleSession> get eligibleSessions => _eligibleSessions;
  bool get isLoading => _isLoading;
  bool get isLoadingSessions => _isLoadingSessions;
  String? get errorMessage => _errorMessage;

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchMyLeaves({BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myLeaves = await _getMyLeavesUseCase.execute();
    } catch (e) {
      _errorMessage = e.toString();
      if (context != null && context.mounted) {
        AmanahToaster.error(
          context,
          message: _errorMessage ?? 'Gagal memuat daftar perizinan',
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableReplacements() async {
    try {
      _availableReplacements =
          await _getAvailableReplacementsUseCase.execute();
      notifyListeners();
    } catch (e) {
      // Non-blocking
    }
  }

  Future<List<EligibleSession>> fetchEligibleSessions(DateTime date) async {
    _isLoadingSessions = true;
    notifyListeners();

    try {
      final String dateStr = _formatDate(date);
      _eligibleSessions = await _getEligibleSessionsUseCase.execute(dateStr);
      return _eligibleSessions;
    } catch (e) {
      _eligibleSessions = const <EligibleSession>[];
      return _eligibleSessions;
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  Future<bool> submitLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? type,
    String? scope,
    List<String>? sessionIds,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _requestLeaveUseCase.execute(
        startDate: _formatDate(startDate),
        endDate: _formatDate(endDate),
        reason: reason,
        type: type,
        scope: scope,
        sessionIds: sessionIds,
      );
      if (context != null && context.mounted) {
        AmanahToaster.success(
          context,
          message: 'Permohonan izin/cuti berhasil diajukan',
        );
      }
      await fetchMyLeaves();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (context != null && context.mounted) {
        AmanahToaster.error(
          context,
          message: _errorMessage ?? 'Gagal mengajukan izin',
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelLeave(String id, {BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cancelLeaveUseCase.execute(id);
      if (context != null && context.mounted) {
        AmanahToaster.success(
          context,
          message: 'Pengajuan cuti berhasil dibatalkan',
        );
      }
      await fetchMyLeaves();
      return true;
    } catch (e) {
      if (context != null && context.mounted) {
        AmanahToaster.error(context, message: e.toString());
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> claimReplacement(String id, {BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _claimReplacementUseCase.execute(id);
      if (context != null && context.mounted) {
        AmanahToaster.success(
          context,
          message:
              'Jadwal dinas pengganti berhasil diklaim. Jadwal telah tercatat.',
        );
      }
      await fetchAvailableReplacements();
      return true;
    } catch (e) {
      if (context != null && context.mounted) {
        AmanahToaster.error(context, message: e.toString());
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
