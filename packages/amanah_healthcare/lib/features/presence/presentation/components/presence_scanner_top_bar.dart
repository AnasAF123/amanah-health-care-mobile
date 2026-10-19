import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/floating_circular_button.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';

/// Top overlay control bar containing Back, Help, Menu, Camera Flip, Flash,
/// and the floating Attendance Mode switcher (Check-In vs Check-Out).
class PresenceScannerTopBar extends StatelessWidget {
  const PresenceScannerTopBar({
    required this.onBack,
    required this.onShowHelp,
    required this.onToggleDrawer,
    required this.isHelpOpen,
    required this.isDrawerOpen,
    required this.drawerView,
    required this.hasCamera,
    required this.hasMoreThanOneCamera,
    required this.onSwitchCamera,
    required this.onToggleFlash,
    required this.isFrontCamera,
    required this.isFlashOn,
    required this.scanMode,
    required this.onSelectScanMode,
    required this.dark,
    this.hardwareNotifier,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onShowHelp;
  final VoidCallback onToggleDrawer;
  final bool isHelpOpen;
  final bool isDrawerOpen;
  final AmanahQrDrawerView drawerView;
  final bool hasCamera;
  final bool hasMoreThanOneCamera;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleFlash;
  final bool isFrontCamera;
  final bool isFlashOn;
  final AttendanceScanMode scanMode;
  final ValueChanged<AttendanceScanMode> onSelectScanMode;
  final bool dark;
  final ValueListenable<ScannerHardwareController?>? hardwareNotifier;

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.paddingOf(context).top;
    final double navTop = topPadding > 0 ? topPadding + 8 : 16;
    final double switcherTop = topPadding > 0 ? topPadding + 64 : 76;

    return Stack(
      children: <Widget>[
        // 1. Navigation Action Buttons
        Positioned(
          top: navTop,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingCircularButton(
                onTap: onBack,
                icon: Icons.arrow_back_rounded,
                label: 'Kembali',
                dark: dark,
              ),
              Row(
                children: <Widget>[
                  FloatingCircularButton(
                    onTap: onShowHelp,
                    icon: Icons.help_outline_rounded,
                    label: 'Bantuan Presensi',
                    dark: dark,
                    size: 40,
                    isActive: isHelpOpen,
                  ),
                  const SizedBox(width: 8),
                  FloatingCircularButton(
                    onTap: onToggleDrawer,
                    icon: Icons.grid_view_rounded,
                    label: 'Buka Menu Presensi',
                    dark: dark,
                    size: 40,
                    isActive: isDrawerOpen &&
                        drawerView == AmanahQrDrawerView.menu,
                  ),
                  if (hasCamera) ...<Widget>[
                    if (hardwareNotifier != null)
                      ValueListenableBuilder<ScannerHardwareController?>(
                        valueListenable: hardwareNotifier!,
                        builder: (_, ScannerHardwareController? hw, _) {
                          final bool front = hw?.isFrontCamera ?? isFrontCamera;
                          final bool torch = hw?.isTorchOn ?? isFlashOn;

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (hasMoreThanOneCamera) ...<Widget>[
                                const SizedBox(width: 8),
                                FloatingCircularButton(
                                  onTap: onSwitchCamera,
                                  icon: Icons.cameraswitch_rounded,
                                  label: 'Ubah Kamera',
                                  dark: dark,
                                  size: 40,
                                  isActive: front,
                                ),
                              ],
                              const SizedBox(width: 8),
                              FloatingCircularButton(
                                onTap: onToggleFlash,
                                icon: torch
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                label: 'Senter Flash',
                                dark: dark,
                                size: 40,
                                isActive: torch,
                              ),
                            ],
                          );
                        },
                      )
                    else ...<Widget>[
                      if (hasMoreThanOneCamera) ...<Widget>[
                        const SizedBox(width: 8),
                        FloatingCircularButton(
                          onTap: onSwitchCamera,
                          icon: Icons.cameraswitch_rounded,
                          label: 'Ubah Kamera',
                          dark: dark,
                          size: 40,
                          isActive: isFrontCamera,
                        ),
                      ],
                      const SizedBox(width: 8),
                      FloatingCircularButton(
                        onTap: onToggleFlash,
                        icon: isFlashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        label: 'Senter Flash',
                        dark: dark,
                        size: 40,
                        isActive: isFlashOn,
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),

        // 2. Attendance Mode Switcher (Check-In vs Check-Out)
        Positioned(
          top: switcherTop,
          left: 20,
          right: 20,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AmanahColorTokens.pureBlack.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.18),
                  width: 1,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AmanahColorTokens.pureBlack.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _PresenceModePill(
                    label: 'Presensi Masuk',
                    icon: Icons.login_rounded,
                    isSelected: scanMode == AttendanceScanMode.checkIn,
                    activeColor: AmanahColorTokens.success,
                    onTap: () => onSelectScanMode(AttendanceScanMode.checkIn),
                  ),
                  const SizedBox(width: 4),
                  _PresenceModePill(
                    label: 'Presensi Pulang',
                    icon: Icons.logout_rounded,
                    isSelected: scanMode == AttendanceScanMode.checkOut,
                    activeColor: AmanahColorTokens.brandPrimary,
                    onTap: () => onSelectScanMode(AttendanceScanMode.checkOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PresenceModePill extends StatelessWidget {
  const _PresenceModePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.70), width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? activeColor
                  : AmanahColorTokens.surfaceLight.withValues(alpha: 0.60),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AmanahColorTokens.surfaceLight
                    : AmanahColorTokens.surfaceLight.withValues(alpha: 0.60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
