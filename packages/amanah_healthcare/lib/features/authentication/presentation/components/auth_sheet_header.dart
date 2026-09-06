import 'package:flutter/material.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class AuthSheetHeader extends StatelessWidget {
  const AuthSheetHeader({
    required this.titlePrefix,
    required this.brand,
    required this.description,
    this.onDismiss,
    super.key,
  });

  final String titlePrefix;
  final String brand;
  final String description;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text.rich(
          TextSpan(
            text: titlePrefix,
            children: <InlineSpan>[
              if (brand.isNotEmpty)
                TextSpan(
                  text: brand,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
            ],
          ),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.04,
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.38,
          ),
        ),
      ],
    );
  }
}
