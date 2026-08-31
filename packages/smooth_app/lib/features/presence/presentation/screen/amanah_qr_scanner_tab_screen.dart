import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_otp_input.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_qr_code_widget.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/pages/scan/camera_scan_page.dart';

enum AmanahQrDrawerView { menu, manualPin, myQr, uploadQr }

class AmanahQrScannerTabScreen extends StatefulWidget {
  const AmanahQrScannerTabScreen({
    super.key,
    this.user,
    this.onBack,
    this.animateLaser = true,
    this.enableCameraScanner = true,
    this.bottomNavigationClearance = 0,
  });

  final AmanahAuthUser? user;
  final VoidCallback? onBack;
  final bool animateLaser;
  final bool enableCameraScanner;
  final double bottomNavigationClearance;

  @override
  State<AmanahQrScannerTabScreen> createState() =>
      _AmanahQrScannerTabScreenState();
}

class _AmanahQrScannerTabScreenState extends State<AmanahQrScannerTabScreen>
    with TickerProviderStateMixin {
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isScanned = false;
  bool _isDrawerOpen = true;
  AmanahQrDrawerView _drawerView = AmanahQrDrawerView.menu;
  String _manualPin = '';
  String? _lastScannedCode;
  String? _pinError;
  bool _copiedFeedback = false;

  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;
  late final AnimationController _successController;
  late final List<_PresenceCelebrationParticle> _successParticles;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
    _successParticles = _createSuccessParticles();

    if (widget.animateLaser) {
      _laserController.repeat(reverse: true);
    } else {
      _laserController.value = 0.5;
    }

    _isDrawerOpen = !(widget.enableCameraScanner && _safeHasACamera());

    _laserAnimation = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    _successController.dispose();
    super.dispose();
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
    _showPresenceSuccess(() {
      _isScanned = true;
      _isDrawerOpen = false;
      _lastScannedCode = 'AMANAH:DOC-2026-0819:POLI-ANAK:20260521:84920';
    });
  }

  void _handleReset() {
    setState(() {
      _isScanned = false;
      _isDrawerOpen = true;
      _drawerView = AmanahQrDrawerView.menu;
      _lastScannedCode = null;
    });
    _successController.reset();
  }

  void _handleVerifyManualPin(String pin) {
    if (pin.length < 6) {
      setState(() => _pinError = 'Masukkan 6 digit kode presensi.');
      return;
    }
    _showPresenceSuccess(() {
      _pinError = null;
      _manualPin = '';
      _drawerView = AmanahQrDrawerView.menu;
      _isScanned = true;
      _isDrawerOpen = false;
      _lastScannedCode = pin;
    });
  }

  Future<bool> _handleBarcodeDetected(String value) async {
    final String code = value.trim();
    if (code.isEmpty || _isScanned) {
      return false;
    }

    await SmoothHapticFeedback.click();
    if (!mounted) {
      return false;
    }

    _showPresenceSuccess(() {
      _lastScannedCode = code;
      _isScanned = true;
      _isDrawerOpen = false;
      _drawerView = AmanahQrDrawerView.menu;
    });
    return true;
  }

  void _showPresenceSuccess(VoidCallback updateState) {
    setState(updateState);
    _successController.forward(from: 0);
  }

  List<_PresenceCelebrationParticle> _createSuccessParticles() {
    final math.Random random = math.Random(84);
    const List<Color> colors = <Color>[
      Color(0xFF0A44FF),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
      Color(0xFFE0F2FE),
      Color(0xFFF2C94C),
    ];

    return List<_PresenceCelebrationParticle>.generate(54, (int index) {
      final bool fromLeft = index.isEven;
      final double side = fromLeft ? -1 : 1;
      final double speed = 145 + random.nextDouble() * 135;
      final double angle = fromLeft
          ? (-0.95 + random.nextDouble() * 0.44)
          : (-math.pi + 0.52 - random.nextDouble() * 0.44);
      return _PresenceCelebrationParticle(
        fromLeft: fromLeft,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        size: Size(4 + random.nextDouble() * 6, 3 + random.nextDouble() * 5),
        color: colors[index % colors.length],
        rotation: random.nextDouble() * math.pi,
        spin: side * (1.4 + random.nextDouble() * 2.8),
        delay: random.nextDouble() * 0.20,
      );
    });
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

  void _showHelpDialog() {
    showDialog<void>(
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
  }

  bool _shouldUseLegacyCameraScanner(BuildContext context) {
    if (!widget.enableCameraScanner || _isScanned || !_safeHasACamera()) {
      return false;
    }

    final PermissionListener? listener = context.watch<PermissionListener?>();
    return listener == null ||
        listener.value.status == DevicePermissionStatus.granted;
  }

  Widget _buildCameraViewport(BuildContext context, double screenHeight) {
    if (_shouldUseLegacyCameraScanner(context)) {
      return _buildLegacyScanner(context);
    }

    final PermissionListener? listener = context.watch<PermissionListener?>();
    if (widget.enableCameraScanner &&
        !_isScanned &&
        _safeHasACamera() &&
        listener != null) {
      return _CameraPermissionViewport(
        status: listener.value.status,
        onRequestPermission: () {
          listener.askPermission(onRationaleNotAvailable: () async => true);
        },
      );
    }

    return _buildSimulatedCameraViewport(screenHeight);
  }

  Widget _buildLegacyScanner(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: math.max(
          0,
          widget.bottomNavigationClearance -
              MediaQuery.viewPaddingOf(context).bottom,
        ),
      ),
      child: Stack(
        children: <Widget>[
          GlobalVars.barcodeScanner.getScanner(
            onScan: _handleBarcodeDetected,
            hapticFeedback: () => SmoothHapticFeedback.click(),
            onCameraFlashError: CameraScannerPage.onCameraFlashError,
            trackCustomEvent: AnalyticsHelper.trackCustomEvent,
            hasMoreThanOneCamera: _safeHasMoreThanOneCamera(),
            toggleCameraModeTooltip: 'Ubah Kamera',
            toggleFlashModeTooltip: 'Senter Flash',
            barcodeScannerIcon: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.90),
                  width: SmoothBarcodeScannerVisor.STROKE_WIDTH - 1,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            torchOnIcon: const Icon(Icons.flash_on_rounded),
            torchOffIcon: const Icon(Icons.flash_off_rounded),
            contentPadding: EdgeInsetsDirectional.only(
              top: 72,
              bottom: _isDrawerOpen ? 250 : 92,
            ),
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
        ],
      ),
    );
  }

  Widget _buildSimulatedCameraViewport(double screenHeight) {
    return GestureDetector(
      onTap: _handleSimulateScan,
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
            if (!_isScanned)
              AnimatedBuilder(
                animation: _laserAnimation,
                builder: (BuildContext ctx, Widget? child) {
                  return Positioned(
                    top: screenHeight * _laserAnimation.value,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                const Color(0xFF00D4FF).withValues(alpha: 0.05),
                                const Color(0xFF00D4FF).withValues(alpha: 0.22),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22D3EE),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: const Color(
                                  0xFF22D3EE,
                                ).withValues(alpha: 0.80),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFF0A44FF,
                                ).withValues(alpha: 0.40),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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

  double _overlayBottomClearance(BuildContext context) {
    if (widget.bottomNavigationClearance > 0) {
      return widget.bottomNavigationClearance;
    }
    return 0;
  }

  double _drawerBottomPadding(BuildContext context) {
    return 22 +
        (widget.bottomNavigationClearance > 0
            ? 0
            : MediaQuery.viewPaddingOf(context).bottom);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    final Color bgColor = dark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFF0F172A);
    final Color drawerBg = dark ? const Color(0xFF111827) : Colors.white;
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color drawerBorder = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: <Widget>[
          // 1. Camera Viewport Background
          Positioned.fill(child: _buildCameraViewport(context, screenHeight)),

          // 2. Top Floating Navigation Bar
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
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
                    ),
                    const SizedBox(width: 8),
                    _FloatingCircularButton(
                      onTap: () {
                        setState(() {
                          _isDrawerOpen = true;
                          _drawerView = AmanahQrDrawerView.uploadQr;
                        });
                      },
                      icon: Icons.image_outlined,
                      label: 'Pilih QR dari Galeri',
                      dark: dark,
                      size: 40,
                    ),
                    const SizedBox(width: 8),
                    _FloatingCircularButton(
                      onTap: () {
                        setState(() {
                          _isDrawerOpen = true;
                          _drawerView = AmanahQrDrawerView.menu;
                        });
                      },
                      icon: Icons.grid_view_rounded,
                      label: 'Buka Menu Presensi',
                      dark: dark,
                      size: 40,
                      isActive:
                          _isDrawerOpen &&
                          _drawerView == AmanahQrDrawerView.menu,
                      activeColor: const Color(0xFF06B6D4),
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
                        activeColor: const Color(0xFF06B6D4),
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
                        activeColor: const Color(0xFFF59E0B),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 4. Master Drawer (Bottom Sheet)
          if (_isDrawerOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: _overlayBottomClearance(context),
              child: GestureDetector(
                onVerticalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 200) {
                    setState(() => _isDrawerOpen = false);
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
                        color: Colors.black.withValues(alpha: 0.40),
                        blurRadius: 32,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Interactive Drag Handle
                      GestureDetector(
                        onTap: () => setState(() => _isDrawerOpen = false),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 14),
                          child: Container(
                            width: 48,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),

                      // VIEW 1: Main Menu Cards (Tampilkan QR • Presensi Manual • Upload QR)
                      if (_drawerView == AmanahQrDrawerView.menu) ...<Widget>[
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
                                color: Color(0xFF67E8F9),
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
                                onTap: () =>
                                    setState(() => _isDrawerOpen = false),
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.25),
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
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
                                onTap: () {
                                  setState(
                                    () => _drawerView = AmanahQrDrawerView.myQr,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Card 2: Presensi Manual
                            Expanded(
                              child: _ActionMenuCard(
                                title: 'Manual',
                                icon: Icons.password_rounded,
                                dark: dark,
                                onTap: () {
                                  setState(() {
                                    _pinError = null;
                                    _manualPin = '';
                                    _drawerView = AmanahQrDrawerView.manualPin;
                                  });
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
                                onTap: () {
                                  setState(
                                    () => _drawerView =
                                        AmanahQrDrawerView.uploadQr,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],

                      // VIEW 2: Manual PIN View
                      if (_drawerView ==
                          AmanahQrDrawerView.manualPin) ...<Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButton.icon(
                              onPressed: () {
                                setState(
                                  () => _drawerView = AmanahQrDrawerView.menu,
                                );
                              },
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
                            IconButton(
                              onPressed: () =>
                                  setState(() => _isDrawerOpen = false),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                              ),
                              color: subtextColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 6-Grid OTP Input
                        AmanahOtpInput(
                          length: 6,
                          error: _pinError,
                          onChanged: (String val) {
                            setState(() {
                              _manualPin = val;
                              _pinError = null;
                            });
                          },
                          onCompleted: _handleVerifyManualPin,
                        ),
                        const SizedBox(height: 16),

                        // Verification Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _handleVerifyManualPin(_manualPin),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Verifikasi Presensi',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // VIEW 3: Tampilkan QR Dokter & 5-Digit Code
                      if (_drawerView == AmanahQrDrawerView.myQr) ...<Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButton.icon(
                              onPressed: () {
                                setState(
                                  () => _drawerView = AmanahQrDrawerView.menu,
                                );
                              },
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
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    backgroundColor: dark
                                        ? Colors.white.withValues(alpha: 0.10)
                                        : const Color(0xFFF1F5F9),
                                    foregroundColor: subtextColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'QR Code berhasil diunduh ke galeri.',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 12,
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFF0F172A,
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.download_rounded,
                                    size: 16,
                                  ),
                                  tooltip: 'Unduh QR',
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    backgroundColor: dark
                                        ? Colors.white.withValues(alpha: 0.10)
                                        : const Color(0xFFF1F5F9),
                                    foregroundColor: subtextColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _isDrawerOpen = false),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                  ),
                                  color: subtextColor,
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
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ],

                      // VIEW 4: Upload QR View (Dashed Dropzone)
                      if (_drawerView ==
                          AmanahQrDrawerView.uploadQr) ...<Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButton.icon(
                              onPressed: () {
                                setState(
                                  () => _drawerView = AmanahQrDrawerView.menu,
                                );
                              },
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
                            IconButton(
                              onPressed: () =>
                                  setState(() => _isDrawerOpen = false),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                              ),
                              color: subtextColor,
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
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: dark
                                    ? Colors.white.withValues(alpha: 0.20)
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
                                    borderRadius: BorderRadius.circular(16),
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

          // 5. Success Feedback Card on Scan
          if (_isScanned && _successController.value < 0)
            Positioned(
              bottom: 110,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.95)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.50),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 24,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Presensi Masuk Berhasil',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: dark
                                  ? Colors.white
                                  : const Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.user?.fullName ?? 'dr. Andika Perkasa'} • Poli Anak',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: dark
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFF047857),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '21 Mei 2026, 07:28 WIB • Room 102',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.70)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          if (_lastScannedCode != null) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              'Kode: $_lastScannedCode',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: dark
                                    ? Colors.white.withValues(alpha: 0.78)
                                    : const Color(0xFF047857),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _handleReset,
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isScanned)
            Positioned(
              left: 0,
              right: 0,
              bottom: _overlayBottomClearance(context),
              child: _PresenceSuccessSheet(
                userName: widget.user?.fullName ?? 'dr. Andika Perkasa',
                scannedCode: _lastScannedCode,
                animation: _successController,
                particles: _successParticles,
                onClose: _handleReset,
              ),
            ),
        ],
      ),
    );
  }
}

class _PresenceSuccessSheet extends StatelessWidget {
  const _PresenceSuccessSheet({
    required this.userName,
    required this.animation,
    required this.particles,
    required this.onClose,
    this.scannedCode,
  });

  final String userName;
  final String? scannedCode;
  final Animation<double> animation;
  final List<_PresenceCelebrationParticle> particles;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color surface = dark ? const Color(0xFF0A0E1A) : Colors.white;
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.68;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double eased = Curves.easeOutCubic.transform(animation.value);
        final double badgeProgress = ((animation.value - 0.10) / 0.46)
            .clamp(0, 1)
            .toDouble();

        return Transform.translate(
          offset: Offset(0, 26 * (1 - eased)),
          child: Opacity(
            opacity: eased,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
                minHeight: math.min(420, maxHeight),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border(
                      top: BorderSide(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.12)
                            : const Color(0xFFE0F2FE),
                      ),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.30),
                        blurRadius: 42,
                        offset: const Offset(0, -12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 250,
                        child: CustomPaint(
                          painter: _PresenceSuccessAuroraPainter(dark: dark),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _PresenceCelebrationPainter(
                              progress: eased,
                              particles: particles,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: onClose,
                            child: SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: Center(
                                child: Container(
                                  width: 44,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: dark
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : const Color(0xFFD4D4D8),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Center(
                                    child: Semantics(
                                      label: 'Presensi masuk berhasil',
                                      image: true,
                                      child: Transform.scale(
                                        scale: 0.88 + 0.12 * eased,
                                        child: _PresenceSuccessEmblem(
                                          progress: Curves.easeOutCubic
                                              .transform(badgeProgress),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Presensi Masuk Berhasil',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontFamily: 'PlusJakartaSans',
                                          fontWeight: FontWeight.w900,
                                          height: 1.1,
                                          color: dark
                                              ? Colors.white
                                              : const Color(0xFF020617),
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$userName berhasil check-in untuk Poli Anak.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'PlusJakartaSans',
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                      color: dark
                                          ? const Color(0xFFBAE6FD)
                                          : const Color(0xFF0F766E),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$userName • Poli Anak',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontFamily: 'PlusJakartaSans',
                                          fontWeight: FontWeight.w800,
                                          color: dark
                                              ? const Color(0xFF6EE7B7)
                                              : const Color(0xFF047857),
                                        ),
                                  ),
                                  const SizedBox(height: 18),
                                  _PresenceSuccessMeta(
                                    dark: dark,
                                    scannedCode: scannedCode,
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: onClose,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2563EB,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Tutup',
                                        style: TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PresenceSuccessMeta extends StatelessWidget {
  const _PresenceSuccessMeta({required this.dark, this.scannedCode});

  final bool dark;
  final String? scannedCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: <Widget>[
          _PresenceSuccessMetaRow(
            icon: Icons.schedule_rounded,
            label: '21 Mei 2026, 07:28 WIB',
            dark: dark,
          ),
          const SizedBox(height: 10),
          _PresenceSuccessMetaRow(
            icon: Icons.meeting_room_rounded,
            label: 'Room 102',
            dark: dark,
          ),
          if (scannedCode != null) ...<Widget>[
            const SizedBox(height: 10),
            _PresenceSuccessMetaRow(
              icon: Icons.qr_code_2_rounded,
              label: scannedCode!,
              dark: dark,
            ),
          ],
        ],
      ),
    );
  }
}

class _PresenceSuccessMetaRow extends StatelessWidget {
  const _PresenceSuccessMetaRow({
    required this.icon,
    required this.label,
    required this.dark,
  });

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 17,
          color: dark ? const Color(0xFF67E8F9) : const Color(0xFF2563EB),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: dark ? const Color(0xFFE0F2FE) : const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}

class _PresenceSuccessEmblem extends StatelessWidget {
  const _PresenceSuccessEmblem({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(124),
      painter: _PresenceSuccessEmblemPainter(progress: progress),
    );
  }
}

class _PresenceSuccessEmblemPainter extends CustomPainter {
  const _PresenceSuccessEmblemPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 124;
    canvas.save();
    canvas.scale(scale, scale);

    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawOval(const Rect.fromLTWH(24, 94, 76, 18), shadowPaint);

    final Path leftWing = Path()
      ..moveTo(44, 35)
      ..lineTo(9, 27)
      ..lineTo(18, 43)
      ..lineTo(27, 60)
      ..lineTo(39, 58)
      ..lineTo(39, 42)
      ..close();
    final Paint wingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFFFFF),
          Color(0xFFBAE6FD),
          Color(0xFF38BDF8),
          Color(0xFF2563EB),
        ],
      ).createShader(const Rect.fromLTWH(0, 20, 124, 44));
    canvas.drawPath(leftWing, wingPaint);

    final Path rightWing = Path()
      ..moveTo(80, 35)
      ..lineTo(115, 27)
      ..lineTo(106, 43)
      ..lineTo(97, 60)
      ..lineTo(85, 58)
      ..lineTo(85, 42)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    final Path shield = Path()
      ..moveTo(62, 12)
      ..lineTo(91, 30)
      ..lineTo(91, 66)
      ..lineTo(62, 86)
      ..lineTo(33, 66)
      ..lineTo(33, 30)
      ..close();
    final Paint shieldPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFE0F2FE),
          Color(0xFF38BDF8),
          Color(0xFF2563EB),
          Color(0xFF0F172A),
        ],
        stops: <double>[0.0, 0.20, 0.66, 1.0],
      ).createShader(const Rect.fromLTWH(30, 10, 64, 78));
    canvas.drawPath(shield, shieldPaint);

    final Path core = Path()
      ..moveTo(62, 20)
      ..lineTo(83, 33)
      ..lineTo(83, 62)
      ..lineTo(62, 76)
      ..lineTo(41, 62)
      ..lineTo(41, 33)
      ..close();
    final Paint corePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF10B981),
          Color(0xFF059669),
          Color(0xFF065F46),
        ],
      ).createShader(const Rect.fromLTWH(40, 20, 44, 58));
    canvas.drawPath(core, corePaint);

    final Paint glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.72),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(const Rect.fromLTWH(41, 20, 42, 29));
    canvas.drawPath(
      Path()
        ..moveTo(42, 34)
        ..lineTo(62, 21)
        ..lineTo(82, 34)
        ..cubicTo(71, 42, 55, 43, 42, 34)
        ..close(),
      glossPaint,
    );

    final Path checkPath = Path()
      ..moveTo(48, 52)
      ..lineTo(58, 62)
      ..lineTo(78, 40);
    final PathMetric metric = checkPath.computeMetrics().first;
    final Path visiblePath = metric.extractPath(0, metric.length * progress);
    final Paint checkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    canvas.drawPath(visiblePath, checkPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PresenceSuccessEmblemPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PresenceSuccessAuroraPainter extends CustomPainter {
  const _PresenceSuccessAuroraPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const <Color>[
                Color(0xFF0F172A),
                Color(0xFF0E7490),
                Color(0xFF064E3B),
              ]
            : const <Color>[
                Color(0xFFE0F2FE),
                Color(0xFFECFDF5),
                Color(0xFFFFFFFF),
              ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, basePaint);

    final Paint cyan = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: dark ? 0.28 : 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.18, size.height * 0.22),
        width: size.width * 0.78,
        height: size.height * 0.66,
      ),
      cyan,
    );

    final Paint green = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: dark ? 0.30 : 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.82, size.height * 0.36),
        width: size.width * 0.70,
        height: size.height * 0.70,
      ),
      green,
    );
  }

  @override
  bool shouldRepaint(covariant _PresenceSuccessAuroraPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

class _PresenceCelebrationParticle {
  const _PresenceCelebrationParticle({
    required this.fromLeft,
    required this.velocity,
    required this.size,
    required this.color,
    required this.rotation,
    required this.spin,
    required this.delay,
  });

  final bool fromLeft;
  final Offset velocity;
  final Size size;
  final Color color;
  final double rotation;
  final double spin;
  final double delay;
}

class _PresenceCelebrationPainter extends CustomPainter {
  const _PresenceCelebrationPainter({
    required this.progress,
    required this.particles,
  });

  final double progress;
  final List<_PresenceCelebrationParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }

    final Paint paint = Paint()..style = PaintingStyle.fill;
    final Offset leftOrigin = Offset(size.width * 0.14, size.height * 0.32);
    final Offset rightOrigin = Offset(size.width * 0.86, size.height * 0.32);

    for (final _PresenceCelebrationParticle particle in particles) {
      final double localProgress =
          ((progress - particle.delay) / (1 - particle.delay)).clamp(0, 1);
      if (localProgress <= 0) {
        continue;
      }

      final double t = localProgress;
      final Offset origin = particle.fromLeft ? leftOrigin : rightOrigin;
      final Offset gravity = Offset(0, 260 * t * t);
      final Offset position = origin + particle.velocity * t + gravity;
      final double opacity = (1 - math.pow(t, 2.25)).clamp(0, 1).toDouble();

      if (opacity <= 0) {
        continue;
      }

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(particle.rotation + particle.spin * t);
      paint.color = particle.color.withValues(alpha: opacity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size.width,
            height: particle.size.height,
          ),
          const Radius.circular(1.6),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PresenceCelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
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
    this.activeColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool dark;
  final double size;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isActive
        ? (activeColor ?? const Color(0xFFF59E0B))
        : (dark
              ? const Color(0xFF1E293B).withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.85));

    final Color iconColor = isActive
        ? const Color(0xFF0F172A)
        : (dark ? Colors.white : const Color(0xFF1E293B));

    final Color borderColor = isActive
        ? (activeColor ?? const Color(0xFFF59E0B))
        : (dark
              ? Colors.white.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.80));

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: borderColor),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, size: size * 0.48, color: iconColor),
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
  });

  final String title;
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color cardBg = dark ? const Color(0xFF1F2937) : Colors.white;

    final Color borderColor = dark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE2E8F0);

    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: const Color(0xFF06B6D4)),
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
                fontWeight: FontWeight.w700,
                color: textColor,
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
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.20)
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
