import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AuthSheetHeader extends StatelessWidget {
  const AuthSheetHeader({
    required this.titlePrefix,
    required this.brand,
    required this.description,
    required this.onDismiss,
    super.key,
  });

  final String titlePrefix;
  final String brand;
  final String description;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Semantics(
            button: true,
            label: 'Tutup autentikasi',
            child: IconButton(
              tooltip: 'Tutup',
              onPressed: onDismiss,
              style: IconButton.styleFrom(
                fixedSize: const Size(MINIMUM_TOUCH_SIZE, MINIMUM_TOUCH_SIZE),
                backgroundColor: theme.colorScheme.secondary.withValues(
                  alpha: 0.68,
                ),
                foregroundColor: theme.colorScheme.onSurface,
              ),
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ),
        ),
        const SizedBox(height: SMALL_SPACE),
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
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: SMALL_SPACE),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.42,
          ),
        ),
      ],
    );
  }
}
