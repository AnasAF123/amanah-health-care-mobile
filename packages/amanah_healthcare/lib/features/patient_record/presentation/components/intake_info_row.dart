import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Reusable information row displaying label and value in patient intake views.
class IntakeInfoRow extends StatelessWidget {
  const IntakeInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
    this.isAlert = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isAlert
                    ? AmanahColorTokens.danger
                    : (isDark
                        ? AmanahColorTokens.surfaceLight
                        : AmanahColorTokens.neutral900),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
