import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.72,
    );

    return Row(
      children: <Widget>[
        Expanded(child: Divider(height: 1, color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
          child: Text(
            'atau lanjutkan dengan',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(height: 1, color: color)),
      ],
    );
  }
}
