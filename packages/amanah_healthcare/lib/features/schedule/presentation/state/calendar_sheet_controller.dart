import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/failures/schedule_failure.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_my_schedules.dart';
import 'package:amanah_healthcare/features/schedule/domain/usecases/get_session_patients.dart';

class CalendarSheetController extends ChangeNotifier {
  CalendarSheetController({
    required this.selectedDate,
    ScheduleRepository? repository,
    GetMySchedulesUseCase? getMySchedulesUseCase,
    GetSessionPatientsUseCase? getSessionPatientsUseCase,
  })  : _getMySchedulesUseCase = getMySchedulesUseCase ??
            GetMySchedulesUseCase(repository ?? ScheduleRepositoryImpl()),
        _getSessionPatientsUseCase = getSessionPatientsUseCase ??
            GetSessionPatientsUseCase(repository ?? ScheduleRepositoryImpl());

  final DateTime selectedDate;
  final GetMySchedulesUseCase _getMySchedulesUseCase;
  final GetSessionPatientsUseCase _getSessionPatientsUseCase;

  bool _isLoadingSessions = true;
  String? _errorMessage;
  List<MyScheduleSession> _activeSessions = const <MyScheduleSession>[];

  // Session ID -> Patients
  final Map<String, List<SessionPatient>> _sessionPatients =
      <String, List<SessionPatient>>{};
  // Session ID -> Loading state
  final Map<String, bool> _loadingPatients = <String, bool>{};
  // Expanded session IDs
  final Set<String> _expandedSessionIds = <String>{};

  bool get isLoadingSessions => _isLoadingSessions;
  String? get errorMessage => _errorMessage;
  List<MyScheduleSession> get activeSessions => _activeSessions;
  Set<String> get expandedSessionIds =>
      Set<String>.unmodifiable(_expandedSessionIds);

  String _formatDateString(DateTime d) => formatIsoDateString(d);

  bool isExpanded(String sessionId) => _expandedSessionIds.contains(sessionId);

  bool isLoadingPatientsForSession(String sessionId) =>
      _loadingPatients[sessionId] ?? false;

  List<SessionPatient>? getPatientsForSession(String sessionId) =>
      _sessionPatients[sessionId];

  Future<void> loadSessions() async {
    _isLoadingSessions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String dateStr = _formatDateString(selectedDate);
      final List<MyScheduleSession> all = await _getMySchedulesUseCase(
        GetMySchedulesParams(date: dateStr),
      );
      // Filter only active / open sessions per user requirement
      _activeSessions = all
          .where((s) => s.isAvailable && s.status.toUpperCase() != 'CLOSED')
          .toList();
    } catch (e) {
      _errorMessage = e is ScheduleFailure ? e.message : e.toString();
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  Future<void> toggleSessionExpanded(String sessionId) async {
    if (_expandedSessionIds.contains(sessionId)) {
      _expandedSessionIds.remove(sessionId);
      notifyListeners();
      return;
    }

    _expandedSessionIds.add(sessionId);
    notifyListeners();

    // Lazy load patients if not loaded yet
    if (!_sessionPatients.containsKey(sessionId)) {
      await loadPatientsForSession(sessionId);
    }
  }

  Future<void> loadPatientsForSession(String sessionId) async {
    _loadingPatients[sessionId] = true;
    notifyListeners();

    try {
      final String dateStr = _formatDateString(selectedDate);
      final List<SessionPatient> patients = await _getSessionPatientsUseCase(
        GetSessionPatientsParams(
          sessionId: sessionId,
          date: dateStr,
        ),
      );
      _sessionPatients[sessionId] = patients;
    } catch (e) {
      _sessionPatients[sessionId] = const <SessionPatient>[];
    } finally {
      _loadingPatients[sessionId] = false;
      notifyListeners();
    }
  }
}
