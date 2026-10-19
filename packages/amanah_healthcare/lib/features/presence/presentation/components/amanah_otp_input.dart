import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahOtpInput extends StatefulWidget {
  const AmanahOtpInput({
    required this.onChanged,
    super.key,
    this.length = 6,
    this.onCompleted,
    this.error,
    this.initialValue = '',
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final String? error;
  final String initialValue;

  @override
  State<AmanahOtpInput> createState() => _AmanahOtpInputState();
}

class _AmanahOtpInputState extends State<AmanahOtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      widget.length,
      (int i) => TextEditingController(
        text: i < widget.initialValue.length ? widget.initialValue[i] : '',
      ),
    );
    _focusNodes = List<FocusNode>.generate(
      widget.length,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp =>
      _controllers.map((TextEditingController c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Paste handling for 6-character alphanumeric QR tokens (e.g. 5B8ZJ5)
      final String charsOnly =
          value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      for (int i = 0; i < widget.length; i++) {
        if (i < charsOnly.length) {
          _controllers[i].text = charsOnly[i];
        }
      }
      final String otp = _currentOtp;
      widget.onChanged(otp);
      if (otp.length == widget.length && widget.onCompleted != null) {
        widget.onCompleted!(otp);
      }
      final int nextFocus =
          charsOnly.length < widget.length ? charsOnly.length : widget.length - 1;
      _focusNodes[nextFocus].requestFocus();
      return;
    }

    widget.onChanged(_currentOtp);

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final String otp = _currentOtp;
    if (otp.length == widget.length && widget.onCompleted != null) {
      widget.onCompleted!(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < widget.length; i++) ...<Widget>[
              _DigitBox(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                dark: dark,
                hasError: widget.error != null,
                onChanged: (String val) => _onDigitChanged(i, val),
              ),
              if (i < widget.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
        if (widget.error != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            widget.error!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AmanahColorTokens.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.controller,
    required this.focusNode,
    required this.dark,
    required this.hasError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool dark;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = dark
        ? (controller.text.isNotEmpty
            ? AmanahColorTokens.neutral800
            : AmanahColorTokens.surfaceDark)
        : (controller.text.isNotEmpty
            ? AmanahColorTokens.neutral50
            : AmanahColorTokens.surfaceLight);

    final Color borderColor = hasError
        ? AmanahColorTokens.danger
        : (controller.text.isNotEmpty
            ? (dark ? AmanahColorTokens.brandLight : AmanahColorTokens.neutral900)
            : (dark
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
                : AmanahColorTokens.neutral300));

    final Color textColor = dark
        ? AmanahColorTokens.surfaceLight
        : AmanahColorTokens.neutral900;

    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        scrollPadding: EdgeInsets.zero,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        ],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: bgColor,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: borderColor,
              width: controller.text.isNotEmpty ? 1.5 : 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: dark
                  ? AmanahColorTokens.brandLight
                  : AmanahColorTokens.brandPrimary,
              width: 2.0,
            ),
          ),
        ),
        onChanged: (String val) {
          if (val.isNotEmpty && val != val.toUpperCase()) {
            controller.value = controller.value.copyWith(
              text: val.toUpperCase(),
              selection: const TextSelection.collapsed(offset: 1),
            );
          }
          onChanged(val.toUpperCase());
        },
      ),
    );
  }
}
