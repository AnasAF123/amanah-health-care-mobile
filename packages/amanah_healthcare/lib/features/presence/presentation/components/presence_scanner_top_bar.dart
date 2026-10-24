import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/floating_circular_button.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';

/// Top overlay control bar containing Back, Help, Menu, Camera Flip, and Flash.
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
  final bool dark;
  final ValueListenable<ScannerHardwareController?>? hardwareNotifier;

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.paddingOf(context).top;
    final double navTop = topPadding > 0 ? topPadding + 8 : 16;

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
                    icon: Icons.dialpad_rounded,
                    label: 'Presensi Manual (Kode)',
                    dark: dark,
                    size: 40,
                    isActive: isDrawerOpen,
                  ),
                  if (hasCamera) ...<Widget>[
                    if (hardwareNotifier != null)
                      ValueListenableBuilder<ScannerHardwareController?>(
                        valueListenable: hardwareNotifier!,
                        builder: (_, ScannerHardwareController? hw, _) {
                          final bool front = hw?.isFrontCamera ?? isFrontCamera;
                          final bool torch = front ? isFlashOn : (hw?.isTorchOn ?? isFlashOn);

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
                                icon: torch ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                label: front ? 'Ring Light Layar' : 'Senter Flash',
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
                        icon: isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
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
      ],
    );
  }
}
