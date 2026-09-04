import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

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

const List<ClinicMonthRecord> kMonthlyRecords = <ClinicMonthRecord>[
  ClinicMonthRecord(
    monthName: 'Mei',
    year: 2026,
    data: <ClinicDayData>[
      ClinicDayData(
        dayShort: '1 Mei',
        label: '1 Mei',
        patients: 82,
        newPatients: 26,
      ),
      ClinicDayData(
        dayShort: '6 Mei',
        label: '6 Mei',
        patients: 95,
        newPatients: 30,
      ),
      ClinicDayData(
        dayShort: '11 Mei',
        label: '11 Mei',
        patients: 104,
        newPatients: 32,
      ),
      ClinicDayData(
        dayShort: '16 Mei',
        label: '16 Mei',
        patients: 98,
        newPatients: 28,
      ),
      ClinicDayData(
        dayShort: '21 Mei',
        label: '21 Mei',
        patients: 112,
        newPatients: 36,
      ),
      ClinicDayData(
        dayShort: '26 Mei',
        label: '26 Mei',
        patients: 120,
        newPatients: 38,
      ),
      ClinicDayData(
        dayShort: '31 Mei',
        label: '31 Mei',
        patients: 128,
        newPatients: 42,
      ),
    ],
  ),
  ClinicMonthRecord(
    monthName: 'Juni',
    year: 2026,
    data: <ClinicDayData>[
      ClinicDayData(
        dayShort: '1 Jun',
        label: '1 Juni',
        patients: 85,
        newPatients: 25,
      ),
      ClinicDayData(
        dayShort: '6 Jun',
        label: '6 Juni',
        patients: 102,
        newPatients: 32,
      ),
      ClinicDayData(
        dayShort: '11 Jun',
        label: '11 Juni',
        patients: 110,
        newPatients: 34,
      ),
      ClinicDayData(
        dayShort: '16 Jun',
        label: '16 Juni',
        patients: 105,
        newPatients: 30,
      ),
      ClinicDayData(
        dayShort: '21 Jun',
        label: '21 Juni',
        patients: 122,
        newPatients: 38,
      ),
      ClinicDayData(
        dayShort: '26 Jun',
        label: '26 Juni',
        patients: 128,
        newPatients: 37,
      ),
      ClinicDayData(
        dayShort: '30 Jun',
        label: '30 Juni',
        patients: 135,
        newPatients: 40,
      ),
    ],
  ),
  ClinicMonthRecord(
    monthName: 'Juli',
    year: 2026,
    data: <ClinicDayData>[
      ClinicDayData(
        dayShort: '1 Jul',
        label: '1 Juli',
        patients: 90,
        newPatients: 28,
      ),
      ClinicDayData(
        dayShort: '6 Jul',
        label: '6 Juli',
        patients: 108,
        newPatients: 35,
      ),
      ClinicDayData(
        dayShort: '11 Jul',
        label: '11 Juli',
        patients: 115,
        newPatients: 36,
      ),
      ClinicDayData(
        dayShort: '16 Jul',
        label: '16 Juli',
        patients: 110,
        newPatients: 88,
      ),
      ClinicDayData(
        dayShort: '21 Jul',
        label: '21 Juli',
        patients: 126,
        newPatients: 40,
      ),
      ClinicDayData(
        dayShort: '26 Jul',
        label: '26 Juli',
        patients: 132,
        newPatients: 42,
      ),
      ClinicDayData(
        dayShort: '31 Jul',
        label: '31 Juli',
        patients: 138,
        newPatients: 45,
      ),
    ],
  ),
  ClinicMonthRecord(
    monthName: 'Agustus',
    year: 2026,
    data: <ClinicDayData>[
      ClinicDayData(
        dayShort: '1 Agu',
        label: '1 Agustus',
        patients: 88,
        newPatients: 27,
      ),
      ClinicDayData(
        dayShort: '3 Agu',
        label: '3 Agustus',
        patients: 112,
        newPatients: 34,
      ),
      ClinicDayData(
        dayShort: '5 Agu',
        label: '5 Agustus',
        patients: 118,
        newPatients: 36,
      ),
      ClinicDayData(
        dayShort: '7 Agu',
        label: '7 Agustus',
        patients: 105,
        newPatients: 32,
      ),
      ClinicDayData(
        dayShort: '9 Agu',
        label: '9 Agustus',
        patients: 114,
        newPatients: 35,
      ),
      ClinicDayData(
        dayShort: '11 Agu',
        label: '11 Agustus',
        patients: 109,
        newPatients: 33,
      ),
      ClinicDayData(
        dayShort: '12 Agu',
        label: '12 Agustus',
        patients: 140,
        newPatients: 43,
      ),
    ],
  ),
  ClinicMonthRecord(
    monthName: 'September',
    year: 2026,
    data: <ClinicDayData>[
      ClinicDayData(
        dayShort: '1 Sep',
        label: '1 September',
        patients: 92,
        newPatients: 29,
      ),
      ClinicDayData(
        dayShort: '6 Sep',
        label: '6 September',
        patients: 115,
        newPatients: 36,
      ),
      ClinicDayData(
        dayShort: '11 Sep',
        label: '11 September',
        patients: 120,
        newPatients: 38,
      ),
      ClinicDayData(
        dayShort: '16 Sep',
        label: '16 September',
        patients: 118,
        newPatients: 35,
      ),
      ClinicDayData(
        dayShort: '21 Sep',
        label: '21 September',
        patients: 130,
        newPatients: 42,
      ),
      ClinicDayData(
        dayShort: '26 Sep',
        label: '26 September',
        patients: 138,
        newPatients: 44,
      ),
      ClinicDayData(
        dayShort: '30 Sep',
        label: '30 September',
        patients: 146,
        newPatients: 46,
      ),
    ],
  ),
];

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
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AmanahThemeTokens.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$returning Pasien',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
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
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AmanahThemeTokens.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$newPatients Pasien',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
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
                    fontFamily: 'PlusJakartaSans',
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
                          fontFamily: 'PlusJakartaSans',
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
                        color: Color(0xFF0D66E9),
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0xFF3B82F6),
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
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF1F5F9),
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
                      fontFamily: 'PlusJakartaSans',
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
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF1F5F9),
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
                            fontFamily: 'PlusJakartaSans',
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
                              fontFamily: 'PlusJakartaSans',
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
                          ? const Color(0xFF0C2445)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: dark
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                            : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 11,
                          color: Color(0xFF0D66E9),
                        ),
                        SizedBox(width: 3),
                        Text(
                          '+12.5%',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D66E9),
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
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: dark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
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
                                      fontFamily: 'PlusJakartaSans',
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
                              fontFamily: 'PlusJakartaSans',
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
                                      fontFamily: 'PlusJakartaSans',
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
                              fontFamily: 'PlusJakartaSans',
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
                const Color(0xFF0D66E9).withValues(alpha: 0.45),
                const Color(0xFF3B82F6).withValues(alpha: 0.15),
                const Color(0xFF0D66E9).withValues(alpha: 0.0),
              ]
            : <Color>[
                const Color(0xFF0D66E9).withValues(alpha: 0.32),
                const Color(0xFF3B82F6).withValues(alpha: 0.08),
                const Color(0xFF0D66E9).withValues(alpha: 0.0),
              ],
        stops: const <double>[0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, fillPaint);

    // Stroke line
    final Paint linePaint = Paint()
      ..color = const Color(0xFF0D66E9)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(strokePath, linePaint);

    // Tip Beam Dot on the Last Point
    final Offset tip = points.last;
    final Paint outerGlow = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.45);
    canvas.drawCircle(tip, 9, outerGlow);

    final Paint midGlow = Paint()
      ..color = const Color(0xFF0D66E9).withValues(alpha: 0.40);
    canvas.drawCircle(tip, 6, midGlow);

    final Paint coreDot = Paint()..color = const Color(0xFF0D66E9);
    final Paint coreDotStroke = Paint()
      ..color = Colors.white
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
        ..color = const Color(0xFF0D66E9).withValues(alpha: 0.4)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(selPoint.dx, 0),
        Offset(selPoint.dx, size.height),
        cursorPaint,
      );

      // Draw Selected Dot
      canvas.drawCircle(selPoint, 5, Paint()..color = const Color(0xFF0D66E9));
      canvas.drawCircle(selPoint, 5, coreDotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ClinicAreaChartPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.isDark != isDark ||
      oldDelegate.selectedPointIndex != selectedPointIndex;
}
