import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_status.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/doctor_queue_appointment.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/doctor_queue_repository.dart';

class DoctorQueueController extends ChangeNotifier {
  final DoctorQueueRepository repository;

  DoctorQueueController({required this.repository});

  List<DoctorQueueAppointment> _queue = [];
  DoctorQueueAppointment? _activeAppointment;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  List<DoctorQueueAppointment> get queue => _queue;
  DoctorQueueAppointment? get activeAppointment => _activeAppointment;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadQueue({
    required String poliklinikId,
    required String date,
    String? session,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await repository.getDailyQueue(
        poliklinikId: poliklinikId,
        date: date,
        session: session,
      );
      _queue = items;
      _syncActiveAppointment();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _syncActiveAppointment() {
    try {
      final inConsultation = _queue.firstWhere(
        (a) => a.status == DoctorQueueStatus.inConsultation,
      );
      _activeAppointment = inConsultation;
      return;
    } catch (_) {}

    try {
      final called = _queue.firstWhere(
        (a) => a.status == DoctorQueueStatus.called,
      );
      _activeAppointment = called;
      return;
    } catch (_) {}

    _activeAppointment = null;
  }

  Future<void> callPatient(String appointmentId) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await repository.callPatient(appointmentId);
      _activeAppointment = updated;
      final index = _queue.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _queue[index] = updated;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> patientRespond(String appointmentId) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await repository.respondPatient(appointmentId);
      _activeAppointment = updated;
      final index = _queue.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _queue[index] = updated;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> noShowPatient(
    String appointmentId, {
    required String poliklinikId,
    required String date,
    String? session,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.noShowPatient(appointmentId);
      _activeAppointment = null;
      await loadQueue(
        poliklinikId: poliklinikId,
        date: date,
        session: session,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeConsultation(
    String appointmentId, {
    String? poliklinikId,
    String? date,
    String? session,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.completeAppointment(appointmentId);
      _activeAppointment = null;
      if (poliklinikId != null && date != null) {
        await loadQueue(
          poliklinikId: poliklinikId,
          date: date,
          session: session,
        );
      } else {
        _queue.removeWhere((a) => a.id == appointmentId);
        _isActionLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
