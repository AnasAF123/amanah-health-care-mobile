import 'package:flutter/material.dart';

/// Reusable inline form validation feedback component.
///
/// Follows production schema/form validation guidelines (e.g. Zod/React Hook Form)
/// by rendering contextual, accessible, non-leaking error feedback directly
/// beneath or associated with the relevant input fields.
class AuthInlineValidationMessage extends StatelessWidget {
  const AuthInlineValidationMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color errorColor = theme.colorScheme.error;

    return Semantics(
      liveRegion: true,
      label: message,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.error_outline_rounded,
                size: 15,
                color: errorColor,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: errorColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
