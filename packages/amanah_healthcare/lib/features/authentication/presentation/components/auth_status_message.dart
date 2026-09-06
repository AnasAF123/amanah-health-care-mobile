import 'package:flutter/material.dart';

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
        ? theme.colorScheme.error.withValues(alpha: 0.08)
        : theme.colorScheme.primary.withValues(alpha: 0.08);
    final Color foreground = isError
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final Color border = isError
        ? theme.colorScheme.error.withValues(alpha: 0.25)
        : theme.colorScheme.primary.withValues(alpha: 0.25);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
