import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/slot_occupied_info.dart';

class AmanahSlotOccupiedDetailDrawer extends StatelessWidget {
  const AmanahSlotOccupiedDetailDrawer({
    required this.time,
    this.info,
    this.subtitle,
    super.key,
  });

  final String time;
  final SlotOccupiedInfo? info;
  final String? subtitle;

  static void show(
    BuildContext context, {
    required String time,
    SlotOccupiedInfo? info,
    String? subtitle,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahSlotOccupiedDetailDrawer(
        time: time,
        info: info,
        subtitle: subtitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final String statusLabel = info?.statusLabel ?? 'Telah Digunakan';
    final bool isPast =
        statusLabel == 'Sudah Selesai' || statusLabel == 'Terlewati';
    final bool isOwn = statusLabel == 'Jadwal Anda';

    final String displayTitle = isPast
        ? 'Waktu Sesi Selesai'
        : isOwn
        ? 'Jadwal Praktik Anda'
        : 'Slot Telah Digunakan';

    final String displayTime = info?.timeRange ?? 'Pukul $time WIB';
    final String occupant = isPast
        ? 'Shift Telah Terlewati'
        : isOwn
        ? 'Jadwal Praktik Anda'
        : (info?.occupiedBy ?? subtitle ?? 'Dokter Lain');

    final String reason = info?.reason ??
        (isPast
            ? 'Waktu sesi ini telah selesai dan tidak dapat dijadwalkan lagi.'
            : isOwn
            ? 'Anda telah memiliki jadwal praktik pada jam ini.'
            : 'Slot ini dialokasikan untuk jadwal praktik dokter lain.');

    final Color badgeBg = isPast
        ? (dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
            : AmanahColorTokens.neutral200)
        : isOwn
        ? (dark
            ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.15)
            : AmanahColorTokens.brand.withValues(alpha: 0.10))
        : (dark
            ? AmanahColorTokens.dangerDark.withValues(alpha: 0.15)
            : AmanahColorTokens.dangerSurface);

    final Color badgeColor = isPast
        ? (dark ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral600)
        : isOwn
        ? (dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand)
        : AmanahColorTokens.danger;

    final IconData badgeIcon = isPast
        ? Icons.history_rounded
        : isOwn
        ? Icons.event_available_rounded
        : Icons.block_rounded;

    final String locationLine = <String>[
      if (info?.poliName != null && info!.poliName!.isNotEmpty) info!.poliName!,
      if (info?.roomName != null && info!.roomName!.isNotEmpty) info!.roomName!,
    ].join(' • ');

    return AmanahBottomSheetScaffold(
      title: displayTitle,
      subtitle: displayTime,
      fixedHeightFactor: 0.38,
      minHeight: 260,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.md,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: AmanahButton.primary(
        text: 'Mengerti',
        size: AmanahButtonSize.medium,
        isFullWidth: true,
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
              : AmanahColorTokens.surfaceSecondaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                : AmanahColorTokens.neutral200,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(badgeIcon, size: 18, color: badgeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        occupant,
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.pureWhite
                              : AmanahColorTokens.neutral900,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (locationLine.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          locationLine,
                          style: TextStyle(
                            color: dark
                                ? AmanahColorTokens.neutral400
                                : AmanahColorTokens.neutral500,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              reason,
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.neutral300
                    : AmanahColorTokens.neutral600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
