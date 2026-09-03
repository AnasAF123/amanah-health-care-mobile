import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_input_field.dart';

class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
    required this.label,
    required this.hintText,
    required this.controller,
    super.key,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.hasError = false,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AuthInputField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      leadingIcon: Icons.lock_outline_rounded,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      hasError: widget.hasError,
      trailing: IconButton(
        tooltip: _obscureText ? 'Tampilkan password' : 'Sembunyikan password',
        onPressed: () => setState(() => _obscureText = !_obscureText),
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
        ),
      ),
    );
  }
}
