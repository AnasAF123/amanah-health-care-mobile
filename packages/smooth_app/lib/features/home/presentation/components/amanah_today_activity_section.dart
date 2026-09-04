import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_empty_state.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_status_badge.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

/// Organism: TodayActivitySection matching TodayActivitySection.tsx (.web)
/// Displays today's patient queue and completed practice metrics with 1:1 fidelity.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Aktivitas hari ini',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AmanahButton.secondary(
                text: 'Detail',
                trailingIcon: Icons.chevron_right_rounded,
                size: AmanahButtonSize.small,
                customHeight: 30,
                borderRadius: BorderRadius.circular(999),
                onPressed: onDetailTap,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Activity Cards Row (Flex 1:1)
        if (activities.isEmpty)
          const AmanahEmptyState.card(
            icon: Icons.insights_rounded,
            title: 'Belum Ada Data Aktivitas',
            message:
                'Tidak ada ringkasan aktivitas dan antrean klinis untuk hari ini.',
          )
        else
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

/// Molecule: ActivityCard matching ActivityCard.tsx (.web)
/// Renders ambient gradient glow, circular icon badge, status pill, title, and bold counter.
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
    final bool dark = AmanahThemeTokens.isDark(context);
    final bool isBlue = item.icon == AmanahActivityIcon.users;

    final Color iconBg = dark
        ? AmanahThemeTokens.surfaceSecondary(context)
        : AmanahColorTokens.brandSurface;

    const Color iconColor = AmanahColorTokens.brand;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 146,
          decoration: BoxDecoration(
            color: AmanahThemeTokens.surface(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AmanahThemeTokens.outline(context),
              width: 1.0,
            ),
            boxShadow: <BoxShadow>[
              AmanahElevation.soft(dark: dark),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: <Widget>[
                // Corner Ambient Gradient Glow (Matching web -top-6 / -bottom-6)
                Positioned(
                  right: -24,
                  top: isBlue ? -24 : null,
                  bottom: !isBlue ? -24 : null,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isBlue
                            ? <Color>[
                                const Color(
                                  0xFF0D66E9,
                                ).withValues(alpha: dark ? 0.30 : 0.20),
                                const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: dark ? 0.15 : 0.10),
                                const Color(0x003B82F6),
                              ]
                            : <Color>[
                                const Color(
                                  0xFF0D66E9,
                                ).withValues(alpha: dark ? 0.28 : 0.20),
                                const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: dark ? 0.20 : 0.15),
                                const Color(0x002563EB),
                              ],
                        stops: const <double>[0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),

                // Foreground Content Hierarchy
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Top Row: Icon Container & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                amanahActivityIconData(item.icon),
                                size: 17,
                                color: iconColor,
                              ),
                            ),
                          ),
                          AmanahStatusBadge(
                            variant: item.badgeVariant,
                            text: item.badgeText,
                          ),
                        ],
                      ),

                      // Bottom Row: Metric Title, Value & Unit
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: AmanahThemeTokens.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Text(
                                item.count,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.0,
                                  height: 1.0,
                                  color: AmanahThemeTokens.textPrimary(context),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.unit,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                  color: AmanahThemeTokens.textTertiary(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
