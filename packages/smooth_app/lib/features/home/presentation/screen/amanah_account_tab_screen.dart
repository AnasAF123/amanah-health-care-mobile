import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';

class AmanahAccountTabScreen extends StatelessWidget {
  const AmanahAccountTabScreen({
    required this.user,
    required this.onMenuItemTap,
    required this.onLogout,
    super.key,
  });

  final AmanahAuthUser user;
  final ValueChanged<String> onMenuItemTap;
  final VoidCallback onLogout;

  static const List<({String id, String label, String? detail, IconData icon})>
      _menuItems = <({String id, String label, String? detail, IconData icon})>[
    (
      id: 'sip',
      label: 'Surat Izin Praktek (SIP)',
      detail: 'SIP: 446/1029/DS/2024',
      icon: Icons.assignment_ind_outlined,
    ),
    (
      id: 'specialist',
      label: 'Spesialisasi & Sertifikasi',
      detail: 'Ikatan Dokter Anak Indonesia (IDAI)',
      icon: Icons.workspace_premium_outlined,
    ),
    (
      id: 'security',
      label: 'Keamanan & PIN Presensi',
      detail: null,
      icon: Icons.lock_outline_rounded,
    ),
    (
      id: 'privacy',
      label: 'Privasi Data Rekam Medis',
      detail: null,
      icon: Icons.shield_outlined,
    ),
    (
      id: 'help',
      label: 'Pusat Bantuan & IT Support',
      detail: null,
      icon: Icons.help_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Scenic Nature Banner with Gradient Fade & Doctor Avatar
          _AccountHeaderBanner(
            doctorName: user.fullName,
            doctorRole: amanahHomeDashboardData.profile.role,
            dark: dark,
          ),

          // 2. Settings Menu List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < _menuItems.length; i++) ...<Widget>[
                  _AccountMenuItemTile(
                    item: _menuItems[i],
                    dark: dark,
                    onTap: () => onMenuItemTap(_menuItems[i].id),
                  ),
                  if (i < _menuItems.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: dark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF1F5F9),
                    ),
                ],
                const SizedBox(height: 28),

                // 3. Logout Action Button
                _LogoutButton(
                  onTap: onLogout,
                  dark: dark,
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountHeaderBanner extends StatelessWidget {
  const _AccountHeaderBanner({
    required this.doctorName,
    required this.doctorRole,
    required this.dark,
  });

  final String doctorName;
  final String doctorRole;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color solidBg = dark ? const Color(0xFF0A0E1A) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Top Nature Banner Stack
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // Scenic Mountain / Forest Nature Background
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
                        solidBg.withValues(alpha: 0.40),
                        solidBg,
                      ],
                    ),
                  ),
                ),
              ),

              // Overlapping Doctor Avatar with Pure White Ring
              Positioned(
                bottom: -36,
                left: 20,
                child: Container(
                  width: 76,
                  height: 76,
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
                          alpha: dark ? 0.40 : 0.12,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/amanah/auth/auth_background.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return Container(
                          color: const Color(0xFF0A44FF).withValues(alpha: 0.2),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF0A44FF),
                            size: 36,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Doctor Name, Role & Hospital Metadata
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                doctorName,
                style: TextStyle(
                  color: dark ? Colors.white : const Color(0xFF0F172A),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctorRole,
                style: const TextStyle(
                  color: Color(0xFF00B4D8), // Vibrant cyan-blue from design
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'ID: DOC-2026-0819',
                      style: TextStyle(
                        color: dark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF94A3B8),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 1,
                        height: 12,
                        color: dark
                            ? Colors.white.withValues(alpha: 0.20)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    Text(
                      'RS Amanah Sehat',
                      style: TextStyle(
                        color: dark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF94A3B8),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountMenuItemTile extends StatelessWidget {
  const _AccountMenuItemTile({
    required this.item,
    required this.dark,
    required this.onTap,
  });

  final ({String id, String label, String? detail, IconData icon}) item;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: <Widget>[
              // Leading Icon Container
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF0F224A)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 18,
                  color: dark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0A44FF),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Optional Detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.label,
                      style: TextStyle(
                        color: dark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (item.detail != null) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        item.detail!,
                        style: TextStyle(
                          color: dark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF94A3B8),
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing Chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: dark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
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
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                  : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: dark
                    ? const Color(0xFFEF4444).withValues(alpha: 0.30)
                    : const Color(0xFFFECDD3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.logout_rounded,
                  size: 18,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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
