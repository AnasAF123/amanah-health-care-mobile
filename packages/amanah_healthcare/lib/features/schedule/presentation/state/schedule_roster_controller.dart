import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_toaster.dart';
import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/failures/schedule_failure.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/reset_doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/update_doctor_roster.dart';

class ScheduleRosterController extends ChangeNotifier {
  ScheduleRosterController({
    ScheduleRepository? repository,
    GetDoctorRosterUseCase? getRosterUseCase,
    UpdateDoctorRosterUseCase? updateRosterUseCase,
    ResetDoctorRosterUseCase? resetRosterUseCase,
  })  : _getRosterUseCase = getRosterUseCase ??
            GetDoctorRosterUseCase(repository ?? ScheduleRepositoryImpl()),
        _updateRosterUseCase = updateRosterUseCase ??
            UpdateDoctorRosterUseCase(repository ?? ScheduleRepositoryImpl()),
        _resetRosterUseCase = resetRosterUseCase ??
            ResetDoctorRosterUseCase(repository ?? ScheduleRepositoryImpl());

  final GetDoctorRosterUseCase _getRosterUseCase;
  final UpdateDoctorRosterUseCase _updateRosterUseCase;
  final ResetDoctorRosterUseCase _resetRosterUseCase;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isResetting = false;
  String? _errorMessage;
  DoctorRoster? _roster;

  // Key: "${dow}_${sessionId}" -> bool
  final Map<String, bool> _draftAssignments = <String, bool>{};
  final Map<String, bool> _templateAssignments = <String, bool>{};

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isResetting => _isResetting;
  String? get errorMessage => _errorMessage;
  DoctorRoster? get roster => _roster;
  Map<String, bool> get draftAssignments =>
      Map<String, bool>.unmodifiable(_draftAssignments);

  bool get isOverride => _roster?.hasAnyOverride ?? false;

  bool get hasUnsavedChanges {
    if (_roster == null) return false;
    for (final DoctorRosterDay day in _roster!.days) {
      for (final DoctorRosterSession session in day.sessions) {
        final String key = '${day.dow}_${session.sessionId}';
        final bool draftVal = _draftAssignments[key] ?? session.isActive;
        if (draftVal != session.isActive) {
          return true;
        }
      }
    }
    return false;
  }

  bool isSessionActive(int dow, String sessionId) {
    final String key = '${dow}_$sessionId';
    return _draftAssignments[key] ?? false;
  }

  bool isDayActive(int dow) {
    if (_roster == null) return false;
    final int idx = _roster!.days.indexWhere((d) => d.dow == dow);
    if (idx < 0) return false;
    final DoctorRosterDay day = _roster!.days[idx];
    return day.sessions.any((s) => isSessionActive(dow, s.sessionId));
  }

  bool hasDayDiffFromTemplate(int dow) {
    if (_roster == null) return false;
    final int idx = _roster!.days.indexWhere((d) => d.dow == dow);
    if (idx < 0) return false;
    final DoctorRosterDay day = _roster!.days[idx];
    for (final DoctorRosterSession s in day.sessions) {
      final String key = '${dow}_${s.sessionId}';
      final bool draft = _draftAssignments[key] ?? false;
      final bool template = _templateAssignments[key] ?? false;
      if (draft != template) return true;
    }
    return false;
  }

  Future<void> loadRoster() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final DoctorRoster result = await _getRosterUseCase(const NoParams());
      _roster = result;
      _populateAssignments(result);
    } catch (e) {
      _errorMessage = e is ScheduleFailure ? e.message : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _populateAssignments(DoctorRoster roster) {
    _draftAssignments.clear();
    _templateAssignments.clear();

    for (final DoctorRosterDay day in roster.days) {
      for (final DoctorRosterSession session in day.sessions) {
        final String key = '${day.dow}_${session.sessionId}';
        _draftAssignments[key] = session.isActive;
        _templateAssignments[key] = session.isTemplateActive ?? session.isActive;
      }
    }
  }

  void toggleSession(int dow, String sessionId) {
    final String key = '${dow}_$sessionId';
    final bool current = _draftAssignments[key] ?? false;
    _draftAssignments[key] = !current;
    notifyListeners();
  }

  void toggleDay(int dow) {
    if (_roster == null) return;
    final int idx = _roster!.days.indexWhere((d) => d.dow == dow);
    if (idx < 0) return;
    final DoctorRosterDay day = _roster!.days[idx];
    final bool currentlyActive = isDayActive(dow);

    for (final DoctorRosterSession session in day.sessions) {
      final String key = '${dow}_${session.sessionId}';
      if (currentlyActive) {
        _draftAssignments[key] = false;
      } else {
        // Activate according to template, or all if template not set
        final bool shouldAct = _templateAssignments[key] ?? true;
        _draftAssignments[key] = shouldAct;
      }
    }
    notifyListeners();
  }

  void resetDayToTemplate(int dow) {
    if (_roster == null) return;
    final int idx = _roster!.days.indexWhere((d) => d.dow == dow);
    if (idx < 0) return;
    final DoctorRosterDay day = _roster!.days[idx];

    for (final DoctorRosterSession session in day.sessions) {
      final String key = '${dow}_${session.sessionId}';
      _draftAssignments[key] = _templateAssignments[key] ?? false;
    }
    notifyListeners();
  }

  Future<bool> saveOverrides(BuildContext context) async {
    if (_roster == null) return false;
    _isSaving = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> assignments = <Map<String, dynamic>>[];
      for (final DoctorRosterDay day in _roster!.days) {
        for (final DoctorRosterSession session in day.sessions) {
          final String key = '${day.dow}_${session.sessionId}';
          assignments.add(<String, dynamic>{
            'dow': day.dow,
            'sessionId': session.sessionId,
            'isActive': _draftAssignments[key] ?? false,
          });
        }
      }

      final DoctorRoster updated = await _updateRosterUseCase(
        UpdateDoctorRosterParams(
          assignments: assignments,
          reason: 'Penyesuaian jadwal dokter dari aplikasi mobile',
        ),
      );

      _roster = updated;
      _populateAssignments(updated);
      _isSaving = false;
      notifyListeners();

      // Instantly synchronize global schedule store (SSOT) to mutate home screen cards
      await AmanahScheduleStore.instance.syncTodaySchedules();

      if (context.mounted) {
        AmanahToaster.success(
          context,
          message: 'Jadwal shift kerja berhasil disimpan',
        );
      }
      return true;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      if (context.mounted) {
        final String msg = e is ScheduleFailure ? e.message : e.toString();
        AmanahToaster.error(context, message: msg);
      }
      return false;
    }
  }

  Future<bool> resetAllToTemplate(BuildContext context) async {
    _isResetting = true;
    notifyListeners();

    try {
      final DoctorRoster res = await _resetRosterUseCase(const NoParams());
      _roster = res;
      _populateAssignments(res);
      _isResetting = false;
      notifyListeners();

      // Instantly synchronize global schedule store (SSOT) to mutate home screen cards
      await AmanahScheduleStore.instance.syncTodaySchedules();

      if (context.mounted) {
        AmanahToaster.success(
          context,
          message: 'Jadwal berhasil direset ke template mingguan klinik',
        );
      }
      return true;
    } catch (e) {
      _isResetting = false;
      notifyListeners();
      if (context.mounted) {
        final String msg = e is ScheduleFailure ? e.message : e.toString();
        AmanahToaster.error(context, message: msg);
      }
      return false;
    }
  }
}
