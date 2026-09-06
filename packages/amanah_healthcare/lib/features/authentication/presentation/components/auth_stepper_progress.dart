import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Ultra-minimalist segmented progress indicator for multi-step authentication.
/// Pure visual progress bars with zero clutter.
class AuthStepperProgress extends StatelessWidget {
  const AuthStepperProgress({
    required this.currentStep,
    super.key,
    this.totalSteps = 3,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color activeColor = dark
        ? AmanahColorTokens.tabActiveDark
        : AmanahColorTokens.brand;
    final Color inactiveColor = dark
        ? AmanahColorTokens.neutral800
        : AmanahColorTokens.neutral200;

    return Semantics(
      label: 'Langkah ${currentStep + 1} dari $totalSteps',
      child: Row(
        children: List<Widget>.generate(totalSteps, (int index) {
          final bool isFilled = index <= currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < totalSteps - 1 ? 6.0 : 0.0,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: 4.0,
                decoration: BoxDecoration(
                  color: isFilled ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
