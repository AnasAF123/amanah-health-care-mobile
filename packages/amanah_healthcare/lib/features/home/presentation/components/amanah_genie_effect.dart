import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

enum AmanahGenieDirection { open, minimize }

/// Mathematical 1:1 Pure Canvas Genie Slicing Painter matching genie-renderer.ts
class AmanahGenieCanvasPainter extends CustomPainter {
  const AmanahGenieCanvasPainter({
    required this.snapshot,
    required this.progress,
    required this.direction,
    required this.dockPoint,
    required this.cardRect,
  });

  final ui.Image snapshot;
  final double progress;
  final AmanahGenieDirection direction;
  final Offset dockPoint;
  final Rect cardRect;

  static double _clamp(double v, double lo, double hi) =>
      math.max(lo, math.min(hi, v));
  static double _lerp(double a, double b, double t) => a + (b - a) * t;
  static double _eioC(double t) =>
      t < 0.5 ? 4.0 * t * t * t : 1.0 - math.pow(-2.0 * t + 2.0, 3.0) / 2.0;
  static double _eIn2(double t) => t * t;
  static double _eOut2(double t) => 1.0 - (1.0 - t) * (1.0 - t);

  @override
  void paint(Canvas canvas, Size size) {
    final double windowWidth = cardRect.width;
    final int windowHeight = cardRect.height.toInt();
    if (windowHeight <= 0 || windowWidth <= 0) {
      return;
    }

    final double dpr = snapshot.width / windowWidth;
    final Paint paint = Paint()..filterQuality = FilterQuality.low;

    final double rawT = progress.clamp(0.0, 1.0);

    for (int y = 0; y < windowHeight; y++) {
      final double prox = y / windowHeight;

      final double rowXStart = direction == AmanahGenieDirection.minimize
          ? (1.0 - prox) * 0.65
          : prox * 0.65;
      final double xP = _clamp(
        (rawT - rowXStart) / (1.0 - rowXStart + 0.00001),
        0.0,
        1.0,
      );
      final double xE = _eioC(xP);

      final double rowYStart = direction == AmanahGenieDirection.minimize
          ? (1.0 - prox) * 0.20
          : prox * 0.20;
      final double yP = _clamp(
        (rawT - rowYStart) / (1.0 - rowYStart + 0.00001),
        0.0,
        1.0,
      );
      final double yE = _eIn2(yP);

      double left;
      double right;
      double destY;

      if (direction == AmanahGenieDirection.minimize) {
        left = _lerp(cardRect.left, dockPoint.dx, xE);
        right = _lerp(cardRect.right, dockPoint.dx, xE);
        destY = _lerp(cardRect.top + y, dockPoint.dy, yE);
      } else {
        left = _lerp(dockPoint.dx, cardRect.left, xE);
        right = _lerp(dockPoint.dx, cardRect.right, xE);
        destY = _lerp(dockPoint.dy, cardRect.top + y, yE);
      }

      final double rowW = right - left;
      if (rowW < 0.8) {
        continue;
      }

      final Rect srcRect = Rect.fromLTWH(
        0,
        y * dpr,
        snapshot.width.toDouble(),
        dpr,
      );
      final Rect dstRect = Rect.fromLTWH(left, destY, rowW, 1.0);

      canvas.drawImageRect(snapshot, srcRect, dstRect, paint);
    }

    final double glowRaw = direction == AmanahGenieDirection.minimize
        ? rawT
        : 1.0 - rawT;
    if (glowRaw > 0.70) {
      final double a = _eOut2((glowRaw - 0.70) / 0.30) * 0.45;
      final Paint glowPaint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.radial(
          dockPoint,
          80,
          <Color>[
            AmanahColorTokens.brandLight.withValues(alpha: a),
            AmanahColorTokens.brandPrimary.withValues(alpha: a * 0.65),
            AmanahColorTokens.brandPrimary.withValues(alpha: 0.0),
          ],
          <double>[0.0, 0.40, 1.0],
        );
      canvas.drawCircle(dockPoint, 80, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AmanahGenieCanvasPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.snapshot != snapshot ||
        oldDelegate.direction != direction ||
        oldDelegate.dockPoint != dockPoint ||
        oldDelegate.cardRect != cardRect;
  }
}

Future<ui.Image> generateCardCoverSnapshot({
  required AmanahQueueCardData card,
  required Size size,
  double pixelRatio = 2.0,
  bool isDark = false,
}) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  canvas.scale(pixelRatio, pixelRatio);

  final Rect rect = Offset.zero & size;
  final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(22));

  final Paint bgPaint = Paint()
    ..shader = (isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AmanahColorTokens.cardCoverDarkTop,
              AmanahColorTokens.neutral900,
              AmanahColorTokens.cardCoverDarkBottom,
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AmanahColorTokens.surfaceLight,
              AmanahColorTokens.canvasLight,
              AmanahColorTokens.cardCoverLightBottom,
            ],
          )).createShader(rect);

  canvas.drawRRect(rrect, bgPaint);

  final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = isDark
        ? AmanahColorTokens.pureWhite.withValues(alpha: 0.14)
        : AmanahColorTokens.surfaceLight;
  canvas.drawRRect(rrect, borderPaint);

  final Paint sheenPaint = Paint()
    ..shader = (isDark
        ? LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              AmanahColorTokens.brandDarkNavy.withValues(alpha: 0.35),
              AmanahColorTokens.neutral800.withValues(alpha: 0.15),
              AmanahColorTokens.neutral800.withValues(alpha: 0.0),
            ],
          )
        : LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              AmanahColorTokens.brandMuted.withValues(alpha: 0.50),
              AmanahColorTokens.brandSurface.withValues(alpha: 0.15),
              AmanahColorTokens.brandSurface.withValues(alpha: 0.0),
            ],
          )).createShader(rect);
  canvas.save();
  canvas.clipRRect(rrect);
  canvas.drawRect(rect, sheenPaint);

  AmanahOrganicPixelPainter.drawPixelsToCanvas(
    canvas,
    size,
    isDark: isDark,
    opacity: isDark ? 0.45 : 0.38,
    fadeTop: true,
  );

  final Paint wmPaint = Paint()
    ..shader = (isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AmanahColorTokens.brandLight,
              AmanahColorTokens.brandSoft,
              AmanahColorTokens.brandSubtle,
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AmanahColorTokens.brandPrimary,
              AmanahColorTokens.brandVividBlue,
              AmanahColorTokens.brandLight,
            ],
          )).createShader(
      Rect.fromCenter(center: rect.center, width: 140, height: 140),
    );

  final Path wmPath = AmanahWatermarkPathData.createPath();
  final Matrix4 matrix = Matrix4.identity()
    ..translateByDouble(
      (size.width - 140) / 2,
      (size.height - 140) / 2 - 25,
      0.0,
      1.0,
    )
    ..scaleByDouble(140.0 / 188.0, 140.0 / 188.0, 1.0, 1.0);
  final Path transformed = wmPath.transform(matrix.storage);
  canvas.drawPath(transformed, wmPaint);

  final TextPainter tp = TextPainter(
    text: TextSpan(
      text: card.queueNumber,
      style: TextStyle(
        color: isDark
            ? AmanahColorTokens.cyanAccent
            : AmanahColorTokens.brandPrimary,
        fontSize: 40,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(
    canvas,
    Offset((size.width - tp.width) / 2, (size.height - 140) / 2 + 120),
  );

  final Paint glossPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: <Color>[
        AmanahColorTokens.pureWhite.withValues(alpha: isDark ? 0.05 : 0.10),
        Colors.transparent,
      ],
      stops: const <double>[0.0, 0.45],
    ).createShader(rect);
  canvas.drawRect(rect, glossPaint);

  canvas.restore();

  final ui.Picture picture = recorder.endRecording();
  try {
    return picture.toImageSync(
      (size.width * pixelRatio).toInt(),
      (size.height * pixelRatio).toInt(),
    );
  } catch (_) {
    return await picture.toImage(
      (size.width * pixelRatio).toInt(),
      (size.height * pixelRatio).toInt(),
    );
  }
}
