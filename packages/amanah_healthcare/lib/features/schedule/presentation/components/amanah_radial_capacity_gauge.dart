import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/schedule_shift_constants.dart';

/// Radial Capacity Progress Gauge (Kapasitas Hari Ini)
/// Matching 1:1 with capacity radial and daily summary in .web
class AmanahRadialCapacityGauge extends StatelessWidget {
  const AmanahRadialCapacityGauge({
    required this.capacityPercentage,
    required this.bookedCount,
    this.totalSlots,
    this.targetQuota,
    required this.isCuti,
    this.onTapInfo,
    super.key,
  }) : assert(
          totalSlots != null || targetQuota != null,
          'Either totalSlots or targetQuota must be provided',
        );

  final int capacityPercentage;
  final int bookedCount;
  final int? totalSlots;
  final int? targetQuota;
  final bool isCuti;
  final VoidCallback? onTapInfo;

  int get effectiveTotalSlots => totalSlots ?? targetQuota ?? 0;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Circular Radial Arc Gauge (44x44)
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomPaint(
                size: const Size(44, 44),
                painter: _RadialArcPainter(
                  progress: isCuti
                      ? 0.0
                      : (capacityPercentage / 100).clamp(0.0, 1.0),
                  isCuti: isCuti,
                  dark: dark,
                ),
              ),
              Text(
                isCuti ? '0%' : '$capacityPercentage%',
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.pureWhite
                      : AmanahColorTokens.neutral900,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Kapasitas Hari Ini',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.pureWhite
                            : AmanahColorTokens.neutral900,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (onTapInfo != null) ...<Widget>[
                      const SizedBox(width: 4),
                      Semantics(
                        button: true,
                        label: 'Info rincian kuota dan kapasitas',
                        child: InkWell(
                          onTap: onTapInfo,
                          borderRadius: BorderRadius.circular(100),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 13,
                              color: dark
                                  ? AmanahColorTokens.neutral400
                                  : AmanahColorTokens.neutral500,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (isCuti) ...<Widget>[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AmanahColorTokens.warning.withValues(
                            alpha: 0.20,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AmanahColorTokens.warning,
                                shape: BoxShape.circle,
                              ),
                              child: SizedBox(width: 5, height: 5),
                            ),
                            SizedBox(width: 4),
                            Text(
                              ScheduleFormConstants.statusCuti,
                              style: TextStyle(
                                color: AmanahColorTokens.warning,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '$bookedCount',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.tabActiveDark
                            : AmanahColorTokens.brand,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ' / $effectiveTotalSlots Slot',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTapInfo != null) {
      return GestureDetector(
        onTap: onTapInfo,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}

class _RadialArcPainter extends CustomPainter {
  const _RadialArcPainter({
    required this.progress,
    required this.isCuti,
    required this.dark,
  });

  final double progress;
  final bool isCuti;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - 6) / 2;
    final Rect bounds = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..color = dark
          ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
          : AmanahColorTokens.neutral200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final List<Color> gradientColors;
      if (isCuti) {
        gradientColors = const <Color>[
          AmanahColorTokens.warning,
          AmanahColorTokens.warningDark,
        ];
      } else if (dark) {
        gradientColors = const <Color>[
          AmanahColorTokens.cyanAccent,
          AmanahColorTokens.auroraCyanDark,
        ];
      } else {
        gradientColors = const <Color>[
          AmanahColorTokens.brandSoft,
          AmanahColorTokens.brand,
        ];
      }

      final Paint arcPaint = Paint()
        ..shader = LinearGradient(
          colors: gradientColors,
        ).createShader(bounds)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.0;

      const double startAngle = -math.pi / 2;
      final double sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(bounds, startAngle, sweepAngle, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isCuti != isCuti ||
      oldDelegate.dark != dark;
}
