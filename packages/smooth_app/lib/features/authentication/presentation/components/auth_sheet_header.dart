import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
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
          child: Transform.translate(
            offset: const Offset(8, 0),
            child: Semantics(
              button: true,
              label: 'Tutup autentikasi',
              child: IconButton(
                tooltip: 'Tutup',
                onPressed: onDismiss,
                style: IconButton.styleFrom(
                  fixedSize: const Size(MINIMUM_TOUCH_SIZE, MINIMUM_TOUCH_SIZE),
                  backgroundColor: theme.brightness == Brightness.dark
                      ? AmanahThemeTokens.surfaceSecondary(context)
                      : const Color(0xFFF3F7FB),
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
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
            fontFamily: 'PlusJakartaSans',
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
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.38,
          ),
        ),
      ],
    );
  }
}
