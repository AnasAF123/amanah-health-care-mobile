import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/services/qr_token_parser.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/checkout_attendance_usecase.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/get_attendance_history_usecase.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/record_attendance_usecase.dart';
import 'package:amanah_healthcare/features/presence/presentation/services/scanner_feedback_service.dart';

enum AmanahQrDrawerView { menu, manualPin, myQr }

enum AttendanceFlowState { idle, detecting, processing, success, error }

enum AttendanceScanMode { checkIn, checkOut }

/// Authoritative Orchestrator for QR Scanning, Camera State, and Attendance Submission.
/// Enforces single-source-of-truth state machine and respects backend error codes.
class PresenceScannerController extends ChangeNotifier {
  PresenceScannerController({
    required RecordAttendanceUseCase recordAttendanceUseCase,
    required CheckoutAttendanceUseCase checkoutAttendanceUseCase,
    GetAttendanceHistoryUseCase? getAttendanceHistoryUseCase,
    IScannerFeedbackService? feedbackService,
  }) : _recordAttendanceUseCase = recordAttendanceUseCase,
       _checkoutAttendanceUseCase = checkoutAttendanceUseCase,
       _getAttendanceHistoryUseCase = getAttendanceHistoryUseCase,
       _feedbackService = feedbackService ?? ScannerFeedbackService();

  final RecordAttendanceUseCase _recordAttendanceUseCase;
  final CheckoutAttendanceUseCase _checkoutAttendanceUseCase;
  final GetAttendanceHistoryUseCase? _getAttendanceHistoryUseCase;
  final IScannerFeedbackService _feedbackService;

  AttendanceFlowState _flowState = AttendanceFlowState.idle;
  AttendanceScanMode _scanMode = AttendanceScanMode.checkIn;
  AmanahQrDrawerView _drawerView = AmanahQrDrawerView.menu;
  bool _isDrawerOpen = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isHelpOpen = false;
  bool _copiedFeedback = false;
  String _manualPin = '';
  String? _pinError;
  String? _errorMessage;
  Object? _lastException;
  AttendanceCheckInResult? _lastResult;
  int _sessionGeneration = 0;
  String? _pendingCheckoutToken;
  String? _pendingCheckoutTicket;
  bool _requiresEarlyDepartureNotes = false;

  AttendanceFlowState get flowState => _flowState;
  AttendanceScanMode get scanMode => _scanMode;
  AmanahQrDrawerView get drawerView => _drawerView;
  bool get isDrawerOpen => _isDrawerOpen;
  bool get isFlashOn => _isFlashOn;
  bool get isFrontCamera => _isFrontCamera;
  bool get isHelpOpen => _isHelpOpen;
  bool get copiedFeedback => _copiedFeedback;
  String get manualPin => _manualPin;
  String? get pinError => _pinError;
  String? get errorMessage => _errorMessage;
  Object? get lastException => _lastException;
  AttendanceCheckInResult? get lastResult => _lastResult;
  String? get pendingCheckoutToken => _pendingCheckoutToken;
  String? get pendingCheckoutTicket => _pendingCheckoutTicket;
  bool get requiresEarlyDepartureNotes => _requiresEarlyDepartureNotes;

  void clearPendingEarlyDeparture() {
    _requiresEarlyDepartureNotes = false;
    _pendingCheckoutToken = null;
    _pendingCheckoutTicket = null;
    notifyListeners();
  }

  /// Deterministic gate: Only allow processing new QR candidate when completely idle.
  bool get isScanningAllowed =>
      _flowState == AttendanceFlowState.idle && !_isDrawerOpen && !_isHelpOpen;

  bool get isFlowActive => _flowState != AttendanceFlowState.idle;
  bool get isLastResultCheckout => _lastResult?.checkOutAt != null;

  /// Switches active scanning mode without unmounting or restarting the camera.
  void setScanMode(AttendanceScanMode mode) {
    if (_scanMode == mode) return;
    _sessionGeneration++;
    _scanMode = mode;
    _errorMessage = null;
    _lastException = null;
    if (_flowState != AttendanceFlowState.success) {
      _flowState = AttendanceFlowState.idle;
    }
    notifyListeners();
  }

  Future<void> initTodayStatus() async {
    if (_getAttendanceHistoryUseCase == null) return;
    try {
      final List<AttendanceRecord> records = await _getAttendanceHistoryUseCase();
      if (records.isNotEmpty) {
        final AttendanceRecord latest = records.first;
        final DateTime now = DateTime.now();
        final DateTime? recordDate = latest.attendanceDate ?? latest.checkInAt;

        final bool isToday = recordDate != null
            ? (recordDate.year == now.year &&
                  recordDate.month == now.month &&
                  recordDate.day == now.day)
            : (latest.dayNumber == now.day);

        // Smart deterministic default: If user checked in today and has not yet checked out
        if (isToday && latest.checkInAt != null && latest.checkOutAt == null) {
          _scanMode = AttendanceScanMode.checkOut;
          notifyListeners();
        } else {
          _scanMode = AttendanceScanMode.checkIn;
          notifyListeners();
        }
      }
    } catch (_) {
      // Graceful fallback to default check-in mode
    }
  }

  void toggleFlash() {
    _isFlashOn = !_isFlashOn;
    notifyListeners();
  }

  void syncFlash(bool on) {
    if (_isFlashOn == on) return;
    _isFlashOn = on;
    notifyListeners();
  }

  void toggleCamera() {
    _isFrontCamera = !_isFrontCamera;
    if (_isFrontCamera) {
      _isFlashOn = false;
    }
    notifyListeners();
  }

  void syncCameraFacing(bool front) {
    if (_isFrontCamera == front) return;
    _isFrontCamera = front;
    if (_isFrontCamera) {
      _isFlashOn = false;
    }
    notifyListeners();
  }

  void openDrawer(AmanahQrDrawerView view) {
    _isDrawerOpen = true;
    _drawerView = view;
    notifyListeners();
  }

  void closeDrawer() {
    _isDrawerOpen = false;
    _drawerView = AmanahQrDrawerView.menu;
    notifyListeners();
  }

  void toggleDrawer() {
    if (_isDrawerOpen) {
      closeDrawer();
    } else {
      openDrawer(AmanahQrDrawerView.menu);
    }
  }

  void setHelpOpen(bool isOpen) {
    _isHelpOpen = isOpen;
    notifyListeners();
  }

  void updateManualPin(String pin) {
    _manualPin = pin;
    _pinError = null;
    notifyListeners();
  }

  void triggerCopiedFeedback() {
    _copiedFeedback = true;
    notifyListeners();
    Future<void>.delayed(const Duration(seconds: 2), () {
      _copiedFeedback = false;
      notifyListeners();
    });
  }

  void reset() {
    _sessionGeneration++;
    _flowState = AttendanceFlowState.idle;
    _isDrawerOpen = false;
    _drawerView = AmanahQrDrawerView.menu;
    _pinError = null;
    _manualPin = '';
    _errorMessage = null;
    _lastException = null;
    _lastResult = null;
    _pendingCheckoutTicket = null;
    _pendingCheckoutToken = null;
    _requiresEarlyDepartureNotes = false;
    notifyListeners();
  }

  /// Authoritative entry point for raw camera barcode detection.
  Future<AttendanceCheckInResult?> handleDetectedBarcode(String rawBarcode) async {
    if (!isScanningAllowed) {
      return null;
    }

    final int generation = ++_sessionGeneration;
    _flowState = AttendanceFlowState.detecting;
    _isDrawerOpen = false;
    _errorMessage = null;
    _lastException = null;
    notifyListeners();

    if (_sessionGeneration != generation) {
      return null;
    }

    final String? token = QrTokenParser.parse(rawBarcode);
    if (token == null || token.isEmpty) {
      if (_sessionGeneration == generation) {
        _errorMessage = 'Format QR Code tidak dikenali.';
        _flowState = AttendanceFlowState.error;
        _isDrawerOpen = true;
        notifyListeners();
        await _feedbackService.onScanError();
      }
      return null;
    }

    _flowState = AttendanceFlowState.processing;
    notifyListeners();

    return _executeAttendanceSubmission(token, generation);
  }

  /// Direct submission entry point (used by manual PIN or programmatic triggers).
  Future<AttendanceCheckInResult?> submitAttendance(String code) async {
    if (isFlowActive) return null;

    final String? token = QrTokenParser.parse(code);
    if (token == null || token.isEmpty) return null;

    final int generation = ++_sessionGeneration;
    _flowState = AttendanceFlowState.processing;
    _isDrawerOpen = false;
    _errorMessage = null;
    _lastException = null;
    notifyListeners();

    return _executeAttendanceSubmission(token, generation);
  }

  Future<AttendanceCheckInResult?> _executeAttendanceSubmission(
    String token,
    int generation,
  ) async {
    try {
      final AttendanceCheckInResult result;
      if (_scanMode == AttendanceScanMode.checkIn) {
        result = await _recordAttendanceUseCase(
          qrToken: token,
          deviceInfo: 'Amanah Mobile (Android/iOS)',
        );
      } else {
        result = await _checkoutAttendanceUseCase(qrToken: token);
      }

      if (_sessionGeneration != generation) {
        return null;
      }

      _lastResult = result;
      _flowState = AttendanceFlowState.success;
      _isDrawerOpen = true;
      notifyListeners();
      await _feedbackService.onScanSuccess();
      return result;
    } catch (err) {
      if (_sessionGeneration != generation) {
        return null;
      }

      _lastException = err;
      if (err is ApiException) {
        final dynamic errData = err.data;
        if (err.code == 'EARLY_DEPARTURE_NOTES_REQUIRED' ||
            (errData is Map && errData['checkoutTicket'] != null)) {
          _requiresEarlyDepartureNotes = true;
          _pendingCheckoutTicket = (errData as Map?)?['checkoutTicket']?.toString();
          _pendingCheckoutToken = token;
        }
      }

      _errorMessage = err is ApiException ? err.message : err.toString();
      _flowState = AttendanceFlowState.error;
      _isDrawerOpen = true;
      notifyListeners();
      await _feedbackService.onScanError();
      return null;
    }
  }

  void openResultDrawer() {
    _isDrawerOpen = true;
    notifyListeners();
  }

  void closeResultDrawer() {
    _sessionGeneration++;
    _isDrawerOpen = false;
    _flowState = AttendanceFlowState.idle;
    _errorMessage = null;
    _lastException = null;
    _lastResult = null;
    _requiresEarlyDepartureNotes = false;
    _pendingCheckoutToken = null;
    _pendingCheckoutTicket = null;
    notifyListeners();
  }

  void acknowledgeError() => closeResultDrawer();

  void clearError() => acknowledgeError();

  Future<AttendanceCheckInResult?> submitManualPin() async {
    final String pin = _manualPin.trim();
    if (pin.length < 6) {
      _pinError = 'Masukkan 6 digit kode presensi.';
      notifyListeners();
      return null;
    }

    _pinError = null;
    _drawerView = AmanahQrDrawerView.menu;
    return submitAttendance(pin);
  }

  Future<AttendanceCheckInResult?> submitCheckout({
    String? qrToken,
    String? checkoutTicket,
    String? notes,
  }) async {
    final int generation = ++_sessionGeneration;
    _flowState = AttendanceFlowState.processing;
    notifyListeners();

    try {
      final AttendanceCheckInResult result = await _checkoutAttendanceUseCase(
        qrToken: qrToken ?? _pendingCheckoutToken,
        checkoutTicket: checkoutTicket ?? _pendingCheckoutTicket,
        notes: notes,
      );
      if (_sessionGeneration != generation) return null;
      _lastResult = result;
      _flowState = AttendanceFlowState.success;
      _requiresEarlyDepartureNotes = false;
      _pendingCheckoutToken = null;
      _pendingCheckoutTicket = null;
      _lastException = null;
      _isDrawerOpen = true;
      notifyListeners();
      await _feedbackService.onScanSuccess();
      return result;
    } catch (err) {
      if (_sessionGeneration != generation) return null;
      _lastException = err;
      if (err is ApiException) {
        final dynamic errData = err.data;
        if (err.code == 'EARLY_DEPARTURE_NOTES_REQUIRED' ||
            (errData is Map && errData['checkoutTicket'] != null)) {
          _requiresEarlyDepartureNotes = true;
          _pendingCheckoutTicket = (errData as Map?)?['checkoutTicket']?.toString();
          _pendingCheckoutToken = qrToken ?? _pendingCheckoutToken;
        }
      }
      _errorMessage = err is ApiException ? err.message : err.toString();
      _flowState = AttendanceFlowState.error;
      _isDrawerOpen = false;
      notifyListeners();
      await _feedbackService.onScanError();
      return null;
    }
  }
}
