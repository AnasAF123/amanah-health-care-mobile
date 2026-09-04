import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/domain/amanah_notification_model.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_aurora_background.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_bottom_navigation_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_clinic_analytics_section.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_home_app_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_master_carousel_section.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_quick_access_section.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_schedule_card_stack.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_today_activity_section.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_account_tab_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_doctor_id_card_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_notification_tab_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_queue_dock_screen.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_schedule_tab_screen.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/features/permission/data/amanah_permission_store.dart';
import 'package:smooth_app/features/permission/presentation/screen/amanah_leave_permission_tab_screen.dart';
import 'package:smooth_app/features/presence/presentation/screen/amanah_presence_history_screen.dart';
import 'package:smooth_app/features/presence/presentation/screen/amanah_qr_scanner_tab_screen.dart';
import 'package:smooth_app/features/schedule/data/amanah_schedule_store.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';
import 'package:smooth_app/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart';

class AmanahHomeShell extends StatefulWidget {
  const AmanahHomeShell({this.user, this.onLogout, super.key});

  final AmanahAuthUser? user;
  final VoidCallback? onLogout;

  static const AmanahAuthUser defaultUser = AmanahAuthUser(
    id: 'doc-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Rayhan Pratama, Sp.A',
    email: 'dokter@amanah.health',
    phone: '081234567890',
    password: '',
    isEmailVerified: false,
  );

  @override
  State<AmanahHomeShell> createState() => _AmanahHomeShellState();
}

class _AmanahHomeShellState extends State<AmanahHomeShell> {
  AmanahAuthUser get _currentUser => widget.user ?? AmanahHomeShell.defaultUser;
  final AmanahScheduleStore _scheduleStore = AmanahScheduleStore.instance;
  final AmanahNotificationStore _notificationStore =
      AmanahNotificationStore.instance;
  final AmanahPermissionStore _permissionStore = AmanahPermissionStore.instance;
  AmanahHomeTab _selectedTab = AmanahHomeTab.home;
  String? _toastMessage;
  Timer? _toastTimer;
  String? _scheduleInitialSessionId;
  AmanahScheduleViewMode? _scheduleInitialViewMode;
  bool _scheduleOpenDetailOnLaunch = false;
  bool _isScanDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _scheduleStore.addListener(_onStoreUpdated);
    _notificationStore.addListener(_onStoreUpdated);
    _permissionStore.addListener(_onStoreUpdated);
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

  Future<void> _handleLogout() async {
    final bool confirmed = await showAmanahConfirmationDialog(
      context: context,
      title: 'Konfirmasi Keluar',
      message: 'Apakah Anda yakin ingin keluar dari akun dokter?',
      confirmLabel: 'Keluar',
      destructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }

    _showToast('Berhasil keluar dari akun dokter');
    if (widget.onLogout != null) {
      widget.onLogout?.call();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleQuickAction(String actionId) {
    switch (actionId) {
      case 'history':
      case 'presensi':
        Navigator.of(context).push(AmanahPresenceHistoryScreen.route());
      case 'jadwal-saya':
        setState(() {
          _scheduleInitialSessionId = null;
          _scheduleInitialViewMode = AmanahScheduleViewMode.overview;
          _scheduleOpenDetailOnLaunch = false;
          _selectedTab = AmanahHomeTab.schedule;
        });
      case 'pilih-antrean':
      case 'queue':
      case 'cari-visit':
        Navigator.of(context).push(AmanahQueueDockScreen.route());
      case 'kartu-id':
        Navigator.of(context).push(
          AmanahDoctorIdCardScreen.route(
            user: _currentUser,
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
    _permissionStore.removeListener(_onStoreUpdated);
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor = dark
        ? AmanahColorTokens.canvasDark
        : (_selectedTab == AmanahHomeTab.home
              ? AmanahColorTokens.canvasLight
              : Colors.white);

    final List<DoctorSchedule> todaySchedules = _scheduleStore
        .getSchedulesForDate(AmanahScheduleStore.baseToday);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: Stack(
        children: <Widget>[
          // Dynamic Aurora Ambient Glow
          if (_selectedTab == AmanahHomeTab.home)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 480,
              child: AmanahAuroraBackground(height: 480),
            ),

          // Main Viewport Container
          SafeArea(
            top: _selectedTab != AmanahHomeTab.scan &&
                _selectedTab != AmanahHomeTab.account,
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: switch (_selectedTab) {
                AmanahHomeTab.home => _AmanahHomeScreenContent(
                  key: const ValueKey<String>('home_content'),
                  user: _currentUser,
                  data: amanahHomeDashboardData,
                  todaySchedules: todaySchedules,
                  unreadNotifications: _notificationStore.unreadCount,
                  onNotificationTap: () {
                    Navigator.of(
                      context,
                    ).push(AmanahNotificationTabScreen.route());
                  },
                  onProfileTap: () {
                    setState(() => _selectedTab = AmanahHomeTab.account);
                  },
                  onQuickActionTap: (AmanahQuickAction action) {
                    _handleQuickAction(action.id);
                  },
                  onScheduleCardTap: _navigateToScheduleWithSession,
                  onCreateScheduleTap: () {
                    AmanahAddEditScheduleDrawer.show(
                      context,
                      initialDate: AmanahScheduleStore.baseToday,
                      onSavedDate: (_) {
                        _showToast('Jadwal praktik berhasil disimpan');
                      },
                    );
                  },
                  onDetailActivityTap: () {
                    _handleQuickAction('queue');
                  },
                  onActivityTap: (AmanahActivityMetric activity) {
                    _showToast('Membuka rincian aktivitas');
                  },
                  onSlideAction: (String slideId) {
                    _showToast('Membuka program promo: $slideId');
                  },
                  onAnalyticsViewDetails: () {
                    _showToast('Membuka analisis tren data klinis');
                  },
                ),
                AmanahHomeTab.schedule => AmanahScheduleTabScreen(
                  key: const ValueKey<String>('schedule_content'),
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
                  user: _currentUser,
                  bottomNavigationClearance:
                      96 + MediaQuery.viewPaddingOf(context).bottom,
                  onDrawerStateChanged: (bool isOpen) {
                    if (_isScanDrawerOpen != isOpen) {
                      setState(() => _isScanDrawerOpen = isOpen);
                    }
                  },
                  onBack: () {
                    setState(() {
                      _isScanDrawerOpen = false;
                      _selectedTab = AmanahHomeTab.home;
                    });
                  },
                ),
                AmanahHomeTab.notifications => AmanahLeavePermissionTabScreen(
                  key: const ValueKey<String>('permissions_content'),
                  doctorName: _currentUser.fullName,
                  doctorRole: 'Dokter Spesialis Anak',
                  onBack: () {
                    setState(() => _selectedTab = AmanahHomeTab.home);
                  },
                ),
                AmanahHomeTab.account => AmanahAccountTabScreen(
                  key: const ValueKey<String>('account_content'),
                  user: _currentUser,
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
      bottomNavigationBar:
          (_selectedTab == AmanahHomeTab.scan && _isScanDrawerOpen)
          ? null
          : AmanahBottomNavigationBar(
              selectedTab: _selectedTab,
              unreadNotifications: _permissionStore.pendingCount,
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
    this.onCreateScheduleTap,
    this.onSlideAction,
    this.onAnalyticsViewDetails,
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
  final VoidCallback? onCreateScheduleTap;
  final ValueChanged<String>? onSlideAction;
  final VoidCallback? onAnalyticsViewDetails;
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

    return Column(
      children: <Widget>[
        // 1. Doctor Profile Header (Fixed master header, 100% aligned with other tab headers)
        AmanahHomeAppBar(
          user: user,
          greeting: data.profile.greeting,
          unreadNotifications: unreadNotifications,
          onNotificationTap: onNotificationTap,
          onProfileTap: onProfileTap,
        ),

        // Scrollable home dashboard body
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: <Widget>[
              // 2. 3D Stack of Schedule Cards with Staggered Depth & Wave Petal Texture
              AmanahScheduleCardStack(
                schedules: todaySchedules,
                onCardTap: onScheduleCardTap,
                onCreateSchedule: onCreateScheduleTap,
              ),
              const SizedBox(height: 16),

              // 3. Quick Access Menu Grid (Raised closer to the card stack)
              AmanahQuickAccessSection(
                actions: data.quickActions,
                onActionTap: onQuickActionTap,
              ),
              const SizedBox(height: 16),

              // 4. Master 3D Deck Carousel (Promotions & Clinical Programs)
              AmanahMasterCarouselSection(onSlideAction: onSlideAction),
              const SizedBox(height: 20),

              // 5. Today's Activity Stat Cards
              AmanahTodayActivitySection(
                activities: dynamicActivities,
                onDetailTap: onDetailActivityTap,
                onActivityTap: onActivityTap,
              ),
              const SizedBox(height: 24),

              // 6. Clinic Performance & Trends Analytics (Area Chart & Monthly Timeline)
              AmanahClinicAnalyticsSection(
                onViewDetails: onAnalyticsViewDetails,
              ),
            ],
          ),
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
