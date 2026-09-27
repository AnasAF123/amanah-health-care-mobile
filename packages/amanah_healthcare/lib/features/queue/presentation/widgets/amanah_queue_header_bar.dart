import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahQueueHeaderBar extends StatelessWidget {
  const AmanahQueueHeaderBar({
    required this.onBack,
    required this.onOpenGuide,
    required this.onOpenHistory,
    required this.historyCount,
    required this.showSuccess,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenHistory;
  final int historyCount;
  final bool showSuccess;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: showSuccess ? 0.0 : 1.0,
      child: AmanahScreenHeader.actionOnly(
        onBack: onBack,
        backgroundColor: Colors.transparent,
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: isDark
                ? AmanahColorTokens.pureWhite
                : AmanahColorTokens.neutral800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isDark
                ? BorderSide(
                    color: AmanahColorTokens.pureWhite.withValues(alpha: 0.12),
                  )
                : BorderSide.none,
          ),
          color: isDark
              ? AmanahColorTokens.surfaceElevatedDark
              : AmanahColorTokens.surfaceLight,
          onSelected: (String val) {
            if (val == 'guide') {
              onOpenGuide();
            } else if (val == 'history') {
              onOpenHistory();
            }
          },
          itemBuilder: (_) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'guide',
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    color: isDark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brandPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Panduan antrean',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AmanahColorTokens.pureWhite
                          : AmanahColorTokens.neutral900,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'history',
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.history_rounded,
                    color: isDark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brandPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Riwayat antrean',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AmanahColorTokens.pureWhite
                          : AmanahColorTokens.neutral900,
                    ),
                  ),
                  if (historyCount > 0) ...<Widget>[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AmanahColorTokens.cyanAccent
                                .withValues(alpha: 0.16)
                            : AmanahColorTokens.brandMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$historyCount',
                        style: TextStyle(
                          color: isDark
                              ? AmanahColorTokens.cyanAccent
                              : AmanahColorTokens.brandPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
