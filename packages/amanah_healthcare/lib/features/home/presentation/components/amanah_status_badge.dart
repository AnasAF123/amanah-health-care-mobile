import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_home_data.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class AmanahStatusBadge extends StatelessWidget {
  const AmanahStatusBadge({
    required this.variant,
    required this.text,
    super.key,
  });

  final AmanahBadgeVariant variant;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final _AmanahBadgeStyle style = switch (variant) {
      AmanahBadgeVariant.live => _AmanahBadgeStyle(
        background: dark
            ? AmanahColorTokens.danger.withValues(alpha: 0.18)
            : AmanahColorTokens.dangerSurface,
        foreground: AmanahColorTokens.danger,
        border: dark
            ? AmanahColorTokens.danger.withValues(alpha: 0.40)
            : AmanahColorTokens.dangerBorder,
        icon: _AmanahBadgeIcon.live,
      ),
      AmanahBadgeVariant.trend => _AmanahBadgeStyle(
        background: dark
            ? AmanahColorTokens.cyanAccent.withValues(alpha: 0.18)
            : AmanahColorTokens.brandSurface,
        foreground: dark
            ? AmanahColorTokens.cyanAccent
            : AmanahColorTokens.brand,
        border: dark
            ? AmanahColorTokens.auroraCyanDark.withValues(alpha: 0.40)
            : AmanahColorTokens.brandMuted,
        icon: _AmanahBadgeIcon.trend,
      ),
      AmanahBadgeVariant.primary => _AmanahBadgeStyle(
        background: dark
            ? AmanahColorTokens.surfaceAccentDark
            : AmanahColorTokens.brand,
        foreground: dark
            ? AmanahColorTokens.cyanAccent
            : AmanahColorTokens.pureWhite,
        border: dark
            ? AmanahColorTokens.btnCrispBlueDarkBorder
            : AmanahColorTokens.btnCrispBlueBorder,
        icon: _AmanahBadgeIcon.none,
      ),
      AmanahBadgeVariant.success => const _AmanahBadgeStyle(
        background: AmanahColorTokens.emerald,
        foreground: AmanahColorTokens.pureWhite,
        border: AmanahColorTokens.emerald,
        icon: _AmanahBadgeIcon.none,
      ),
      AmanahBadgeVariant.warning => _AmanahBadgeStyle(
        background: dark
            ? AmanahColorTokens.warning.withValues(alpha: 0.18)
            : AmanahColorTokens.warningSurface,
        foreground: AmanahColorTokens.warning,
        border: dark
            ? AmanahColorTokens.warning.withValues(alpha: 0.40)
            : AmanahColorTokens.warningBorder,
        icon: _AmanahBadgeIcon.none,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(
          variant == AmanahBadgeVariant.live ||
                  variant == AmanahBadgeVariant.trend
              ? 6
              : 999,
        ),
        border: Border.all(color: style.border.withValues(alpha: 0.72)),
        boxShadow:
            variant == AmanahBadgeVariant.primary ||
                variant == AmanahBadgeVariant.success
            ? <BoxShadow>[
                BoxShadow(
                  color: style.background.withValues(alpha: 0.20),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SMALL_SPACE,
          vertical: VERY_SMALL_SPACE,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (style.icon == _AmanahBadgeIcon.live) ...<Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: style.foreground,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(width: 6, height: 6),
              ),
              const SizedBox(width: 6),
            ] else if (style.icon == _AmanahBadgeIcon.trend) ...<Widget>[
              Icon(
                Icons.trending_up_rounded,
                size: 11,
                color: style.foreground,
              ),
              const SizedBox(width: VERY_SMALL_SPACE),
            ],
            Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: style.foreground,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmanahBadgeStyle {
  const _AmanahBadgeStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final _AmanahBadgeIcon icon;
}

enum _AmanahBadgeIcon { none, live, trend }
