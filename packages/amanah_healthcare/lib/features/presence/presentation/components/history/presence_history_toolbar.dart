import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class PresenceHistoryToolbar extends StatelessWidget {
  const PresenceHistoryToolbar({
    required this.textColor,
    required this.subtextColor,
    required this.dark,
    required this.hasActiveFilters,
    required this.isDownloading,
    required this.onOpenInfo,
    required this.onOpenFilter,
    required this.onDownloadPdf,
    super.key,
  });

  final Color textColor;
  final Color subtextColor;
  final bool dark;
  final bool hasActiveFilters;
  final bool isDownloading;
  final VoidCallback onOpenInfo;
  final VoidCallback onOpenFilter;
  final VoidCallback onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onOpenInfo,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                      : AmanahColorTokens.canvasLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: subtextColor,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            // Filter Button
            InkWell(
              onTap: onOpenFilter,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: hasActiveFilters
                      ? (dark
                          ? AmanahColorTokens.tabActiveDark
                              .withValues(alpha: 0.16)
                          : AmanahColorTokens.brandSurface)
                      : (dark
                          ? AmanahColorTokens.surfaceLight
                              .withValues(alpha: 0.05)
                          : AmanahColorTokens.surfaceLight),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasActiveFilters
                        ? (dark
                            ? AmanahColorTokens.tabActiveDark
                                .withValues(alpha: 0.50)
                            : AmanahColorTokens.brandAccent)
                        : (dark
                            ? AmanahColorTokens.surfaceLight
                                .withValues(alpha: 0.10)
                            : AmanahColorTokens.neutral200),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: hasActiveFilters
                          ? (dark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brandPrimary)
                          : subtextColor,
                    ),
                    if (hasActiveFilters)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dark
                                ? AmanahColorTokens.tabActiveDark
                                : AmanahColorTokens.brandAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Download PDF Button
            InkWell(
              onTap: onDownloadPdf,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                      : AmanahColorTokens.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: dark
                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                        : AmanahColorTokens.neutral200,
                  ),
                ),
                child: isDownloading
                    ? const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AmanahColorTokens.brandPrimary,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.download_rounded,
                        size: 16,
                        color: subtextColor,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
