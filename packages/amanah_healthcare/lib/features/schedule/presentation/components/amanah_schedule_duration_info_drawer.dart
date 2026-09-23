import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Modal bottom sheet drawer explaining doctor consultation duration policy.
///
/// Follows the design language and behavior of [AmanahPresenceInfoDrawer].
class AmanahScheduleDurationInfoDrawer extends StatelessWidget {
  const AmanahScheduleDurationInfoDrawer({
    required this.durationMinutes,
    super.key,
  });

  /// The authoritative consultation duration per patient from database/policy.
  final int durationMinutes;

  static void show(
    BuildContext context, {
    required int durationMinutes,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahScheduleDurationInfoDrawer(
        durationMinutes: durationMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color subtextColor =
        dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    return AmanahBottomSheetScaffold(
      title: 'Ketentuan Waktu Praktik',
      subtitle: 'Informasi kebijakan durasi konsultasi per pasien',
      fixedHeightFactor: 0.62,
      minHeight: 380,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: AmanahButton.primary(
        text: 'Mengerti',
        size: AmanahButtonSize.medium,
        isFullWidth: true,
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sistem menjadwalkan alur praktik dan antrean konsultasi secara otomatis sesuai ketentuan manajemen RS Amanah:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: subtextColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _SchedulePolicyRow(
            dotColor: dark
                ? AmanahColorTokens.tabActiveDark
                : AmanahColorTokens.brand,
            title: 'Durasi per Pasien',
            description: '$durationMinutes Menit',
            highlightDescription: true,
          ),
          const _SchedulePolicyRow(
            dotColor: AmanahColorTokens.success,
            title: 'Jam Selesai ("To")',
            description: 'Dihitung Otomatis',
          ),
          const _SchedulePolicyRow(
            dotColor: AmanahColorTokens.amberLight,
            title: 'Kapasitas Sesi',
            description: 'Batas Akhir Shift',
          ),
          const _SchedulePolicyRow(
            dotColor: AmanahColorTokens.tabActiveDark,
            title: 'Pengaturan Kebijakan',
            description: 'Dikelola oleh Admin Klinik',
            isLast: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                  : AmanahColorTokens.brandLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dark
                    ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.20)
                    : AmanahColorTokens.brand.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: dark
                      ? AmanahColorTokens.tabActiveDark
                      : AmanahColorTokens.brand,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Dokter cukup menentukan jam mulai praktik ("From"). Jam selesai dan alokasi antrean pasien akan terisi otomatis tanpa perlu penghitungan manual.',
                    style: TextStyle(
                      color: dark
                          ? AmanahColorTokens.pureWhite
                          : AmanahColorTokens.brandAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}

class _SchedulePolicyRow extends StatelessWidget {
  const _SchedulePolicyRow({
    required this.dotColor,
    required this.title,
    required this.description,
    this.highlightDescription = false,
    this.isLast = false,
  });

  final Color dotColor;
  final String title;
  final String description;
  final bool highlightDescription;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.06)
                      : AmanahColorTokens.neutral100,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: dark
                      ? AmanahColorTokens.pureWhite
                      : AmanahColorTokens.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              description,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: highlightDescription ? FontWeight.w800 : FontWeight.w600,
                color: highlightDescription
                    ? (dark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brand)
                    : (dark
                        ? AmanahColorTokens.neutral300
                        : AmanahColorTokens.neutral600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
