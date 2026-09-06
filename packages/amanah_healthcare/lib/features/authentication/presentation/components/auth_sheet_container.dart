import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

/// Dynamic-height modal bottom sheet container for authentication flows.
/// - Hugs dynamic content height rather than forcing full height.
/// - Allows background image/context to remain visible at the top.
/// - Lifts smoothly above keyboard via animated bottom padding.
/// - Safely constrained to prevent overflowing past the status bar.
/// - Scrollable internally without displaying visible scrollbars.
class AuthSheetContainer extends StatelessWidget {
  const AuthSheetContainer({
    required this.child,
    super.key,
    this.centerContent = false,
  });

  final Widget child;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Size size = MediaQuery.sizeOf(context);
    final double topInset = MediaQuery.paddingOf(context).top;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final double maxSheetHeight = size.height - topInset - MEDIUM_SPACE;
    const EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      28,
      12,
      28,
      VERY_LARGE_SPACE,
    );

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxSheetHeight,
          minWidth: double.infinity,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AmanahThemeTokens.canvas(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AmanahElevation.sheet(dark: dark).color.withValues(
                      alpha: dark ? 0.34 : 0.16,
                    ),
                blurRadius: 28,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
            child: Stack(
              children: <Widget>[
                if (!dark)
                  const Positioned.fill(child: _AuthSheetBottomGradient()),
                SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const AmanahSheetHandle(),
                      Flexible(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(
                            context,
                          ).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: contentPadding,
                            child: centerContent
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: size.height * 0.35,
                                    ),
                                    child: Center(child: child),
                                  )
                                : child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthSheetBottomGradient extends StatelessWidget {
  const _AuthSheetBottomGradient();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: CustomPaint(painter: _AuthSheetBottomGradientPainter(dark: dark)),
    );
  }
}

class _AuthSheetBottomGradientPainter extends CustomPainter {
  const _AuthSheetBottomGradientPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final double top = size.height * 0.67;
    final Path path = Path()
      ..moveTo(0, size.height * 0.84)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.70,
        size.width * 0.62,
        size.height * 0.76,
        size.width,
        top,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: <Color>[
          Color(dark ? 0xFF081D3E : 0xFFE8F7FF).withValues(alpha: 0.84),
          Color(dark ? 0xFF083C5A : 0xFFDDFBFF).withValues(alpha: 0.52),
          Color(dark ? 0xFF27235A : 0xFFEDE8FF).withValues(alpha: 0.46),
          Color(dark ? 0xFF0F0A5A : 0xFFFFFFFF).withValues(alpha: 0.10),
        ],
        stops: const <double>[0, 0.36, 0.76, 1],
      ).createShader(Offset(0, top) & Size(size.width, size.height - top));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AuthSheetBottomGradientPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}
