import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Segmented tab switcher between "Izin Saya" and "Jadwal Pengganti".
/// Features a smooth animated sliding pill indicator and clean round badge counters.
class AmanahPermissionSegmentSwitcher extends StatelessWidget {
  const AmanahPermissionSegmentSwitcher({
    required this.activeSegment,
    required this.onSegmentChanged,
    required this.myLeavesCount,
    required this.openReplacementsCount,
    required this.dark,
    super.key,
  });

  final int activeSegment;
  final ValueChanged<int> onSegmentChanged;
  final int myLeavesCount;
  final int openReplacementsCount;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: dark
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
              : AmanahColorTokens.neutral100,
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.all(3),
        child: Stack(
          children: <Widget>[
            // Smooth Animated Sliding Pill Indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              alignment: activeSegment == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: dark
                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Foreground Tab Labels Row
            Row(
              children: <Widget>[
                // Tab 0: Izin Saya
                Expanded(
                  child: InkWell(
                    onTap: () => onSegmentChanged(0),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      height: 34,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Izin Saya',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: activeSegment == 0 ? FontWeight.w700 : FontWeight.w500,
                              color: activeSegment == 0
                                  ? (dark ? Colors.white : AmanahColorTokens.neutral900)
                                  : AmanahColorTokens.neutral500,
                            ),
                          ),
                          if (myLeavesCount > 0) ...<Widget>[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: activeSegment == 0
                                    ? (dark
                                          ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.20)
                                          : AmanahColorTokens.neutral200)
                                    : (dark
                                          ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                                          : AmanahColorTokens.neutral300),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '$myLeavesCount',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: activeSegment == 0
                                      ? (dark ? Colors.white : AmanahColorTokens.neutral800)
                                      : AmanahColorTokens.neutral500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Tab 1: Jadwal Pengganti
                Expanded(
                  child: InkWell(
                    onTap: () => onSegmentChanged(1),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      height: 34,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Jadwal Pengganti',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: activeSegment == 1 ? FontWeight.w700 : FontWeight.w500,
                              color: activeSegment == 1
                                  ? (dark ? Colors.white : AmanahColorTokens.neutral900)
                                  : AmanahColorTokens.neutral500,
                            ),
                          ),
                          if (openReplacementsCount > 0) ...<Widget>[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: dark
                                    ? AmanahColorTokens.tabActiveDark
                                    : AmanahColorTokens.brand,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '$openReplacementsCount',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: dark ? AmanahColorTokens.neutral950 : Colors.white,
                                ),
                              ),
                            ),
                          ],
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
