import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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
    final double maxHeight = size.height - topInset - MEDIUM_SPACE;
    final double sheetHeight = (size.height * 0.95).clamp(0, maxHeight);
    const EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      28,
      MEDIUM_SPACE,
      28,
      VERY_LARGE_SPACE,
    );

    return SizedBox(
      height: sheetHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          border: Border.all(
            color: dark
                ? AmanahThemeTokens.outline(context)
                : Colors.white.withValues(alpha: 0.62),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.34 : 0.16),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          child: Material(
            color: dark ? AmanahColorTokens.canvasDark : Colors.white,
            child: Stack(
              children: <Widget>[
                if (!dark) const Positioned.fill(child: _AuthSheetBottomGradient()),
                SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final double centeredContentHeight =
                              (constraints.maxHeight - contentPadding.vertical)
                                  .clamp(0, double.infinity);
                          return SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: contentPadding,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: centerContent
                                    ? constraints.maxHeight
                                    : 0,
                              ),
                              child: centerContent
                                  ? SizedBox(
                                      height: centeredContentHeight,
                                      width: double.infinity,
                                      child: child,
                                    )
                                  : child,
                            ),
                          );
                        },
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
