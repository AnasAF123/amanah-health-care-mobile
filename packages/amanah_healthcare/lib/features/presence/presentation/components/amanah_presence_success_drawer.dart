import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_success_core.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/amanah_presence_history_screen.dart';

class AmanahPresenceSuccessDrawer extends StatelessWidget {
  AmanahPresenceSuccessDrawer({
    required this.onClose,
    super.key,
    String? timeString,
    this.bottomPadding = 24,
    this.isCheckOut = false,
    this.validatedDurationHours,
    this.onGoHome,
    this.onViewHistory,
  }) : timeString = timeString ?? _formatCurrentTime();

  final String timeString;
  final double bottomPadding;
  final bool isCheckOut;
  final double? validatedDurationHours;
  final VoidCallback onClose;
  final VoidCallback? onGoHome;
  final VoidCallback? onViewHistory;

  static String _formatCurrentTime() {
    final DateTime now = DateTime.now();
    final String h = now.hour.toString().padLeft(2, '0');
    final String m = now.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  static Future<void> show(
    BuildContext context, {
    String? timeString,
    bool isCheckOut = false,
    double? validatedDurationHours,
    double bottomPadding = 24,
    VoidCallback? onGoHome,
    VoidCallback? onViewHistory,
  }) {
    final NavigatorState parentNavigator = Navigator.of(context);

    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahPresenceSuccessDrawer(
        timeString: timeString,
        isCheckOut: isCheckOut,
        validatedDurationHours: validatedDurationHours,
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
      isCheckOut: isCheckOut,
      validatedDurationHours: validatedDurationHours,
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
