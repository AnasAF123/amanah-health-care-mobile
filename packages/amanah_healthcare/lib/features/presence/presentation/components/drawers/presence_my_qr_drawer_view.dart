import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_qr_code_widget.dart';

class PresenceMyQrDrawerView extends StatelessWidget {
  const PresenceMyQrDrawerView({
    required this.userQrValue,
    required this.copiedFeedback,
    required this.onBack,
    required this.onCopy,
    required this.onDownload,
    required this.dark,
    super.key,
  });

  final String userQrValue;
  final bool copiedFeedback;
  final VoidCallback onBack;
  final VoidCallback onCopy;
  final VoidCallback onDownload;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color subtextColor =
        dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 16,
                color: AmanahColorTokens.brandPrimary,
              ),
              label: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AmanahColorTokens.brandPrimary,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: onCopy,
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 16,
                  ),
                  tooltip: 'Salin Kode',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    backgroundColor: dark
                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                        : AmanahColorTokens.canvasLight,
                    foregroundColor: subtextColor,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDownload,
                  icon: const Icon(
                    Icons.download_rounded,
                    size: 16,
                  ),
                  tooltip: 'Unduh QR',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    backgroundColor: dark
                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                        : AmanahColorTokens.canvasLight,
                    foregroundColor: subtextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Vector SVG QR Code Widget (152x152)
        AmanahQrCodeWidget(
          value: userQrValue,
          size: 152,
        ),
        const SizedBox(height: 12),

        // Prominent Code Container (dynamic user staff code / presence token, no hardcoded dummy)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AmanahColorTokens.brandAccent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AmanahColorTokens.brandAccent.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            userQrValue,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: AmanahColorTokens.brandAccent,
            ),
          ),
        ),

        if (copiedFeedback) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            'Kode $userQrValue berhasil disalin',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AmanahColorTokens.brand,
            ),
          ),
        ],
      ],
    );
  }
}
