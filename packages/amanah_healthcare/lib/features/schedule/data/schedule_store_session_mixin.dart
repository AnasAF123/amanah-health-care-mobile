import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_repository.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

mixin ScheduleStoreSessionMixin on ChangeNotifier {
  AmanahScheduleRepository get repository;
  void setLoading(bool loading);
  void setErrorMessage(String? error);
  void setLastConflict(AmanahScheduleConflictException? conflict);
  Future<List<DoctorSchedule>> loadSchedulesForDate(
    DateTime date, {
    String? doctorId,
    bool forceRefresh = false,
  });
  Future<CalendarSummaryResponse?> loadCalendarSummary(String month);

  SessionPatientsData? _activeSessionPatients;
  bool _isSessionPatientsLoading = false;
  String? _sessionPatientsError;

  SessionPatientsData? get activeSessionPatients => _activeSessionPatients;
  bool get isSessionPatientsLoading => _isSessionPatientsLoading;
  String? get sessionPatientsError => _sessionPatientsError;

  void clearActiveSessionPatients() {
    _activeSessionPatients = null;
    _sessionPatientsError = null;
    notifyListeners();
  }

  void resetSessionState() {
    _activeSessionPatients = null;
    _isSessionPatientsLoading = false;
    _sessionPatientsError = null;
  }

  Future<SessionPatientsData> fetchSessionPatients(String sessionId) async {
    _isSessionPatientsLoading = true;
    _sessionPatientsError = null;
    notifyListeners();

    try {
      final SessionPatientsData data =
          await repository.fetchSessionPatients(sessionId);
      _activeSessionPatients = data;
      _isSessionPatientsLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _isSessionPatientsLoading = false;
      _sessionPatientsError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> callPatient(String appointmentId) async {
    try {
      await repository.callPatient(appointmentId);
      if (_activeSessionPatients != null) {
        final List<BookedPatient> updated = _activeSessionPatients!.patients
            .map((BookedPatient p) => p.id == appointmentId || p.appointmentId == appointmentId
                ? p.copyWith(
                    status: 'IN_SERVICE',
                    statusBadge: 'Pemeriksaan',
                    badge: 'Pemeriksaan',
                    badgeVariant: AmanahBadgeVariant.live,
                  )
                : p)
            .toList();
        _activeSessionPatients = _activeSessionPatients!.copyWith(patients: updated);
        notifyListeners();
      }
    } catch (e) {
      setErrorMessage(e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> completeConsultation(String appointmentId) async {
    try {
      await repository.completeConsultation(appointmentId);
      if (_activeSessionPatients != null) {
        final List<BookedPatient> updated = _activeSessionPatients!.patients
            .map((BookedPatient p) => p.id == appointmentId || p.appointmentId == appointmentId
                ? p.copyWith(
                    status: 'COMPLETED',
                    statusBadge: 'Selesai',
                    badge: 'Selesai',
                    badgeVariant: AmanahBadgeVariant.success,
                  )
                : p)
            .toList();
        _activeSessionPatients = _activeSessionPatients!.copyWith(patients: updated);
        notifyListeners();
      }
    } catch (e) {
      setErrorMessage(e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelAppointment(String appointmentId, {String? reason}) async {
    try {
      await repository.cancelAppointment(
        appointmentId,
        reason: reason ?? 'Dibatalkan oleh dokter',
      );
      if (_activeSessionPatients != null) {
        final List<BookedPatient> updated = _activeSessionPatients!.patients
            .map((BookedPatient p) => p.id == appointmentId || p.appointmentId == appointmentId
                ? p.copyWith(
                    status: 'CANCELLED',
                    statusBadge: 'Dibatalkan',
                    badge: 'Dibatalkan',
                    badgeVariant: AmanahBadgeVariant.warning,
                  )
                : p)
            .toList();
        _activeSessionPatients = _activeSessionPatients!.copyWith(patients: updated);
        notifyListeners();
      }
    } catch (e) {
      setErrorMessage(e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<RescheduleEligibilityData?> checkRescheduleEligibility({
    required String doctorId,
    required String sessionId,
    String? targetDate,
    String? targetStartTime,
    String? targetRoomId,
  }) async {
    try {
      return await repository.checkRescheduleEligibility(
        doctorId: doctorId,
        sessionId: sessionId,
        targetDate: targetDate,
        targetStartTime: targetStartTime,
        targetRoomId: targetRoomId,
      );
    } catch (e) {
      setErrorMessage(e.toString());
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>> rescheduleSession({
    required String doctorId,
    required String sessionId,
    required String targetDate,
    required String targetStartTime,
    String? targetScheduleContextId,
    String? targetRoomId,
    String? notes,
    bool rescheduleActiveAppointments = true,
    DateTime? sourceDate,
  }) async {
    setLoading(true);
    setErrorMessage(null);
    setLastConflict(null);
    notifyListeners();

    try {
      final Map<String, dynamic> result = await repository.rescheduleSession(
        doctorId: doctorId,
        sessionId: sessionId,
        targetDate: targetDate,
        targetStartTime: targetStartTime,
        targetScheduleContextId: targetScheduleContextId,
        targetRoomId: targetRoomId,
        notes: notes,
        rescheduleActiveAppointments: rescheduleActiveAppointments,
      );

      final List<Future<dynamic>> refreshFutures = <Future<dynamic>>[];
      if (sourceDate != null) {
        refreshFutures.add(loadSchedulesForDate(sourceDate, forceRefresh: true));
      }
      final DateTime? parsedTarget = DateTime.tryParse(targetDate);
      if (parsedTarget != null) {
        refreshFutures.add(loadSchedulesForDate(parsedTarget, forceRefresh: true));
        refreshFutures.add(loadCalendarSummary(
          '${parsedTarget.year}-${parsedTarget.month.toString().padLeft(2, '0')}',
        ));
      }

      if (refreshFutures.isNotEmpty) {
        await Future.wait(refreshFutures);
      }

      setLoading(false);
      notifyListeners();
      return result;
    } on AmanahScheduleConflictException catch (e) {
      setLoading(false);
      setLastConflict(e);
      setErrorMessage(e.message);
      notifyListeners();
      rethrow;
    } catch (e) {
      setLoading(false);
      setErrorMessage(e.toString());
      notifyListeners();
      rethrow;
    }
  }
}
