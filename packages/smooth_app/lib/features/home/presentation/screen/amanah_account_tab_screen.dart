import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_clay_icon.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_edit_profile_drawer.dart';

class AmanahSettingsItemData {
  const AmanahSettingsItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colorPrimary,
    required this.colorLight,
    required this.colorDark,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color colorPrimary;
  final Color colorLight;
  final Color colorDark;
  final IconData icon;
}

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
  late String _phone;
  late String _email;
  late String _bio;
  String? _customAvatarPath;
  String? _presetAvatarUrl;

  static const List<AmanahSettingsItemData> _settingsItems =
      <AmanahSettingsItemData>[
    AmanahSettingsItemData(
      id: 'account',
      title: 'Akun & Identitas Dokter',
      subtitle: 'SIP, STR, NIK, Bio Medis',
      colorPrimary: Color(0xFF2563EB),
      colorLight: Color(0xFF60A5FA),
      colorDark: Color(0xFF1D4ED8),
      icon: Icons.person_outline_rounded,
    ),
    AmanahSettingsItemData(
      id: 'practice',
      title: 'Pengaturan Praktik & Shift',
      subtitle: 'Poli Spesialis, Kuota Pasien, Jadwal',
      colorPrimary: Color(0xFFF59E0B),
      colorLight: Color(0xFFFCD34D),
      colorDark: Color(0xFFD97706),
      icon: Icons.calendar_today_outlined,
    ),
    AmanahSettingsItemData(
      id: 'security',
      title: 'Privasi & Keamanan',
      subtitle: 'PIN Presensi, Biometrik, Akses Data',
      colorPrimary: Color(0xFF10B981),
      colorLight: Color(0xFF6EE7B7),
      colorDark: Color(0xFF059669),
      icon: Icons.verified_user_outlined,
    ),
    AmanahSettingsItemData(
      id: 'notifications',
      title: 'Notifikasi & Pengingat',
      subtitle: 'Panggilan Darurat IGD, Suara, Alarm Shift',
      colorPrimary: Color(0xFFEF4444),
      colorLight: Color(0xFFFCA5A5),
      colorDark: Color(0xFFDC2626),
      icon: Icons.notifications_none_rounded,
    ),
    AmanahSettingsItemData(
      id: 'data',
      title: 'Data & Penyimpanan',
      subtitle: 'Unduh Laporan PDF, Cache SIMRS',
      colorPrimary: Color(0xFF3B82F6),
      colorLight: Color(0xFF93C5FD),
      colorDark: Color(0xFF1E40AF),
      icon: Icons.storage_rounded,
    ),
    AmanahSettingsItemData(
      id: 'documents',
      title: 'Dokumen & Sertifikasi',
      subtitle: 'SIP Aktif, STR KKI, IDAI',
      colorPrimary: Color(0xFF06B6D4),
      colorLight: Color(0xFF67E8F9),
      colorDark: Color(0xFF0891B2),
      icon: Icons.description_outlined,
    ),
    AmanahSettingsItemData(
      id: 'devices',
      title: 'Perangkat Terhubung',
      subtitle: 'Mobile App, Tablet Poli, Desktop RS',
      colorPrimary: Color(0xFF14B8A6),
      colorLight: Color(0xFF5EEAD4),
      colorDark: Color(0xFF0F766E),
      icon: Icons.devices_rounded,
    ),
    AmanahSettingsItemData(
      id: 'help',
      title: 'Bantuan & IT Support',
      subtitle: 'Helpdesk SIMRS, Panduan Presensi',
      colorPrimary: Color(0xFF8B5CF6),
      colorLight: Color(0xFFC4B5FD),
      colorDark: Color(0xFF6D28D9),
      icon: Icons.help_outline_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _phone = '+62 812-3456-7890';
    _email = 'rayhan.pratama@rsamanah.co.id';
    _bio =
        'Dokter Spesialis Anak di RS Amanah Sehat, melayani konsultasi rawat jalan & rawat inap anak.';
  }

  Future<void> _openEditProfileDrawer() async {
    final AmanahEditProfileResult? result =
        await AmanahEditProfileDrawer.show(
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
    final AmanahAvatarPhotoResult? result =
        await AmanahAvatarPhotoSheet.show(context);

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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor =
        dark ? const Color(0xFF0A0E1A) : const Color(0xFFF8FAFF);
    final Color cardBg =
        dark ? const Color(0xFF111624) : const Color(0xFFFFFFFF);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor =
        dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color dividerColor = dark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF1F5F9);

    return ColoredBox(
      color: bgColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Full-Bleed Nature Masked Profile Header
            _AccountHeaderBanner(
              doctorName: widget.user.fullName,
              doctorRole: 'Dokter Spesialis Anak',
              doctorBio: _bio,
              customAvatarPath: _customAvatarPath,
              presetAvatarUrl: _presetAvatarUrl,
              dark: dark,
              onBack: widget.onBack,
              onEditProfile: _openEditProfileDrawer,
              onChangePhoto: _openAvatarPhotoSheet,
            ),

            // 2. Settings Items Container (3D ClayIcon Style in Rounded-3xl Card)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: dark ? 0.40 : 0.04,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        children: <Widget>[
                          for (int i = 0; i < _settingsItems.length; i++) ...<Widget>[
                            _SettingsItemRow(
                              item: _settingsItems[i],
                              dark: dark,
                              textColor: textColor,
                              subtextColor: subtextColor,
                              onTap: () {
                                if (_settingsItems[i].id == 'account') {
                                  _openEditProfileDrawer();
                                } else {
                                  widget.onMenuItemTap(_settingsItems[i].id);
                                }
                              },
                            ),
                            if (i < _settingsItems.length - 1)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: dividerColor,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Logout Action Button
                  _LogoutButton(
                    onTap: widget.onLogout,
                    dark: dark,
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

class _AccountHeaderBanner extends StatelessWidget {
  const _AccountHeaderBanner({
    required this.doctorName,
    required this.doctorRole,
    required this.doctorBio,
    required this.customAvatarPath,
    required this.presetAvatarUrl,
    required this.dark,
    required this.onEditProfile,
    required this.onChangePhoto,
    this.onBack,
  });

  final String doctorName;
  final String doctorRole;
  final String doctorBio;
  final String? customAvatarPath;
  final String? presetAvatarUrl;
  final bool dark;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePhoto;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final Color solidBg = dark ? const Color(0xFF0A0E1A) : Colors.white;
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor =
        dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      color: solidBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Scenic Nature Cover Photo with Linear Mask
          SizedBox(
            height: 135,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned.fill(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=800&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              Color(0xFF1E3A8A),
                              Color(0xFF0284C7),
                              Color(0xFF38BDF8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Smooth Linear Gradient Fade to bottom
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const <double>[0.15, 0.65, 1.0],
                        colors: <Color>[
                          Colors.transparent,
                          solidBg.withValues(alpha: 0.30),
                          solidBg,
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating Liquid Glassmorphism Back Button
                if (onBack != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dark
                              ? Colors.black.withValues(alpha: 0.40)
                              : Colors.white.withValues(alpha: 0.75),
                          border: Border.all(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.20)
                                : Colors.white.withValues(alpha: 0.80),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 20,
                          color: dark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Profile Identity Body
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Overlapping Avatar with Pure White Ring and Floating Camera Button
                Transform.translate(
                  offset: const Offset(0, -36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          // Avatar Container 74x74
                          InkWell(
                            onTap: onChangePhoto,
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: solidBg,
                                border: Border.all(
                                  color: solidBg,
                                  width: 4,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: dark ? 0.50 : 0.15,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _buildAvatarImage(),
                              ),
                            ),
                          ),

                          // Floating Camera Button (28x28, #2AABEE, 2px ring)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: onChangePhoto,
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF2AABEE),
                                  border: Border.all(
                                    color: solidBg,
                                    width: 2,
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.20,
                                      ),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Doctor Name & Role
                      Text(
                        doctorName,
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctorRole,
                        style: TextStyle(
                          color: dark
                              ? const Color(0xFF22D3EE)
                              : const Color(0xFF0891B2),
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Doctor Bio
                      if (doctorBio.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(
                          doctorBio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: dark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF475569),
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Sub-row: ID Metadata & Compose [Pencil + Text] Edit Profil Trigger
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'ID: DOC-2026-0819 • RS Amanah Sehat',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: subtextColor,
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Compose: [Leading Icon + Text] Edit Profil
                          InkWell(
                            onTap: onEditProfile,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 13,
                                    color: dark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF2563EB),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Edit Profil',
                                    style: TextStyle(
                                      color: dark
                                          ? const Color(0xFF38BDF8)
                                          : const Color(0xFF2563EB),
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (customAvatarPath != null) {
      return Image.file(
        File(customAvatarPath!),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (BuildContext ctx, Object err, StackTrace? st) {
          return Image.asset(
            'assets/amanah/auth/auth_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          );
        },
      );
    }
    if (presetAvatarUrl != null) {
      return Image.network(
        presetAvatarUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (BuildContext ctx, Object err, StackTrace? st) {
          return Image.asset(
            'assets/amanah/auth/auth_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          );
        },
      );
    }
    return Image.asset(
      'assets/amanah/auth/auth_background.png',
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (BuildContext ctx, Object err, StackTrace? st) {
        return const Icon(
          Icons.person_rounded,
          color: Color(0xFF0A44FF),
          size: 36,
        );
      },
    );
  }
}

class _SettingsItemRow extends StatelessWidget {
  const _SettingsItemRow({
    required this.item,
    required this.dark,
    required this.textColor,
    required this.subtextColor,
    required this.onTap,
  });

  final AmanahSettingsItemData item;
  final bool dark;
  final Color textColor;
  final Color subtextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              // Left: 3D ClayIcon Badge without glow
              AmanahClayIcon(
                icon: item.icon,
                colorPrimary: item.colorPrimary,
                colorLight: item.colorLight,
                colorDark: item.colorDark,
                size: 28,
              ),
              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subtextColor,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Subtle Trailing Chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: subtextColor.withValues(alpha: 0.50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.onTap,
    required this.dark,
  });

  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Keluar dari Akun Dokter',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                  : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: dark
                    ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                    : const Color(0xFFFECDD3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.logout_rounded,
                  size: 16,
                  color: dark
                      ? const Color(0xFFF87171)
                      : const Color(0xFFE11D48),
                ),
                const SizedBox(width: 8),
                Text(
                  'Keluar dari Akun Dokter',
                  style: TextStyle(
                    color: dark
                        ? const Color(0xFFF87171)
                        : const Color(0xFFE11D48),
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
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
