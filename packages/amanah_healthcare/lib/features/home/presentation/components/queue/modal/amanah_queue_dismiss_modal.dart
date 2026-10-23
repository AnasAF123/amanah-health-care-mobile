import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Enum representing the action to take when an appointment card is swiped up.
enum AmanahQueueDismissAction { cancel, noShow }

/// Modal bottom sheet allowing the practitioner to choose between
/// cancelling an appointment or marking the patient as no-show.
class AmanahQueueDismissModal extends StatelessWidget {
  const AmanahQueueDismissModal({required this.patientName, required this.queueNumber, super.key});

  final String patientName;
  final String queueNumber;

  static Future<AmanahQueueDismissAction?> show(
    BuildContext context, {
    required String patientName,
    required String queueNumber,
  }) {
    return showAmanahBottomSheet<AmanahQueueDismissAction>(
      context: context,
      builder: (_) => AmanahQueueDismissModal(patientName: patientName, queueNumber: queueNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AmanahThemeTokens.isDark(context);

    return AmanahBottomSheetScaffold(
      title: 'Tindakan Antrean Pasien',
      subtitle: 'Antrean $queueNumber • $patientName',
      hugContent: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _AmanahDismissOptionTile(
            title: 'Batalkan Janji Temu',
            subtitle: 'Batalkan janji temu pasien ini karena kendala medis atau permintaan pasien.',
            icon: Icons.cancel_outlined,
            iconColor: AmanahColorTokens.danger,
            iconBackgroundColor: isDark
                ? AmanahColorTokens.danger.withValues(alpha: 0.16)
                : AmanahColorTokens.dangerSurface,
            onTap: () => Navigator.of(context).pop(AmanahQueueDismissAction.cancel),
          ),
          const SizedBox(height: AmanahSpacing.sm),
          _AmanahDismissOptionTile(
            title: 'Tandai Tidak Hadir (No-Show)',
            subtitle:
                'Pasien tidak berada di ruang tunggu atau melewati giliran pemanggilan antrean.',
            icon: Icons.person_off_outlined,
            iconColor: AmanahColorTokens.warning,
            iconBackgroundColor: isDark
                ? AmanahColorTokens.warning.withValues(alpha: 0.16)
                : AmanahColorTokens.warningSurface,
            onTap: () => Navigator.of(context).pop(AmanahQueueDismissAction.noShow),
          ),
          const SizedBox(height: AmanahSpacing.md),
        ],
      ),
    );
  }
}

class _AmanahDismissOptionTile extends StatelessWidget {
  const _AmanahDismissOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AmanahThemeTokens.isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AmanahRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AmanahColorTokens.surfaceDark : AmanahColorTokens.surfaceLight,
            borderRadius: BorderRadius.circular(AmanahRadius.lg),
            border: Border.all(color: AmanahThemeTokens.outline(context)),
          ),
          padding: const EdgeInsets.all(AmanahSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(AmanahRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AmanahSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AmanahThemeTokens.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AmanahSpacing.xxs),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AmanahThemeTokens.textSecondary(context),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AmanahSpacing.xs),
              Icon(Icons.chevron_right, size: 20, color: AmanahThemeTokens.textMuted(context)),
            ],
          ),
        ),
      ),
    );
  }
}
