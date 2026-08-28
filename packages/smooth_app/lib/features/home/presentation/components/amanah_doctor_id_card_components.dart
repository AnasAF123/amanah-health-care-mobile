import 'dart:math' as math;
import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_qr_code_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AmanahDoctorIdCardHeader extends StatelessWidget {
  const AmanahDoctorIdCardHeader({
    required this.onBack,
    required this.onInfo,
    required this.onQr,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onInfo;
  final VoidCallback onQr;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark
                ? const Color(0xFF0A0E1A).withValues(alpha: 0.70)
                : Colors.white.withValues(alpha: 0.75),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _RoundIconButton(
                          icon: Icons.arrow_back,
                          label: 'Kembali',
                          onTap: onBack,
                          dark: dark,
                          foreground: dark
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF334155),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _RoundIconButton(
                              icon: Icons.info_outline_rounded,
                              label: 'Petunjuk & Informasi ID Card',
                              onTap: onInfo,
                              dark: dark,
                              foreground: dark
                                  ? const Color(0xFF22D3EE)
                                  : const Color(0xFF0A44FF),
                              hoverColor: dark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : const Color(0xFFEFF6FF),
                            ),
                            const SizedBox(width: 4),
                            _RoundIconButton(
                              icon: Icons.qr_code_2_rounded,
                              label: 'Tampilkan QR Code Presensi',
                              onTap: onQr,
                              dark: dark,
                              foreground: dark
                                  ? const Color(0xFF22D3EE)
                                  : const Color(0xFF0A44FF),
                              hoverColor: dark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : const Color(0xFFEFF6FF),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 92),
                  child: Text(
                    'Kartu Identitas',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: dark ? Colors.white : const Color(0xFF14103B),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      height: 1.1,
                    ),
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

class AmanahDoctorIdCardStage extends StatefulWidget {
  const AmanahDoctorIdCardStage({required this.profile, super.key});

  final AmanahDoctorProfile profile;

  @override
  State<AmanahDoctorIdCardStage> createState() =>
      _AmanahDoctorIdCardStageState();
}

class _AmanahDoctorIdCardStageState extends State<AmanahDoctorIdCardStage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration? _lastElapsed;

  Offset? _cardPos;
  Offset _cardVel = Offset.zero;

  double _rotationY = 0.0;
  double _spinVelY = 0.0;

  double _cardTiltZ = 0.0;
  double _tiltVelZ = 0.0;

  bool _isDragging = false;
  Offset _dragTouchStart = Offset.zero;
  Offset _dragCardStart = Offset.zero;
  DateTime _dragStartTime = DateTime.now();

  Offset _lastPointerPos = Offset.zero;
  DateTime _lastPointerTime = DateTime.now();
  Offset _pointerVelocity = Offset.zero;

  double _ambientTime = 0.0;

  WebViewController? _webController;
  bool _useWebView = true;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _initWebView();
  }

  void _initWebView() {
    try {
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..clearCache()
        ..clearLocalStorage()
        ..setNavigationDelegate(
          NavigationDelegate(
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView Error: ${error.description}');
            },
          ),
        )
        ..loadFlutterAsset('assets/amanah/id_card/interactive_card.html');
    } catch (_) {
      _useWebView = false;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _wakeUp() {
    if (!_ticker.isActive) {
      _lastElapsed = null;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) {
      return;
    }

    final double dt;
    if (_lastElapsed == null) {
      dt = 0.016;
    } else {
      dt = (elapsed - _lastElapsed!).inMicroseconds / 1000000.0;
    }
    _lastElapsed = elapsed;

    final double clampedDt = dt.clamp(0.001, 0.033);
    _ambientTime += clampedDt;

    setState(() {
      final Size size = MediaQuery.sizeOf(context);
      final double vw = size.width;
      final double vh = size.height;

      final Offset anchor = Offset(vw / 2, 0);
      final Offset restingPos = Offset(
        vw / 2 + math.sin(_ambientTime * 1.15) * 4.5,
        vh * 0.44 + math.cos(_ambientTime * 0.85) * 2.5,
      );

      _cardPos ??= restingPos;

      if (!_isDragging) {
        // 1. Spring Force (Hooke's Law towards dynamic resting position)
        const double kSpring = 46.0;
        const double cDamping = 6.4;

        final Offset deltaPos = restingPos - _cardPos!;
        final Offset springForce = deltaPos * kSpring;
        final Offset dampingForce = _cardVel * cDamping;
        final Offset accel = springForce - dampingForce;

        _cardVel += accel * clampedDt;
        _cardPos = _cardPos! + _cardVel * clampedDt;

        // 2. Angular Tilt Oscillation (Pendulum Sway)
        const double kTilt = 44.0;
        const double cTilt = 6.0;

        final double targetTilt =
            (_cardPos!.dx - anchor.dx) * 0.0016 +
            _cardVel.dx * 0.00030 +
            math.sin(_ambientTime * 1.15) * 0.015;
        final double tiltDelta = targetTilt - _cardTiltZ;
        final double tiltAccel = tiltDelta * kTilt - _tiltVelZ * cTilt;

        _tiltVelZ += tiltAccel * clampedDt;
        _cardTiltZ += _tiltVelZ * clampedDt;

        // 3. Y-axis Spin (Flipping Front / Back)
        if (_spinVelY.abs() > 0.05) {
          _rotationY += _spinVelY * clampedDt;
          _spinVelY *= math.pow(0.12, clampedDt).toDouble();
        } else {
          // Snap smoothly to nearest side (0 or pi radians)
          final double nearestSide =
              (_rotationY / math.pi).round() * math.pi;
          final double snapDelta = nearestSide - _rotationY;
          if (snapDelta.abs() > 0.001) {
            _rotationY += snapDelta * math.min(1.0, clampedDt * 14.0);
          } else {
            _rotationY = nearestSide;
            _spinVelY = 0.0;
          }
        }

        // Auto sleep when motion is fully dampening and settled near rest
        if (_cardVel.distance < 0.25 &&
            _tiltVelZ.abs() < 0.002 &&
            _spinVelY.abs() < 0.02 &&
            deltaPos.distance < 0.6) {
          _cardPos = restingPos;
          _cardVel = Offset.zero;
          _cardTiltZ = 0.0;
          _tiltVelZ = 0.0;
          _spinVelY = 0.0;
          _ticker.stop();
        }
      } else {
        // While dragging: tilt follows displacement angle
        final double targetTilt =
            (_cardPos!.dx - anchor.dx) * 0.0015;
        _cardTiltZ = _cardTiltZ + (targetTilt - _cardTiltZ) * math.min(1.0, clampedDt * 18.0);
      }
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    _wakeUp();
    _isDragging = true;
    _dragTouchStart = event.position;
    _dragCardStart = _cardPos ?? Offset(
      MediaQuery.sizeOf(context).width / 2,
      MediaQuery.sizeOf(context).height * 0.44,
    );
    _dragStartTime = DateTime.now();

    _lastPointerPos = event.position;
    _lastPointerTime = DateTime.now();
    _pointerVelocity = Offset.zero;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isDragging) {
      return;
    }

    final Size size = MediaQuery.sizeOf(context);
    final double vw = size.width;
    final double vh = size.height;

    final Offset delta = event.position - _dragTouchStart;
    final Offset target = _dragCardStart + delta;

    // Full freedom to pull all the way down across the screen!
    final double clampedX = target.dx.clamp(vw * 0.05, vw * 0.95);
    final double clampedY = target.dy.clamp(vh * 0.18, vh * 0.92);

    setState(() {
      _cardPos = Offset(clampedX, clampedY);
    });

    // Velocity tracker
    final DateTime now = DateTime.now();
    final int dtUs = now.difference(_lastPointerTime).inMicroseconds;
    if (dtUs > 2000) {
      final Offset curVel = (event.position - _lastPointerPos) /
          (dtUs / 1000000.0);
      _pointerVelocity = _pointerVelocity * 0.3 + curVel * 0.7;
      _lastPointerPos = event.position;
      _lastPointerTime = now;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_isDragging) {
      return;
    }

    final double moveDistance = (event.position - _dragTouchStart).distance;
    final int elapsedMs =
        DateTime.now().difference(_dragStartTime).inMilliseconds;

    if (moveDistance < 14 && elapsedMs < 360) {
      // User tapped or flicked: Spin the card 3D to flip side
      HapticFeedback.selectionClick();
      final double clickX = event.position.dx;
      final double cardCenterX = _cardPos?.dx ?? MediaQuery.sizeOf(context).width / 2;
      final double spinDir = clickX < cardCenterX ? 1.0 : -1.0;
      _spinVelY = spinDir * 18.0;
      _cardVel = Offset(spinDir * 80.0, 40.0);
    } else {
      // Released after dragging: transfer velocity into spring rebound
      final double vx = _pointerVelocity.dx.clamp(-2600.0, 2600.0);
      final double vy = _pointerVelocity.dy.clamp(-2600.0, 2600.0);
      _cardVel = Offset(vx, vy);

      if (vx.abs() > 700) {
        _spinVelY = (vx > 0 ? 1.0 : -1.0) * math.min(18.0, vx.abs() * 0.012);
      }
    }

    _wakeUp();
    setState(() {
      _isDragging = false;
    });
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _wakeUp();
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    if (_useWebView && _webController != null) {
      return Stack(
        children: <Widget>[
          // Ambient medical glow
          const Positioned.fill(
            child: Align(
              alignment: Alignment(0, -0.2),
              child: _IdCardUnderglow(),
            ),
          ),
          // Genuine 3D Three.js WebGL Canvas with card.glb & tag_texture.png
          Positioned.fill(
            child: WebViewWidget(controller: _webController!),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double viewportWidth = constraints.maxWidth;
        final double viewportHeight = constraints.maxHeight;

        final double cardWidth = math.min(280.0, viewportWidth * 0.74);
        final double cardHeight = cardWidth * 1.50;

        final Offset anchor = Offset(viewportWidth / 2, 0);
        final Offset cardCenter = _cardPos ??
            Offset(viewportWidth / 2, viewportHeight * 0.44);

        // Normalize rotation for front/back detection
        final double normalizedRot = (_rotationY % (math.pi * 2) + math.pi * 2) % (math.pi * 2);
        final bool showBack = normalizedRot > (math.pi / 2) && normalizedRot < (math.pi * 1.5);

        // Sheen specular shine angle
        final double sheenShift = math.sin(_cardTiltZ * 4.0 + _rotationY) * 0.5 + 0.5;

        return Listener(
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerUp,
          onPointerCancel: _handlePointerCancel,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // 1. Ambient Medical Underglow
              Positioned(
                top: viewportHeight * 0.22,
                left: (viewportWidth - 320) / 2,
                child: const _IdCardUnderglow(),
              ),

              // 2. Dynamic Elastic Lanyard Strap (Canvas Painter)
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _LanyardPhysicsPainter(
                      anchorPos: anchor,
                      cardCenter: cardCenter,
                      cardTiltZ: _cardTiltZ,
                      cardHeight: cardHeight,
                      dark: dark,
                    ),
                  ),
                ),
              ),

              // 3. 3D Positioned & Rotated ID Card Body
              Positioned(
                left: cardCenter.dx - cardWidth / 2,
                top: cardCenter.dy - cardHeight / 2,
                width: cardWidth,
                height: cardHeight,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0011)
                    ..rotateY(_rotationY)
                    ..rotateZ(_cardTiltZ),
                  child: Stack(
                    children: <Widget>[
                      // Card Front / Back Surface
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(showBack ? math.pi : 0.0),
                        child: _DoctorIdCardFace(
                          profile: widget.profile,
                          width: cardWidth,
                          height: cardHeight,
                          back: showBack,
                          dark: dark,
                        ),
                      ),

                      // Dynamic Acrylic Clearcoat Sheen
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(-1.5 + sheenShift * 3.0, -1.0),
                                  end: Alignment(-0.5 + sheenShift * 3.0, 1.0),
                                  colors: <Color>[
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: dark ? 0.08 : 0.18),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const <double>[0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. 3D Black Metallic Swivel Carabiner Snap Hook Clasp
              Positioned(
                left: cardCenter.dx - 18,
                top: cardCenter.dy - cardHeight / 2 - 38,
                width: 36,
                height: 72,
                child: Transform(
                  alignment: const Alignment(0, 0.72),
                  transform: Matrix4.rotationZ(_cardTiltZ),
                  child: _IdCardClip(dark: dark),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AmanahDoctorIdInfoDrawer extends StatelessWidget {
  const AmanahDoctorIdInfoDrawer({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (BuildContext ctx) => const AmanahDoctorIdInfoDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.88;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final Color bgColor = dark ? const Color(0xFF0A0E1A) : Colors.white;
    final Color borderColor = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFF1F5F9);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 380, maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: borderColor)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.80 : 0.25),
                blurRadius: 45,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.20)
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Text(
                    'Panduan & Informasi ID Card 3D',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'ID Card Digital Terverifikasi RS Amanah Sehat dilengkapi simulasi fisika tiga dimensi dan token presensi aman:',
                          style: TextStyle(
                            color: subtextColor,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.02)
                                : const Color(
                                    0xFFF8FAFC,
                                  ).withValues(alpha: 0.50),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: <Widget>[
                              _InfoDrawerItem(
                                icon: Icons.explore_outlined,
                                title: 'Fisika 3D & Gesture Interaktif',
                                subtitle:
                                    'Tarik tali lanyard atau ketuk sisi kartu untuk memutar balik kartu secara natural.',
                                dark: dark,
                                showDivider: true,
                              ),
                              _InfoDrawerItem(
                                icon: Icons.fingerprint_rounded,
                                title: 'Barcode & Token Presensi',
                                subtitle:
                                    'Sisi belakang memuat 1D Barcode, dan tombol QR di pojok atas menyediakan kode scanner poli/IGD.',
                                dark: dark,
                                showDivider: true,
                              ),
                              _InfoDrawerItem(
                                icon: Icons.verified_user_outlined,
                                title: 'Verifikasi Resmi KKI',
                                subtitle:
                                    'Nomor Surat Izin Praktik (SIP) terdaftar aktif di Konsil Kedokteran Indonesia.',
                                dark: dark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, bottomInset + 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        backgroundColor: dark
                            ? Colors.white.withValues(alpha: 0.10)
                            : const Color(0xFF0A44FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Mengerti',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
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

class AmanahDoctorIdQrDialog extends StatelessWidget {
  const AmanahDoctorIdQrDialog({required this.profile, super.key});

  final AmanahDoctorProfile profile;

  static Future<void> show(BuildContext context, AmanahDoctorProfile profile) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup QR Presensi',
      barrierColor: Colors.black.withValues(alpha: 0.60),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder:
          (
            BuildContext ctx,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return AmanahDoctorIdQrDialog(profile: profile);
          },
      transitionBuilder:
          (
            BuildContext ctx,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final Animation<double> curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
                child: child,
              ),
            );
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final String payload = 'AMANAH-DOC-${profile.sip}';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: math.min(MediaQuery.sizeOf(context).width - 40, 360),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFF0F1422).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color(0xFFF1F5F9),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.80 : 0.20),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: Color(0xFF06B6D4),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'QR Presensi & Akses IGD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gunakan barcode ini untuk tap-in di reader poli atau ruang tindakan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subtextColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: AmanahQrCodeWidget(
                    value: payload,
                    size: 160,
                    borderRadius: 8,
                    fgColor: const Color(0xFF0F172A),
                    bgColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      color: subtextColor.withValues(alpha: 0.75),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Token dinamis berganti setiap 60 detik',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subtextColor.withValues(alpha: 0.78),
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: dark
                          ? Colors.white.withValues(alpha: 0.10)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: dark
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _DoctorIdCardFace extends StatelessWidget {
  const _DoctorIdCardFace({
    required this.profile,
    required this.width,
    required this.height,
    required this.back,
    required this.dark,
  });

  final AmanahDoctorProfile profile;
  final double width;
  final double height;
  final bool back;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF08141E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.62)
                : const Color(0xFF0A44FF).withValues(alpha: 0.12),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: back ? _buildBack() : _buildFront(),
      ),
    );
  }

  Widget _buildFront() {
    final double panelHeight = height * 0.245;
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CustomPaint(painter: _BauhausGridPainter(dark: dark)),
        ),
        Positioned(
          left: width * 0.075,
          top: width * 0.085,
          child: Row(
            children: <Widget>[
              _AmanahMark(size: width * 0.085, dark: dark),
              SizedBox(width: width * 0.035),
              Text(
                'Amanah',
                style: TextStyle(
                  color: subtextColor,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: width * 0.075,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        // Top Center Frosted Slot Hole Punch for Clip
        Positioned(
          top: width * 0.08,
          left: (width - width * 0.16) / 2,
          width: width * 0.16,
          height: width * 0.065,
          child: Container(
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.65)
                  : const Color(0xFF0A0E1A).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(width * 0.035),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.90),
                width: 1.5,
              ),
            ),
          ),
        ),
        Positioned(
          left: -width * 0.12,
          right: -width * 0.12,
          bottom: panelHeight * 0.72,
          height: height * 0.64,
          child: Image.asset(
            profile.avatarAsset,
            fit: BoxFit.fitHeight,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.high,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return const SizedBox.shrink();
                },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: panelHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF0C1B29) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: dark
                      ? const Color(0xFF00D4FF).withValues(alpha: 0.25)
                      : const Color(0xFF0A44FF).withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                width * 0.075,
                panelHeight * 0.17,
                width * 0.075,
                panelHeight * 0.12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            profile.name,
                            maxLines: 1,
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: width * 0.071,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                              height: 1,
                            ),
                          ),
                        ),
                        SizedBox(height: panelHeight * 0.07),
                        Text(
                          profile.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: subtextColor,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: width * 0.039,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: width * 0.05),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'NOMOR SIP / ID',
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontFamily: 'PlusJakartaSans',
                            fontSize: width * 0.028,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: panelHeight * 0.08),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            profile.sip,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: subtextColor,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: width * 0.034,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                        SizedBox(height: panelHeight * 0.09),
                        Text(
                          'RS AMANAH SEHAT',
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: dark
                                ? const Color(0xFF2DD4BF)
                                : const Color(0xFF0A44FF),
                            fontFamily: 'PlusJakartaSans',
                            fontSize: width * 0.033,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    final String barcodeValue =
        '*DOC-${profile.sip.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}*';
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CustomPaint(painter: _BauhausGridPainter(dark: dark)),
        ),
        // Top Center Frosted Slot Hole Punch for Clip
        Positioned(
          top: width * 0.08,
          left: (width - width * 0.16) / 2,
          width: width * 0.16,
          height: width * 0.065,
          child: Container(
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.65)
                  : const Color(0xFF0A0E1A).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(width * 0.035),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.90),
                width: 1.5,
              ),
            ),
          ),
        ),
        Positioned(
          left: width * 0.09,
          right: width * 0.09,
          top: height * 0.64,
          height: height * 0.125,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.045,
              vertical: height * 0.018,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: barcodeValue,
              drawText: true,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
              color: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: height * 0.075,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _AmanahMark(size: width * 0.09, dark: dark),
                  SizedBox(width: width * 0.035),
                  Text(
                    'Amanah',
                    style: TextStyle(
                      color: subtextColor,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: width * 0.078,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'HEALTHCARE IDENTITY SYSTEM',
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: width * 0.032,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.dark,
    required this.foreground,
    this.hoverColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;
  final Color foreground;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            splashColor: hoverColor,
            highlightColor: hoverColor,
            child: Icon(icon, size: 21, color: foreground),
          ),
        ),
      ),
    );
  }
}

class _IdCardClip extends StatelessWidget {
  const _IdCardClip({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 72,
      child: CustomPaint(painter: _IdCardClipPainter(dark: dark)),
    );
  }
}

class _IdCardUnderglow extends StatelessWidget {
  const _IdCardUnderglow();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: CustomPaint(
        size: const Size(320, 320),
        painter: _UnderglowPainter(dark: dark),
      ),
    );
  }
}

class _InfoDrawerItem extends StatelessWidget {
  const _InfoDrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.dark,
    this.showDivider = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool dark;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = dark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF1F5F9);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: borderColor))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: dark
                    ? const Color(0xFF06B6D4).withValues(alpha: 0.10)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 16,
                color: dark ? const Color(0xFF22D3EE) : const Color(0xFF0A44FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtextColor,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmanahMark extends StatelessWidget {
  const _AmanahMark({required this.size, required this.dark});

  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFFA3E635) : const Color(0xFF00D4FF),
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: CustomPaint(painter: _AmanahCrossPainter(dark: dark)),
    );
  }
}

class _AmanahCrossPainter extends CustomPainter {
  const _AmanahCrossPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = dark ? const Color(0xFF00D4FF) : const Color(0xFF0A44FF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.39,
          size.height * 0.22,
          size.width * 0.22,
          size.height * 0.56,
        ),
        Radius.circular(size.width * 0.02),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.22,
          size.height * 0.39,
          size.width * 0.56,
          size.height * 0.22,
        ),
        Radius.circular(size.width * 0.02),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AmanahCrossPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class _BauhausGridPainter extends CustomPainter {
  const _BauhausGridPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final List<_BauhausColorPair> palette = dark
        ? const <_BauhausColorPair>[
            _BauhausColorPair(Color(0xFF00D4FF), Color(0xFF062837)),
            _BauhausColorPair(Color(0xFFA3E635), Color(0xFF083344)),
            _BauhausColorPair(Color(0xFF14B8A6), Color(0xFF04202C)),
            _BauhausColorPair(Color(0xFF22D3EE), Color(0xFF0D3846)),
            _BauhausColorPair(Color(0xFF84CC16), Color(0xFF021824)),
            _BauhausColorPair(Color(0xFF67E8F9), Color(0xFF0F4050)),
          ]
        : const <_BauhausColorPair>[
            _BauhausColorPair(Color(0xFF002B9E), Color(0xFFEEF4FF)),
            _BauhausColorPair(Color(0xFF0A44FF), Color(0xFFDBEAFE)),
            _BauhausColorPair(Color(0xFF07247A), Color(0xFFEEF4FF)),
            _BauhausColorPair(Color(0xFF00D4FF), Color(0xFF002B9E)),
            _BauhausColorPair(Color(0xFF0A44FF), Colors.white),
            _BauhausColorPair(Color(0xFF002B9E), Color(0xFFDBEAFE)),
          ];

    final Paint paint = Paint()..style = PaintingStyle.fill;
    const int cols = 4;
    const int rows = 5;
    final double gap = size.width * 0.012;
    final double left = size.width * 0.075;
    final double top = size.height * 0.125;
    final double cellW = (size.width - left * 2 - gap * (cols - 1)) / cols;
    final double cellH = (size.height * 0.58 - gap * (rows - 1)) / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final _BauhausColorPair pair = palette[(r * cols + c) % palette.length];
        final Rect rect = Rect.fromLTWH(
          left + c * (cellW + gap),
          top + r * (cellH + gap),
          cellW,
          cellH,
        );
        _drawShape(canvas, paint, rect, (r * 3 + c * 2) % 6, pair);
      }
    }
  }

  void _drawShape(
    Canvas canvas,
    Paint paint,
    Rect rect,
    int type,
    _BauhausColorPair pair,
  ) {
    paint.color = pair.bg;
    canvas.drawRect(rect, paint);
    paint.color = pair.fg;

    final Path path = Path();
    final Offset center = rect.center;
    final double radius = rect.width / 2;
    switch (type) {
      case 0:
        canvas.drawCircle(center, radius * 0.92, paint);
      case 1:
        path
          ..moveTo(rect.left, center.dy)
          ..arcTo(
            Rect.fromCircle(
              center: Offset(center.dx, center.dy + radius * 0.20),
              radius: radius * 0.88,
            ),
            math.pi,
            math.pi,
            false,
          )
          ..lineTo(rect.right, center.dy)
          ..close();
        canvas.drawPath(path, paint);
      case 2:
        path
          ..moveTo(rect.left, rect.top)
          ..arcTo(
            Rect.fromCircle(center: rect.topLeft, radius: rect.width * 0.95),
            0,
            math.pi / 2,
            false,
          )
          ..lineTo(rect.left, rect.top)
          ..close();
        canvas.drawPath(path, paint);
      case 3:
        path
          ..moveTo(center.dx, rect.top + 3)
          ..lineTo(rect.right - 3, center.dy)
          ..lineTo(center.dx, rect.bottom - 3)
          ..lineTo(rect.left + 3, center.dy)
          ..close();
        canvas.drawPath(path, paint);
      case 4:
        path
          ..moveTo(rect.left, rect.top)
          ..lineTo(rect.right, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..close();
        canvas.drawPath(path, paint);
      default:
        path
          ..moveTo(rect.left, center.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: radius * 0.92),
            math.pi,
            math.pi,
            false,
          )
          ..lineTo(center.dx + radius * 0.45, center.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: radius * 0.45),
            0,
            -math.pi,
            false,
          )
          ..close();
        canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BauhausGridPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class _BauhausColorPair {
  const _BauhausColorPair(this.fg, this.bg);

  final Color fg;
  final Color bg;
}

class _LanyardPhysicsPainter extends CustomPainter {
  const _LanyardPhysicsPainter({
    required this.anchorPos,
    required this.cardCenter,
    required this.cardTiltZ,
    required this.cardHeight,
    required this.dark,
  });

  final Offset anchorPos;
  final Offset cardCenter;
  final double cardTiltZ;
  final double cardHeight;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Calculate top ring attachment point of the snap hook
    final double halfH = cardHeight / 2 + 26;
    final Offset topLoopPoint = Offset(
      cardCenter.dx - math.sin(cardTiltZ) * halfH,
      cardCenter.dy - math.cos(cardTiltZ) * halfH,
    );

    final Offset p0 = anchorPos;
    final Offset p3 = topLoopPoint;
    final Offset diff = p3 - p0;

    // Intermediate Bézier control points
    final Offset p1 = Offset(
      p0.dx + diff.dx * 0.25,
      p0.dy + diff.dy * 0.35,
    );
    final Offset p2 = Offset(
      p0.dx + diff.dx * 0.75,
      p0.dy + diff.dy * 0.70,
    );

    final Path ribbonPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    // 2. Drop Shadow underneath the ribbon
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: dark ? 0.45 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(ribbonPath, shadowPaint);

    // 3. Main Lanyard Ribbon Body (Sleek dark ribbon)
    final Paint ribbonPaint = Paint()
      ..color = dark ? const Color(0xFF050B14) : const Color(0xFF081326)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 15;
    canvas.drawPath(ribbonPath, ribbonPaint);

    // 4. White Micro-Stitches along Left and Right Edges
    final Paint stitchPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Path leftStitch = Path();
    final Path rightStitch = Path();
    const int stitchSegments = 32;
    for (int i = 0; i < stitchSegments; i++) {
      if (i.isEven) {
        final double t1 = i / stitchSegments;
        final double t2 = (i + 0.65) / stitchSegments;
        final Offset pt1 = _evalCubic(p0, p1, p2, p3, t1);
        final Offset tang1 = _evalCubicTangent(p0, p1, p2, p3, t1);
        final double len1 = math.max(0.001, tang1.distance);
        final Offset norm1 = Offset(-tang1.dy / len1, tang1.dx / len1) * 5.8;

        final Offset pt2 = _evalCubic(p0, p1, p2, p3, t2);
        final Offset tang2 = _evalCubicTangent(p0, p1, p2, p3, t2);
        final double len2 = math.max(0.001, tang2.distance);
        final Offset norm2 = Offset(-tang2.dy / len2, tang2.dx / len2) * 5.8;

        leftStitch.moveTo(pt1.dx - norm1.dx, pt1.dy - norm1.dy);
        leftStitch.lineTo(pt2.dx - norm2.dx, pt2.dy - norm2.dy);

        rightStitch.moveTo(pt1.dx + norm1.dx, pt1.dy + norm1.dy);
        rightStitch.lineTo(pt2.dx + norm2.dx, pt2.dy + norm2.dy);
      }
    }
    canvas.drawPath(leftStitch, stitchPaint);
    canvas.drawPath(rightStitch, stitchPaint);

    // 5. Vertical Repeat Brand Badge & Text along Ribbon
    _drawRibbonText(canvas, p0, p1, p2, p3, diff);
  }

  void _drawRibbonText(
    Canvas canvas,
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    Offset diff,
  ) {
    final double dist = diff.distance;
    if (dist < 40) {
      return;
    }

    final TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: 'RS AMANAH SEHAT',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'PlusJakartaSans',
          fontSize: 6.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Paint badgePaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.fill;

    final Paint crossPaint = Paint()
      ..color = const Color(0xFF091B36)
      ..style = PaintingStyle.fill;

    final int repeats = math.max(1, (dist / 140).floor());
    for (int i = 1; i <= repeats; i++) {
      final double t = i / (repeats + 1);
      final Offset pt = _evalCubic(p0, p1, p2, p3, t);
      final Offset tangent = _evalCubicTangent(p0, p1, p2, p3, t);
      final double angle = math.atan2(tangent.dy, tangent.dx) - math.pi / 2;

      canvas.save();
      canvas.translate(pt.dx, pt.dy);
      canvas.rotate(angle);

      // Cyan Cross Emblem Badge
      final Offset emblemCenter = Offset(0, -textPainter.height / 2 - 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: emblemCenter, width: 7, height: 7),
          const Radius.circular(2),
        ),
        badgePaint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: emblemCenter, width: 2.2, height: 4.8),
        crossPaint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: emblemCenter, width: 4.8, height: 2.2),
        crossPaint,
      );

      // Brand Text
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  Offset _evalCubic(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final double u = 1 - t;
    final double tt = t * t;
    final double uu = u * u;
    final double uuu = uu * u;
    final double ttt = tt * t;

    final double x = uuu * p0.dx +
        3 * uu * t * p1.dx +
        3 * u * tt * p2.dx +
        ttt * p3.dx;
    final double y = uuu * p0.dy +
        3 * uu * t * p1.dy +
        3 * u * tt * p2.dy +
        ttt * p3.dy;
    return Offset(x, y);
  }

  Offset _evalCubicTangent(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final double u = 1 - t;
    final double dx = 3 * u * u * (p1.dx - p0.dx) +
        6 * u * t * (p2.dx - p1.dx) +
        3 * t * t * (p3.dx - p2.dx);
    final double dy = 3 * u * u * (p1.dy - p0.dy) +
        6 * u * t * (p2.dy - p1.dy) +
        3 * t * t * (p3.dy - p2.dy);
    return Offset(dx, dy);
  }

  @override
  bool shouldRepaint(covariant _LanyardPhysicsPainter oldDelegate) =>
      oldDelegate.anchorPos != anchorPos ||
      oldDelegate.cardCenter != cardCenter ||
      oldDelegate.cardTiltZ != cardTiltZ ||
      oldDelegate.cardHeight != cardHeight ||
      oldDelegate.dark != dark;
}

class _IdCardClipPainter extends CustomPainter {
  const _IdCardClipPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    const double cx = 18.0;

    // 1. Top D-Ring / Loop for Lanyard
    final Rect topLoop = Rect.fromCenter(
      center: const Offset(cx, 12),
      width: 22,
      height: 14,
    );

    final Paint loopPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFF334155),
          Color(0xFF0F172A),
          Color(0xFF1E293B),
        ],
      ).createShader(topLoop)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(topLoop, const Radius.circular(5)),
      loopPaint,
    );

    // 2. Swivel Collar
    final Rect collar = Rect.fromCenter(
      center: const Offset(cx, 22),
      width: 10,
      height: 7,
    );
    final Paint collarPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(collar, const Radius.circular(2)),
      collarPaint,
    );

    final Paint collarRim = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(collar, const Radius.circular(2)),
      collarRim,
    );

    // 3. Black Metallic Carabiner Snap Hook Body
    final Path hookPath = Path()
      ..moveTo(cx - 2, 25)
      ..lineTo(cx + 4, 25)
      ..lineTo(cx + 6, 36)
      ..cubicTo(cx + 7, 48, cx + 5, 58, cx - 1, 65)
      ..cubicTo(cx - 5, 68, cx - 11, 65, cx - 12, 58)
      ..cubicTo(cx - 13, 52, cx - 11, 46, cx - 9, 44);

    final Paint hookShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(hookPath, hookShadow);

    final Paint hookPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF334155),
          Color(0xFF0F172A),
          Color(0xFF020617),
          Color(0xFF1E293B),
        ],
      ).createShader(const Rect.fromLTWH(0, 24, 36, 48))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(hookPath, hookPaint);

    // 4. Spring Trigger Lever & Specular Bevel
    final Path triggerPath = Path()
      ..moveTo(cx + 1, 32)
      ..lineTo(cx - 4, 39);
    final Paint triggerPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(triggerPath, triggerPaint);

    // 5. Specular Highlights along Outer Curve
    final Path sheenPath = Path()
      ..moveTo(cx + 5, 34)
      ..cubicTo(cx + 6, 46, cx + 4, 56, cx - 1, 63);
    final Paint sheenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(sheenPath, sheenPaint);
  }

  @override
  bool shouldRepaint(covariant _IdCardClipPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

class _UnderglowPainter extends CustomPainter {
  const _UnderglowPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = (dark ? const Color(0xFF06B6D4) : const Color(0xFF60A5FA))
          .withValues(alpha: dark ? 0.20 : 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.2, paint);
  }

  @override
  bool shouldRepaint(covariant _UnderglowPainter oldDelegate) =>
      oldDelegate.dark != dark;
}
