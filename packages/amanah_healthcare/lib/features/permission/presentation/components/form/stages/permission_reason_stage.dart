import 'package:flutter/material.dart';
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
    final Color borderColor = errorMessage != null
        ? AmanahColorTokens.danger
        : (dark
            ? AmanahPermissionTokens.cardBorderDark
            : AmanahPermissionTokens.cardBorderLight);

    final Color inputBg = dark
        ? AmanahColorTokens.surfaceDark
        : AmanahColorTokens.surfaceLight;

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
            border: Border.all(color: borderColor),
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
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: draft.isSubmitting ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: dark
                          ? AmanahPermissionTokens.cardBorderDark
                          : AmanahPermissionTokens.cardBorderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: draft.isSubmitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AmanahColorTokens.brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: draft.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim Pengajuan Izin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
