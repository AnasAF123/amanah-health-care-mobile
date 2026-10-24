import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_slide_to_confirm.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/modal/amanah_queue_session_selector.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_otp_input.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_session_info.dart';
import 'package:amanah_healthcare/features/queue/presentation/state/amanah_queue_store.dart';

class PresenceManualPinDrawerView extends StatelessWidget {
  const PresenceManualPinDrawerView({
    required this.manualPin,
    required this.onChanged,
    required this.onClose,
    required this.onSubmit,
    required this.dark,
    required this.scanMode,
    required this.onScanModeChanged,
    super.key,
    this.user,
    this.pinError,
  });

  final AmanahAuthUser? user;
  final String manualPin;
  final String? pinError;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  final VoidCallback onSubmit;
  final bool dark;
  final AttendanceScanMode scanMode;
  final ValueChanged<AttendanceScanMode> onScanModeChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AmanahQueueStore.instance,
      builder: (BuildContext context, _) {
        final bool isLoading = AmanahQueueStore.instance.isLoading;
        final List<QueueSessionInfo> sessions = AmanahQueueStore.instance.sessions;
        final QueueSessionInfo? activeSession = AmanahQueueStore.instance.activeSession;
        final bool hasActiveSession = activeSession != null;
        final bool canSelectSession = sessions.length > 1;

        // Condition: No active doctor duty session -> Render 3D Isometric Empty Box with flies
        if (!isLoading && !hasActiveSession) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: AmanahEmptyState.box(
              title: 'Tidak Ada Sesi Dinas Aktif',
              message:
                  'Anda tidak memiliki jadwal dinas dokter aktif saat ini untuk melakukan presensi manual.',
              boxSize: 130,
              variant: AmanahEmptyStateVariant.compact,
              actionText: 'Tutup',
              onAction: onClose,
            ),
          );
        }

        final String bannerText;
        if (isLoading && !hasActiveSession) {
          bannerText = 'Memeriksa Jadwal Sesi Dinas...';
        } else if (hasActiveSession) {
          bannerText = user?.staff?.profession != null
              ? 'Sesi Dinas ${user!.staff!.profession} (${activeSession.sessionLabel}) Aktif'
              : 'Sesi Dinas ${activeSession.poliklinikName} (${activeSession.sessionLabel}) Aktif';
        } else {
          bannerText = 'Presensi Dinas RS Amanah';
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Info Strip Banner (Gradient Brand Banner + Shift Switcher)
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
                    hasActiveSession
                        ? Icons.auto_awesome_rounded
                        : (isLoading ? Icons.sync_rounded : Icons.event_busy_rounded),
                    size: 16,
                    color: hasActiveSession
                        ? AmanahColorTokens.surfaceLight
                        : (dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: canSelectSession
                          ? () {
                              AmanahQueueSessionSelector.show(
                                context,
                                sessions: sessions,
                                activeSession: activeSession,
                                onSelectSession: (QueueSessionInfo s) {
                                  AmanahQueueStore.instance.selectSession(s);
                                },
                              );
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              bannerText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: hasActiveSession
                                    ? AmanahColorTokens.surfaceLight
                                    : (dark
                                          ? AmanahColorTokens.neutral200
                                          : AmanahColorTokens.neutral700),
                              ),
                            ),
                          ),
                          if (canSelectSession) ...<Widget>[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.unfold_more_rounded,
                              size: 15,
                              color: hasActiveSession
                                  ? AmanahColorTokens.surfaceLight
                                  : (dark
                                        ? AmanahColorTokens.neutral300
                                        : AmanahColorTokens.neutral600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
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

            // Mode Switcher Slider (Presensi Masuk <-> Presensi Pulang)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: AmanahSlideToConfirm(
                key: ValueKey<AttendanceScanMode>(scanMode),
                text: scanMode == AttendanceScanMode.checkIn
                    ? 'Geser ke Presensi Pulang'
                    : 'Geser ke Presensi Masuk',
                targetText: scanMode == AttendanceScanMode.checkIn
                    ? 'Presensi Pulang'
                    : 'Presensi Masuk',
                completedText: scanMode == AttendanceScanMode.checkIn
                    ? 'Beralih ke Pulang...'
                    : 'Beralih ke Masuk...',
                variant: AmanahSlideVariant.brandGradient,
                height: 48.0,
                borderRadius: BorderRadius.circular(16),
                onConfirmed: () async {
                  HapticFeedback.mediumImpact();
                  onScanModeChanged(
                    scanMode == AttendanceScanMode.checkIn
                        ? AttendanceScanMode.checkOut
                        : AttendanceScanMode.checkIn,
                  );
                  return false;
                },
              ),
            ),

            const SizedBox(height: 16),

            // Instruction Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  scanMode == AttendanceScanMode.checkIn
                      ? 'Presensi Masuk (Kode)'
                      : 'Presensi Pulang (Kode)',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                  ),
                ),
                Text(
                  '6 Karakter',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              scanMode == AttendanceScanMode.checkIn
                  ? 'Masukkan kode alfanumerik dinamis yang tertera pada layar terminal presensi klinik untuk presensi masuk.'
                  : 'Masukkan kode alfanumerik dinamis yang tertera pada layar terminal presensi klinik untuk presensi pulang.',
              style: TextStyle(
                fontSize: 11.5,
                color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // 6-Grid OTP Input
            AmanahOtpInput(length: 6, error: pinError, onChanged: onChanged),
            const SizedBox(height: 18),

            // Verification Button
            AmanahButton.primary(
              text: scanMode == AttendanceScanMode.checkIn
                  ? 'Verifikasi Presensi Masuk'
                  : 'Verifikasi Presensi Pulang',
              isFullWidth: true,
              isDisabled: manualPin.trim().length < 6,
              onPressed: onSubmit,
            ),
          ],
        );
      },
    );
  }
}
