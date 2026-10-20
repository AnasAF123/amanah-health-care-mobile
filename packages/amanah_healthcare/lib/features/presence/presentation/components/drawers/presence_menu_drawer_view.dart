import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/action_menu_card.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_session_info.dart';
import 'package:amanah_healthcare/features/queue/presentation/state/amanah_queue_store.dart';

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
    return ListenableBuilder(
      listenable: AmanahQueueStore.instance,
      builder: (BuildContext context, _) {
        final QueueSessionInfo? activeSession = AmanahQueueStore.instance.activeSession;
        final bool hasActiveSession = activeSession != null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Info Strip Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: hasActiveSession
                    ? const LinearGradient(
                        colors: <Color>[AmanahColorTokens.brand, AmanahColorTokens.brandAccent],
                      )
                    : null,
                color: hasActiveSession
                    ? null
                    : (dark
                          ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
                          : AmanahColorTokens.neutral100),
                borderRadius: BorderRadius.circular(18),
                border: hasActiveSession
                    ? null
                    : Border.all(
                        color: dark
                            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.12)
                            : AmanahColorTokens.neutral200,
                      ),
                boxShadow: hasActiveSession
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AmanahColorTokens.brand.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    hasActiveSession ? Icons.auto_awesome_rounded : Icons.event_busy_rounded,
                    size: 16,
                    color: hasActiveSession
                        ? AmanahColorTokens.surfaceLight
                        : (dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasActiveSession
                          ? (user?.staff?.profession != null
                                ? 'Sesi Dinas ${user!.staff!.profession} (${activeSession.sessionShift}) Aktif'
                                : 'Sesi Dinas ${activeSession.poliklinikName} Aktif')
                          : 'Tidak Ada Sesi Dinas Dokter Aktif Saat Ini',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: hasActiveSession
                            ? AmanahColorTokens.surfaceLight
                            : (dark ? AmanahColorTokens.neutral200 : AmanahColorTokens.neutral700),
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
                        color: hasActiveSession
                            ? AmanahColorTokens.pureBlack.withValues(alpha: 0.25)
                            : (dark
                                  ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                                  : AmanahColorTokens.neutral200),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: hasActiveSession
                            ? AmanahColorTokens.surfaceLight
                            : (dark ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (hasActiveSession) ...<Widget>[
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
          ],
        );
      },
    );
  }
}
