import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import '../../domain/entities/pregnancy_calculation_result.dart';
import '../../domain/services/pregnancy_calculator_service.dart';

class AmanahPregnancyCalculatorDrawer extends StatefulWidget {
  const AmanahPregnancyCalculatorDrawer({super.key});

  static Future<void> show(BuildContext context) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => const AmanahPregnancyCalculatorDrawer(),
    );
  }

  @override
  State<AmanahPregnancyCalculatorDrawer> createState() =>
      _AmanahPregnancyCalculatorDrawerState();
}

class _AmanahPregnancyCalculatorDrawerState
    extends State<AmanahPregnancyCalculatorDrawer> {
  final PregnancyCalculatorService _service = const PregnancyCalculatorService();
  DateTime? _selectedLmp;
  PregnancyCalculationResult? _result;

  void _onDatePicked(DateTime date) {
    setState(() {
      _selectedLmp = date;
      _result = _service.calculate(lmp: date);
    });
  }

  void _handleReset() {
    setState(() {
      _selectedLmp = null;
      _result = null;
    });
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime initial =
        _selectedLmp ?? now.subtract(const Duration(days: 70));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: now.subtract(const Duration(days: 300)),
      lastDate: now,
      helpText: 'Hari pertama haid terakhir (HPHT)',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      _onDatePicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900;
    final Color subTextColor =
        dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600;
    final Color cardBg =
        dark ? AmanahColorTokens.surfaceSecondaryDark : AmanahColorTokens.neutral50;
    final Color borderColor =
        dark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral200;

    return AmanahBottomSheetScaffold(
      title: 'Kalkulator Kehamilan',
      fixedHeightFactor: 0.50,
      hugContent: false,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: subTextColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedLmp != null
                            ? formatLocalizedDate(_selectedLmp!, style: 'human_medium')
                            : 'Pilih Hari Pertama Haid Terakhir (HPHT)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: _selectedLmp != null
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _selectedLmp != null ? textColor : subTextColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: subTextColor,
                    ),
                  ],
                ),
              ),
            ),
            if (_result != null) ...<Widget>[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Hari Perkiraan Lahir (HPL)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatLocalizedDate(_result!.edd, style: 'human_full'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_result!.daysRemaining} hari lagi',
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),
                    Divider(
                      height: 24,
                      thickness: 1,
                      color: borderColor,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Usia Kehamilan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _result!.gestationalAgeFormatted,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'Trimester',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Trimester ${_result!.trimester}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AmanahColorTokens.emerald,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _handleReset,
                  child: Text(
                    'Reset Perhitungan',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: subTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
