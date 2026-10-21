import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/data/repositories/attendance_repository_impl.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/repositories/attendance_repository.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/checkout_attendance_usecase.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/get_attendance_history_usecase.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/record_attendance_usecase.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/attendance_processing_overlay.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/dialogs/early_checkout_reason_modal.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/dialogs/presence_info_dialog.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_drawer.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/presence_scanner_master_drawer.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/presence_scanner_camera_viewport.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/presence_scanner_top_bar.dart';
import 'package:amanah_healthcare/features/presence/presentation/services/scanner_feedback_service.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/amanah_presence_history_screen.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';
import 'package:amanah_healthcare/features/presence/presentation/utils/scan_trace.dart';

export 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart'
    show AmanahQrDrawerView, AttendanceFlowState, AttendanceScanMode;

class AmanahQrScannerTabScreen extends StatefulWidget {
  const AmanahQrScannerTabScreen({
    super.key,
    this.user,
    this.onBack,
    this.onDrawerStateChanged,
    this.animateLaser = true,
    this.enableCameraScanner = true,
    this.bottomNavigationClearance = 0,
  });

  final AmanahAuthUser? user;
  final VoidCallback? onBack;
  final ValueChanged<bool>? onDrawerStateChanged;
  final bool animateLaser;
  final bool enableCameraScanner;
  final double bottomNavigationClearance;

  @override
  State<AmanahQrScannerTabScreen> createState() => AmanahQrScannerTabScreenState();
}

class AmanahQrScannerTabScreenState extends State<AmanahQrScannerTabScreen>
    with TickerProviderStateMixin {
  late final PresenceScannerController _controller;
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;
  late final AnimationController _drawerAnimationController;
  final ValueNotifier<ScannerHardwareController?> _scannerHardwareNotifier =
      ValueNotifier<ScannerHardwareController?>(null);

  Timer? _mlDiagnosticTimer;
  DateTime _lastDetectionTimestamp = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastMissTimestamp = DateTime.now();
  int _consecutiveMissCount = 0;
  int _consecutiveHitCount = 0;

  static String _formatTime(DateTime dt) {
    final String h = dt.hour.toString().padLeft(2, '0');
    final String m = dt.minute.toString().padLeft(2, '0');
    final String s = dt.second.toString().padLeft(2, '0');
    final String ms = dt.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  void resetPresence() {
    _consecutiveHitCount = 0;
    _consecutiveMissCount = 0;
    _lastMissTimestamp = DateTime.now();
    if (widget.animateLaser && !_laserController.isAnimating) {
      _laserController.repeat(reverse: true);
    }
    _controller.reset();
    _drawerAnimationController.reset();
    widget.onDrawerStateChanged?.call(false);
  }

  @override
  void initState() {
    super.initState();
    ScanTrace.start();
    AppLog.scanner('[QR SCANNER] 🚀 Initializing QR scanner screen');

    final AttendanceRepository repository = AttendanceRepositoryImpl();
    _controller = PresenceScannerController(
      recordAttendanceUseCase: RecordAttendanceUseCase(repository),
      checkoutAttendanceUseCase: CheckoutAttendanceUseCase(repository),
      getAttendanceHistoryUseCase: GetAttendanceHistoryUseCase(repository),
      feedbackService: ScannerFeedbackService(),
    );

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 280),
    );

    if (widget.animateLaser) {
      _laserController.repeat(reverse: true);
    } else {
      _laserController.value = 0.5;
    }

    _drawerAnimationController.value = 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onDrawerStateChanged?.call(false);
        _controller.initTodayStatus();
      }
    });

    _laserAnimation = Tween<double>(
      begin: 0.10,
      end: 0.90,
    ).animate(CurvedAnimation(parent: _laserController, curve: Curves.easeInOut));

    _mlDiagnosticTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      final DateTime now = DateTime.now();
      final int diff = now.difference(_lastDetectionTimestamp).inMilliseconds;
      if (diff >= 500) {
        _consecutiveMissCount++;
        _consecutiveHitCount = 0;
        _lastMissTimestamp = now;
        debugPrint(
          '[ML TEST] [${_formatTime(now)}] ⚪ Tidak terdeteksi QR (standby #$_consecutiveMissCount, durasi kosong: ${diff}ms)',
        );
      }
    });
  }

  @override
  void dispose() {
    _mlDiagnosticTimer?.cancel();
    _laserController.dispose();
    _drawerAnimationController.dispose();
    _scannerHardwareNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openDrawer(AmanahQrDrawerView view) {
    _controller.openDrawer(view);
    widget.onDrawerStateChanged?.call(true);
    _drawerAnimationController.forward(
      from: _drawerAnimationController.value == 1.0 ? 0.0 : _drawerAnimationController.value,
    );
  }

  Future<void> closeDrawer() async {
    widget.onDrawerStateChanged?.call(false);
    await _drawerAnimationController.reverse();
    if (mounted) {
      _controller.closeDrawer();
    }
  }

  Future<void> _closeDrawer() => closeDrawer();

  void _toggleDrawer() {
    if (_controller.isDrawerOpen) {
      _closeDrawer();
    } else {
      _openDrawer(AmanahQrDrawerView.menu);
    }
  }

  String get _userQrValue {
    final String? code = widget.user?.staff?.staffCode;
    if (code != null && code.isNotEmpty) {
      return code;
    }
    final String? uid = widget.user?.id;
    if (uid != null && uid.isNotEmpty) {
      return uid;
    }
    return 'AMANAH-STAFF';
  }

  Future<void> _handleBarcodeDetected(String value) async {
    // 1. Authoritative scan gate: ignore frames if already processing or drawer/dialog open
    if (!_controller.isScanningAllowed) {
      return;
    }

    final DateTime now = DateTime.now();
    final bool isFirstLockOn = _consecutiveHitCount == 0;
    final int reactionMs = now.difference(_lastMissTimestamp).inMilliseconds;

    _lastDetectionTimestamp = now;
    _consecutiveMissCount = 0;
    _consecutiveHitCount++;

    if (isFirstLockOn) {
      debugPrint(
        '[ML TEST] [${_formatTime(now)}] 🚀 LOCK-ON INSTAN! (Reaksi kembali ke QR: ${reactionMs}ms) 🟢 TERDETEKSI QR! Frame #1 | Payload: $value',
      );
    } else {
      debugPrint(
        '[ML TEST] [${_formatTime(now)}] 🟢 TERDETEKSI QR (Frame #$_consecutiveHitCount) | Payload: $value',
      );
    }

    // Submit to authoritative orchestrator (camera stream stays uninterrupted)
    final AttendanceCheckInResult? result = await _controller.handleDetectedBarcode(value);

    if (!mounted) return;

    // Immediate feedback handling
    if (result != null) {
      _showResultDrawer(
        PresenceStatusPayload.fromSuccess(
          timeFormatted: result.timeFormatted,
          isCheckOut: _controller.isLastResultCheckout,
          validatedDurationHours: result.validatedDurationHours,
        ),
      );
      return;
    }

    // Intercept early departure requiring reason notes
    if (_controller.requiresEarlyDepartureNotes &&
        (_controller.pendingCheckoutTicket != null || _controller.pendingCheckoutToken != null)) {
      final String? ticket = _controller.pendingCheckoutTicket;
      final String? token = _controller.pendingCheckoutToken;
      _controller.clearPendingEarlyDeparture();
      final String? reason = await EarlyCheckoutReasonModal.show(context);
      if (!mounted) return;
      if (reason != null && reason.trim().isNotEmpty) {
        final AttendanceCheckInResult? earlyResult = await _controller.submitCheckout(
          qrToken: ticket == null ? token : null,
          checkoutTicket: ticket,
          notes: reason,
        );
        if (!mounted) return;
        if (earlyResult != null) {
          _showResultDrawer(
            PresenceStatusPayload.fromSuccess(
              timeFormatted: earlyResult.timeFormatted,
              isCheckOut: true,
              validatedDurationHours: earlyResult.validatedDurationHours,
            ),
          );
          return;
        }
      }
    }

    if (_controller.lastException != null) {
      _showResultDrawer(PresenceStatusPayload.fromException(_controller.lastException!));
    } else if (_controller.errorMessage != null) {
      _showResultDrawer(PresenceStatusPayload.fromError(_controller.errorMessage!));
    }
  }

  Future<void> _handleVerifyManualPin() async {
    FocusScope.of(context).unfocus();
    _drawerAnimationController.stop();
    _drawerAnimationController.reset();
    widget.onDrawerStateChanged?.call(true);

    final AttendanceCheckInResult? result = await _controller.submitManualPin();

    if (!mounted) return;

    if (result != null) {
      _showResultDrawer(
        PresenceStatusPayload.fromSuccess(
          timeFormatted: result.timeFormatted,
          isCheckOut: _controller.isLastResultCheckout,
          validatedDurationHours: result.validatedDurationHours,
        ),
      );
      return;
    }

    // Intercept early departure requiring reason notes for manual PIN
    if (_controller.requiresEarlyDepartureNotes &&
        (_controller.pendingCheckoutTicket != null || _controller.pendingCheckoutToken != null)) {
      final String? ticket = _controller.pendingCheckoutTicket;
      final String? token = _controller.pendingCheckoutToken;
      _controller.clearPendingEarlyDeparture();
      final String? reason = await EarlyCheckoutReasonModal.show(context);
      if (!mounted) return;
      if (reason != null && reason.trim().isNotEmpty) {
        final AttendanceCheckInResult? earlyResult = await _controller.submitCheckout(
          qrToken: ticket == null ? token : null,
          checkoutTicket: ticket,
          notes: reason,
        );
        if (!mounted) return;
        if (earlyResult != null) {
          _showResultDrawer(
            PresenceStatusPayload.fromSuccess(
              timeFormatted: earlyResult.timeFormatted,
              isCheckOut: true,
              validatedDurationHours: earlyResult.validatedDurationHours,
            ),
          );
          return;
        }
      }
    }

    if (_controller.lastException != null) {
      _showResultDrawer(PresenceStatusPayload.fromException(_controller.lastException!));
    } else if (_controller.errorMessage != null) {
      _showResultDrawer(PresenceStatusPayload.fromError(_controller.errorMessage!));
    }
  }

  void _showResultDrawer(PresenceStatusPayload payload) {
    _controller.openResultDrawer();
    widget.onDrawerStateChanged?.call(true);
    if (widget.animateLaser && _laserController.isAnimating) {
      _laserController.stop();
    }
    unawaited(_scannerHardwareNotifier.value?.pauseCamera());

    AmanahPresenceResultDrawer.show(
      context,
      payload: payload,
      bottomPadding: _drawerBottomPadding(context),
      onGoHome: widget.onBack,
      onViewHistory: () {
        Navigator.of(context).push(AmanahPresenceHistoryScreen.route());
      },
      onSwitchToCheckIn: () {
        _controller.setScanMode(AttendanceScanMode.checkIn);
      },
    ).whenComplete(() {
      if (mounted) {
        _consecutiveHitCount = 0;
        _consecutiveMissCount = 0;
        _lastMissTimestamp = DateTime.now();
        unawaited(_scannerHardwareNotifier.value?.resumeCamera());
        resetPresence();
      }
    });
  }

  void _handleCopyQr() {
    Clipboard.setData(ClipboardData(text: _userQrValue));
    _controller.triggerCopiedFeedback();
  }

  void _handleDownloadQr() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR Code berhasil disimpan ke galeri.', style: TextStyle(fontSize: 12)),
        backgroundColor: AmanahColorTokens.neutral900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showHelpDialog() async {
    _controller.setHelpOpen(true);
    await PresenceHelpDialog.show(context);
    if (mounted) {
      _controller.setHelpOpen(false);
    }
  }

  double _drawerBottomPadding(BuildContext context) {
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    if (widget.bottomNavigationClearance > 0) {
      return widget.bottomNavigationClearance + 16;
    }
    return 24 + safeBottom;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AmanahColorTokens.pureBlack,
          body: Stack(
            children: <Widget>[
              // 1. Camera Viewport Background
              Positioned.fill(
                child: PresenceScannerCameraViewport(
                  laserAnimation: _laserAnimation,
                  isFlashOn: _controller.isFlashOn,
                  isDrawerOpen: _controller.isDrawerOpen,
                  enableCameraScanner: widget.enableCameraScanner,
                  bottomNavigationClearance: widget.bottomNavigationClearance,
                  scanMode: _controller.scanMode,
                  onSelectScanMode: (AttendanceScanMode mode) {
                    _controller.setScanMode(mode);
                    if (widget.animateLaser && !_laserController.isAnimating) {
                      _laserController.repeat(reverse: true);
                    }
                  },
                  onBarcodeDetected: _handleBarcodeDetected,
                  hardwareNotifier: _scannerHardwareNotifier,
                  onScannerCreated: (ScannerHardwareController hardware) {
                    _scannerHardwareNotifier.value = hardware;
                    ScanTrace.mark('cameraReady');
                    AppLog.scanner('[QR SCANNER] 📷 Scanner hardware initialized and ready');
                  },
                ),
              ),

              // 2. Modal Backdrop Scrim
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _drawerAnimationController,
                  builder: (BuildContext ctx, Widget? child) {
                    final double progress = Curves.easeOutCubic.transform(
                      _drawerAnimationController.value.clamp(0.0, 1.0),
                    );
                    if (progress <= 0.001) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: _closeDrawer,
                      behavior: HitTestBehavior.opaque,
                      child: ColoredBox(
                        color: AmanahColorTokens.pureBlack.withValues(alpha: 0.50 * progress),
                      ),
                    );
                  },
                ),
              ),

              // 3. Top Floating Navigation Bar
              PresenceScannerTopBar(
                onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
                onShowHelp: _showHelpDialog,
                onToggleDrawer: _toggleDrawer,
                isHelpOpen: _controller.isHelpOpen,
                isDrawerOpen: _controller.isDrawerOpen,
                drawerView: _controller.drawerView,
                hasCamera: PresenceScannerCameraViewport.safeHasACamera(),
                hasMoreThanOneCamera: PresenceScannerCameraViewport.safeHasMoreThanOneCamera(),
                hardwareNotifier: _scannerHardwareNotifier,
                onSwitchCamera: () async {
                  await _scannerHardwareNotifier.value?.switchCamera();
                  final bool isFront =
                      _scannerHardwareNotifier.value?.isFrontCamera ?? !_controller.isFrontCamera;
                  _controller.syncCameraFacing(isFront);
                  AppLog.scanner(
                    '[QR SCANNER] 🔄 Switched camera facing: ${isFront ? "FRONT" : "BACK"}',
                  );
                },
                onToggleFlash: () async {
                  await _scannerHardwareNotifier.value?.toggleTorch();
                  final bool isTorch =
                      _scannerHardwareNotifier.value?.isTorchOn ?? !_controller.isFlashOn;
                  _controller.syncFlash(isTorch);
                  AppLog.scanner('[QR SCANNER] 💡 Toggled torch: ${isTorch ? "ON" : "OFF"}');
                },
                isFrontCamera:
                    _scannerHardwareNotifier.value?.isFrontCamera ?? _controller.isFrontCamera,
                isFlashOn: _scannerHardwareNotifier.value?.isTorchOn ?? _controller.isFlashOn,
                dark: dark,
              ),

              // 4. Master Slide-up Drawer
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PresenceScannerMasterDrawer(
                  drawerAnimationController: _drawerAnimationController,
                  isDrawerOpen: _controller.isDrawerOpen,
                  drawerView: _controller.drawerView,
                  user: widget.user,
                  userQrValue: _userQrValue,
                  copiedFeedback: _controller.copiedFeedback,
                  manualPin: _controller.manualPin,
                  pinError: _controller.pinError,
                  dark: dark,
                  bottomPadding: _drawerBottomPadding(context),
                  onClose: _closeDrawer,
                  onOpenView: _openDrawer,
                  onManualPinChanged: _controller.updateManualPin,
                  onVerifyManualPin: _handleVerifyManualPin,
                  onCopyQr: _handleCopyQr,
                  onDownloadQr: _handleDownloadQr,
                ),
              ),

              // 5. Processing Overlay
              if (_controller.flowState == AttendanceFlowState.detecting ||
                  _controller.flowState == AttendanceFlowState.processing)
                const Positioned.fill(child: AttendanceProcessingOverlay()),
            ],
          ),
        );
      },
    );
  }
}
