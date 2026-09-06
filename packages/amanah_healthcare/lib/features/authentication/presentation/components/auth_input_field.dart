import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

/// In-Field Top-Aligned (IFTA) Input Field with morphing label animation.
/// - Label morphs smoothly to the top of the container when focused or populated.
/// - Label stays strictly WITHIN the container frame (unbroken, solid border).
/// - Easier to read and more visually cohesive than notched floating labels.
class AuthInputField extends StatefulWidget {
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
    this.onChanged,
    this.hasError = false,
    this.scrollPadding = const EdgeInsets.only(bottom: 120.0),
    this.focusNode,
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
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final EdgeInsets scrollPadding;
  final FocusNode? focusNode;

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _isFocused = false;
  bool _hasText = false;
  FormFieldState<String>? _fieldState;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _isFocused = _focusNode.hasFocus;
    _hasText = widget.controller.text.isNotEmpty;
    _focusNode.addListener(_handleFocusChanged);
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant AuthInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
      _hasText = widget.controller.text.isNotEmpty;
      if (_fieldState != null && _fieldState!.value != widget.controller.text) {
        _fieldState!.didChange(widget.controller.text);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    widget.controller.removeListener(_handleTextChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted && _isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _handleTextChanged() {
    final String text = widget.controller.text;
    final bool hasText = text.isNotEmpty;
    if (_fieldState != null && _fieldState!.value != text) {
      _fieldState!.didChange(text);
    }
    if (mounted && _hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool isFloating = _isFocused || _hasText;

    return FormField<String>(
      initialValue: widget.controller.text,
      validator: (String? _) => widget.validator?.call(widget.controller.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> fieldState) {
        _fieldState = fieldState;
        final bool effectiveHasError = widget.hasError || fieldState.hasError;
        final String? errorText = fieldState.errorText;

        final Color normalBorderColor = isDark
            ? AmanahThemeTokens.outline(context)
            : theme.colorScheme.outline.withValues(alpha: 0.34);
        final Color activeBorderColor = isDark
            ? AmanahColorTokens.tabActiveDark
            : AmanahColorTokens.brand;
        final Color borderColor = effectiveHasError
            ? theme.colorScheme.error.withValues(alpha: 0.90)
            : (_isFocused ? activeBorderColor : normalBorderColor);

        final Color fillColor = effectiveHasError
            ? (isDark
                ? theme.colorScheme.error.withValues(alpha: 0.08)
                : AmanahColorTokens.dangerSurface)
            : (isDark
                ? AmanahThemeTokens.surfaceSecondary(context)
                : AmanahColorTokens.neutral50.withValues(alpha: 0.72));

        final Color iconColor = effectiveHasError
            ? theme.colorScheme.error
            : (_isFocused
                ? activeBorderColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.42));

        final Color labelColor = effectiveHasError
            ? theme.colorScheme.error
            : (_isFocused
                ? activeBorderColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.48));

        return Semantics(
          container: true,
          label: widget.label,
          textField: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Unbroken IFTA Frame Container
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: _isFocused || effectiveHasError ? 1.4 : 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Leading Icon
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: LARGE_SPACE,
                          end: BALANCED_SPACE,
                        ),
                        child: Center(
                          child: Icon(
                            widget.leadingIcon,
                            size: 20,
                            color: iconColor,
                          ),
                        ),
                      ),
                      // IFTA Morphing Label + Input Stack
                      Expanded(
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: <Widget>[
                            // Morphing Label (slides up inside the frame)
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
                              top: isFloating ? 11.5 : 19.0,
                              left: 0,
                              right: 0,
                              child: ExcludeSemantics(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  style: TextStyle(
                                    fontFamily:
                                        theme.textTheme.bodyMedium?.fontFamily,
                                    fontSize: isFloating ? 11.0 : 14.0,
                                    fontWeight: isFloating
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: labelColor,
                                    height: isFloating ? 1.0 : 1.1,
                                  ),
                                  child: Text(
                                    widget.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            // Text Input Area
                            Positioned(
                              top: 24.5,
                              left: 0,
                              right: 0,
                              child: TextField(
                                controller: widget.controller,
                                focusNode: _focusNode,
                                keyboardType: widget.keyboardType,
                                textInputAction: widget.textInputAction,
                                autofillHints: widget.autofillHints,
                                obscureText: widget.obscureText,
                                onSubmitted: widget.onFieldSubmitted,
                                onChanged: (String val) {
                                  _fieldState?.didChange(val);
                                  widget.onChanged?.call(val);
                                },
                                scrollPadding: widget.scrollPadding,
                                spellCheckConfiguration:
                                    const SpellCheckConfiguration.disabled(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                  height: 1.2,
                                  color: isDark
                                      ? AmanahColorTokens.neutral100
                                      : AmanahColorTokens.neutral900,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Trailing Widget
                      if (widget.trailing != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8.0),
                          child: Center(child: widget.trailing),
                        ),
                    ],
                  ),
                ),
              ),
              // External Validation Error Feedback
              if (effectiveHasError && errorText != null && errorText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: LARGE_SPACE,
                    top: 6.0,
                  ),
                  child: Text(
                    errorText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
