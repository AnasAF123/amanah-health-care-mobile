import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class MedicalGridPainter extends CustomPainter {
  const MedicalGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AmanahColorTokens.brandLight.withValues(alpha: 0.20)
      ..strokeWidth = 0.5;

    const double step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PresenceScannerTargetOverlay extends StatelessWidget {
  const PresenceScannerTargetOverlay({
    super.key,
    required this.laserAnimation,
    required this.contentPadding,
    this.drawFrame = true,
  });

  final Animation<double> laserAnimation;
  final EdgeInsetsGeometry contentPadding;
  final bool drawFrame;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets resolvedContentPadding = contentPadding.resolve(
      Directionality.of(context),
    );
    final EdgeInsets scannerPadding = EdgeInsets.fromLTRB(
      26 + resolvedContentPadding.left,
      MediaQuery.viewPaddingOf(context).top + 13 + resolvedContentPadding.top,
      26 + resolvedContentPadding.right,
      26 + resolvedContentPadding.bottom,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double targetWidth = math.max(
          0,
          constraints.maxWidth - scannerPadding.horizontal,
        );
        final double targetHeight = math.max(
          0,
          constraints.maxHeight - scannerPadding.vertical,
        );

        if (targetWidth <= 0 || targetHeight <= 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: scannerPadding,
          child: Stack(
            children: <Widget>[
              if (drawFrame)
                const Positioned.fill(
                  child: CustomPaint(
                    painter: PresenceScannerFramePainter(
                      color: AmanahColorTokens.brandLight,
                    ),
                  ),
                ),
              AnimatedBuilder(
                animation: laserAnimation,
                builder: (BuildContext context, Widget? child) {
                  final double sweepHeight = math.max(0, targetHeight - 34);
                  final double lineTop = sweepHeight * laserAnimation.value;
                  return Positioned(
                    top: lineTop,
                    left: 22,
                    right: 22,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                AmanahColorTokens.brandLight.withValues(
                                  alpha: 0.20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AmanahColorTokens.brandAccent,
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AmanahColorTokens.brandAccent.withValues(
                                  alpha: 0.86,
                                ),
                                blurRadius: 9,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: AmanahColorTokens.brandLight.withValues(
                                  alpha: 0.90,
                                ),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class PresenceScannerFramePainter extends CustomPainter {
  const PresenceScannerFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path path = _buildPath(rect);
    final Paint paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    paint
      ..color = AmanahColorTokens.pureBlack.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.65);
    canvas.drawPath(path, paint);

    paint
      ..color = color
      ..maskFilter = null;
    canvas.drawPath(path, paint);
  }

  Path _buildPath(Rect rect) {
    const double fullCornerSize = 31;
    const double halfCornerSize = fullCornerSize / 2;
    const Radius borderRadius = Radius.circular(halfCornerSize);
    final double bottomPosition = rect.bottom;

    final Path path = Path()
      ..moveTo(rect.left, rect.top + fullCornerSize)
      ..lineTo(rect.left, rect.top + halfCornerSize)
      ..arcToPoint(
        Offset(rect.left + halfCornerSize, rect.top),
        radius: borderRadius,
      )
      ..lineTo(rect.left + fullCornerSize, rect.top)
      ..moveTo(rect.right - fullCornerSize, rect.top)
      ..lineTo(rect.right - halfCornerSize, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + halfCornerSize),
        radius: borderRadius,
      )
      ..lineTo(rect.right, rect.top + fullCornerSize)
      ..moveTo(rect.right, bottomPosition - fullCornerSize)
      ..lineTo(rect.right, bottomPosition - halfCornerSize)
      ..arcToPoint(
        Offset(rect.right - halfCornerSize, bottomPosition),
        radius: borderRadius,
      )
      ..lineTo(rect.right - fullCornerSize, bottomPosition)
      ..moveTo(rect.left + fullCornerSize, bottomPosition)
      ..lineTo(rect.left + halfCornerSize, bottomPosition)
      ..arcToPoint(
        Offset(rect.left, bottomPosition - halfCornerSize),
        radius: borderRadius,
      )
      ..lineTo(rect.left, bottomPosition - fullCornerSize);

    return path;
  }

  @override
  bool shouldRepaint(covariant PresenceScannerFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
