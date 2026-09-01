import 'package:flutter/material.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_presence_success_core.dart';
import 'package:smooth_app/features/presence/presentation/screen/amanah_presence_history_screen.dart';

class AmanahPresenceSuccessDrawer extends StatelessWidget {
  const AmanahPresenceSuccessDrawer({
    required this.onClose,
    super.key,
    this.timeString = '07:55 WIB',
    this.bottomPadding = 24,
    this.onGoHome,
    this.onViewHistory,
  });

  final String timeString;
  final double bottomPadding;
  final VoidCallback onClose;
  final VoidCallback? onGoHome;
  final VoidCallback? onViewHistory;

  static Future<void> show(
    BuildContext context, {
    String timeString = '07:55 WIB',
    double bottomPadding = 24,
    VoidCallback? onGoHome,
    VoidCallback? onViewHistory,
  }) {
    final NavigatorState parentNavigator = Navigator.of(context);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.40),
      builder: (BuildContext ctx) => AmanahPresenceSuccessDrawer(
        timeString: timeString,
        bottomPadding: bottomPadding,
        onClose: () => Navigator.of(ctx).pop(),
        onGoHome: () {
          Navigator.of(ctx).pop();
          onGoHome?.call();
        },
        onViewHistory: () {
          Navigator.of(ctx).pop();
          if (onViewHistory != null) {
            onViewHistory();
            return;
          }
          parentNavigator.push(AmanahPresenceHistoryScreen.route());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AmanahPresenceSuccessCore(
      timeString: timeString,
      bottomPadding: bottomPadding,
      onClose: onClose,
      onGoHome:
          onGoHome ??
          () {
            onClose();
          },
      onViewHistory:
          onViewHistory ??
          () {
            onClose();
            Navigator.of(context).push(AmanahPresenceHistoryScreen.route());
          },
    );
  }
}
