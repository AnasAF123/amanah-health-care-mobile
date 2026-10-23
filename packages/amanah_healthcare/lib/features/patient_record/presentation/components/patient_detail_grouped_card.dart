import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Reusable utility for clinical data masking.
abstract final class PatientDataMasker {
  /// Standard Indonesian NIK masking (e.g. 2322323232232323 -> 232232******2323).
  static String maskNik(String? nik) {
    if (nik == null || nik.trim().isEmpty) return '-';
    final String clean = nik.trim();
    if (clean.length == 16) {
      return '${clean.substring(0, 6)}******${clean.substring(12)}';
    }
    if (clean.length >= 8) {
      final int prefixLen = clean.length > 10 ? 4 : 2;
      final int suffixLen = clean.length > 10 ? 3 : 2;
      final int maskLen = clean.length - prefixLen - suffixLen;
      return '${clean.substring(0, prefixLen)}${'*' * maskLen}${clean.substring(clean.length - suffixLen)}';
    }
    return clean;
  }
}

/// Grouped inset section card container with a subtle section label above it.
/// Matches modern minimalist iOS/Grok profile and settings list style.
class PatientDetailGroupSection extends StatelessWidget {
  const PatientDetailGroupSection({
    super.key,
    required this.title,
    required this.children,
    required this.isDark,
    this.bottomSpacing = 20,
  });

  final String title;
  final List<Widget> children;
  final bool isDark;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? AmanahColorTokens.surfaceSecondaryDark
                  : AmanahColorTokens.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral200,
                width: 1,
              ),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ],
      ),
    );
  }
}

/// Minimalist list tile inside [PatientDetailGroupSection].
/// Displays leading monochrome icon, primary value text, and secondary description label.
class PatientDetailTile extends StatelessWidget {
  const PatientDetailTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.showDivider = true,
    this.maxLines = 3,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool showDivider;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 20,
                color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      value.isNotEmpty ? value : '-',
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? AmanahColorTokens.surfaceLight
                            : AmanahColorTokens.neutral900,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AmanahColorTokens.neutral800.withValues(alpha: 0.6)
                  : AmanahColorTokens.neutral100,
            ),
          ),
      ],
    );
  }
}

/// Interactive Action list tile inside [PatientDetailGroupSection].
/// Displays a chevron right icon, optional badge count chip, and triggers [onTap].
class PatientDetailActionTile extends StatelessWidget {
  const PatientDetailActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.isDark,
    this.badgeText,
    this.showDivider = true,
    this.maxLines = 2,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isDark;
  final String? badgeText;
  final bool showDivider;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 20,
                    color: isDark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brandPrimary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          value.isNotEmpty ? value : '-',
                          maxLines: maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? AmanahColorTokens.surfaceLight
                                : AmanahColorTokens.neutral900,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            color: isDark
                                ? AmanahColorTokens.neutral400
                                : AmanahColorTokens.neutral500,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (badgeText != null && badgeText!.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.16)
                            : AmanahColorTokens.brand.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.32)
                              : AmanahColorTokens.brand.withValues(alpha: 0.20),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        badgeText!,
                        style: TextStyle(
                          color: isDark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brandPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AmanahColorTokens.neutral800.withValues(alpha: 0.6)
                  : AmanahColorTokens.neutral100,
            ),
          ),
      ],
    );
  }
}
