import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/functions/format_localized_date.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_shift_booking_ticket.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_slide_to_confirm.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/widgets/amanah_avatar.dart';

/// Modal bottom sheet drawer displaying essential, 100% DB-driven replacement opportunity details.
class AmanahReplacementDetailDrawer extends StatelessWidget {
  const AmanahReplacementDetailDrawer({
    required this.item,
    required this.onClaim,
    required this.currentStaffProfileId,
    required this.currentUserName,
    super.key,
  });

  final ReplacementItem item;
  final Future<bool> Function() onClaim;
  final String currentStaffProfileId;
  final String currentUserName;

  static Future<void> show({
    required BuildContext context,
    required ReplacementItem item,
    required Future<bool> Function() onClaim,
    required String currentStaffProfileId,
    required String currentUserName,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahReplacementDetailDrawer(
        item: item,
        onClaim: onClaim,
        currentStaffProfileId: currentStaffProfileId,
        currentUserName: currentUserName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final bool claimedByMe =
        (currentStaffProfileId.isNotEmpty &&
            item.claimedByStaffProfileId == currentStaffProfileId) ||
        (currentUserName.isNotEmpty && item.claimedByName == currentUserName);
    final bool isOpen = item.isOpen;

    final String sessionDisplay = item.sessionLabel ?? '-';

    return AmanahBottomSheetScaffold(
      title: 'Detail Jadwal Pengganti',
      subtitle: item.formattedWorkDate,
      hugContent: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Status Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  sessionDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: AmanahSpacing.md),
              AmanahStatusBadge(
                text: item.statusBadgeText(currentStaffProfileId, currentUserName),
                variant: isOpen
                    ? AmanahBadgeVariant.primary
                    : (claimedByMe ? AmanahBadgeVariant.success : AmanahBadgeVariant.warning),
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: AmanahSpacing.lg),
          const _DrawerDivider(),

          // 2. Essential Shift Info (Unified Booking Ticket Component)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AmanahSpacing.md),
            child: AmanahShiftBookingTicket(
              startTime: item.startTimeShort,
              endTime: item.endTimeShort,
              sessionLabel: sessionDisplay,
              dateLabel: item.formattedWorkDate,
            ),
          ),

          const _DrawerDivider(),

          // 3. Staf yang Digantikan (Original Staff) with Rounded Squircle Avatar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AmanahSpacing.md),
            child: Row(
              children: <Widget>[
                AmanahAvatar.staff(
                  avatarUrl: item.originalStaffAvatarUrl,
                  name: item.originalStaffName ?? 'Rekan Staf',
                  size: 42,
                  backgroundColor: dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand,
                  initialsColor: dark ? AmanahColorTokens.neutral950 : Colors.white,
                ),
                const SizedBox(width: AmanahSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Menggantikan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AmanahThemeTokens.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.originalStaffName ?? 'Rekan Staf',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AmanahThemeTokens.textPrimary(context),
                        ),
                      ),
                      if (item.originalStaffRole != null && item.originalStaffRole!.isNotEmpty)
                        Text(
                          item.originalStaffRole!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AmanahThemeTokens.textTertiary(context),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Alasan Izin (100% DB-driven from staff_leave_requests.reason)
          if (item.leaveReason != null && item.leaveReason!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AmanahSpacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dark
                    ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.04)
                    : AmanahColorTokens.neutral100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
                      : AmanahColorTokens.neutral200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Alasan Ketidakhadiran Rekan:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AmanahThemeTokens.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.leaveReason!.trim(),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AmanahThemeTokens.textPrimary(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 5. Claimant info if already claimed
          if (!isOpen && item.claimedByName != null) ...<Widget>[
            const SizedBox(height: AmanahSpacing.sm),
            const _DrawerDivider(),
            _DrawerInfoRow(
              label: 'Diambil Oleh',
              value: claimedByMe ? 'Anda (${item.claimedByName})' : item.claimedByName!,
            ),
            if (item.claimedAt != null)
              _DrawerInfoRow(
                label: 'Waktu Klaim',
                value:
                    '${formatLocalizedDate(item.claimedAt!, style: 'human_short')} ${item.claimedAt!.hour.toString().padLeft(2, '0')}:${item.claimedAt!.minute.toString().padLeft(2, '0')} WIB',
              ),
          ],

          const SizedBox(height: AmanahSpacing.lg),

          // 6. Action: Agnostic Slide To Confirm or Guidance Box
          if (isOpen) ...<Widget>[
            AmanahSlideToConfirm(
              text: 'Geser untuk Ambil Jadwal',
              variant: AmanahSlideVariant.brandGradient,
              borderRadius: BorderRadius.circular(AmanahRadius.md),
              onConfirmed: () async {
                final bool success = await onClaim();
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
                return success;
              },
            ),
          ] else if (claimedByMe) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand)
                    .withValues(alpha: dark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand)
                      .withValues(alpha: dark ? 0.28 : 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 16,
                        color: dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Petunjuk Presensi Masuk (QR)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: dark ? Colors.white : AmanahColorTokens.brandNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Silakan hadir di klinik pada tanggal dinas dan lakukan scan QR Presensi Masuk di meja admin/resepsionis. Sistem backend otomatis memvalidasi jadwal pengganti ini.',
                    style: TextStyle(
                      fontSize: 11,
                      color: dark ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DrawerInfoRow extends StatelessWidget {
  const _DrawerInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AmanahSpacing.sm + 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AmanahThemeTokens.textSecondary(context),
              ),
            ),
          ),
          const SizedBox(width: AmanahSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AmanahThemeTokens.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: AmanahThemeTokens.outline(context));
  }
}
