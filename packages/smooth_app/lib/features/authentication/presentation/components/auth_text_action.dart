import 'package:flutter/material.dart';

class AuthTextAction extends StatelessWidget {
  const AuthTextAction({
    required this.label,
    required this.onPressed,
    super.key,
    this.alignment = AlignmentDirectional.centerEnd,
  });

  final String label;
  final VoidCallback onPressed;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Align(
      alignment: alignment,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(44, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: theme.colorScheme.primary,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
