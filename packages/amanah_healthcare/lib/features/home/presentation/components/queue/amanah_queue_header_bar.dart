import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Top bar for Queue Dock navigation, help guide, and queue history
class AmanahQueueHeaderBar extends StatelessWidget {
  const AmanahQueueHeaderBar({
    super.key,
    required this.onBack,
    required this.onOpenGuide,
    required this.onOpenHistory,
    required this.historyCount,
    required this.showSuccess,
    this.sessionLabel,
    this.onSelectSession,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenHistory;
  final int historyCount;
  final bool showSuccess;
  final String? sessionLabel;
  final VoidCallback? onSelectSession;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: isDark
                      ? AmanahColorTokens.surfaceLight
                      : AmanahColorTokens.neutral800,
                ),
                if (onSelectSession != null && !showSuccess)
                  IconButton(
                    onPressed: onSelectSession,
                    icon: const Icon(Icons.schedule_rounded),
                    color: isDark
                        ? AmanahColorTokens.surfaceLight
                        : AmanahColorTokens.neutral800,
                    tooltip: 'Pilih Sesi Praktik',
                  ),
              ],
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: showSuccess ? 0.0 : 1.0,
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: onOpenGuide,
                  icon: const Icon(Icons.help_outline_rounded),
                  color: isDark
                      ? AmanahColorTokens.surfaceLight
                      : AmanahColorTokens.neutral800,
                  tooltip: 'Panduan Rel 3D',
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    IconButton(
                      onPressed: onOpenHistory,
                      icon: const Icon(Icons.history_rounded),
                      color: isDark
                          ? AmanahColorTokens.surfaceLight
                          : AmanahColorTokens.neutral800,
                      tooltip: 'Riwayat Antrean',
                    ),
                    if (historyCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AmanahColorTokens.brandPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$historyCount',
                            style: const TextStyle(
                              color: AmanahColorTokens.surfaceLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
