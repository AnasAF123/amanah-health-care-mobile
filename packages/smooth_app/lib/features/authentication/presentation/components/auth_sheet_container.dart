import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AuthSheetContainer extends StatelessWidget {
  const AuthSheetContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.sizeOf(context);
    final double keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final double maxHeight = size.height * (keyboardHeight > 0 ? 0.96 : 0.88);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Material(
          color: theme.colorScheme.surface,
          elevation: 16,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                28,
                MEDIUM_SPACE,
                28,
                VERY_LARGE_SPACE,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
