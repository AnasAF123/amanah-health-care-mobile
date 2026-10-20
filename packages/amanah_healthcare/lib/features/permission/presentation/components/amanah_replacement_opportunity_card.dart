import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_shift_booking_ticket.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_slide_to_confirm.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/widgets/amanah_avatar.dart';

/// Compact, ticket-booking styled card for replacement opportunities.
/// Respects 1-file-1-class and Feature-First Clean Architecture.
class AmanahReplacementOpportunityCard extends StatelessWidget {
  const AmanahReplacementOpportunityCard({
    required this.item,
    required this.onTap,
    required this.onClaim,
    required this.currentStaffProfileId,
    required this.currentUserName,
    super.key,
  });

  final ReplacementItem item;
  final VoidCallback onTap;
  final Future<bool> Function() onClaim;
  final String currentStaffProfileId;
  final String currentUserName;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final bool claimedByMe = (currentStaffProfileId.isNotEmpty &&
            item.claimedByStaffProfileId == currentStaffProfileId) ||
        (currentUserName.isNotEmpty && item.claimedByName == currentUserName);
    final bool isOpen = item.isOpen;

    final String sessionDisplay =
        item.sessionLabel ?? item.sessionCode ?? item.sessionId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: dark
                  ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                  : AmanahColorTokens.neutral200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Header: Squircle Avatar + Staff Name & Role + Title Case Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AmanahAvatar.staff(
                    avatarUrl: item.originalStaffAvatarUrl,
                    name: item.originalStaffName ?? 'Rekan Staf',
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.originalStaffName ?? 'Rekan Staf',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.1,
                            color: AmanahThemeTokens.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          item.originalStaffRole ?? 'Staf Operasional',
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
                  const SizedBox(width: 8),
                  AmanahStatusBadge(
                    text: item.statusBadgeText(currentStaffProfileId, currentUserName),
                    variant: isOpen
                        ? AmanahBadgeVariant.primary
                        : (claimedByMe ? AmanahBadgeVariant.success : AmanahBadgeVariant.warning),
                    fontSize: 10.5,
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Booking Ticket Shift Time Row
              AmanahShiftBookingTicket(
                startTime: item.startTimeShort,
                endTime: item.endTimeShort,
                sessionLabel: sessionDisplay,
                dateLabel: item.formattedWorkDate,
              ),

              // 3. Action Section: Agnostic Slide To Confirm / Status Banner
              if (isOpen) ...<Widget>[
                const SizedBox(height: 14),
                AmanahSlideToConfirm(
                  height: 44,
                  text: 'Geser untuk Ambil Jadwal',
                  variant: AmanahSlideVariant.brandGradient,
                  borderRadius: BorderRadius.circular(12),
                  onConfirmed: onClaim,
                ),
              ] else if (claimedByMe) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AmanahColorTokens.brand.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AmanahColorTokens.brand.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 15,
                        color: AmanahColorTokens.brand,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Jadwal Anda: lakukan presensi masuk via QR saat bertugas.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: dark ? Colors.white : AmanahColorTokens.brandNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: dark
                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.04)
                        : AmanahColorTokens.neutral100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 15,
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sudah diambil oleh ${item.claimedByName ?? "rekan kerja"}.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: dark
                                ? AmanahColorTokens.neutral300
                                : AmanahColorTokens.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
