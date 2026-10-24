import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/presence_manual_pin_drawer_view.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';

class PresenceScannerMasterDrawer extends StatelessWidget {
  const PresenceScannerMasterDrawer({
    required this.drawerAnimationController,
    required this.isDrawerOpen,
    required this.drawerView,
    required this.manualPin,
    required this.dark,
    required this.bottomPadding,
    required this.onClose,
    required this.onOpenView,
    required this.onManualPinChanged,
    required this.onVerifyManualPin,
    required this.scanMode,
    required this.onScanModeChanged,
    super.key,
    this.user,
    this.pinError,
    this.userQrValue = '',
    this.copiedFeedback = false,
    this.onCopyQr,
    this.onDownloadQr,
  });

  final AnimationController drawerAnimationController;
  final bool isDrawerOpen;
  final AmanahQrDrawerView drawerView;
  final AmanahAuthUser? user;
  final String userQrValue;
  final bool copiedFeedback;
  final String manualPin;
  final String? pinError;
  final bool dark;
  final double bottomPadding;
  final AttendanceScanMode scanMode;
  final ValueChanged<AttendanceScanMode> onScanModeChanged;
  final VoidCallback onClose;
  final ValueChanged<AmanahQrDrawerView> onOpenView;
  final ValueChanged<String> onManualPinChanged;
  final VoidCallback onVerifyManualPin;
  final VoidCallback? onCopyQr;
  final VoidCallback? onDownloadQr;

  @override
  Widget build(BuildContext context) {
    final Color drawerBg = dark
        ? AmanahThemeTokens.canvas(context)
        : AmanahColorTokens.surfaceLight;
    final Color drawerBorder = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
        : AmanahColorTokens.canvasLight;

    return AnimatedBuilder(
      animation: drawerAnimationController,
      builder: (BuildContext context, Widget? child) {
        if (drawerAnimationController.value <= 0.001 && !isDrawerOpen) {
          return const SizedBox.shrink();
        }
        final double progress = CurvedAnimation(
          parent: drawerAnimationController,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ).value;

        return FractionalTranslation(
          translation: Offset(0, 1.0 - progress),
          child: Opacity(
            opacity: progress.clamp(0.0, 1.0),
            child: GestureDetector(
              onVerticalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
                  onClose();
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding),
                decoration: BoxDecoration(
                  color: drawerBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(top: BorderSide(color: drawerBorder)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AmanahColorTokens.pureBlack.withValues(alpha: 0.40 * progress),
                      blurRadius: 32,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                      key: ValueKey<AmanahQrDrawerView>(drawerView),
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Drag Handle
                          GestureDetector(
                            onTap: onClose,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 14),
                              child: Container(
                                width: 48,
                                height: 4.5,
                                decoration: BoxDecoration(
                                  color: dark
                                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.25)
                                      : AmanahColorTokens.neutral300,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),

                          // Active View: Directly show manual PIN drawer (with active session check or empty state inside)
                          PresenceManualPinDrawerView(
                            user: user,
                            manualPin: manualPin,
                            pinError: pinError,
                            onChanged: onManualPinChanged,
                            onClose: onClose,
                            onSubmit: onVerifyManualPin,
                            dark: dark,
                            scanMode: scanMode,
                            onScanModeChanged: onScanModeChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
