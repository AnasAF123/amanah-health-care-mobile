import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/checkout_attendance_usecase.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/get_attendance_history_usecase.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/record_attendance_usecase.dart';

enum AmanahQrDrawerView { menu, manualPin, myQr }

enum AttendanceFlowState { idle, processing, success }

enum AttendanceScanMode { checkIn, checkOut }

class PresenceScannerController extends ChangeNotifier {
  PresenceScannerController({
    required RecordAttendanceUseCase recordAttendanceUseCase,
    required CheckoutAttendanceUseCase checkoutAttendanceUseCase,
    GetAttendanceHistoryUseCase? getAttendanceHistoryUseCase,
  })  : _recordAttendanceUseCase = recordAttendanceUseCase,
        _checkoutAttendanceUseCase = checkoutAttendanceUseCase,
        _getAttendanceHistoryUseCase = getAttendanceHistoryUseCase;

  final RecordAttendanceUseCase _recordAttendanceUseCase;
  final CheckoutAttendanceUseCase _checkoutAttendanceUseCase;
  final GetAttendanceHistoryUseCase? _getAttendanceHistoryUseCase;

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
  AttendanceCheckInResult? _lastResult;

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
  AttendanceCheckInResult? get lastResult => _lastResult;

  bool get isFlowActive => _flowState != AttendanceFlowState.idle;
  bool get isLastResultCheckout => _lastResult?.checkOutAt != null;

  void setScanMode(AttendanceScanMode mode) {
    if (_scanMode == mode) return;
    _scanMode = mode;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> initTodayStatus() async {
    if (_getAttendanceHistoryUseCase == null) return;
    try {
      final List<AttendanceRecord> records =
          await _getAttendanceHistoryUseCase();
      if (records.isNotEmpty) {
        final AttendanceRecord latest = records.first;
        final DateTime now = DateTime.now();
        if (latest.dayNumber == now.day) {
          // If staff already has attendance today, smart default to check-out
          _scanMode = AttendanceScanMode.checkOut;
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
    _flowState = AttendanceFlowState.idle;
    _isDrawerOpen = false;
    _drawerView = AmanahQrDrawerView.menu;
    _pinError = null;
    _manualPin = '';
    _errorMessage = null;
    notifyListeners();
  }

  Future<AttendanceCheckInResult?> submitAttendance(String code) async {
    if (isFlowActive) return null;

    final String trimmed = code.trim();
    if (trimmed.isEmpty) return null;

    _flowState = AttendanceFlowState.processing;
    _isDrawerOpen = false;
    _errorMessage = null;
    notifyListeners();

    try {
      AttendanceCheckInResult result;
      if (_scanMode == AttendanceScanMode.checkIn) {
        try {
          result = await _recordAttendanceUseCase(
            qrToken: trimmed,
            deviceInfo: 'Amanah Mobile (Android/iOS)',
          );
        } catch (err) {
          final String errMsg = _formatError(err);
          if (errMsg.toLowerCase().contains('sudah melakukan presensi masuk') ||
              errMsg.contains('409')) {
            _scanMode = AttendanceScanMode.checkOut;
            result = await _checkoutAttendanceUseCase(
              qrToken: trimmed,
            );
          } else {
            rethrow;
          }
        }
      } else {
        result = await _checkoutAttendanceUseCase(
          qrToken: trimmed,
        );
      }
      _lastResult = result;
      _flowState = AttendanceFlowState.success;
      notifyListeners();
      return result;
    } catch (err) {
      _errorMessage = _formatError(err);
      _flowState = AttendanceFlowState.idle;
      _isDrawerOpen = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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

  Future<AttendanceCheckInResult?> submitCheckout({String? qrToken}) async {
    _flowState = AttendanceFlowState.processing;
    notifyListeners();

    try {
      final AttendanceCheckInResult result =
          await _checkoutAttendanceUseCase(qrToken: qrToken);
      _lastResult = result;
      _flowState = AttendanceFlowState.success;
      notifyListeners();
      return result;
    } catch (err) {
      _errorMessage = _formatError(err);
      _flowState = AttendanceFlowState.idle;
      _isDrawerOpen = false;
      notifyListeners();
      return null;
    }
  }


  String _formatError(dynamic err) {
    final String str = err.toString();
    if (str.contains('sudah melakukan presensi masuk') ||
        (str.contains('409') && _scanMode == AttendanceScanMode.checkIn)) {
      return 'Anda sudah melakukan presensi masuk hari ini.';
    }
    if (str.contains('sudah tercatat sebelumnya') ||
        (str.contains('409') && _scanMode == AttendanceScanMode.checkOut)) {
      return 'Presensi pulang sudah tercatat sebelumnya untuk hari ini.';
    }
    if (str.contains('tidak ditemukan') || str.contains('404')) {
      return 'Belum ada catatan presensi masuk hari ini. Silakan presensi masuk terlebih dahulu.';
    }
    if (str.contains('Token QR') ||
        str.contains('kedaluwarsa') ||
        str.contains('400')) {
      return 'Token QR tidak valid atau sudah kedaluwarsa. Silakan scan token terbaru di terminal klinik.';
    }
    if (str.contains('cuti') || str.contains('izin resmi')) {
      return 'Anda sedang dalam masa cuti/izin resmi yang disetujui pada hari ini.';
    }
    if (str.contains('jadwal dinas') ||
        str.contains('roster') ||
        str.contains('403')) {
      return 'Anda tidak memiliki jadwal dinas aktif pada sesi waktu ini.';
    }
    return str.replaceAll('Exception: ', '').replaceAll('FormatException: ', '');
  }
}
