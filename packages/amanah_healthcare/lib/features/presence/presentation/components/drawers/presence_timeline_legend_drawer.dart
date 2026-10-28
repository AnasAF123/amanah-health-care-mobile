import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Info / Legend Master Drawer ("Keterangan Timeline Presensi")
class AmanahPresenceInfoDrawer extends StatelessWidget {
  const AmanahPresenceInfoDrawer({super.key});

  static void show(BuildContext context) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => const AmanahPresenceInfoDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color subtextColor = dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    return AmanahBottomSheetScaffold(
      title: 'Keterangan Timeline Presensi',
      fixedHeightFactor: 0.55,
      minHeight: 340,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Data timeline presensi diakumulasikan secara otomatis setiap bulan berdasarkan shift dan jadwal yang terdaftar di sistem RS Amanah:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: subtextColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          const _InfoStatusRow(
            dotColor: AmanahColorTokens.success,
            title: 'Hadir',
            description: 'Tepat waktu sesuai shift',
          ),
          const _InfoStatusRow(
            dotColor: AmanahColorTokens.amberLight,
            title: 'Telat',
            description: 'Melewati toleransi shift',
          ),
          const _InfoStatusRow(
            dotColor: AmanahColorTokens.danger,
            title: 'Missed',
            description: 'Tidak tercatat check-in',
          ),
          const _InfoStatusRow(
            dotColor: AmanahColorTokens.violet,
            title: 'Cuti',
            description: 'Izin atau cuti resmi HRD',
            isLast: true,
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}

class _InfoStatusRow extends StatelessWidget {
  const _InfoStatusRow({
    required this.dotColor,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final Color dotColor;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
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
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
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
                fontWeight: FontWeight.w500,
                color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
