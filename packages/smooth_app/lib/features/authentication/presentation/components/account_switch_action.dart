import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';

class AccountSwitchAction extends StatelessWidget {
  const AccountSwitchAction({
    required this.message,
    required this.actionLabel,
    required this.onTap,
    super.key,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
          AmanahButton.text(
            text: actionLabel,
            onPressed: onTap,
            size: AmanahButtonSize.small,
          ),
        ],
      ),
    );
  }
}
