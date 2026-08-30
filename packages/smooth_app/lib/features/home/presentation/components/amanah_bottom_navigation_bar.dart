import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

enum AmanahHomeTab { home, schedule, scan, notifications, account }

class AmanahBottomNavigationBar extends StatelessWidget {
  const AmanahBottomNavigationBar({
    required this.selectedTab,
    required this.onTabSelected,
    super.key,
    this.unreadNotifications = 0,
  });

  final AmanahHomeTab selectedTab;
  final ValueChanged<AmanahHomeTab> onTabSelected;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final Color surfaceColor = dark
        ? theme.colorScheme.surface
        : const Color(0xFFFFFFFF);
    final Color activeColor = dark
        ? const Color(0xFF22D3EE)
        : const Color(0xFF0A44FF);
    const Color inactiveColor = Color(0xFF9CA3AF);

    return Semantics(
      container: true,
      label: 'Navigasi utama',
      child: SizedBox(
        height: 96 + bottomInset,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Positioned(
              top: 28,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(
                    top: BorderSide(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.10)
                          : const Color(0xFFF3F4F6),
                    ),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: dark ? 0.22 : 0.03),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                MEDIUM_SPACE,
                28,
                MEDIUM_SPACE,
                bottomInset + MEDIUM_SPACE,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  _AmanahNavigationItem(
                    tab: AmanahHomeTab.home,
                    selectedTab: selectedTab,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Home',
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: onTabSelected,
                  ),
                  _AmanahNavigationItem(
                    tab: AmanahHomeTab.schedule,
                    selectedTab: selectedTab,
                    icon: Icons.calendar_today_outlined,
                    selectedIcon: Icons.calendar_today_rounded,
                    label: 'Jadwal',
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: onTabSelected,
                  ),
                  _AmanahScanSlot(
                    selected: selectedTab == AmanahHomeTab.scan,
                    onTap: () => onTabSelected(AmanahHomeTab.scan),
                  ),
                  _AmanahNavigationItem(
                    tab: AmanahHomeTab.notifications,
                    selectedTab: selectedTab,
                    icon: Icons.notifications_none_rounded,
                    selectedIcon: Icons.notifications_rounded,
                    label: 'Notifikasi',
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    badgeCount: unreadNotifications,
                    onTap: onTabSelected,
                  ),
                  _AmanahNavigationItem(
                    tab: AmanahHomeTab.account,
                    selectedTab: selectedTab,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: 'Akun',
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: onTabSelected,
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

class _AmanahNavigationItem extends StatelessWidget {
  const _AmanahNavigationItem({
    required this.tab,
    required this.selectedTab,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
    this.badgeCount = 0,
  });

  final AmanahHomeTab tab;
  final AmanahHomeTab selectedTab;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<AmanahHomeTab> onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool selected = selectedTab == tab;
    final Color color = selected ? activeColor : inactiveColor;

    return SizedBox(
      width: 56,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(tab),
          child: Padding(
            padding: const EdgeInsets.only(bottom: VERY_SMALL_SPACE),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Icon(selected ? selectedIcon : icon, size: 24, color: color),
                    if (badgeCount > 0)
                      Positioned(
                        top: -2,
                        right: -4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF171717)
                                  : Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: VERY_SMALL_SPACE),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.1,
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

class _AmanahScanSlot extends StatelessWidget {
  const _AmanahScanSlot({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 66,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            top: -20,
            left: 4,
            right: 4,
            child: _AmanahScanButton(selected: selected, onTap: onTap),
          ),
        ],
      ),
    );
  }
}

class _AmanahScanButton extends StatelessWidget {
  const _AmanahScanButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color primary = dark
        ? const Color(0xFF06B6D4)
        : const Color(0xFF0A44FF);

    return Semantics(
      button: true,
      label: 'Pindai QR Presensi',
      child: SizedBox(
        width: 56,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: dark ? const Color(0xFF0A0A0A) : Colors.white,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: primary.withValues(alpha: selected ? 0.38 : 0.30),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
