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
    final BorderRadius fieldRadius = BorderRadius.circular(16);
    final Color borderColor = theme.colorScheme.outline.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.28 : 0.34,
    );
    final Color fillColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.42)
        : const Color(0xFFFAFAFA).withValues(alpha: 0.72);
    final Color iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.42);

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
          constraints: const BoxConstraints(minHeight: 50),
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.36),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: LARGE_SPACE,
              end: BALANCED_SPACE,
            ),
            child: Icon(leadingIcon, size: 18, color: iconColor),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 48,
          ),
          suffixIcon: trailing,
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.70),
              width: 1.2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(
              color: theme.colorScheme.error.withValues(alpha: 0.78),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1.3),
          ),
        ),
      ),
    );
  }
}
