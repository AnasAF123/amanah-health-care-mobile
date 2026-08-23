import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AuthStatusMessage extends StatelessWidget {
  const AuthStatusMessage({
    required this.message,
    required this.isError,
    super.key,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background = isError
        ? theme.colorScheme.error.withValues(alpha: 0.10)
        : theme.colorScheme.primary.withValues(alpha: 0.10);
    final Color foreground = isError
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: LARGE_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: ANGULAR_BORDER_RADIUS,
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }
}
