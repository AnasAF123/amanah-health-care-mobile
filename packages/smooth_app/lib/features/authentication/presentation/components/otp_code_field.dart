import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    required this.controllers,
    required this.onChanged,
    super.key,
  }) : assert(controllers.length == 6);

  final List<TextEditingController> controllers;
  final VoidCallback onChanged;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color borderColor = isDark
        ? AmanahThemeTokens.outline(context)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.9);

    return Row(
      children: List<Widget>.generate(6, (int index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == 5 ? 0 : SMALL_SPACE,
            ),
            child: Semantics(
              label: 'Digit ke ${index + 1}',
              textField: true,
              child: SizedBox(
                height: 56,
                child: TextFormField(
                  controller: widget.controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textInputAction: index == 5
                      ? TextInputAction.done
                      : TextInputAction.next,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: isDark
                        ? AmanahThemeTokens.surfaceSecondary(context)
                        : theme.colorScheme.surface,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(LARGE_SPACE),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(LARGE_SPACE),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(LARGE_SPACE),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                  onChanged: (String value) {
                    if (value.isNotEmpty && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    widget.onChanged();
                  },
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
