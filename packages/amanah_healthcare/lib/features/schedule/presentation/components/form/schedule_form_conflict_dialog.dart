import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Reusable Schedule Conflict & Validation Bottom Sheet Dialog
void showScheduleConflictDialog(
  BuildContext context,
  String message, {
  String title = 'Validasi Jadwal Praktik',
  String subtitle = 'Validasi Sistem Praktik Dokter',
}) {
  showAmanahBottomSheet<void>(
    context: context,
    builder: (BuildContext ctx) {
      final bool dark = Theme.of(ctx).brightness == Brightness.dark;
      return AmanahBottomSheetScaffold(
        title: title,
        subtitle: subtitle,
        maxHeightFactor: 0.45,
        footer: AmanahButton.primary(
          text: 'Mengerti',
          isFullWidth: true,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AmanahColorTokens.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AmanahColorTokens.warning.withValues(alpha: 0.40),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AmanahColorTokens.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.pureWhite
                            : AmanahColorTokens.neutral900,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
