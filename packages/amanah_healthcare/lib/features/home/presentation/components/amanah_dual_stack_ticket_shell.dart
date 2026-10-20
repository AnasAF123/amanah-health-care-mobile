import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Molecular / Organism Container: Dual-Stack Ticket Shell.
/// Combines a primary upper card/stack with a secondary stacked element beneath it
/// featuring authentic pixelated texture (`AmanahPixelTexture`) and an exposed bottom lip/rim.
/// Styled 1:1 with the signature doctor profile SIP header (`AmanahDualStackProfileCard`).
class AmanahDualStackTicketShell extends StatelessWidget {
  const AmanahDualStackTicketShell({
    required this.child,
    this.onBottomActionTap,
    this.bottomTitle = 'Laporan Slip Gaji & Insentif',
    this.bottomActionLabel = 'Lihat Gaji',
    this.bottomLeadingIcon = Icons.receipt_long_rounded,
    this.showBottomLip = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onBottomActionTap;
  final String bottomTitle;
  final String bottomActionLabel;
  final IconData bottomLeadingIcon;
  final bool showBottomLip;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    if (!showBottomLip) {
      return child;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AmanahThemeTokens.surfaceHighlight(context),
        border: Border.all(
          color: dark
              ? AmanahThemeTokens.outlineStrong(context)
              : AmanahColorTokens.brandMuted,
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dark
                ? AmanahColorTokens.pureBlack.withValues(alpha: 0.40)
                : AmanahColorTokens.sky.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: AmanahPixelTexture(
                isDark: dark,
                opacity: dark ? 0.28 : 0.22,
                maskType: AmanahPixelMaskType.horizontalEdges,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Upper Stack / Ticket Child
                child,

                // Exposed Bottom Lip / Action Rim
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBottomActionTap,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  bottomLeadingIcon,
                                  size: 18,
                                  color: dark
                                      ? AmanahColorTokens.cyanLight
                                      : AmanahColorTokens.brandNavy,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    bottomTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: dark
                                          ? AmanahColorTokens.surfaceLight
                                          : AmanahColorTokens.brandNavy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                bottomActionLabel,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: dark
                                      ? AmanahColorTokens.cyanLight
                                      : AmanahColorTokens.skyDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: dark
                                      ? AmanahColorTokens.tabActiveDark
                                      : AmanahColorTokens.brandNavy,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: dark
                                      ? AmanahColorTokens.brandNavy
                                      : AmanahColorTokens.cyanLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
