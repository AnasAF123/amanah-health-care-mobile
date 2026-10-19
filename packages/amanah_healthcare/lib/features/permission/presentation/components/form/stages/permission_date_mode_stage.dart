import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/presentation/theme/amanah_permission_tokens.dart';

/// Stage 2: Select date mode via horizontal grid (Hari Ini vs Rentang Tanggal).
class PermissionDateModeStage extends StatelessWidget {
  final CalendarDateRange dateRange;
  final bool isCustomDateRange;
  final VoidCallback onTodaySelected;
  final VoidCallback onCustomRangeSelected;
  final bool isTodayEligible;
  final String? todayDisabledReason;

  const PermissionDateModeStage({
    super.key,
    required this.dateRange,
    required this.isCustomDateRange,
    required this.onTodaySelected,
    required this.onCustomRangeSelected,
    this.isTodayEligible = true,
    this.todayDisabledReason,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        dark ? AmanahPermissionTokens.textTitleDark : AmanahPermissionTokens.textTitleLight;
    final Color subtextColor =
        dark ? AmanahPermissionTokens.textMutedDark : AmanahPermissionTokens.textMutedLight;
    final Color borderColor = dark
        ? AmanahPermissionTokens.cardBorderDark
        : AmanahPermissionTokens.cardBorderLight;

    final DateTime now = DateTime.now();
    final String dayName = formatLocalizedDate(now, style: 'day_name');
    final String dateShort = formatLocalizedDate(now, style: 'human_short');
    final String todayFormatted = '$dayName, $dateShort';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Pilih pengajuan untuk hari ini atau tentukan rentang tanggal izin.',
          style: TextStyle(
            fontSize: 13,
            color: subtextColor,
          ),
        ),
        const SizedBox(height: 18),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Option 1: Hari Ini (Auto-advance to scope if eligible)
              Expanded(
                child: _buildDateModeCard(
                  context: context,
                  title: 'Hari Ini',
                  subtitle: isTodayEligible
                      ? todayFormatted
                      : (todayDisabledReason ?? 'Jadwal hari ini telah selesai'),
                  pillText: isTodayEligible ? '1 Hari' : 'Selesai',
                  icon: isTodayEligible
                      ? Icons.today_rounded
                      : Icons.event_busy_rounded,
                  isSelected: isTodayEligible && !isCustomDateRange,
                  isEnabled: isTodayEligible,
                  onTap: isTodayEligible
                      ? onTodaySelected
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Jadwal dinas hari ini telah selesai atau Anda tidak memiliki jadwal aktif hari ini. Silakan pilih "Rentang Tanggal" untuk hari esok atau yang akan datang.',
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: AmanahColorTokens.neutral800,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                  dark: dark,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  borderColor: borderColor,
                ),
              ),
              const SizedBox(width: 12),
              // Option 2: Rentang Tanggal (Advances to dateCustom picker)
              Expanded(
                child: _buildDateModeCard(
                  context: context,
                  title: 'Rentang Tanggal',
                  subtitle: 'Lebih dari 1 hari atau kustom',
                  pillText: 'Kustom',
                  icon: Icons.date_range_rounded,
                  isSelected: isCustomDateRange,
                  isEnabled: true,
                  onTap: onCustomRangeSelected,
                  dark: dark,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  borderColor: borderColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String pillText,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool dark,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    bool isEnabled = true,
  }) {
    final Color activeBorder = isSelected ? AmanahColorTokens.brand : borderColor;
    final Color activeBg = isSelected
        ? AmanahColorTokens.brand.withValues(alpha: dark ? 0.15 : 0.08)
        : (dark ? AmanahColorTokens.surfaceDark : AmanahColorTokens.surfaceLight);

    final Widget card = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: activeBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activeBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AmanahColorTokens.brand.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AmanahColorTokens.brand
                        : (dark
                            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
                            : AmanahColorTokens.neutral50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : textColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AmanahColorTokens.brand.withValues(alpha: 0.14)
                        : (dark
                            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.06)
                            : AmanahColorTokens.neutral100),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    pillText,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AmanahColorTokens.brand : subtextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: subtextColor,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );

    if (!isEnabled) {
      return Opacity(
        opacity: 0.55,
        child: card,
      );
    }
    return card;
  }
}
