import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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
        background: dark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
        foreground: const Color(0xFFEF4444),
        border: dark ? const Color(0xFFEF4444) : const Color(0xFFFEE2E2),
        icon: _AmanahBadgeIcon.live,
      ),
      AmanahBadgeVariant.trend => _AmanahBadgeStyle(
        background: dark ? const Color(0xFF0C2445) : const Color(0xFFEFF6FF),
        foreground: dark ? const Color(0xFF3B82F6) : const Color(0xFF0D66E9),
        border: dark ? const Color(0xFF1D4ED8) : const Color(0xFFDBEAFE),
        icon: _AmanahBadgeIcon.trend,
      ),
      AmanahBadgeVariant.primary => const _AmanahBadgeStyle(
        background: Color(0xFF0D66E9),
        foreground: Colors.white,
        border: Color(0xFF1D58AC),
        icon: _AmanahBadgeIcon.none,
      ),
      AmanahBadgeVariant.success => const _AmanahBadgeStyle(
        background: Color(0xFF38C474),
        foreground: Colors.white,
        border: Color(0xFF38C474),
        icon: _AmanahBadgeIcon.none,
      ),
      AmanahBadgeVariant.warning => _AmanahBadgeStyle(
        background: dark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
        foreground: const Color(0xFFF59E0B),
        border: dark ? const Color(0xFFF59E0B) : const Color(0xFFFDE68A),
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
                fontFamily: 'PlusJakartaSans',
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
