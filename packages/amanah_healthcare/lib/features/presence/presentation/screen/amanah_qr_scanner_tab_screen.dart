import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/data/repositories/attendance_repository_impl.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/repositories/attendance_repository.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/checkout_attendance_usecase.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/get_attendance_history_usecase.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/record_attendance_usecase.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_success_drawer.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/attendance_processing_overlay.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/presence_scanner_master_drawer.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/floating_circular_button.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/presence_scanner_camera_viewport.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/amanah_presence_history_screen.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';

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
  State<AmanahQrScannerTabScreen> createState() =>
      AmanahQrScannerTabScreenState();
}

class AmanahQrScannerTabScreenState extends State<AmanahQrScannerTabScreen>
    with TickerProviderStateMixin {
  late final PresenceScannerController _controller;
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;
  late final AnimationController _drawerAnimationController;

  void resetPresence() {
    _controller.reset();
    _drawerAnimationController.reset();
    widget.onDrawerStateChanged?.call(false);
  }

  @override
  void initState() {
    super.initState();
    final AttendanceRepository repository = AttendanceRepositoryImpl();
    _controller = PresenceScannerController(
      recordAttendanceUseCase: RecordAttendanceUseCase(repository),
      checkoutAttendanceUseCase: CheckoutAttendanceUseCase(repository),
      getAttendanceHistoryUseCase: GetAttendanceHistoryUseCase(repository),
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

    _laserAnimation = Tween<double>(begin: 0.10, end: 0.90).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    _drawerAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openDrawer(AmanahQrDrawerView view) {
    _controller.openDrawer(view);
    widget.onDrawerStateChanged?.call(true);
    _drawerAnimationController.forward(
      from: _drawerAnimationController.value == 1.0
          ? 0.0
          : _drawerAnimationController.value,
    );
  }

  Future<void> _closeDrawer() async {
    widget.onDrawerStateChanged?.call(false);
    await _drawerAnimationController.reverse();
    if (mounted) {
      _controller.closeDrawer();
    }
  }

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
    final String code = value.trim();
    if (code.isEmpty || _controller.isFlowActive) {
      return;
    }

    await HapticFeedback.selectionClick();
    if (!mounted) {
      return;
    }

    _drawerAnimationController.stop();
    _drawerAnimationController.reset();
    widget.onDrawerStateChanged?.call(true);

    final AttendanceCheckInResult? result =
        await _controller.submitAttendance(code);

    if (!mounted) return;

    if (result != null) {
      _showSuccessDrawer(
        result.timeFormatted,
        isCheckOut: _controller.isLastResultCheckout,
        validatedDurationHours: result.validatedDurationHours,
      );
      return;
    }

    if (_controller.errorMessage != null) {
      _showErrorSnackBar(_controller.errorMessage!);
    }
  }

  Future<void> _handleVerifyManualPin() async {
    FocusScope.of(context).unfocus();
    _drawerAnimationController.stop();
    _drawerAnimationController.reset();
    widget.onDrawerStateChanged?.call(true);

    final AttendanceCheckInResult? result =
        await _controller.submitManualPin();

    if (!mounted) return;

    if (result != null) {
      _showSuccessDrawer(
        result.timeFormatted,
        isCheckOut: _controller.isLastResultCheckout,
        validatedDurationHours: result.validatedDurationHours,
      );
      return;
    }

    if (_controller.errorMessage != null) {
      _showErrorSnackBar(_controller.errorMessage!);
    }
  }

  void _showSuccessDrawer(
    String timeFormatted, {
    bool isCheckOut = false,
    double? validatedDurationHours,
  }) {
    AmanahPresenceSuccessDrawer.show(
      context,
      timeString: timeFormatted,
      isCheckOut: isCheckOut,
      validatedDurationHours: validatedDurationHours,
      bottomPadding: _drawerBottomPadding(context),
      onGoHome: widget.onBack,
      onViewHistory: () {
        Navigator.of(context).push(AmanahPresenceHistoryScreen.route());
      },
    ).whenComplete(() {
      if (mounted) {
        resetPresence();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: AmanahColorTokens.dangerDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleCopyQr() {
    Clipboard.setData(ClipboardData(text: _userQrValue));
    _controller.triggerCopiedFeedback();
  }

  void _handleDownloadQr() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'QR Code berhasil disimpan ke galeri.',
          style: TextStyle(fontSize: 12),
        ),
        backgroundColor: AmanahColorTokens.neutral900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showHelpDialog() async {
    _controller.setHelpOpen(true);
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: <Widget>[
            Icon(Icons.help_outline_rounded,
                color: AmanahColorTokens.brandPrimary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Panduan Presensi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: const Text(
          'Arahkan kamera smartphone ke QR Code presensi dinas RS Amanah Sehat, atau gunakan Presensi Manual dengan kode 6-digit.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Mengerti',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AmanahColorTokens.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
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
                  onBarcodeDetected: _handleBarcodeDetected,
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
                        color: AmanahColorTokens.pureBlack.withValues(
                          alpha: 0.50 * progress,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 3. Top Floating Navigation Bar
              Positioned(
                top: (MediaQuery.paddingOf(context).top > 0)
                    ? MediaQuery.paddingOf(context).top + 8
                    : 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingCircularButton(
                      onTap: widget.onBack ??
                          () => Navigator.of(context).maybePop(),
                      icon: Icons.arrow_back_rounded,
                      label: 'Kembali',
                      dark: dark,
                    ),
                    Row(
                      children: <Widget>[
                        FloatingCircularButton(
                          onTap: _showHelpDialog,
                          icon: Icons.help_outline_rounded,
                          label: 'Bantuan Presensi',
                          dark: dark,
                          size: 40,
                          isActive: _controller.isHelpOpen,
                        ),
                        const SizedBox(width: 8),
                        FloatingCircularButton(
                          onTap: _toggleDrawer,
                          icon: Icons.grid_view_rounded,
                          label: 'Buka Menu Presensi',
                          dark: dark,
                          size: 40,
                          isActive: _controller.isDrawerOpen &&
                              _controller.drawerView == AmanahQrDrawerView.menu,
                        ),
                        if (!PresenceScannerCameraViewport.safeHasACamera()) ...<Widget>[
                          const SizedBox(width: 8),
                          FloatingCircularButton(
                            onTap: _controller.toggleCamera,
                            icon: Icons.cameraswitch_rounded,
                            label: 'Ubah Kamera',
                            dark: dark,
                            size: 40,
                            isActive: _controller.isFrontCamera,
                          ),
                          const SizedBox(width: 8),
                          FloatingCircularButton(
                            onTap: _controller.toggleFlash,
                            icon: _controller.isFlashOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            label: 'Senter Flash',
                            dark: dark,
                            size: 40,
                            isActive: _controller.isFlashOn,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // 3b. Floating Segmented Mode Switcher (Presensi Masuk vs Presensi Pulang)
              Positioned(
                top: (MediaQuery.paddingOf(context).top > 0)
                    ? MediaQuery.paddingOf(context).top + 64
                    : 76,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.pureBlack.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.18),
                        width: 1,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AmanahColorTokens.pureBlack.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _PresenceModePill(
                          label: 'Presensi Masuk',
                          icon: Icons.login_rounded,
                          isSelected: _controller.scanMode == AttendanceScanMode.checkIn,
                          activeColor: AmanahColorTokens.success,
                          onTap: () => _controller.setScanMode(AttendanceScanMode.checkIn),
                        ),
                        const SizedBox(width: 4),
                        _PresenceModePill(
                          label: 'Presensi Pulang',
                          icon: Icons.logout_rounded,
                          isSelected: _controller.scanMode == AttendanceScanMode.checkOut,
                          activeColor: AmanahColorTokens.brandPrimary,
                          onTap: () => _controller.setScanMode(AttendanceScanMode.checkOut),
                        ),
                      ],
                    ),
                  ),
                ),
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
              if (_controller.flowState == AttendanceFlowState.processing)
                const Positioned.fill(child: AttendanceProcessingOverlay()),
            ],
          ),
        );
      },
    );
  }
}

class _PresenceModePill extends StatelessWidget {
  const _PresenceModePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.70), width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? activeColor
                  : AmanahColorTokens.surfaceLight.withValues(alpha: 0.60),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AmanahColorTokens.surfaceLight
                    : AmanahColorTokens.surfaceLight.withValues(alpha: 0.60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
