import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

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
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.helperText,
    this.trailing,
    this.onFieldSubmitted,
    this.onChanged,
    this.hasError = false,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData leadingIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final String? helperText;
  final Widget? trailing;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius fieldRadius = BorderRadius.circular(16);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color normalBorderColor = isDark
        ? AmanahThemeTokens.outline(context)
        : theme.colorScheme.outline.withValues(alpha: 0.34);
    final Color borderColor = hasError
        ? theme.colorScheme.error.withValues(alpha: 0.85)
        : normalBorderColor;
    final Color fillColor = hasError
        ? (isDark
              ? theme.colorScheme.error.withValues(alpha: 0.08)
              : AmanahColorTokens.dangerSurface)
        : (isDark
              ? AmanahThemeTokens.surfaceSecondary(context)
              : AmanahColorTokens.neutral50.withValues(alpha: 0.72));
    final Color iconColor = hasError
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface.withValues(alpha: 0.42);

    return Semantics(
      label: label,
      textField: true,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        enabled: enabled,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        validator: validator,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        buildCounter: maxLength != null
            ? (
                BuildContext context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) =>
                null
            : null,
        obscureText: obscureText,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          constraints: const BoxConstraints(minHeight: 50),
          hintText: hintText,
          helperText: helperText,
          helperStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
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
            borderSide: BorderSide(
              color: borderColor,
              width: hasError ? 1.2 : 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(
              color: borderColor,
              width: hasError ? 1.2 : 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: fieldRadius,
            borderSide: BorderSide(
              color: hasError
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary.withValues(alpha: 0.70),
              width: hasError ? 1.4 : 1.2,
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
