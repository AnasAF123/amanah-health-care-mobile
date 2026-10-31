import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/data/staff_profile_store.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_home_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/account/amanah_account_hero_banner.dart';
import 'package:amanah_healthcare/features/home/presentation/components/account/amanah_account_preferences_card.dart';
import 'package:amanah_healthcare/features/home/presentation/components/account/amanah_dual_stack_profile_card.dart';
import 'package:amanah_healthcare/features/home/presentation/components/account/amanah_winged_mail_banner.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/amanah_doctor_id_card_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_account_identity_settings_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_data_storage_settings_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_it_support_settings_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_privacy_security_settings_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/payroll.dart';

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
  final StaffProfileStore _profileStore = StaffProfileStore.instance;
  bool _isEmailVerified = false;
  String? _customAvatarPath;
  String? _presetAvatarUrl;

  @override
  void initState() {
    super.initState();
    _isEmailVerified = widget.user.isEmailVerified;
    _presetAvatarUrl =
        widget.user.avatar.directUrl ??
        (widget.user.avatar.url.isNotEmpty ? widget.user.avatar.url : null);
    _profileStore.addListener(_onStoreUpdated);
    _profileStore.seedFromUser(widget.user);
  }

  @override
  void didUpdateWidget(AmanahAccountTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.isEmailVerified != widget.user.isEmailVerified) {
      _isEmailVerified = widget.user.isEmailVerified;
    }
  }

  void _onStoreUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _profileStore.removeListener(_onStoreUpdated);
    super.dispose();
  }

  AmanahStaffProfile? get _activeStaff => _profileStore.profile ?? widget.user.staff;
  String get _fullName => _activeStaff?.fullName ?? widget.user.fullName;
  String get _phone => _activeStaff?.phoneNumber ?? widget.user.phone;
  String get _roleText => _activeStaff?.profession ?? widget.user.roleName;

  AmanahDoctorProfile get _doctorProfile {
    final AmanahAuthUser effectiveUser = widget.user.copyWith(
      fullName: _fullName,
      phone: _phone,
      staff: _activeStaff,
    );
    return AmanahDoctorProfile.fromAuthUser(effectiveUser);
  }

  void _handleVerifyEmail() {
    setState(() {
      _isEmailVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tautan verifikasi telah dikirim ke ${widget.user.email}. Email berhasil diverifikasi.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AmanahColorTokens.sky,
      ),
    );
  }

  Future<void> _openEditProfileDrawer() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => AmanahAccountIdentitySettingsScreen(
          user: widget.user,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _handleOpenDoctorIdCard() {
    final AmanahAuthUser effectiveUser = widget.user.copyWith(
      fullName: _fullName,
      phone: _phone,
      staff: _activeStaff,
    );
    Navigator.of(
      context,
    ).push<void>(AmanahDoctorIdCardScreen.route(user: effectiveUser, profile: _doctorProfile));
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
              user: widget.user,
              onBack: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
        break;
      case 'payroll':
        Navigator.of(context).push<void>(AmanahPayrollHistoryScreen.route());
        break;
      case 'data':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext ctx) =>
                AmanahDataStorageSettingsScreen(onBack: () => Navigator.of(ctx).pop()),
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
            title: widget.user.roleName.isNotEmpty
                ? 'Profil ${widget.user.roleName}'
                : 'Profil Akun',
            onBack: widget.onBack,
            titleAlignment: AmanahScreenHeaderTitleAlignment.start,
          ),

          // Scrollable Viewport with Pull-to-Refresh
          Expanded(
            child: AmanahPullToRefresh(
              onRefresh: () async {
                await _profileStore.fetchProfile(force: true);
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.only(bottom: 120 + MediaQuery.paddingOf(context).bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Top Header Region with Medical Hero Illustration
                    AmanahAccountHeroBanner(dark: dark, onIdCardTap: _handleOpenDoctorIdCard),

                    // 2. Signature Dual-Stack Profile Card
                    Transform.translate(
                      offset: const Offset(0, -56),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AmanahDualStackProfileCard(
                          userName: _fullName,
                          roleText: _roleText,
                          phoneText: _phone,
                          customAvatarPath: _customAvatarPath,
                          presetAvatarUrl: _presetAvatarUrl,
                          dark: dark,
                          onEditTap: _openEditProfileDrawer,
                          onAvatarTap: () {},
                          onLoyaltyTap: _handleOpenDoctorIdCard,
                        ),
                      ),
                    ),

                    // 3. Pixel-Perfect Winged Mail Banner (Email Sync Banner)
                    Transform.translate(
                      offset: const Offset(0, -42),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AmanahWingedMailBanner(
                          email: widget.user.email,
                          isVerified: _isEmailVerified,
                          dark: dark,
                          onActionTap: _openEditProfileDrawer,
                          onVerifyTap: _handleVerifyEmail,
                        ),
                      ),
                    ),

                    // 4. Grouped Preferences Menu List ("Preferensi")
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AmanahAccountPreferencesCard(
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
                        child: _LogoutButton(
                          onTap: widget.onLogout,
                          dark: dark,
                          roleLabel: widget.user.roleName.isNotEmpty
                              ? widget.user.roleName
                              : 'Akun',
                        ),
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

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap, required this.dark, required this.roleLabel});

  final VoidCallback onTap;
  final bool dark;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: AmanahButton.ghost(
        text: 'Keluar dari Akun $roleLabel',
        leadingIcon: Icons.logout_rounded,
        isFullWidth: true,
        customForegroundColor: dark ? AmanahColorTokens.dangerBorder : AmanahColorTokens.dangerDark,
        semanticsLabel: 'Keluar dari Akun $roleLabel',
        onPressed: onTap,
      ),
    );
  }
}
