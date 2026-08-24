import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.leadingIcon,
    super.key,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.obscureText = false,
    this.trailing,
    this.onFieldSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData leadingIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? trailing;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.56,
    );
    final Color iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.46);

    return Semantics(
      label: label,
      textField: true,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        validator: validator,
        obscureText: obscureText,
        onFieldSubmitted: onFieldSubmitted,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          constraints: const BoxConstraints(minHeight: 52),
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(leadingIcon, size: 20, color: iconColor),
          suffixIcon: trailing,
          filled: true,
          fillColor: theme.brightness == Brightness.dark
              ? theme.colorScheme.surface
              : const Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: CIRCULAR_BORDER_RADIUS,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: CIRCULAR_BORDER_RADIUS,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: CIRCULAR_BORDER_RADIUS,
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.78),
              width: 1.2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: CIRCULAR_BORDER_RADIUS,
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: CIRCULAR_BORDER_RADIUS,
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1.4),
          ),
        ),
      ),
    );
  }
}
