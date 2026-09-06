import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      // Paste handling
      final String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < widget.length; i++) {
        if (i < digitsOnly.length) {
          _controllers[i].text = digitsOnly[i];
        }
      }
      final String otp = _currentOtp;
      widget.onChanged(otp);
      if (otp.length == widget.length && widget.onCompleted != null) {
        widget.onCompleted!(otp);
      }
      final int nextFocus =
          digitsOnly.length < widget.length ? digitsOnly.length : widget.length - 1;
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
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEF4444),
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
            ? const Color(0xFF1E293B)
            : const Color(0xFF111827))
        : (controller.text.isNotEmpty
            ? const Color(0xFFF8FAFC)
            : Colors.white);

    final Color borderColor = hasError
        ? const Color(0xFFEF4444)
        : (controller.text.isNotEmpty
            ? (dark ? const Color(0xFF3B82F6) : const Color(0xFF0F172A))
            : (dark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1)));

    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);

    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        scrollPadding: EdgeInsets.zero,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
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
              color: dark ? const Color(0xFF3B82F6) : const Color(0xFF0A44FF),
              width: 2.0,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
