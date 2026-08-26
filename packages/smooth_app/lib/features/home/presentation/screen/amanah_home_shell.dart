import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_bottom_navigation_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_home_app_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_quick_access_section.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_schedule_card_stack.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_today_activity_section.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_account_tab_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_schedule_tab_screen.dart';
import 'package:smooth_app/features/presence/presentation/screen/amanah_presence_history_screen.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AmanahHomeShell extends StatefulWidget {
  const AmanahHomeShell({required this.user, this.onLogout, super.key});

  final AmanahAuthUser user;
  final VoidCallback? onLogout;

  @override
  State<AmanahHomeShell> createState() => _AmanahHomeShellState();
}

class _AmanahHomeShellState extends State<AmanahHomeShell> {
  AmanahHomeTab _selectedTab = AmanahHomeTab.home;
  String? _toastMessage;
  Timer? _toastTimer;

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
    });
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  void _handleLogout() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final bool dark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: dark ? const Color(0xFF171717) : Colors.white,
          title: Text(
            'Konfirmasi Keluar',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun dokter?',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showToast('Berhasil keluar dari akun dokter');
                if (widget.onLogout != null) {
                  widget.onLogout?.call();
                } else if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleQuickAction(String actionId) {
    switch (actionId) {
      case 'history':
      case 'presensi':
        Navigator.of(context).push(AmanahPresenceHistoryScreen.route());
      case 'jadwal-saya':
        setState(() => _selectedTab = AmanahHomeTab.schedule);
      case 'cari-visit':
        _showToast('Membuka menu Cari Visit Pasien');
      case 'kartu-id':
        setState(() => _selectedTab = AmanahHomeTab.account);
      default:
        _showToast('Fitur segera hadir');
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor = dark
        ? const Color(0xFF0A0E1A)
        : (_selectedTab == AmanahHomeTab.home
              ? const Color(0xFFF8FAFF)
              : Colors.white);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: Stack(
        children: <Widget>[
          // Dynamic Aurora Ambient Glow (265px reaching slightly past the middle of schedule card)
          if (_selectedTab == AmanahHomeTab.home)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 265,
              child: _AmanahHomeAuroraBackground(dark: dark),
            ),

          // Main Viewport Container
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: switch (_selectedTab) {
                AmanahHomeTab.home => _AmanahHomeScreenContent(
                  key: const ValueKey<String>('home_content'),
                  user: widget.user,
                  data: amanahHomeDashboardData,
                  onNotificationTap: () {
                    setState(() => _selectedTab = AmanahHomeTab.notifications);
                  },
                  onProfileTap: () {
                    setState(() => _selectedTab = AmanahHomeTab.account);
                  },
                  onQuickActionTap: (AmanahQuickAction action) {
                    _handleQuickAction(action.id);
                  },
                  onDetailActivityTap: () {
                    setState(() => _selectedTab = AmanahHomeTab.schedule);
                  },
                  onActivityTap: (AmanahActivityMetric activity) {
                    _showToast('Membuka rincian aktivitas');
                  },
                ),
                AmanahHomeTab.schedule => AmanahScheduleTabScreen(
                  key: const ValueKey<String>('schedule_content'),
                  onBack: () {
                    setState(() => _selectedTab = AmanahHomeTab.home);
                  },
                ),
                AmanahHomeTab.account => AmanahAccountTabScreen(
                  key: const ValueKey<String>('account_content'),
                  user: widget.user,
                  onMenuItemTap: (String id) {
                    _showToast('Membuka menu $id');
                  },
                  onLogout: _handleLogout,
                ),
                _ => _AmanahPlaceholderPage(
                  key: ValueKey<AmanahHomeTab>(_selectedTab),
                  tab: _selectedTab,
                  user: widget.user,
                  onBackToHome: () {
                    setState(() => _selectedTab = AmanahHomeTab.home);
                  },
                ),
              },
            ),
          ),

          // Ephemeral Toast Banner
          if (_toastMessage != null)
            Positioned(
              top: 60,
              left: 24,
              right: 24,
              child: Center(
                child: _AmanahEphemeralToast(message: _toastMessage!),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AmanahBottomNavigationBar(
        selectedTab: _selectedTab,
        onTabSelected: (AmanahHomeTab tab) {
          setState(() => _selectedTab = tab);
        },
      ),
    );
  }
}

class _AmanahHomeScreenContent extends StatelessWidget {
  const _AmanahHomeScreenContent({
    required this.user,
    required this.data,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.onQuickActionTap,
    required this.onDetailActivityTap,
    required this.onActivityTap,
    super.key,
  });

  final AmanahAuthUser user;
  final AmanahHomeDashboardData data;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final ValueChanged<AmanahQuickAction> onQuickActionTap;
  final VoidCallback onDetailActivityTap;
  final ValueChanged<AmanahActivityMetric> onActivityTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: <Widget>[
        // 1. Doctor Profile Header
        AmanahHomeAppBar(
          user: user,
          greeting: data.profile.greeting,
          unreadNotifications: data.profile.unreadNotifications,
          onNotificationTap: onNotificationTap,
          onProfileTap: onProfileTap,
        ),
        const SizedBox(height: 10),

        // 2. 3D Stack of Schedule Cards with Staggered Depth & Wave Petal Texture
        AmanahScheduleCardStack(schedules: data.schedules),
        const SizedBox(height: 16),

        // 3. Quick Access Menu Grid (Raised closer to the card stack)
        AmanahQuickAccessSection(
          actions: data.quickActions,
          onActionTap: onQuickActionTap,
        ),
        const SizedBox(height: 38),

        // 4. Today's Activity Stat Cards
        AmanahTodayActivitySection(
          activities: data.activities,
          onDetailTap: onDetailActivityTap,
          onActivityTap: onActivityTap,
        ),
      ],
    );
  }
}

class _AmanahEphemeralToast extends StatelessWidget {
  const _AmanahEphemeralToast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xE6171717),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _AmanahPlaceholderPage extends StatelessWidget {
  const _AmanahPlaceholderPage({
    required this.tab,
    required this.user,
    required this.onBackToHome,
    super.key,
  });

  final AmanahHomeTab tab;
  final AmanahAuthUser user;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final _AmanahPageCopy copy = _copyForTab(tab);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 126),
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: onBackToHome,
              color: dark ? Colors.white : const Color(0xFF1E293B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Amanah Healthcare',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: VERY_SMALL_SPACE),
                  Text(
                    copy.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: dark ? Colors.white : theme.colorScheme.onSurface,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                ],
              ),
            ),
            _AmanahUserAvatar(user: user),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          copy.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: dark
                ? const Color(0xFF94A3B8)
                : theme.colorScheme.onSurface.withValues(alpha: 0.58),
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        _AmanahFeaturePlaceholder(copy: copy),
      ],
    );
  }

  _AmanahPageCopy _copyForTab(AmanahHomeTab tab) {
    return switch (tab) {
      AmanahHomeTab.home => const _AmanahPageCopy(
        title: 'Home',
        description:
            'Ringkasan layanan klinik, jadwal, presensi, dan informasi harian akan ditempatkan di sini.',
        icon: Icons.home_rounded,
      ),
      AmanahHomeTab.schedule => const _AmanahPageCopy(
        title: 'Jadwal Dokter',
        description: 'Kelola jadwal praktik, antrean poliklinik, dan visit.',
        icon: Icons.calendar_today_rounded,
      ),
      AmanahHomeTab.scan => const _AmanahPageCopy(
        title: 'Presensi QR',
        description: 'Arahkan kamera ke QR terminal poliklinik untuk presensi.',
        icon: Icons.qr_code_2_rounded,
      ),
      AmanahHomeTab.notifications => const _AmanahPageCopy(
        title: 'Pusat Notifikasi',
        description:
            'Pemberitahuan darurat, antrean baru, dan pesan internal klinik.',
        icon: Icons.notifications_rounded,
      ),
      AmanahHomeTab.account => const _AmanahPageCopy(
        title: 'Profil & Kartu ID',
        description:
            'Informasi SIP/STR, spesialisasi dokter, dan pengaturan akun.',
        icon: Icons.person_rounded,
      ),
    };
  }
}

class _AmanahHomeAuroraBackground extends StatelessWidget {
  const _AmanahHomeAuroraBackground({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _AmanahHomeAuroraPainter(dark: dark)),
    );
  }
}

class _AmanahHomeAuroraPainter extends CustomPainter {
  const _AmanahHomeAuroraPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect topMask = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.saveLayer(topMask, Paint());

    // 1. Deep Blue Base (Atmospheric glow behind App Bar and top of schedule card)
    final Paint blueGlow = Paint()
      ..color = (dark ? const Color(0xFF07247A) : const Color(0xFF0A44FF))
          .withValues(alpha: dark ? 0.70 : 0.76)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.25, 40),
        width: size.width * 1.40,
        height: 360,
      ),
      blueGlow,
    );

    // 2. Vibrant Cyan Glow (Radiant cyan glow in upper right)
    final Paint cyanGlow = Paint()
      ..color = (dark ? const Color(0xFF0088CC) : const Color(0xFF00D4FF))
          .withValues(alpha: dark ? 0.55 : 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.85, 60),
        width: size.width * 1.10,
        height: 300,
      ),
      cyanGlow,
    );

    // 3. Smooth Integration Mask (Full color at top, fading just past the middle of schedule card)
    final Paint fadePaint = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Colors.black, Colors.black, Colors.transparent],
        stops: <double>[0, 0.50, 1],
      ).createShader(topMask);
    canvas.drawRect(topMask, fadePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AmanahHomeAuroraPainter oldDelegate) => true;
}

class _AmanahUserAvatar extends StatelessWidget {
  const _AmanahUserAvatar({required this.user});

  final AmanahAuthUser user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String name = user.fullName.trim();
    final String initial = name.isEmpty
        ? 'A'
        : name.substring(0, 1).toUpperCase();

    return Semantics(
      label: 'Profil ${user.fullName}',
      child: CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
        child: Text(
          initial,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AmanahFeaturePlaceholder extends StatelessWidget {
  const _AmanahFeaturePlaceholder({required this.copy});

  final _AmanahPageCopy copy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? const Color(0xE6171717) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.15)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.52),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.36 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(copy.icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: LARGE_SPACE),
            Text(
              'Placeholder ${copy.title}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: dark ? Colors.white : theme.colorScheme.onSurface,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: SMALL_SPACE),
            Text(
              'Konten halaman ini akan diisi setelah struktur navigasi final.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: dark
                    ? const Color(0xFF94A3B8)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.52),
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmanahPageCopy {
  const _AmanahPageCopy({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
