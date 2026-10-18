import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/action_menu_card.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';

class PresenceMenuDrawerView extends StatelessWidget {
  const PresenceMenuDrawerView({
    required this.activeView,
    required this.onSelectView,
    required this.onClose,
    required this.dark,
    super.key,
    this.user,
  });

  final AmanahAuthUser? user;
  final AmanahQrDrawerView activeView;
  final ValueChanged<AmanahQrDrawerView> onSelectView;
  final VoidCallback onClose;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Blue Info Strip Banner
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                AmanahColorTokens.brandAccent,
                AmanahColorTokens.indigoDark,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AmanahColorTokens.brandAccent.withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AmanahColorTokens.brandSoft,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user?.staff?.profession != null
                      ? 'Sesi Dinas ${user!.staff!.profession} Aktif'
                      : 'Sesi Presensi Kehadiran Dinas Aktif',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AmanahColorTokens.surfaceLight,
                  ),
                ),
              ),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AmanahColorTokens.pureBlack.withValues(alpha: 0.25),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AmanahColorTokens.surfaceLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2 Action Cards Grid (Tampilkan QR & Manual)
        Row(
          children: <Widget>[
            // Card 1: Tampilkan QR
            Expanded(
              child: ActionMenuCard(
                title: 'Tampilkan QR',
                icon: Icons.qr_code_rounded,
                dark: dark,
                isActive: activeView == AmanahQrDrawerView.myQr,
                onTap: () => onSelectView(AmanahQrDrawerView.myQr),
              ),
            ),
            const SizedBox(width: 10),

            // Card 2: Presensi Manual
            Expanded(
              child: ActionMenuCard(
                title: 'Manual',
                icon: Icons.password_rounded,
                dark: dark,
                isActive: activeView == AmanahQrDrawerView.manualPin,
                onTap: () => onSelectView(AmanahQrDrawerView.manualPin),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
