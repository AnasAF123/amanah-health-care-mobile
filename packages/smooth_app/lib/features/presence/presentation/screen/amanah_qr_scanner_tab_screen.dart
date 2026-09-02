import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_otp_input.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_presence_success_drawer.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_qr_code_widget.dart';
import 'package:smooth_app/features/presence/presentation/screen/amanah_presence_history_screen.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/pages/scan/camera_scan_page.dart';

enum AmanahQrDrawerView { menu, manualPin, myQr, uploadQr }

enum _AttendanceFlowState { idle, processing, success }

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
  /// Public helper to reset presence state
  void resetPresence() => _handleReset();
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isDrawerOpen = true;
  bool _isHelpOpen = false;
  _AttendanceFlowState _attendanceFlowState = _AttendanceFlowState.idle;
  AmanahQrDrawerView _drawerView = AmanahQrDrawerView.menu;
  String _manualPin = '';
  String? _pinError;
  bool _copiedFeedback = false;

  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;
  late final AnimationController _drawerAnimationController;

  bool get _isAttendanceFlowActive =>
      _attendanceFlowState != _AttendanceFlowState.idle;

  @override
  void initState() {
    super.initState();
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

    _isDrawerOpen = false;
    _drawerAnimationController.value = 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onDrawerStateChanged?.call(false);
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
    super.dispose();
  }

  void _openDrawer(AmanahQrDrawerView view) {
    setState(() {
      _isDrawerOpen = true;
      _drawerView = view;
    });
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
      setState(() {
        _isDrawerOpen = false;
        _drawerView = AmanahQrDrawerView.menu;
      });
    }
  }

  void _toggleDrawer() {
    if (_isDrawerOpen) {
      _closeDrawer();
    } else {
      _openDrawer(AmanahQrDrawerView.menu);
    }
  }

  void _toggleFlash() {
    setState(() => _isFlashOn = !_isFlashOn);
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      if (_isFrontCamera) {
        _isFlashOn = false;
      }
    });
  }

  void _handleSimulateScan() {
    _beginAttendanceProcessing('AMANAH:DOC-2026-0819:POLI-ANAK:20260521:84920');
  }

  void _handleReset() {
    setState(() {
      _attendanceFlowState = _AttendanceFlowState.idle;
      _isDrawerOpen = false;
      _drawerView = AmanahQrDrawerView.menu;
    });
    widget.onDrawerStateChanged?.call(false);
  }

  void _handleVerifyManualPin(String pin) {
    if (pin.trim().length < 6) {
      setState(() => _pinError = 'Masukkan 6 digit kode presensi.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _pinError = null;
      _manualPin = '';
      _drawerView = AmanahQrDrawerView.menu;
    });
    _beginAttendanceProcessing(pin.trim());
  }

  Future<bool> _handleBarcodeDetected(String value) async {
    final String code = value.trim();
    if (code.isEmpty || _isAttendanceFlowActive) {
      return false;
    }

    await SmoothHapticFeedback.click();
    if (!mounted) {
      return false;
    }

    _beginAttendanceProcessing(code);
    return true;
  }

  Future<void> _beginAttendanceProcessing(String code) async {
    if (_isAttendanceFlowActive) {
      return;
    }

    _drawerAnimationController.stop();
    _drawerAnimationController.reset();
    setState(() {
      _attendanceFlowState = _AttendanceFlowState.processing;
      _isDrawerOpen = false;
      _drawerView = AmanahQrDrawerView.menu;
    });
    widget.onDrawerStateChanged?.call(true);

    await _submitAttendance(code);
    if (!mounted || _attendanceFlowState != _AttendanceFlowState.processing) {
      return;
    }

    setState(() => _attendanceFlowState = _AttendanceFlowState.success);
    AmanahPresenceSuccessDrawer.show(
      context,
      timeString: '07:55 WIB',
      bottomPadding: _drawerBottomPadding(context),
      onGoHome: widget.onBack,
      onViewHistory: () {
        Navigator.of(context).push(AmanahPresenceHistoryScreen.route());
      },
    ).whenComplete(() {
      if (mounted) {
        _handleReset();
      }
    });
  }

  Future<void> _submitAttendance(String _) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
  }

  void _handleCopyQr() {
    Clipboard.setData(const ClipboardData(text: '84920'));
    setState(() => _copiedFeedback = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copiedFeedback = false);
      }
    });
  }

  Future<void> _handlePickUploadQr() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && mounted) {
        _handleSimulateScan();
      }
    } catch (_) {
      if (mounted) {
        _handleSimulateScan();
      }
    }
  }

  Future<void> _showHelpDialog() async {
    setState(() => _isHelpOpen = true);
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: <Widget>[
            Icon(Icons.help_outline_rounded, color: Color(0xFF0A44FF)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Panduan Presensi',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Arahkan kamera smartphone ke QR Code di meja poli atau resepsionis RS Amanah Sehat, atau gunakan Presensi Manual dengan kode 6-digit.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Mengerti',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A44FF),
              ),
            ),
          ),
        ],
      ),
    );
    if (mounted) {
      setState(() => _isHelpOpen = false);
    }
  }

  bool _shouldUseLegacyCameraScanner(BuildContext context) {
    if (!widget.enableCameraScanner || !_safeHasACamera()) {
      return false;
    }

    final PermissionListener? listener = context.watch<PermissionListener?>();
    return listener == null ||
        listener.value.status == DevicePermissionStatus.granted;
  }

  Widget _buildCameraViewport(BuildContext context, double screenHeight) {
    final Widget cameraBase = _buildSimulatedCameraViewport(
      screenHeight,
      enableTap: !_safeHasACamera(),
    );

    if (_shouldUseLegacyCameraScanner(context)) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[cameraBase, _buildLegacyScanner(context)],
      );
    }

    final PermissionListener? listener = context.watch<PermissionListener?>();
    if (widget.enableCameraScanner &&
        _safeHasACamera() &&
        listener != null &&
        listener.value.status != DevicePermissionStatus.checking) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          cameraBase,
          _CameraPermissionViewport(
            status: listener.value.status,
            onRequestPermission: () {
              listener.askPermission(onRationaleNotAvailable: () async => true);
            },
          ),
        ],
      );
    }

    return cameraBase;
  }

  Widget _buildLegacyScanner(BuildContext context) {
    final EdgeInsetsDirectional scannerContentPadding =
        _scannerContentPadding();

    return Stack(
      children: <Widget>[
        GlobalVars.barcodeScanner.getScanner(
          onScan: _handleBarcodeDetected,
          hapticFeedback: () => SmoothHapticFeedback.click(),
          onCameraFlashError: CameraScannerPage.onCameraFlashError,
          trackCustomEvent: AnalyticsHelper.trackCustomEvent,
          hasMoreThanOneCamera: _safeHasMoreThanOneCamera(),
          toggleCameraModeTooltip: '',
          toggleFlashModeTooltip: '',
          barcodeScannerIcon: const SizedBox.shrink(),
          torchOnIcon: const SizedBox.shrink(),
          torchOffIcon: const SizedBox.shrink(),
          visorColor: AmanahColorTokens.brandLight,
          contentPadding: scannerContentPadding,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.50),
                  ],
                  stops: const <double>[0.0, 0.48, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: _PresenceScannerTargetOverlay(
              laserAnimation: _laserAnimation,
              contentPadding: scannerContentPadding,
              drawFrame: false,
            ),
          ),
        ),
      ],
    );
  }

  EdgeInsetsDirectional _scannerContentPadding() {
    return EdgeInsetsDirectional.only(
      top: 72,
      bottom: _isDrawerOpen
          ? 250
          : (widget.bottomNavigationClearance > 0
                ? widget.bottomNavigationClearance + 20
                : 92),
    );
  }

  Widget _buildSimulatedCameraViewport(
    double screenHeight, {
    bool enableTap = true,
  }) {
    return GestureDetector(
      onTap: enableTap && !_isAttendanceFlowActive ? _handleSimulateScan : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: const Color(0xFF050811),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: CustomPaint(painter: _MedicalGridPainter()),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.80),
                    ],
                    stops: const <double>[0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: _PresenceScannerTargetOverlay(
                  laserAnimation: _laserAnimation,
                  contentPadding: _scannerContentPadding(),
                ),
              ),
            ),
            if (_isFlashOn)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFFEF3C7).withValues(alpha: 0.20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static bool _safeHasACamera() {
    try {
      return CameraHelper.hasACamera;
    } catch (_) {
      return false;
    }
  }

  static bool _safeHasMoreThanOneCamera() {
    try {
      return CameraHelper.hasMoreThanOneCamera;
    } catch (_) {
      return false;
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
    final double screenHeight = MediaQuery.sizeOf(context).height;

    const Color bgColor = Colors.black;
    final Color drawerBg = dark ? const Color(0xFF111827) : Colors.white;
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color drawerBorder = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFF1F5F9);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgColor,
      body: Stack(
        children: <Widget>[
          // 1. Camera Viewport Background
          Positioned.fill(child: _buildCameraViewport(context, screenHeight)),

          // 2. Modal Backdrop Scrim (Tapping outside drawer closes it)
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
                    color: Colors.black.withValues(alpha: 0.50 * progress),
                  ),
                );
              },
            ),
          ),

          // 3. Top Floating Navigation Bar (Always on top of camera and scrim)
          Positioned(
            top: (MediaQuery.paddingOf(context).top > 0)
                ? MediaQuery.paddingOf(context).top + 8
                : 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Circular Back Button ( ← )
                _FloatingCircularButton(
                  onTap:
                      widget.onBack ?? () => Navigator.of(context).maybePop(),
                  icon: Icons.arrow_back_rounded,
                  label: 'Kembali',
                  dark: dark,
                ),

                // Top Right Action Buttons: ( ? ) ( 🖼️ ) ( 🔄 ) ( ⚡ )
                Row(
                  children: <Widget>[
                    _FloatingCircularButton(
                      onTap: _showHelpDialog,
                      icon: Icons.help_outline_rounded,
                      label: 'Bantuan Presensi',
                      dark: dark,
                      size: 40,
                      isActive: _isHelpOpen,
                    ),
                    const SizedBox(width: 8),
                    _FloatingCircularButton(
                      onTap: () => _openDrawer(AmanahQrDrawerView.uploadQr),
                      icon: Icons.image_outlined,
                      label: 'Pilih QR dari Galeri',
                      dark: dark,
                      size: 40,
                      isActive: _isDrawerOpen &&
                          _drawerView == AmanahQrDrawerView.uploadQr,
                    ),
                    const SizedBox(width: 8),
                    _FloatingCircularButton(
                      onTap: _toggleDrawer,
                      icon: Icons.grid_view_rounded,
                      label: 'Buka Menu Presensi',
                      dark: dark,
                      size: 40,
                      isActive: _isDrawerOpen &&
                          _drawerView == AmanahQrDrawerView.menu,
                    ),
                    if (!_shouldUseLegacyCameraScanner(context)) ...<Widget>[
                      const SizedBox(width: 8),
                      _FloatingCircularButton(
                        onTap: _toggleCamera,
                        icon: Icons.cameraswitch_rounded,
                        label: 'Ubah Kamera',
                        dark: dark,
                        size: 40,
                        isActive: _isFrontCamera,
                      ),
                      const SizedBox(width: 8),
                      _FloatingCircularButton(
                        onTap: _toggleFlash,
                        icon: _isFlashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        label: 'Senter Flash',
                        dark: dark,
                        size: 40,
                        isActive: _isFlashOn,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 4. Master Drawer (Slide-up modal matching patient detail / bottom sheet paradigm)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _drawerAnimationController,
              builder: (BuildContext context, Widget? child) {
                if (_drawerAnimationController.value <= 0.001 &&
                    !_isDrawerOpen) {
                  return const SizedBox.shrink();
                }
                final double progress = CurvedAnimation(
                  parent: _drawerAnimationController,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ).value;

                return FractionalTranslation(
                  translation: Offset(0, 1.0 - progress),
                  child: Opacity(
                    opacity: progress.clamp(0.0, 1.0),
                    child: GestureDetector(
                      onVerticalDragEnd: (DragEndDetails details) {
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! > 200) {
                          _closeDrawer();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          10,
                          20,
                          _drawerBottomPadding(context),
                        ),
                        decoration: BoxDecoration(
                          color: drawerBg,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          border: Border(top: BorderSide(color: drawerBorder)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.40 * progress,
                              ),
                              blurRadius: 32,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder:
                                (Widget child, Animation<double> anim) {
                                  return FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.06),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: child,
                                    ),
                                  );
                                },
                            child: SingleChildScrollView(
                              key: ValueKey<AmanahQrDrawerView>(_drawerView),
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  // Interactive Drag Handle
                                  GestureDetector(
                                    onTap: _closeDrawer,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 2,
                                        bottom: 14,
                                      ),
                                      child: Container(
                                        width: 48,
                                        height: 4.5,
                                        decoration: BoxDecoration(
                                          color: dark
                                              ? Colors.white.withValues(
                                                  alpha: 0.25,
                                                )
                                              : const Color(0xFFCBD5E1),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // VIEW 1: Main Menu Cards (Tampilkan QR • Presensi Manual • Upload QR)
                                  if (_drawerView ==
                                      AmanahQrDrawerView.menu) ...<Widget>[
                                    // Blue Info Strip Banner
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 11,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: <Color>[
                                            Color(0xFF2563EB),
                                            Color(0xFF4338CA),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: const Color(
                                              0xFF2563EB,
                                            ).withValues(alpha: 0.30),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.auto_awesome_rounded,
                                            size: 16,
                                            color: Color(0xFF60A5FA),
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'Praktek Poli Anak dimulai 08:00 WIB',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: _closeDrawer,
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black.withValues(
                                                  alpha: 0.25,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // 3 Action Cards Grid
                                    Row(
                                      children: <Widget>[
                                        // Card 1: Tampilkan QR
                                        Expanded(
                                          child: _ActionMenuCard(
                                            title: 'Tampilkan QR',
                                            icon: Icons.qr_code_rounded,
                                            dark: dark,
                                            isActive: _drawerView ==
                                                AmanahQrDrawerView.myQr,
                                            onTap: () => _openDrawer(
                                              AmanahQrDrawerView.myQr,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Card 2: Presensi Manual
                                        Expanded(
                                          child: _ActionMenuCard(
                                            title: 'Manual',
                                            icon: Icons.password_rounded,
                                            dark: dark,
                                            isActive: _drawerView ==
                                                AmanahQrDrawerView.manualPin,
                                            onTap: () {
                                              setState(() {
                                                _pinError = null;
                                                _manualPin = '';
                                              });
                                              _openDrawer(
                                                AmanahQrDrawerView.manualPin,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Card 3: Upload QR
                                        Expanded(
                                          child: _ActionMenuCard(
                                            title: 'Upload QR',
                                            icon: Icons.image_outlined,
                                            dark: dark,
                                            isActive: _drawerView ==
                                                AmanahQrDrawerView.uploadQr,
                                            onTap: () => _openDrawer(
                                              AmanahQrDrawerView.uploadQr,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  // VIEW 2: Manual PIN View
                                  if (_drawerView ==
                                      AmanahQrDrawerView.manualPin) ...<Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        TextButton.icon(
                                          onPressed: () => _openDrawer(
                                            AmanahQrDrawerView.menu,
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_back_rounded,
                                            size: 16,
                                            color: Color(0xFF2563EB),
                                          ),
                                          label: const Text(
                                            'Kembali',
                                            style: TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // 6-Grid OTP Input (Without auto-verify on 6th digit)
                                    AmanahOtpInput(
                                      length: 6,
                                      error: _pinError,
                                      onChanged: (String val) {
                                        setState(() {
                                          _manualPin = val;
                                          _pinError = null;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Verification Button
                                    AmanahButton.primary(
                                      text: 'Verifikasi Presensi',
                                      isFullWidth: true,
                                      isDisabled: _manualPin.trim().length < 6,
                                      onPressed: () =>
                                          _handleVerifyManualPin(_manualPin),
                                    ),
                                  ],

                                  // VIEW 3: Tampilkan QR Dokter & 5-Digit Code
                                  if (_drawerView ==
                                      AmanahQrDrawerView.myQr) ...<Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        TextButton.icon(
                                          onPressed: () => _openDrawer(
                                            AmanahQrDrawerView.menu,
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_back_rounded,
                                            size: 16,
                                            color: Color(0xFF2563EB),
                                          ),
                                          label: const Text(
                                            'Kembali',
                                            style: TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            IconButton(
                                              onPressed: _handleCopyQr,
                                              icon: const Icon(
                                                Icons.copy_rounded,
                                                size: 16,
                                              ),
                                              tooltip: 'Salin Kode',
                                              visualDensity:
                                                  VisualDensity.compact,
                                              style: IconButton.styleFrom(
                                                backgroundColor: dark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.10,
                                                      )
                                                    : const Color(0xFFF1F5F9),
                                                foregroundColor: subtextColor,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              onPressed: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                      'QR Code berhasil diunduh ke galeri.',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'PlusJakartaSans',
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFF0F172A),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.download_rounded,
                                                size: 16,
                                              ),
                                              tooltip: 'Unduh QR',
                                              visualDensity:
                                                  VisualDensity.compact,
                                              style: IconButton.styleFrom(
                                                backgroundColor: dark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.10,
                                                      )
                                                    : const Color(0xFFF1F5F9),
                                                foregroundColor: subtextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Vector SVG QR Code Widget (152x152)
                                    const AmanahQrCodeWidget(
                                      value:
                                          'AMANAH:DOC-2026-0819:POLI-ANAK:20260521:84920',
                                      size: 152,
                                    ),
                                    const SizedBox(height: 12),

                                    // Large Prominent 5-Digit Code
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2563EB,
                                        ).withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF2563EB,
                                          ).withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: const Text(
                                        '84920',
                                        style: TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 6,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),

                                    if (_copiedFeedback) ...<Widget>[
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Kode 84920 berhasil disalin',
                                        style: TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: AmanahColorTokens.brand,
                                        ),
                                      ),
                                    ],
                                  ],

                                  // VIEW 4: Upload QR View (Dashed Dropzone)
                                  if (_drawerView ==
                                      AmanahQrDrawerView.uploadQr) ...<Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        TextButton.icon(
                                          onPressed: () => _openDrawer(
                                            AmanahQrDrawerView.menu,
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_back_rounded,
                                            size: 16,
                                            color: Color(0xFF2563EB),
                                          ),
                                          label: const Text(
                                            'Kembali',
                                            style: TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Dashed Border Dropzone
                                    InkWell(
                                      onTap: _handlePickUploadQr,
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: dark
                                              ? Colors.white.withValues(
                                                  alpha: 0.04,
                                                )
                                              : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: dark
                                                ? Colors.white.withValues(
                                                    alpha: 0.20,
                                                  )
                                                : const Color(0xFFCBD5E1),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF2563EB,
                                                ).withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: const Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 28,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Pilih file QR atau seret ke sini',
                                              style: TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Format PNG, JPG, JPEG (Maks. 5MB)',
                                              style: TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w500,
                                                color: subtextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_attendanceFlowState == _AttendanceFlowState.processing)
            const Positioned.fill(child: _AttendanceProcessingOverlay()),
        ],
      ),
    );
  }
}

class _AttendanceProcessingOverlay extends StatelessWidget {
  const _AttendanceProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color surface = dark ? theme.colorScheme.surface : Colors.white;
    final Color title = dark
        ? theme.colorScheme.onSurface
        : AmanahColorTokens.heading;
    final Color subtitle = dark
        ? theme.colorScheme.onSurfaceVariant
        : AmanahColorTokens.muted;
    final Color border = dark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.34)
        : AmanahColorTokens.brandMuted;

    return AbsorbPointer(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.32)),
        child: Center(
          child: Container(
            width: 248,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.42 : 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AmanahColorTokens.brand,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Memproses presensi Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: title,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'QR dikenali. Mengirim data ke sistem klinik.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: subtitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraPermissionViewport extends StatelessWidget {
  const _CameraPermissionViewport({
    required this.status,
    required this.onRequestPermission,
  });

  final DevicePermissionStatus status;
  final VoidCallback onRequestPermission;

  @override
  Widget build(BuildContext context) {
    if (status == DevicePermissionStatus.checking) {
      return const ColoredBox(
        color: Color(0xFF050811),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return ColoredBox(
      color: const Color(0xFF050811),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.photo_camera_outlined,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              const Text(
                'Izin kamera diperlukan untuk presensi QR.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onRequestPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text(
                  'Aktifkan Kamera',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingCircularButton extends StatelessWidget {
  const _FloatingCircularButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.dark,
    this.size = 44,
    this.isActive = false,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool dark;
  final double size;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Gradient? bgGradient = isActive
        ? (dark
            ? AmanahColorTokens.btnCrispBlueDarkGradient
            : AmanahColorTokens.btnCrispBlueGradient)
        : null;

    final Color? bgColor = isActive
        ? null
        : (dark
            ? const Color(0xFF1E293B).withValues(alpha: 0.75)
            : Colors.white.withValues(alpha: 0.85));

    final Color iconColor = isActive
        ? Colors.white
        : (dark ? Colors.white : const Color(0xFF1E293B));

    final Color borderColor = isActive
        ? (dark
            ? AmanahColorTokens.btnCrispBlueDarkBorder
            : AmanahColorTokens.btnCrispBlueBorder)
        : (dark
            ? Colors.white.withValues(alpha: 0.20)
            : Colors.white.withValues(alpha: 0.80));

    final List<BoxShadow> shadows = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.16),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    return Semantics(
      button: true,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              gradient: bgGradient,
              border: Border.all(
                color: borderColor,
                width: isActive ? 0.8 : 1.0,
              ),
              boxShadow: shadows,
            ),
            child: Center(
              child: Icon(icon, size: size * 0.48, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionMenuCard extends StatelessWidget {
  const _ActionMenuCard({
    required this.title,
    required this.icon,
    required this.dark,
    required this.onTap,
    this.isActive = false,
  });

  final String title;
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color cardBg = dark ? const Color(0xFF1F2937) : Colors.white;

    final Color borderColor = dark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE2E8F0);

    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);

    final Gradient? bgGradient = isActive
        ? (dark
            ? AmanahColorTokens.btnCrispBlueDarkGradient
            : AmanahColorTokens.btnCrispBlueGradient)
        : null;

    final Color effectiveBorderColor = isActive
        ? (dark
            ? AmanahColorTokens.btnCrispBlueDarkBorder
            : AmanahColorTokens.btnCrispBlueBorder)
        : borderColor;

    final List<BoxShadow> shadows = isActive
        ? <BoxShadow>[
            if (dark)
              AmanahColorTokens.btnCrispBlueDarkShadow
            else
              AmanahColorTokens.btnCrispBlueShadow,
            BoxShadow(
              color: (dark
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF0D66E9))
                  .withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? null : cardBg,
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: effectiveBorderColor, width: 1.2),
          boxShadow: shadows,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.22)
                    : (dark
                        ? const Color(0xFF2563EB).withValues(alpha: 0.20)
                        : const Color(0xFF2563EB).withValues(alpha: 0.14)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive
                    ? Colors.white
                    : (dark
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                color: isActive ? Colors.white : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.20)
      ..strokeWidth = 0.5;

    const double step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PresenceScannerTargetOverlay extends StatelessWidget {
  const _PresenceScannerTargetOverlay({
    required this.laserAnimation,
    required this.contentPadding,
    this.drawFrame = true,
  });

  final Animation<double> laserAnimation;
  final EdgeInsetsGeometry contentPadding;
  final bool drawFrame;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets resolvedContentPadding = contentPadding.resolve(
      Directionality.of(context),
    );
    final EdgeInsets scannerPadding = EdgeInsets.fromLTRB(
      26 + resolvedContentPadding.left,
      MediaQuery.viewPaddingOf(context).top + 13 + resolvedContentPadding.top,
      26 + resolvedContentPadding.right,
      26 + resolvedContentPadding.bottom,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double targetWidth = math.max(
          0,
          constraints.maxWidth - scannerPadding.horizontal,
        );
        final double targetHeight = math.max(
          0,
          constraints.maxHeight - scannerPadding.vertical,
        );

        if (targetWidth <= 0 || targetHeight <= 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: scannerPadding,
          child: Stack(
            children: <Widget>[
              if (drawFrame)
                const Positioned.fill(
                  child: CustomPaint(
                    painter: _PresenceScannerFramePainter(
                      color: AmanahColorTokens.brandLight,
                    ),
                  ),
                ),
              AnimatedBuilder(
                animation: laserAnimation,
                builder: (BuildContext context, Widget? child) {
                  final double sweepHeight = math.max(0, targetHeight - 34);
                  final double lineTop = sweepHeight * laserAnimation.value;
                  return Positioned(
                    top: lineTop,
                    left: 22,
                    right: 22,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                AmanahColorTokens.brandLight.withValues(
                                  alpha: 0.20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AmanahColorTokens.brandAccent,
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AmanahColorTokens.brandAccent.withValues(
                                  alpha: 0.86,
                                ),
                                blurRadius: 9,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: AmanahColorTokens.brandLight.withValues(
                                  alpha: 0.90,
                                ),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PresenceScannerFramePainter extends CustomPainter {
  const _PresenceScannerFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path path = _buildPath(rect);
    final Paint paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    paint
      ..color = Colors.black12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.65);
    canvas.drawPath(path, paint);

    paint
      ..color = color
      ..maskFilter = null;
    canvas.drawPath(path, paint);
  }

  Path _buildPath(Rect rect) {
    const double fullCornerSize = 31;
    const double halfCornerSize = fullCornerSize / 2;
    const Radius borderRadius = Radius.circular(halfCornerSize);
    final double bottomPosition = rect.bottom;

    final Path path = Path()
      ..moveTo(rect.left, rect.top + fullCornerSize)
      ..lineTo(rect.left, rect.top + halfCornerSize)
      ..arcToPoint(
        Offset(rect.left + halfCornerSize, rect.top),
        radius: borderRadius,
      )
      ..lineTo(rect.left + fullCornerSize, rect.top)
      ..moveTo(rect.right - fullCornerSize, rect.top)
      ..lineTo(rect.right - halfCornerSize, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + halfCornerSize),
        radius: borderRadius,
      )
      ..lineTo(rect.right, rect.top + fullCornerSize)
      ..moveTo(rect.right, bottomPosition - fullCornerSize)
      ..lineTo(rect.right, bottomPosition - halfCornerSize)
      ..arcToPoint(
        Offset(rect.right - halfCornerSize, bottomPosition),
        radius: borderRadius,
      )
      ..lineTo(rect.right - fullCornerSize, bottomPosition)
      ..moveTo(rect.left + fullCornerSize, bottomPosition)
      ..lineTo(rect.left + halfCornerSize, bottomPosition)
      ..arcToPoint(
        Offset(rect.left, bottomPosition - halfCornerSize),
        radius: borderRadius,
      )
      ..lineTo(rect.left, bottomPosition - fullCornerSize);

    return path;
  }

  @override
  bool shouldRepaint(covariant _PresenceScannerFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
