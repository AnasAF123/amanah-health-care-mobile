import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/widgets/permission_summary_card.dart';
import 'package:amanah_healthcare/features/permission/presentation/state/permission_draft_state.dart';
import 'package:amanah_healthcare/features/permission/presentation/theme/amanah_permission_tokens.dart';

/// Stage 4: Review application recap and input detailed reason.
class PermissionReasonStage extends StatelessWidget {
  final PermissionDraftState draft;
  final TextEditingController reasonController;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const PermissionReasonStage({
    super.key,
    required this.draft,
    required this.reasonController,
    this.errorMessage,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        dark ? AmanahPermissionTokens.textTitleDark : AmanahPermissionTokens.textTitleLight;
    final Color subtextColor =
        dark ? AmanahPermissionTokens.textMutedDark : AmanahPermissionTokens.textMutedLight;

    final Color inputBg = AmanahThemeTokens.elevatedSurface(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Periksa kembali rincian permohonan Anda dan tuliskan alasan pengajuan.',
          style: TextStyle(
            fontSize: 13,
            color: subtextColor,
          ),
        ),
        const SizedBox(height: 14),

        // Summary Recap Card
        PermissionSummaryCard(draft: draft),

        const SizedBox(height: 18),

        Text(
          'Alasan / Keterangan *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),

        // Multiline Reason Input
        Container(
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(16),
            border: errorMessage != null
                ? Border.all(color: AmanahColorTokens.danger, width: 1.5)
                : null,
          ),
          child: TextField(
            controller: reasonController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText:
                  'Tuliskan alasan izin/cuti secara jelas dan lengkap (minimal 8 karakter)...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: subtextColor.withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),

        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            errorMessage!,
            style: const TextStyle(
              fontSize: 12,
              color: AmanahColorTokens.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: AmanahButton.outline(
                text: 'Batal',
                size: AmanahButtonSize.medium,
                isFullWidth: true,
                isDisabled: draft.isSubmitting,
                onPressed: onCancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AmanahButton.primary(
                text: 'Kirim Pengajuan Izin',
                size: AmanahButtonSize.medium,
                isFullWidth: true,
                isLoading: draft.isSubmitting,
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
