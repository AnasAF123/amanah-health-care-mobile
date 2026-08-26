import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_status_badge.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AmanahTodayActivitySection extends StatelessWidget {
  const AmanahTodayActivitySection({
    required this.activities,
    required this.onDetailTap,
    required this.onActivityTap,
    super.key,
  });

  final List<AmanahActivityMetric> activities;
  final VoidCallback onDetailTap;
  final ValueChanged<AmanahActivityMetric> onActivityTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VERY_SMALL_SPACE),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Aktivitas hari ini',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: dark ? Colors.white : const Color(0xFF1A1D2E),
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _DetailButton(onTap: onDetailTap, dark: dark),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Activity Cards Row
        Row(
          children: <Widget>[
            for (int i = 0; i < activities.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: AmanahActivityCard(
                  item: activities[i],
                  onTap: () => onActivityTap(activities[i]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DetailButton extends StatelessWidget {
  const _DetailButton({required this.onTap, required this.dark});

  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color textColor = dark
        ? const Color(0xFF38BDF8)
        : const Color(0xFF0A44FF);

    return Semantics(
      button: true,
      label: 'Lihat detail aktivitas',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Detail',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AmanahActivityCard extends StatelessWidget {
  const AmanahActivityCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final AmanahActivityMetric item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final bool isBlue = item.glow == AmanahActivityGlow.blue;

    final Color iconBg = dark
        ? (isBlue ? const Color(0xFF0B214D) : const Color(0xFF063E2D))
        : (isBlue ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5));

    final Color iconColor = isBlue
        ? (dark ? const Color(0xFF38BDF8) : const Color(0xFF0A44FF))
        : const Color(0xFF38C474);

    return Semantics(
      button: true,
      label: '${item.title}, ${item.count} ${item.unit}',
      child: Container(
        height: 142,
        decoration: BoxDecoration(
          color: dark ? const Color(0xE6171717) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: dark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFF1F5F9),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.36 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: <Widget>[
              // Corner Ambient Gradient Glow (Clean luminous falloff, 0% black artifact)
              Positioned(
                right: -24,
                top: isBlue ? -24 : null,
                bottom: !isBlue ? -24 : null,
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isBlue
                          ? <Color>[
                              const Color(0xFF0A44FF)
                                  .withValues(alpha: dark ? 0.28 : 0.18),
                              const Color(0xFF00D4FF)
                                  .withValues(alpha: dark ? 0.14 : 0.09),
                              const Color(0x0000D4FF),
                            ]
                          : <Color>[
                              const Color(0xFF38C474)
                                  .withValues(alpha: dark ? 0.28 : 0.20),
                              const Color(0xFF00D4FF)
                                  .withValues(alpha: dark ? 0.12 : 0.08),
                              const Color(0x0038C474),
                            ],
                      stops: const <double>[0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              // Card Content
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Top row: Icon & StatusBadge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: iconBg,
                                shape: BoxShape.circle,
                                border: dark
                                    ? Border.all(
                                        color: iconColor.withValues(alpha: 0.25),
                                      )
                                    : null,
                              ),
                              child: Icon(
                                amanahActivityIconData(item.icon),
                                size: 18,
                                color: iconColor,
                              ),
                            ),
                            AmanahStatusBadge(
                              variant: item.badgeVariant,
                              text: item.badgeText,
                            ),
                          ],
                        ),
                        // Bottom section: Title & Value
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: dark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: <Widget>[
                                  Text(
                                    item.count,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      color: dark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.unit,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: dark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF94A3B8),
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }
}
