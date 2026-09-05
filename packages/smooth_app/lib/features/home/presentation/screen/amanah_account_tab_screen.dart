import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_edit_profile_drawer.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_doctor_id_card_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_account_identity_settings_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_data_storage_settings_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_it_support_settings_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/settings/amanah_privacy_security_settings_screen.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahAccountTabScreen extends StatefulWidget {
  const AmanahAccountTabScreen({
    required this.user,
    required this.onMenuItemTap,
    required this.onLogout,
    this.onBack,
    super.key,
  });

  final AmanahAuthUser user;
  final ValueChanged<String> onMenuItemTap;
  final VoidCallback onLogout;
  final VoidCallback? onBack;

  @override
  State<AmanahAccountTabScreen> createState() => _AmanahAccountTabScreenState();
}

class _AmanahAccountTabScreenState extends State<AmanahAccountTabScreen> {
  String _phone = '+62 812-3456-7890';
  String _email = 'rayhan.pratama@rsamanah.co.id';
  String _bio =
      'Dokter Spesialis Anak di RS Amanah Sehat, melayani konsultasi rawat jalan & rawat inap anak.';
  bool _isEmailVerified = false;
  String? _customAvatarPath;
  String? _presetAvatarUrl;

  @override
  void initState() {
    super.initState();
    _phone = '+62 812-3456-7890';
    _email = widget.user.email.isNotEmpty
        ? widget.user.email
        : 'rayhan.pratama@rsamanah.co.id';
    _bio =
        'Dokter Spesialis Anak di RS Amanah Sehat, melayani konsultasi rawat jalan & rawat inap anak.';
    _isEmailVerified = widget.user.isEmailVerified;
  }

  @override
  void didUpdateWidget(AmanahAccountTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.isEmailVerified != widget.user.isEmailVerified) {
      _isEmailVerified = widget.user.isEmailVerified;
    }
  }

  void _handleVerifyEmail() {
    setState(() {
      _isEmailVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tautan verifikasi telah dikirim ke $_email. Email berhasil diverifikasi.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0284C7),
      ),
    );
  }

  void _handleToggleVerification() {
    setState(() {
      _isEmailVerified = !_isEmailVerified;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEmailVerified
              ? 'Status email diubah ke: Terverifikasi (Mode Dummy)'
              : 'Status email diubah ke: Belum Terverifikasi (Mode Dummy)',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isEmailVerified
            ? const Color(0xFF0284C7)
            : const Color(0xFFD97706),
      ),
    );
  }

  AmanahDoctorProfile get _doctorProfile => AmanahDoctorProfile(
    name: widget.user.fullName,
    role: 'Dokter Spesialis Anak',
    greeting: 'Selamat Bertugas',
    unreadNotifications: 3,
    sip: 'SIP. 503/442.1/SIP-D/2026',
    str: 'STR. 31.2.1.100.1.20.123456',
    phone: _phone,
    email: _email,
    hospital: 'RS Amanah Sehat',
    department: 'Departemen Ilmu Kesehatan Anak',
  );

  Future<void> _openEditProfileDrawer() async {
    final AmanahEditProfileResult? result = await AmanahEditProfileDrawer.show(
      context: context,
      doctorName: widget.user.fullName,
      initialPhone: _phone,
      initialEmail: _email,
      initialBio: _bio,
    );

    if (result != null && mounted) {
      setState(() {
        _phone = result.phone;
        _email = result.email;
        _bio = result.bio;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: <Widget>[
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Profil dokter berhasil diperbarui',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openAvatarPhotoSheet() async {
    final AmanahAvatarPhotoResult? result = await AmanahAvatarPhotoSheet.show(
      context,
    );

    if (result != null && mounted) {
      setState(() {
        if (result.isReset) {
          _customAvatarPath = null;
          _presetAvatarUrl = null;
        } else if (result.customImagePath != null) {
          _customAvatarPath = result.customImagePath;
          _presetAvatarUrl = null;
        } else if (result.presetAvatarUrl != null) {
          _presetAvatarUrl = result.presetAvatarUrl;
          _customAvatarPath = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: <Widget>[
              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Foto profil dokter berhasil diperbarui',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleOpenDoctorIdCard() {
    Navigator.of(context).push<void>(
      AmanahDoctorIdCardScreen.route(
        user: widget.user,
        profile: _doctorProfile,
      ),
    );
  }

  void _handleMenuItemTap(String id) {
    widget.onMenuItemTap(id);
    switch (id) {
      case 'account':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext ctx) => AmanahAccountIdentitySettingsScreen(
              user: widget.user,
              onBack: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
        break;
      case 'security':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext ctx) => AmanahPrivacySecuritySettingsScreen(
              onBack: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
        break;
      case 'data':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext ctx) => AmanahDataStorageSettingsScreen(
              onBack: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
        break;
      case 'help':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext ctx) => AmanahItSupportSettingsScreen(
              user: widget.user,
              onBack: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
        break;
      case 'idcard':
        _handleOpenDoctorIdCard();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = AmanahThemeTokens.canvas(context);

    return ColoredBox(
      color: bgColor,
      child: Column(
        children: <Widget>[
          // Pinned App Header (100% consistent with Home, Schedule, Permissions)
          AmanahScreenHeader(
            title: 'Profil Dokter',
            onBack: widget.onBack,
            titleAlignment: AmanahScreenHeaderTitleAlignment.start,
          ),

          // Scrollable Viewport with Pull-to-Refresh
          Expanded(
            child: AmanahPullToRefresh(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 900));
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.only(
                  bottom: 120 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Top Header Region with Medical Hero Illustration
                    _MedicalHeroBanner(
                      dark: dark,
                      onIdCardTap: _handleOpenDoctorIdCard,
                    ),

                    // 2. Signature Dual-Stack Profile Card (Stack 1 on Stack 2)
                    Transform.translate(
                      offset: const Offset(0, -56),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _DualStackProfileCard(
                          userName: widget.user.fullName,
                          roleText: 'Dokter Spesialis Anak',
                          phoneText: _phone,
                          customAvatarPath: _customAvatarPath,
                          presetAvatarUrl: _presetAvatarUrl,
                          dark: dark,
                          onEditTap: _openEditProfileDrawer,
                          onAvatarTap: _openAvatarPhotoSheet,
                          onLoyaltyTap: _handleOpenDoctorIdCard,
                        ),
                      ),
                    ),

                    // 3. Pixel-Perfect Winged Mail Banner (Email Sync Banner)
                    Transform.translate(
                      offset: const Offset(0, -42),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _WingedMailBanner(
                          email: _email,
                          isVerified: _isEmailVerified,
                          dark: dark,
                          onActionTap: _openEditProfileDrawer,
                          onVerifyTap: _handleVerifyEmail,
                          onToggleVerification: _handleToggleVerification,
                        ),
                      ),
                    ),

                    // 4. Grouped Preferences Menu List ("Preferensi")
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _PreferencesCard(
                          dark: dark,
                          onItemTap: _handleMenuItemTap,
                        ),
                      ),
                    ),

                    // 5. Logout Button
                    Transform.translate(
                      offset: const Offset(0, -14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _LogoutButton(onTap: widget.onLogout, dark: dark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPONENT 1: Medical Hero Banner with Canvas Vector Waves & Telehealth Artwork
// =============================================================================

class _MedicalHeroBanner extends StatelessWidget {
  const _MedicalHeroBanner({required this.dark, this.onIdCardTap});

  final bool dark;
  final VoidCallback? onIdCardTap;

  @override
  Widget build(BuildContext context) {
    const double bannerHeight = 148.0;

    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) {
          if (dark) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black,
                Color(0xCC000000), // 80%
                Color(0x40000000), // 25%
                Colors.transparent,
              ],
              stops: <double>[0.0, 0.45, 0.75, 1.0],
            ).createShader(bounds);
          } else {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x8A000000), // ~54% max opacity in light mode for non-contrasting soft look
                Color(0x70000000), // ~44%
                Color(0x20000000), // ~12%
                Colors.transparent,
              ],
              stops: <double>[0.0, 0.45, 0.75, 1.0],
            ).createShader(bounds);
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Background Vector Canvas: Grid, Waves, ECG Line, Sparkles
            Positioned.fill(
              child: CustomPaint(
                painter: _MedicalHeroIllustrationPainter(dark: dark),
              ),
            ),

            // Right Telehealth Tablet & Badges Illustration
            Positioned(
              right: 8,
              bottom: 24,
              child: _TelehealthArtwork(dark: dark, onTap: onIdCardTap),
            ),
          ],
        ),
      ),
    );
  }
}

/// Canvas Painter for the Medical Hero Illustration matching POC 1:1
class _MedicalHeroIllustrationPainter extends CustomPainter {
  const _MedicalHeroIllustrationPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // 1. Base Gradient Background
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? const <Color>[
                Color(0xFF060B18),
                Color(0xFF082F49),
                Color(0xFF0B1329),
              ]
            : const <Color>[
                Color(0xFFF0F9FF),
                Color(0xFFE0F2FE),
                Color(0xFFBAE6FD),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Clinical Medical Grid Pattern
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: dark ? 0.08 : 0.12)
      ..strokeWidth = 0.6;
    const double gridSize = 22.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Mid Fluid Medical Wave
    final Path midWave = Path()
      ..moveTo(-20, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.44,
        size.width * 0.52,
        size.height * 0.60,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.76,
        size.width + 20,
        size.height * 0.48,
      )
      ..lineTo(size.width + 20, size.height)
      ..lineTo(-20, size.height)
      ..close();

    final Paint midWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? <Color>[
                const Color(0xFF0E7490).withValues(alpha: 0.6),
                const Color(0xFF082F49).withValues(alpha: 0.8),
              ]
            : <Color>[
                const Color(0xFF38BDF8).withValues(alpha: 0.35),
                const Color(0xFF0EA5E9).withValues(alpha: 0.45),
              ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(midWave, midWavePaint);

    // 4. Foreground Deep Clinical Wave
    final Path deepWave = Path()
      ..moveTo(-20, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.58,
        size.width * 0.60,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.94,
        size.width + 20,
        size.height * 0.65,
      )
      ..lineTo(size.width + 20, size.height)
      ..lineTo(-20, size.height)
      ..close();

    final Paint deepWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const <Color>[Color(0xFF082F49), Color(0xFF060B18)]
            : <Color>[
                const Color(0xFF0284C7).withValues(alpha: 0.30),
                const Color(0xFF0369A1).withValues(alpha: 0.38),
              ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(deepWave, deepWavePaint);

    // 5. Glowing ECG Heartbeat Rhythm Line
    final double ecgY = size.height * 0.56;
    final Path ecgPath = Path()
      ..moveTo(-10, ecgY)
      ..lineTo(size.width * 0.20, ecgY)
      ..lineTo(size.width * 0.23, ecgY)
      ..lineTo(size.width * 0.25, ecgY - 14)
      ..lineTo(size.width * 0.27, ecgY + 16)
      ..lineTo(size.width * 0.29, ecgY - 34)
      ..lineTo(size.width * 0.31, ecgY + 18)
      ..lineTo(size.width * 0.33, ecgY - 6)
      ..lineTo(size.width * 0.35, ecgY)
      ..lineTo(size.width * 0.48, ecgY)
      ..lineTo(size.width * 0.50, ecgY - 13)
      ..lineTo(size.width * 0.52, ecgY + 10)
      ..lineTo(size.width * 0.54, ecgY - 24)
      ..lineTo(size.width * 0.56, ecgY + 11)
      ..lineTo(size.width * 0.58, ecgY - 5)
      ..lineTo(size.width * 0.60, ecgY)
      ..lineTo(size.width + 10, ecgY);

    final Paint ecgGlowPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[
          Color(0x3338BDF8),
          Color(0xFF00D3F2),
          Color(0xFF67E8F9),
          Color(0x3338BDF8),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(ecgPath, ecgGlowPaint);

    // 6. Pulse Node Dot Highlights
    final Paint pulsePaint = Paint()
      ..color = const Color(0xFF00D3F2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.29, ecgY - 34), 3.2, pulsePaint);
    canvas.drawCircle(
      Offset(size.width * 0.54, ecgY - 24),
      2.6,
      Paint()..color = const Color(0xFF67E8F9),
    );

    // 7. Floating Medical Plus Signs
    _drawPlusSign(
      canvas,
      Offset(size.width * 0.12, size.height * 0.26),
      7,
      const Color(0xFF00D3F2),
    );
    _drawPlusSign(
      canvas,
      Offset(size.width * 0.36, size.height * 0.18),
      6,
      const Color(0xFF38BDF8),
    );
    _drawPlusSign(
      canvas,
      Offset(size.width * 0.50, size.height * 0.28),
      5,
      Colors.white.withValues(alpha: 0.8),
    );
  }

  void _drawPlusSign(Canvas canvas, Offset center, double radius, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MedicalHeroIllustrationPainter oldDelegate) =>
      oldDelegate.dark != dark;
}

/// Telehealth Tablet Artwork matching POC's right hero elements
class _TelehealthArtwork extends StatelessWidget {
  const _TelehealthArtwork({required this.dark, this.onTap});

  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 175,
        height: 125,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Tilted Telehealth Tablet (-12 deg)
            Positioned(
              right: 18,
              top: 8,
              child: Transform.rotate(
                angle: -12 * math.pi / 180,
                child: Container(
                  width: 95,
                  height: 110,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: dark
                          ? const <Color>[Color(0xFF0369A1), Color(0xFF082F49)]
                          : const <Color>[Color(0xFF38BDF8), Color(0xFF0284C7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dark
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFBAE6FD),
                      width: 2,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: dark
                            ? Colors.black.withValues(alpha: 0.30)
                            : const Color(0xFF0284C7).withValues(alpha: 0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Tablet Speaker Notch
                      Container(
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),

                      // Tablet Clinical Screen
                      Container(
                        width: double.infinity,
                        height: 80,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: dark
                                ? const <Color>[
                                    Color(0xFF0F172A),
                                    Color(0xFF1E293B),
                                  ]
                                : const <Color>[
                                    Colors.white,
                                    Color(0xFFF0F9FF),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            // Heart / Stethoscope Icon Badge
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Color(0xFF0284C7),
                                    Color(0xFF38BDF8),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),

                            // Miniature Vitals Wave
                            SizedBox(
                              height: 10,
                              width: 55,
                              child: CustomPaint(painter: _MiniVitalsPainter()),
                            ),

                            // TeleCare Active Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF00D3F2,
                                ).withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(
                                    0xFF00D3F2,
                                  ).withValues(alpha: 0.60),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'TeleCare Active',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                  color: dark
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tablet Home Button Dot
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // First Aid Cross Badge (Top Left of Tablet)
            Positioned(
              left: 18,
              top: 8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF0284C7), Color(0xFF00D3F2)],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.80),
                    width: 1.2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            // Medical Shield Badge (Right of Tablet)
            Positioned(
              right: 2,
              top: 36,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF00D3F2), Color(0xFF0284C7)],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.80),
                    width: 1.2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniVitalsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(size.width * 0.30, size.height * 0.5)
      ..lineTo(size.width * 0.40, 0)
      ..lineTo(size.width * 0.50, size.height)
      ..lineTo(size.width * 0.60, size.height * 0.2)
      ..lineTo(size.width * 0.70, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.5);

    final Paint paint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// COMPONENT 2: Signature Dual-Stack Profile Card (Stack 1 on Stack 2)
// =============================================================================

class _DualStackProfileCard extends StatelessWidget {
  const _DualStackProfileCard({
    required this.userName,
    required this.roleText,
    required this.phoneText,
    required this.dark,
    required this.onEditTap,
    required this.onAvatarTap,
    required this.onLoyaltyTap,
    this.customAvatarPath,
    this.presetAvatarUrl,
  });

  final String userName;
  final String roleText;
  final String phoneText;
  final String? customAvatarPath;
  final String? presetAvatarUrl;
  final bool dark;
  final VoidCallback onEditTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onLoyaltyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AmanahThemeTokens.surfaceHighlight(context),
        border: Border.all(
          color: dark
              ? AmanahThemeTokens.outlineStrong(context)
              : AmanahColorTokens.brandMuted,
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.40)
                : const Color(0xFF0284C7).withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: <Widget>[
            AmanahPixelTexture(
              isDark: dark,
              opacity: dark ? 0.28 : 0.22,
              maskType: AmanahPixelMaskType.horizontalEdges,
            ),
            Column(
              children: <Widget>[
                // STACK 1: White / Dark Surface Profile Card overlapping Stack 2
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark
                        ? AmanahThemeTokens.surface(context)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: dark
                          ? AmanahThemeTokens.outline(context)
                          : const Color(0xFFE0F2FE),
                      width: 1,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: dark ? 0.35 : 0.06,
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      // Doctor Avatar (Clean, 56x56, tap to change)
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: dark
                                  ? AmanahColorTokens.brand
                                  : const Color(0xFFBAE6FD),
                              width: 2.2,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(child: _buildAvatar()),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Doctor Name and Contact Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: dark
                                    ? Colors.white
                                    : const Color(0xFF082F49),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$roleText • $phoneText',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: dark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pencil Edit Profile Button
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        iconSize: 20,
                        tooltip: 'Edit Profil',
                        style: IconButton.styleFrom(
                          backgroundColor: dark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFE0F2FE).withValues(alpha: 0.60),
                          foregroundColor: dark
                              ? const Color(0xFF67E8F9)
                              : const Color(0xFF082F49),
                        ),
                        onPressed: onEditTap,
                      ),
                    ],
                  ),
                ),

                // STACK 2: Bottom Loyalty / Status Tier Bar exposed beneath Stack 1
                InkWell(
                  onTap: onLoyaltyTap,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Left side: Badge icon + "SIP Terverifikasi"
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.verified_rounded,
                                size: 18,
                                color: dark
                                    ? const Color(0xFF67E8F9)
                                    : const Color(0xFF082F49),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'SIP Terverifikasi',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: dark
                                        ? Colors.white
                                        : const Color(0xFF082F49),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Right side: "Kartu ID Dokter" + circular button with arrow
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Kartu ID Dokter',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: dark
                                    ? const Color(0xFF67E8F9)
                                    : const Color(0xFF0369A1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dark
                                    ? AmanahColorTokens.tabActiveDark
                                    : const Color(0xFF082F49),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: dark
                                    ? const Color(0xFF082F49)
                                    : const Color(0xFF67E8F9),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildAvatar() {
    if (customAvatarPath != null) {
      return Image.file(
        File(customAvatarPath!),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (BuildContext ctx, Object err, StackTrace? st) =>
            _fallbackAvatar(),
      );
    }
    if (presetAvatarUrl != null) {
      return Image.network(
        presetAvatarUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (BuildContext ctx, Object err, StackTrace? st) =>
            _fallbackAvatar(),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    return Image.asset(
      'assets/amanah/auth/auth_background.png',
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (BuildContext ctx, Object err, StackTrace? st) => Container(
        color: const Color(0xFF0284C7),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
// =============================================================================
// COMPONENT 3: Pixel-Perfect Winged Mail Banner matching POC 1:1
// =============================================================================

class _WingedMailBanner extends StatelessWidget {
  const _WingedMailBanner({
    required this.email,
    required this.isVerified,
    required this.dark,
    required this.onActionTap,
    this.onVerifyTap,
    this.onToggleVerification,
  });

  final String email;
  final bool isVerified;
  final bool dark;
  final VoidCallback onActionTap;
  final VoidCallback? onVerifyTap;
  final VoidCallback? onToggleVerification;

  @override
  Widget build(BuildContext context) {
    final String titleText = isVerified
        ? 'Email terverifikasi'
        : 'Belum verifikasi email';

    final Color titleColor = isVerified
        ? (dark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1))
        : (dark ? const Color(0xFFFBBF24) : const Color(0xFFB45309));

    final IconData statusIcon = isVerified
        ? Icons.verified_rounded
        : Icons.mark_email_unread_outlined;

    final String buttonLabel = isVerified ? 'Perbarui' : 'Verifikasi email';

    return GestureDetector(
      onLongPress: onToggleVerification,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: dark
              ? (isVerified
                    ? const LinearGradient(
                        colors: <Color>[Color(0xFF0B1329), Color(0xFF0F1629)],
                      )
                    : const LinearGradient(
                        colors: <Color>[Color(0xFF1E170A), Color(0xFF191308)],
                      ))
              : (isVerified
                    ? const LinearGradient(
                        colors: <Color>[Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                      )
                    : const LinearGradient(
                        colors: <Color>[Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      )),
          border: Border.all(
            color: dark
                ? (isVerified
                      ? AmanahThemeTokens.outline(context)
                      : const Color(0xFF78350F))
                : (isVerified
                      ? const Color(0xFFBAE6FD)
                      : const Color(0xFFFDE68A)),
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: dark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFF0284C7).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            // Left: Descriptive copy & Action Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(statusIcon, size: 16, color: titleColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (email.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 3),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: dark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: isVerified
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: isVerified
                        ? onActionTap
                        : (onVerifyTap ?? onActionTap),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right: Pixel-Perfect Winged Mail Vector Illustration
            const SizedBox(
              width: 105,
              height: 90,
              child: CustomPaint(painter: _PixelPerfectWingedMailPainter()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Precise Vector Painter for the Winged Mail with golden wax seal and spring antenna
class _PixelPerfectWingedMailPainter extends CustomPainter {
  const _PixelPerfectWingedMailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Scale 120x110 design to available size
    final double scale = math.min(size.width / 120.0, size.height / 110.0);
    canvas.scale(scale, scale);
    canvas.translate(
      (size.width / scale - 120.0) / 2.0,
      (size.height / scale - 110.0) / 2.0,
    );

    // Warm Background Glow
    final Paint glowPaint = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(const Offset(68, 48), 28, glowPaint);

    // 1. Feathered Wings at Top
    // Left Wing (3 tiers)
    final Path leftWing = Path()
      ..moveTo(52, 31)
      ..cubicTo(45, 28, 38, 18, 34, 10)
      ..cubicTo(31, 6, 26, 8, 27, 13)
      ..cubicTo(28, 17, 31, 22, 33, 24)
      ..cubicTo(27, 21, 23, 23, 24, 27)
      ..cubicTo(25, 31, 29, 34, 35, 36)
      ..cubicTo(30, 35, 27, 38, 29, 42)
      ..cubicTo(32, 46, 40, 45, 52, 35)
      ..close();

    final Paint leftWingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFFFFF),
          Color(0xFFD5DBE3),
          Color(0xFFB4BECC),
        ],
      ).createShader(const Rect.fromLTWH(24, 10, 28, 36));
    canvas.drawPath(leftWing, leftWingPaint);

    final Paint wingStroke = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(leftWing, wingStroke);

    // Right Wing (mirrored 3 tiers)
    final Path rightWing = Path()
      ..moveTo(64, 31)
      ..cubicTo(71, 28, 78, 18, 82, 10)
      ..cubicTo(85, 6, 90, 8, 89, 13)
      ..cubicTo(88, 17, 85, 22, 83, 24)
      ..cubicTo(89, 21, 93, 23, 92, 27)
      ..cubicTo(91, 31, 87, 34, 81, 36)
      ..cubicTo(86, 35, 89, 38, 87, 42)
      ..cubicTo(84, 46, 76, 45, 64, 35)
      ..close();

    final Paint rightWingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFFFFF),
          Color(0xFFD5DBE3),
          Color(0xFFB4BECC),
        ],
      ).createShader(const Rect.fromLTWH(64, 10, 28, 36));
    canvas.drawPath(rightWing, rightWingPaint);
    canvas.drawPath(rightWing, wingStroke);

    // 2. Coiled Wire / Spring Antenna
    final Path antennaPath = Path()
      ..moveTo(58, 52)
      ..cubicTo(57, 46, 62, 44, 62, 40)
      ..cubicTo(62, 36, 53, 38, 54, 34)
      ..cubicTo(55, 30, 59, 31, 58, 27);

    final Paint antennaPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(antennaPath, antennaPaint);

    // 3. Tilted Envelope Body (-3 deg)
    canvas.save();
    canvas.translate(58, 74);
    canvas.rotate(-3 * math.pi / 180);
    canvas.translate(-58, -74);

    // Isometric dark blue top flap interior
    final Path topFlap = Path()
      ..moveTo(26, 47)
      ..lineTo(58, 31)
      ..lineTo(90, 47)
      ..lineTo(58, 63)
      ..close();
    final Paint flapPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFF0096C7), Color(0xFF0284C7)],
      ).createShader(const Rect.fromLTWH(26, 31, 64, 32));
    canvas.drawPath(topFlap, flapPaint);

    // Front envelope body
    final Path frontBody = Path()
      ..moveTo(24, 48)
      ..lineTo(58, 64)
      ..lineTo(92, 48)
      ..lineTo(92, 84)
      ..cubicTo(92, 88, 88, 91, 84, 91)
      ..lineTo(32, 91)
      ..cubicTo(28, 91, 24, 88, 24, 84)
      ..close();

    final Paint bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFBBF2F6), Color(0xFF8DE0F7)],
      ).createShader(const Rect.fromLTWH(24, 48, 68, 43));
    canvas.drawPath(frontBody, bodyPaint);

    final Paint bodyStroke = Paint()
      ..color = const Color(0xFF74C5E3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(frontBody, bodyStroke);

    // Envelope fold creases
    final Paint foldPaint = Paint()
      ..color = const Color(0xFF0090C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path folds = Path()
      ..moveTo(24, 49)
      ..lineTo(58, 73)
      ..lineTo(92, 49);
    canvas.drawPath(folds, foldPaint);
    canvas.drawLine(const Offset(25, 89), const Offset(46, 72), foldPaint);
    canvas.drawLine(const Offset(91, 89), const Offset(70, 72), foldPaint);

    // 4. Golden Wax Seal with white @ emblem
    final Paint sealOuter = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFFFBBF24), Color(0xFFF59E0B)],
      ).createShader(const Rect.fromLTWH(46, 61, 24, 24));
    canvas.drawCircle(const Offset(58, 73), 12, sealOuter);

    final Paint sealBorder = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(const Offset(58, 73), 12, sealBorder);

    final Paint sealInnerRing = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(const Offset(58, 73), 10, sealInnerRing);

    // White @ Text Symbol
    const TextSpan span = TextSpan(
      text: '@',
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12.5,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(58 - tp.width / 2, 73 - tp.height / 2));

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// COMPONENT 4: Grouped Preferences Menu List ("Preferensi")
// =============================================================================

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.dark, required this.onItemTap});

  final bool dark;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Preferensi',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: dark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: dark ? AmanahThemeTokens.surface(context) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: dark
                  ? AmanahThemeTokens.outline(context)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.35 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              children: <Widget>[
                _PreferenceRowItem(
                  icon: Icons.shield_outlined,
                  title: 'Keamanan akun & PIN',
                  badgeText: 'PIN Aktif',
                  badgeColor: const Color(0xFF10B981),
                  dark: dark,
                  onTap: () => onItemTap('security'),
                ),
                _divider(context),
                _PreferenceRowItem(
                  icon: Icons.badge_outlined,
                  title: 'Akun & identitas dokter',
                  badgeText: 'Terverifikasi',
                  badgeColor: const Color(0xFF0284C7),
                  dark: dark,
                  onTap: () => onItemTap('account'),
                ),
                _divider(context),
                _PreferenceRowItem(
                  icon: Icons.storage_rounded,
                  title: 'Data & penyimpanan laporan',
                  dark: dark,
                  onTap: () => onItemTap('data'),
                ),
                _divider(context),
                _PreferenceRowItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Bantuan teknisi IT RS',
                  badgeText: 'Online 24 Jam',
                  badgeColor: const Color(0xFF0D66E9),
                  dark: dark,
                  onTap: () => onItemTap('help'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    color: AmanahThemeTokens.divider(context),
  );
}

class _PreferenceRowItem extends StatelessWidget {
  const _PreferenceRowItem({
    required this.icon,
    required this.title,
    required this.dark,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
  });

  final IconData icon;
  final String title;
  final String? badgeText;
  final Color? badgeColor;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              // Icon in brand color
              Icon(icon, size: 20, color: const Color(0xFF0284C7)),
              const SizedBox(width: 14),

              // Title and Badge
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: dark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (badgeText != null) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? const Color(0xFF0284C7))
                              .withValues(alpha: dark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText!,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: badgeColor ?? const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing Chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// COMPONENT 5: Clean Logout Action Button
// =============================================================================

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap, required this.dark});

  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: AmanahButton.ghost(
        text: 'Keluar dari Akun Dokter',
        leadingIcon: Icons.logout_rounded,
        isFullWidth: true,
        customForegroundColor: dark
            ? AmanahColorTokens.dangerBorder
            : AmanahColorTokens.dangerDark,
        semanticsLabel: 'Keluar dari Akun Dokter',
        onPressed: onTap,
      ),
    );
  }
}
