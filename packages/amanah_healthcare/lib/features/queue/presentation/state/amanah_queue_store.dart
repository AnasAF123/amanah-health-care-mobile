import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/notifications/amanah_push_service.dart';
import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/queue/data/repositories/queue_repository_impl.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_patient_card.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_session_info.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/reschedule_options_entity.dart';
import 'package:amanah_healthcare/features/queue/domain/failures/queue_failure.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/call_patient_use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/cancel_appointment_use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/complete_service_use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/get_completed_queue_use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/get_doctor_today_sessions_use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/get_reschedule_options_use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/get_session_queue_use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/report_no_show_use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/reschedule_appointment_use_case.dart';
import 'package:amanah_healthcare/features/queue/domain/usecases/start_service_use_case.dart';

/// Reactive Store managing clinical queue state for the authenticated practitioner.
class AmanahQueueStore extends ChangeNotifier {
  AmanahQueueStore._() {
    final QueueRepository repo = QueueRepositoryImpl();
    _getSessionsUseCase = GetDoctorTodaySessionsUseCase(repo);
    _getQueueUseCase = GetSessionQueueUseCase(repo);
    _callPatientUseCase = CallPatientUseCase(repo);
    _startServiceUseCase = StartServiceUseCase(repo);
    _completeServiceUseCase = CompleteServiceUseCase(repo);
    _cancelAppointmentUseCase = CancelAppointmentUseCase(repo);
    _reportNoShowUseCase = ReportNoShowUseCase(repo);
    _rescheduleAppointmentUseCase = RescheduleAppointmentUseCase(repo);
    _getRescheduleOptionsUseCase = GetRescheduleOptionsUseCase(repo);
    _getCompletedQueueUseCase = GetCompletedQueueUseCase(repo);

    // Auto-refresh queue when an incoming push notification arrives
    AmanahPushService.instance.addMessageListener((_) {
      refreshQueue(silent: true);
    });
  }

  static final AmanahQueueStore instance = AmanahQueueStore._();

  late final GetDoctorTodaySessionsUseCase _getSessionsUseCase;
  late final GetSessionQueueUseCase _getQueueUseCase;
  late final CallPatientUseCase _callPatientUseCase;
  late final StartServiceUseCase _startServiceUseCase;
  late final CompleteServiceUseCase _completeServiceUseCase;
  late final CancelAppointmentUseCase _cancelAppointmentUseCase;
  late final ReportNoShowUseCase _reportNoShowUseCase;
  late final RescheduleAppointmentUseCase _rescheduleAppointmentUseCase;
  late final GetRescheduleOptionsUseCase _getRescheduleOptionsUseCase;
  late final GetCompletedQueueUseCase _getCompletedQueueUseCase;

  List<QueueSessionInfo> _sessions = <QueueSessionInfo>[];
  QueueSessionInfo? _activeSession;
  List<QueuePatientCard> _waitingPatients = <QueuePatientCard>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<QueueSessionInfo> get sessions => List<QueueSessionInfo>.unmodifiable(_sessions);
  QueueSessionInfo? get activeSession => _activeSession;
  List<QueuePatientCard> get waitingPatients =>
      List<QueuePatientCard>.unmodifiable(_waitingPatients);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads today's duty sessions and automatically fetches the waiting queue for the active shift.
  Future<void> loadTodaySessionsAndQueue() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Ensure FCM push device token is active and linked to current session
    unawaited(AmanahPushService.instance.registerDeviceWithBackend());

    try {
      _sessions = await _getSessionsUseCase(const NoParams());

      if (_sessions.isNotEmpty) {
        _activeSession = _resolveOptimalActiveSession(_sessions);
        if (_activeSession != null) {
          _waitingPatients = await _getQueueUseCase(_activeSession!.sessionId);
        } else {
          _waitingPatients = <QueuePatientCard>[];
        }
      } else {
        _activeSession = null;
        _waitingPatients = <QueuePatientCard>[];
      }
    } catch (e) {
      _errorMessage = e is QueueFailure ? e.message : e.toString();
      AppLog.error('[AmanahQueueStore] Error loading today sessions and queue: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Manually switches to another shift session.
  Future<void> selectSession(QueueSessionInfo session) async {
    if (_activeSession?.sessionId == session.sessionId) return;
    _activeSession = session;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _waitingPatients = await _getQueueUseCase(session.sessionId);
    } catch (e) {
      _errorMessage = e is QueueFailure ? e.message : e.toString();
      AppLog.error('[AmanahQueueStore] Error selecting session: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes waiting patients for the currently active session.
  Future<void> refreshQueue({bool silent = false}) async {
    if (_activeSession == null) return;
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _waitingPatients = await _getQueueUseCase(_activeSession!.sessionId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e is QueueFailure ? e.message : e.toString();
      AppLog.error('[AmanahQueueStore] Error refreshing queue: $_errorMessage');
    } finally {
      if (!silent) _isLoading = false;
      notifyListeners();
    }
  }

  /// Calls a patient to enter the consultation room.
  Future<void> callPatient(String appointmentId, {String? notes}) async {
    try {
      await _callPatientUseCase(
        CallPatientParams(appointmentId: appointmentId, notes: notes),
      );
      await refreshQueue(silent: true);
    } catch (e) {
      _errorMessage = e is QueueFailure ? e.message : e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Starts examination (WAITING -> IN_SERVICE).
  Future<void> startService(String appointmentId) async {
    try {
      await _startServiceUseCase(appointmentId);
      await refreshQueue(silent: true);
    } catch (e) {
      _errorMessage = e is QueueFailure ? e.message : e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Completes consultation (IN_SERVICE -> COMPLETED).
  Future<void> completeService(String appointmentId) async {
    try {
      await _completeServiceUseCase(appointmentId);
      await refreshQueue(silent: true);
    } catch (e) {
      _errorMessage = e is QueueFailure ? e.message : e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Cancels appointment from queue.
  Future<void> cancelAppointment(String appointmentId, {String? reason}) async {
    try {
      await _cancelAppointmentUseCase(
        CancelAppointmentParams(appointmentId: appointmentId, reason: reason),
      );
      await refreshQueue(silent: true);
    } catch (e) {
      _errorMessage = e is QueueFailure ? e.message : e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Reports patient did not show up.
  Future<void> reportNoShow(String appointmentId, {String? notes}) async {
    try {
      await _reportNoShowUseCase(
        ReportNoShowParams(appointmentId: appointmentId, notes: notes),
      );
      await refreshQueue(silent: true);
    } catch (e) {
      _errorMessage = e is QueueFailure ? e.message : e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Reschedules an appointment to a target date and session.
  Future<void> rescheduleAppointment(
    String appointmentId, {
    required String targetDate,
    String? session,
    String? targetSessionId,
    String? reason,
  }) async {
    try {
      await _rescheduleAppointmentUseCase(
        RescheduleAppointmentParams(
          appointmentId: appointmentId,
          targetDate: targetDate,
          session: session,
          targetSessionId: targetSessionId,
          reason: reason,
        ),
      );
      await refreshQueue(silent: true);
    } catch (e) {
      _errorMessage = e is QueueFailure ? e.message : e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Fetches dynamic reschedule options (available dates and active shifts) from backend.
  Future<RescheduleOptionsEntity?> getRescheduleOptions(
      String appointmentId) async {
    try {
      return await _getRescheduleOptionsUseCase(appointmentId);
    } catch (e) {
      AppLog.error('[AmanahQueueStore] Error fetching reschedule options: $e');
      return null;
    }
  }

  /// Fetches completed queue patients for a specific session from backend.
  Future<List<QueuePatientCard>> loadCompletedPatients(String sessionId) async {
    try {
      return await _getCompletedQueueUseCase(sessionId);
    } catch (e) {
      AppLog.error('[AmanahQueueStore] Error loading completed patients: $e');
      return <QueuePatientCard>[];
    }
  }

  /// Auto-selects the optimal session based on current clock time.
  QueueSessionInfo? _resolveOptimalActiveSession(List<QueueSessionInfo> sessions) {
    if (sessions.isEmpty) return null;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    for (final s in sessions) {
      final startMin = _parseTimeToMinutes(s.startTime);
      final endMin = _parseTimeToMinutes(s.endTime);
      if (startMin != null && endMin != null) {
        if (nowMinutes >= startMin && nowMinutes <= endMin) {
          return s;
        }
      }
    }

    // Fallback: return the first available session
    return sessions.first;
  }

  int? _parseTimeToMinutes(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        return h * 60 + m;
      }
    } catch (_) {}
    return null;
  }
}
