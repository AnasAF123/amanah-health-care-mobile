import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Variant style for [AmanahNoticeBanner].
enum AmanahNoticeVariant {
  info,
  warning,
  success,
  danger,
}

/// Standardized notice/warning banner component across RS Amanah mobile apps.
///
/// Designed with clean, accessible contrast and consistent typography.
class AmanahNoticeBanner extends StatelessWidget {
  const AmanahNoticeBanner({
    required this.message,
    this.variant = AmanahNoticeVariant.warning,
    this.title,
    this.icon,
    this.onClose,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final AmanahNoticeVariant variant;
  final String? title;
  final IconData? icon;
  final VoidCallback? onClose;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final (Color primaryColor, Color bgColor, Color borderColor, IconData defaultIcon) =
        switch (variant) {
      AmanahNoticeVariant.info => (
          dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand,
          dark
              ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.10)
              : AmanahColorTokens.brandLight,
          dark
              ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.25)
              : AmanahColorTokens.brand.withValues(alpha: 0.20),
          Icons.info_outline_rounded,
        ),
      AmanahNoticeVariant.warning => (
          AmanahColorTokens.warning,
          AmanahColorTokens.warning.withValues(alpha: 0.12),
          AmanahColorTokens.warning.withValues(alpha: 0.35),
          Icons.warning_amber_rounded,
        ),
      AmanahNoticeVariant.success => (
          AmanahColorTokens.success,
          AmanahColorTokens.success.withValues(alpha: 0.12),
          AmanahColorTokens.success.withValues(alpha: 0.35),
          Icons.check_circle_outline_rounded,
        ),
      AmanahNoticeVariant.danger => (
          AmanahColorTokens.danger,
          AmanahColorTokens.danger.withValues(alpha: 0.12),
          AmanahColorTokens.danger.withValues(alpha: 0.35),
          Icons.error_outline_rounded,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon ?? defaultIcon,
            size: 18,
            color: primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null && title!.isNotEmpty) ...<Widget>[
                  Text(
                    title!,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: dark ? AmanahColorTokens.pureWhite : primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...<Widget>[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onAction,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        actionLabel!,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null) ...<Widget>[
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onClose,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: primaryColor.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
