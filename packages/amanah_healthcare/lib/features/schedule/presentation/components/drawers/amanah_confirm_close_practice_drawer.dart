import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_session_builder.dart';

/// Modal Drawer for confirming practice closure on edit schedule.
class AmanahConfirmClosePracticeDrawer extends StatelessWidget {
  const AmanahConfirmClosePracticeDrawer({
    required this.date,
    super.key,
  });

  final DateTime date;

  static Future<bool> show(
    BuildContext context, {
    required DateTime date,
  }) async {
    final bool? result = await showAmanahBottomSheet<bool>(
      context: context,
      builder: (BuildContext ctx) =>
          AmanahConfirmClosePracticeDrawer(date: date),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final String formattedDate = formatIndonesianDate(date);

    return AmanahBottomSheetScaffold(
      title: 'Tutup Jadwal Praktik',
      subtitle: 'Konfirmasi Penonaktifan Jadwal',
      maxHeightFactor: 0.42,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.md,
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
      ),
      footer: AmanahActionRow(
        axis: AmanahActionRowAxis.horizontal,
        secondary: AmanahButton.ghost(
          text: 'Batal',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        primary: AmanahButton.destructive(
          text: 'Ya, Tutup',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.dangerDark.withValues(alpha: 0.14)
                  : AmanahColorTokens.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: dark
                    ? AmanahColorTokens.dangerDark.withValues(alpha: 0.35)
                    : AmanahColorTokens.danger.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: dark
                        ? AmanahColorTokens.dangerDark.withValues(alpha: 0.25)
                        : AmanahColorTokens.danger.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_busy_rounded,
                    color: AmanahColorTokens.danger,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Apakah Anda yakin ingin menutup jadwal praktik pada $formattedDate?',
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.pureWhite
                              : AmanahColorTokens.neutral900,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Status jadwal akan diubah menjadi "Tutup" dan seluruh sesi praktik serta antrean pada tanggal ini akan dinonaktifkan.',
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral600,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
