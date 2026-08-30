import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/domain/amanah_notification_model.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_bottom_navigation_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_home_app_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_quick_access_section.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_schedule_card_stack.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_today_activity_section.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_account_tab_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_doctor_id_card_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_notification_tab_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_queue_dock_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_schedule_tab_screen.dart';
import 'package:smooth_app/features/presence/presentation/screen/amanah_presence_history_screen.dart';
import 'package:smooth_app/features/presence/presentation/screen/amanah_qr_scanner_tab_screen.dart';
import 'package:smooth_app/features/schedule/data/amanah_schedule_store.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';

class AmanahHomeShell extends StatefulWidget {
  const AmanahHomeShell({required this.user, this.onLogout, super.key});

  final AmanahAuthUser user;
  final VoidCallback? onLogout;

  @override
  State<AmanahHomeShell> createState() => _AmanahHomeShellState();
}

class _AmanahHomeShellState extends State<AmanahHomeShell> {
  final AmanahScheduleStore _scheduleStore = AmanahScheduleStore.instance;
  final AmanahNotificationStore _notificationStore =
      AmanahNotificationStore.instance;
  AmanahHomeTab _selectedTab = AmanahHomeTab.home;
  String? _toastMessage;
  Timer? _toastTimer;
  String? _scheduleInitialSessionId;
  AmanahScheduleViewMode? _scheduleInitialViewMode;
  bool _scheduleOpenDetailOnLaunch = false;

  @override
  void initState() {
    super.initState();
    _scheduleStore.addListener(_onStoreUpdated);
    _notificationStore.addListener(_onStoreUpdated);
  }

  void _onStoreUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

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
        setState(() {
          _scheduleInitialSessionId = null;
          _scheduleInitialViewMode = AmanahScheduleViewMode.sessions;
          _scheduleOpenDetailOnLaunch = false;
          _selectedTab = AmanahHomeTab.schedule;
        });
      case 'pilih-antrean':
      case 'cari-visit':
        Navigator.of(context).push(AmanahQueueDockScreen.route());
      case 'kartu-id':
        Navigator.of(context).push(
          AmanahDoctorIdCardScreen.route(
            user: widget.user,
            profile: amanahHomeDashboardData.profile,
          ),
        );
      default:
        _showToast('Fitur segera hadir');
    }
  }

  void _navigateToScheduleWithSession(DoctorSchedule schedule) {
    setState(() {
      _scheduleInitialSessionId = schedule.id;
      _scheduleInitialViewMode = AmanahScheduleViewMode.overview;
      _scheduleOpenDetailOnLaunch = false;
      _selectedTab = AmanahHomeTab.schedule;
    });
  }

  @override
  void dispose() {
    _scheduleStore.removeListener(_onStoreUpdated);
    _notificationStore.removeListener(_onStoreUpdated);
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

    final List<DoctorSchedule> todaySchedules = _scheduleStore
        .getSchedulesForDate(AmanahScheduleStore.baseToday);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: Stack(
        children: <Widget>[
          // Dynamic Aurora Ambient Glow (480px extended reach with fade starting at Poli Gigi & Mulut row)
          if (_selectedTab == AmanahHomeTab.home)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 480,
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
                  todaySchedules: todaySchedules,
                  unreadNotifications: _notificationStore.unreadCount,
                  onNotificationTap: () {
                    setState(() => _selectedTab = AmanahHomeTab.notifications);
                  },
                  onProfileTap: () {
                    setState(() => _selectedTab = AmanahHomeTab.account);
                  },
                  onQuickActionTap: (AmanahQuickAction action) {
                    _handleQuickAction(action.id);
                  },
                  onScheduleCardTap: _navigateToScheduleWithSession,
                  onDetailActivityTap: () {
                    setState(() {
                      _scheduleInitialSessionId = null;
                      _scheduleInitialViewMode =
                          AmanahScheduleViewMode.overview;
                      _scheduleOpenDetailOnLaunch = false;
                      _selectedTab = AmanahHomeTab.schedule;
                    });
                  },
                  onActivityTap: (AmanahActivityMetric activity) {
                    _showToast('Membuka rincian aktivitas');
                  },
                ),
                AmanahHomeTab.schedule => AmanahScheduleTabScreen(
                  key: ValueKey<String>(
                    'schedule_content_${_scheduleInitialSessionId ?? "all"}_${_scheduleInitialViewMode?.name ?? "default"}',
                  ),
                  initialSessionId: _scheduleInitialSessionId,
                  initialViewMode: _scheduleInitialViewMode,
                  openDetailOnLaunch: _scheduleOpenDetailOnLaunch,
                  onBack: () {
                    setState(() {
                      _scheduleInitialSessionId = null;
                      _scheduleInitialViewMode = null;
                      _scheduleOpenDetailOnLaunch = false;
                      _selectedTab = AmanahHomeTab.home;
                    });
                  },
                ),
                AmanahHomeTab.scan => AmanahQrScannerTabScreen(
                  key: const ValueKey<String>('scan_content'),
                  user: widget.user,
                  onBack: () {
                    setState(() => _selectedTab = AmanahHomeTab.home);
                  },
                ),
                AmanahHomeTab.notifications => AmanahNotificationTabScreen(
                  key: const ValueKey<String>('notifications_content'),
                  onBack: () {
                    setState(() => _selectedTab = AmanahHomeTab.home);
                  },
                ),
                AmanahHomeTab.account => AmanahAccountTabScreen(
                  key: const ValueKey<String>('account_content'),
                  user: widget.user,
                  onBack: () {
                    setState(() => _selectedTab = AmanahHomeTab.home);
                  },
                  onMenuItemTap: (String id) {
                    _showToast('Membuka menu $id');
                  },
                  onLogout: _handleLogout,
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
        unreadNotifications: _notificationStore.unreadCount,
        onTabSelected: (AmanahHomeTab tab) {
          setState(() {
            if (tab == AmanahHomeTab.schedule) {
              _scheduleInitialSessionId = null;
              _scheduleInitialViewMode = null;
              _scheduleOpenDetailOnLaunch = false;
            }
            _selectedTab = tab;
          });
        },
      ),
    );
  }
}

class _AmanahHomeScreenContent extends StatelessWidget {
  const _AmanahHomeScreenContent({
    required this.user,
    required this.data,
    required this.todaySchedules,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.onQuickActionTap,
    required this.onDetailActivityTap,
    required this.onActivityTap,
    this.unreadNotifications = 0,
    this.onScheduleCardTap,
    super.key,
  });

  final AmanahAuthUser user;
  final AmanahHomeDashboardData data;
  final List<DoctorSchedule> todaySchedules;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final ValueChanged<AmanahQuickAction> onQuickActionTap;
  final VoidCallback onDetailActivityTap;
  final ValueChanged<AmanahActivityMetric> onActivityTap;
  final ValueChanged<DoctorSchedule>? onScheduleCardTap;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final int totalBookedPatients = todaySchedules.fold<int>(
      0,
      (int acc, DoctorSchedule s) => acc + s.bookedPatients.length,
    );

    final List<AmanahActivityMetric> dynamicActivities = data.activities.map((
      AmanahActivityMetric act,
    ) {
      if (act.id == 'antrean-aktif') {
        return act.copyWith(
          count: totalBookedPatients > 0
              ? totalBookedPatients.toString()
              : act.count,
        );
      }
      return act;
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: <Widget>[
        // 1. Doctor Profile Header
        AmanahHomeAppBar(
          user: user,
          greeting: data.profile.greeting,
          unreadNotifications: unreadNotifications,
          onNotificationTap: onNotificationTap,
          onProfileTap: onProfileTap,
        ),
        const SizedBox(height: 10),

        // 2. 3D Stack of Schedule Cards with Staggered Depth & Wave Petal Texture
        AmanahScheduleCardStack(
          schedules: todaySchedules,
          onCardTap: onScheduleCardTap,
        ),
        const SizedBox(height: 16),

        // 3. Quick Access Menu Grid (Raised closer to the card stack)
        AmanahQuickAccessSection(
          actions: data.quickActions,
          onActionTap: onQuickActionTap,
        ),
        const SizedBox(height: 38),

        // 4. Today's Activity Stat Cards
        AmanahTodayActivitySection(
          activities: dynamicActivities,
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

    if (dark) {
      // 1. Deep Cosmic Sapphire Glow (alpha 0.75, blur 100px)
      final Paint sapphireGlow = Paint()
        ..color = const Color(0xFF07247A).withValues(alpha: 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
      canvas.drawOval(
        Rect.fromLTWH(
          -size.width * 0.20,
          -size.height * 0.12,
          size.width * 1.40,
          320,
        ),
        sapphireGlow,
      );

      // 2. Electric Cyan/Teal Glow (alpha 0.65, blur 90px)
      final Paint tealGlow = Paint()
        ..color = const Color(0xFF0088CC).withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.20,
          size.height * 0.05,
          size.width * 1.0,
          260,
        ),
        tealGlow,
      );
    } else {
      // 1. Vibrant Apple/Amanah Blue Base in top-left (alpha 0.72, blur 95px, balanced and radiant)
      final Paint blueGlow = Paint()
        ..color = const Color(0xFF0A44FF).withValues(alpha: 0.72)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 95);
      canvas.drawOval(
        Rect.fromLTWH(
          -size.width * 0.20,
          -size.height * 0.08,
          size.width * 1.40,
          320,
        ),
        blueGlow,
      );

      // 2. Radiant Cyan Glow in top-right (alpha 0.75, blur 85px)
      final Paint cyanGlow = Paint()
        ..color = const Color(0xFF00D4FF).withValues(alpha: 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 85);
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.20,
          size.height * 0.04,
          size.width * 1.05,
          260,
        ),
        cyanGlow,
      );
    }

    // 3. Smooth Integration Mask (Fade starts right at the "Poli Gigi & Mulut" schedule text at ~53% of 480px, softly disappearing downwards)
    final Paint fadePaint = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Colors.black, Colors.black, Colors.transparent],
        stops: <double>[0.0, 0.53, 1.0],
      ).createShader(topMask);
    canvas.drawRect(topMask, fadePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AmanahHomeAuroraPainter oldDelegate) =>
      oldDelegate.dark != dark;
}
