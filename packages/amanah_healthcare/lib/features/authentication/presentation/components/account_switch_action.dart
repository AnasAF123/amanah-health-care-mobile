import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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
    final bool dark = theme.brightness == Brightness.dark;

    final Color messageColor = dark
        ? AmanahColorTokens.neutral400
        : AmanahColorTokens.neutral600;
    final Color actionColor = dark
        ? AmanahColorTokens.tabActiveDark
        : AmanahColorTokens.brand;

    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Text.rich(
            TextSpan(
              text: '${message.trim()} ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: messageColor,
                fontWeight: FontWeight.w500,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: actionLabel.trim(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: actionColor,
                    fontWeight: FontWeight.w700,
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
