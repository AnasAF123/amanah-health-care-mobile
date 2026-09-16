import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class ClinicMonthRecord {
  const ClinicMonthRecord({
    required this.monthName,
    required this.year,
    required this.data,
  });

  final String monthName;
  final int year;
  final List<ClinicDayData> data;
}

class ClinicDayData {
  const ClinicDayData({
    required this.dayShort,
    required this.label,
    required this.patients,
    required this.newPatients,
  });

  final String dayShort;
  final String label;
  final int patients;
  final int newPatients;
}

const List<ClinicMonthRecord> kMonthlyRecords = <ClinicMonthRecord>[];

class AmanahClinicAnalyticsSection extends StatefulWidget {
  const AmanahClinicAnalyticsSection({super.key, this.onViewDetails});

  final VoidCallback? onViewDetails;

  @override
  State<AmanahClinicAnalyticsSection> createState() =>
      _AmanahClinicAnalyticsSectionState();
}

class _AmanahClinicAnalyticsSectionState
    extends State<AmanahClinicAnalyticsSection> {
  int _monthIndex = 1; // Default: Juni
  int? _selectedPointIndex;

  void _showDetailSheet(BuildContext context, ClinicMonthRecord record) {
    final int total = record.data.fold<int>(
      0,
      (int a, ClinicDayData b) => a + b.patients,
    );
    final int newPatients = record.data.fold<int>(
      0,
      (int a, ClinicDayData b) => a + b.newPatients,
    );
    final int returning = total - newPatients;

    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AmanahBottomSheetScaffold(
          title: 'Rincian Kunjungan Poliklinik',
          subtitle: '${record.monthName} ${record.year} • RS Amanah Sehat',
          fixedHeightFactor: 0.58,
          minHeight: 360,
          bodyPadding: const EdgeInsets.fromLTRB(
            AmanahSpacing.xxl,
            AmanahSpacing.lg,
            AmanahSpacing.xxl,
            AmanahSpacing.xxl,
          ),
          footer: AmanahButton.primary(
            text: 'Tutup',
            size: AmanahButtonSize.medium,
            isFullWidth: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Metrics Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AmanahThemeTokens.surfaceSecondary(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AmanahThemeTokens.outline(context),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Pasien Kontrol (Lama)',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AmanahThemeTokens.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$returning Pasien',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AmanahThemeTokens.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AmanahThemeTokens.surfaceSecondary(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AmanahThemeTokens.outline(context),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Pasien Baru',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AmanahThemeTokens.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$newPatients Pasien',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AmanahColorTokens.brand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AmanahThemeTokens.surfaceSecondary(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AmanahThemeTokens.outline(context)),
                ),
                child: Text(
                  'Total kunjungan poli anak RS Amanah Sehat pada bulan ${record.monthName} ${record.year} mencapai $total pasien, didominasi oleh pasien kontrol rutin (${((returning / total) * 100).round()}%) dan pasien baru (${((newPatients / total) * 100).round()}%).',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: AmanahThemeTokens.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kMonthlyRecords.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Tren kunjungan pasien',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                ),
                if (widget.onViewDetails != null)
                  AmanahButton.text(
                    text: 'Rincian',
                    trailingIcon: Icons.chevron_right_rounded,
                    size: AmanahButtonSize.small,
                    customForegroundColor: AmanahThemeTokens.accent(context),
                    onPressed: widget.onViewDetails,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const AmanahEmptyState.card(
            icon: Icons.analytics_outlined,
            title: 'Belum Ada Data Tren Pasien',
            message:
                'Grafik kunjungan poliklinik akan muncul setelah terhubung dengan database.',
          ),
        ],
      );
    }

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final ClinicMonthRecord currentRecord = kMonthlyRecords[_monthIndex];
    final List<ClinicDayData> series = currentRecord.data;

    final int totalPatients = series.fold<int>(
      0,
      (int sum, ClinicDayData item) => sum + item.patients,
    );
    final int totalNewPatients = series.fold<int>(
      0,
      (int sum, ClinicDayData item) => sum + item.newPatients,
    );
    final int totalReturningPatients = totalPatients - totalNewPatients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section Title & Rincian Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Tren kunjungan pasien',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: AmanahThemeTokens.textPrimary(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AmanahColorTokens.brand,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AmanahColorTokens.brandLight,
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AmanahButton.text(
                text: 'Rincian',
                trailingIcon: Icons.chevron_right_rounded,
                size: AmanahButtonSize.small,
                customForegroundColor: dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand,
                onPressed: () {
                  if (widget.onViewDetails != null) {
                    widget.onViewDetails?.call();
                  } else {
                    _showDetailSheet(context, currentRecord);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Expanded Patient Growth Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AmanahThemeTokens.surface(context),
            border: Border.all(color: AmanahThemeTokens.outline(context)),
            boxShadow: <BoxShadow>[AmanahElevation.soft(dark: dark)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Month Selector Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: dark
                          ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.06)
                          : AmanahColorTokens.neutral100,
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      setState(() {
                        _monthIndex =
                            (_monthIndex - 1 + kMonthlyRecords.length) %
                            kMonthlyRecords.length;
                        _selectedPointIndex = null;
                      });
                    },
                  ),
                  Text(
                    '${currentRecord.monthName} ${currentRecord.year}',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AmanahThemeTokens.textPrimary(context),
                    ),
                  ),
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: dark
                          ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.06)
                          : AmanahColorTokens.neutral100,
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {
                      setState(() {
                        _monthIndex =
                            (_monthIndex + 1) % kMonthlyRecords.length;
                        _selectedPointIndex = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Total Metric & Growth Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(
                          '$totalPatients',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: AmanahThemeTokens.textPrimary(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Total Kunjungan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AmanahThemeTokens.textSecondary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? AmanahColorTokens.brand.withValues(alpha: 0.18)
                          : AmanahColorTokens.brandSurface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: dark
                            ? AmanahColorTokens.brandLight.withValues(alpha: 0.3)
                            : AmanahColorTokens.brandMuted,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 11,
                          color: AmanahColorTokens.brand,
                        ),
                        SizedBox(width: 3),
                        Text(
                          '+12.5%',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AmanahColorTokens.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Interactive Curve Chart
              SizedBox(
                height: 130,
                width: double.infinity,
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    final int point =
                        (details.localPosition.dx /
                                (MediaQuery.sizeOf(context).width - 76) *
                                series.length)
                            .floor()
                            .clamp(0, series.length - 1);
                    setState(() {
                      _selectedPointIndex = point;
                    });
                  },
                  child: CustomPaint(
                    painter: _ClinicAreaChartPainter(
                      data: series,
                      isDark: dark,
                      selectedPointIndex: _selectedPointIndex,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // X-Axis Day Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: series.map((ClinicDayData item) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        item.dayShort,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: dark
                              ? AmanahColorTokens.neutral500
                              : AmanahColorTokens.neutral400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Bottom 2-Column Breakdown (Kontrol vs Baru)
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AmanahThemeTokens.surfaceSecondary(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AmanahThemeTokens.outline(context),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AmanahColorTokens.brand,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Kontrol',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AmanahThemeTokens.textSecondary(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalReturningPatients',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: AmanahThemeTokens.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AmanahThemeTokens.surfaceSecondary(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AmanahThemeTokens.outline(context),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AmanahColorTokens.brand,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Baru',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AmanahThemeTokens.textSecondary(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalNewPatients',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: AmanahThemeTokens.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClinicAreaChartPainter extends CustomPainter {
  _ClinicAreaChartPainter({
    required this.data,
    required this.isDark,
    this.selectedPointIndex,
  });

  final List<ClinicDayData> data;
  final bool isDark;
  final int? selectedPointIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      return;
    }

    final int minVal =
        data.map((ClinicDayData e) => e.patients).reduce(math.min) - 15;
    final int maxVal =
        data.map((ClinicDayData e) => e.patients).reduce(math.max) + 15;
    final double range = (maxVal - minVal).toDouble().clamp(1.0, 999.0);

    final List<Offset> points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final double x = (size.width / (data.length - 1)) * i;
      final double normalized = (data[i].patients - minVal) / range;
      final double y = size.height - (normalized * size.height);
      points.add(Offset(x, y));
    }

    // Build Smooth Cubic Bezier Path
    final Path strokePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final Offset current = points[i];
      final Offset next = points[i + 1];
      final Offset controlPoint1 = Offset(
        current.dx + (next.dx - current.dx) / 2,
        current.dy,
      );
      final Offset controlPoint2 = Offset(
        current.dx + (next.dx - current.dx) / 2,
        next.dy,
      );
      strokePath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        next.dx,
        next.dy,
      );
    }

    // Area Fill Path
    final Path areaPath = Path.from(strokePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? <Color>[
                AmanahColorTokens.brand.withValues(alpha: 0.45),
                AmanahColorTokens.brandLight.withValues(alpha: 0.15),
                AmanahColorTokens.brand.withValues(alpha: 0.0),
              ]
            : <Color>[
                AmanahColorTokens.brand.withValues(alpha: 0.32),
                AmanahColorTokens.brandLight.withValues(alpha: 0.08),
                AmanahColorTokens.brand.withValues(alpha: 0.0),
              ],
        stops: const <double>[0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, fillPaint);

    // Stroke line
    final Paint linePaint = Paint()
      ..color = AmanahColorTokens.brand
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(strokePath, linePaint);

    // Tip Beam Dot on the Last Point
    final Offset tip = points.last;
    final Paint outerGlow = Paint()
      ..color = AmanahColorTokens.brandLight.withValues(alpha: 0.45);
    canvas.drawCircle(tip, 9, outerGlow);

    final Paint midGlow = Paint()
      ..color = AmanahColorTokens.brand.withValues(alpha: 0.40);
    canvas.drawCircle(tip, 6, midGlow);

    final Paint coreDot = Paint()..color = AmanahColorTokens.brand;
    final Paint coreDotStroke = Paint()
      ..color = AmanahColorTokens.surfaceLight
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(tip, 4, coreDot);
    canvas.drawCircle(tip, 4, coreDotStroke);

    // Tooltip if a point is selected
    if (selectedPointIndex != null &&
        selectedPointIndex! >= 0 &&
        selectedPointIndex! < points.length) {
      final Offset selPoint = points[selectedPointIndex!];

      // Draw vertical cursor dash line
      final Paint cursorPaint = Paint()
        ..color = AmanahColorTokens.brand.withValues(alpha: 0.4)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(selPoint.dx, 0),
        Offset(selPoint.dx, size.height),
        cursorPaint,
      );

      // Draw Selected Dot
      canvas.drawCircle(selPoint, 5, Paint()..color = AmanahColorTokens.brand);
      canvas.drawCircle(selPoint, 5, coreDotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ClinicAreaChartPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.isDark != isDark ||
      oldDelegate.selectedPointIndex != selectedPointIndex;
}
