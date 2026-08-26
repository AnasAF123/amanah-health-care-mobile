import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_otp_input.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_qr_code_widget.dart';

enum AmanahQrDrawerView { menu, manualPin, myQr, uploadQr }

class AmanahQrScannerTabScreen extends StatefulWidget {
  const AmanahQrScannerTabScreen({
    super.key,
    this.user,
    this.onBack,
    this.animateLaser = true,
  });

  final AmanahAuthUser? user;
  final VoidCallback? onBack;
  final bool animateLaser;

  @override
  State<AmanahQrScannerTabScreen> createState() =>
      _AmanahQrScannerTabScreenState();
}

class _AmanahQrScannerTabScreenState extends State<AmanahQrScannerTabScreen>
    with SingleTickerProviderStateMixin {
  bool _isFlashOn = false;
  bool _isScanned = false;
  bool _isDrawerOpen = true;
  AmanahQrDrawerView _drawerView = AmanahQrDrawerView.menu;
  String _manualPin = '';
  String? _pinError;
  bool _copiedFeedback = false;

  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    if (widget.animateLaser) {
      _laserController.repeat(reverse: true);
    } else {
      _laserController.value = 0.5;
    }

    _laserAnimation = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(
        parent: _laserController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() => _isFlashOn = !_isFlashOn);
  }

  void _handleSimulateScan() {
    setState(() {
      _isScanned = true;
      _isDrawerOpen = false;
    });
  }

  void _handleReset() {
    setState(() {
      _isScanned = false;
      _isDrawerOpen = true;
      _drawerView = AmanahQrDrawerView.menu;
    });
  }

  void _handleVerifyManualPin(String pin) {
    if (pin.length < 6) {
      setState(() => _pinError = 'Masukkan 6 digit kode presensi.');
      return;
    }
    setState(() {
      _pinError = null;
      _manualPin = '';
      _drawerView = AmanahQrDrawerView.menu;
      _isScanned = true;
      _isDrawerOpen = false;
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    final Color bgColor =
        dark ? const Color(0xFF0A0E1A) : const Color(0xFF0F172A);
    final Color drawerBg =
        dark ? const Color(0xFF111827) : Colors.white;
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor =
        dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color drawerBorder =
        dark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: <Widget>[
          // 1. Camera Viewport Background / Tap to simulate
          Positioned.fill(
            child: GestureDetector(
              onTap: _handleSimulateScan,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: const Color(0xFF050811),
                child: Stack(
                  children: <Widget>[
                    // Subtle Background Medical Grid pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.15,
                        child: CustomPaint(
                          painter: _MedicalGridPainter(),
                        ),
                      ),
                    ),

                    // Ambient Dark Vignette overlay
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

                    // Retro Scanner Silhouette Pass (Animated horizontal laser)
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
                                // Gradient Laser Glow Trail
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[
                                        Colors.transparent,
                                        const Color(0xFF00D4FF)
                                            .withValues(alpha: 0.05),
                                        const Color(0xFF00D4FF)
                                            .withValues(alpha: 0.22),
                                      ],
                                    ),
                                  ),
                                ),
                                // Sharp Master Scanline
                                Container(
                                  width: double.infinity,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22D3EE),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xFF22D3EE)
                                            .withValues(alpha: 0.80),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF0A44FF)
                                            .withValues(alpha: 0.40),
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

                    // Flashlight Simulation Overlay
                    if (_isFlashOn)
                      Positioned.fill(
                        child: Container(
                          color: const Color(0xFFFEF3C7).withValues(alpha: 0.20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

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
                  onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                  icon: Icons.arrow_back_rounded,
                  label: 'Kembali',
                  dark: dark,
                ),

                // Top Right Action Buttons: ( ? ) ( 🖼️ ) ( ⚡ )
                Row(
                  children: <Widget>[
                    _FloatingCircularButton(
                      onTap: _showHelpDialog,
                      icon: Icons.help_outline_rounded,
                      label: 'Bantuan Presensi',
                      dark: dark,
                      size: 42,
                    ),
                    const SizedBox(width: 10),
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
                      size: 42,
                    ),
                    const SizedBox(width: 10),
                    _FloatingCircularButton(
                      onTap: _toggleFlash,
                      icon: _isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      label: 'Senter Flash',
                      dark: dark,
                      size: 42,
                      isActive: _isFlashOn,
                      activeColor: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Floating Bottom Trigger when Drawer is closed
          if (!_isDrawerOpen && !_isScanned)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isDrawerOpen = true;
                      _drawerView = AmanahQrDrawerView.menu;
                    });
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.90)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.20)
                            : const Color(0xFFCBD5E1),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: Color(0xFF06B6D4),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Buka Menu Presensi',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 4. Master Drawer (Bottom Sheet)
          if (_isDrawerOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onVerticalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 200) {
                    setState(() => _isDrawerOpen = false);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 130),
                  decoration: BoxDecoration(
                    color: drawerBg,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
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
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.30),
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
                                  setState(() => _drawerView =
                                      AmanahQrDrawerView.myQr);
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
                                  setState(() => _drawerView =
                                      AmanahQrDrawerView.uploadQr);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],

                      // VIEW 2: Manual PIN View
                      if (_drawerView == AmanahQrDrawerView.manualPin) ...<Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButton.icon(
                              onPressed: () {
                                setState(() =>
                                    _drawerView = AmanahQrDrawerView.menu);
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
                                setState(() =>
                                    _drawerView = AmanahQrDrawerView.menu);
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
                                  icon: const Icon(Icons.copy_rounded, size: 16),
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
                                        backgroundColor:
                                            const Color(0xFF0F172A),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                            color: const Color(0xFF2563EB)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.25),
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
                      if (_drawerView == AmanahQrDrawerView.uploadQr) ...<Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButton.icon(
                              onPressed: () {
                                setState(() =>
                                    _drawerView = AmanahQrDrawerView.menu);
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
                                    color: const Color(0xFF2563EB)
                                        .withValues(alpha: 0.12),
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
          if (_isScanned)
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
        ],
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
            child: Icon(
              icon,
              size: size * 0.48,
              color: iconColor,
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
  });

  final String title;
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color cardBg = dark
        ? const Color(0xFF1F2937)
        : Colors.white;

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
              child: Icon(
                icon,
                size: 22,
                color: const Color(0xFF06B6D4),
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
