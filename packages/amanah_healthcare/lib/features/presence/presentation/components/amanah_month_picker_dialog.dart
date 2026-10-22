import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Clean Dialog for selecting Year and Month.
/// Features direct year typing input (< [Year] >) and a 3x4 grid of 12 months.
class AmanahMonthPickerDialog extends StatefulWidget {
  const AmanahMonthPickerDialog({required this.initialMonth, super.key});

  final DateTime initialMonth;

  static Future<DateTime?> show({required BuildContext context, required DateTime initialMonth}) {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext ctx) => AmanahMonthPickerDialog(initialMonth: initialMonth),
    );
  }

  static const List<String> monthsFull = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String formatMonthYear(DateTime date) {
    if (date.month >= 1 && date.month <= 12) {
      return '${monthsFull[date.month - 1]} ${date.year}';
    }
    return '${date.month}-${date.year}';
  }

  @override
  State<AmanahMonthPickerDialog> createState() => _AmanahMonthPickerDialogState();
}

class _AmanahMonthPickerDialogState extends State<AmanahMonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late final TextEditingController _yearController;

  static const List<String> _monthsShort = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialMonth.year;
    _selectedMonth = widget.initialMonth.month;
    _yearController = TextEditingController(text: '$_selectedYear');
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final DateTime now = DateTime.now();

    final Color bgColor = dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.surfaceLight;
    final Color textColor = dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900;
    final Color subtextColor = dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600;
    final Color activeAccent = dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand;
    final Color activeText = dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.surfaceLight;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: dark ? AmanahThemeTokens.outline(context) : AmanahColorTokens.neutral200,
          width: 1,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 1. Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Pilih Bulan Ekspor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, size: 18, color: subtextColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Year Navigator (< [ Year Input ] >)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: dark
                    ? AmanahColorTokens.neutral800.withValues(alpha: 0.5)
                    : AmanahColorTokens.neutral100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    iconSize: 22,
                    color: textColor,
                    onPressed: () {
                      setState(() {
                        _selectedYear--;
                        _yearController.text = '$_selectedYear';
                      });
                    },
                  ),
                  Container(
                    width: 76,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: dark
                          ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
                          : AmanahColorTokens.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: dark
                            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
                            : AmanahColorTokens.neutral300,
                        width: 0.8,
                      ),
                    ),
                    child: TextField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 2),
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: (String val) {
                        final int? parsed = int.tryParse(val);
                        if (parsed != null && parsed >= 1900 && parsed <= 2100) {
                          setState(() {
                            _selectedYear = parsed;
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    iconSize: 22,
                    color: textColor,
                    onPressed: () {
                      setState(() {
                        _selectedYear++;
                        _yearController.text = '$_selectedYear';
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3. Month Grid (3 columns x 4 rows)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (BuildContext ctx, int index) {
                final int monthNumber = index + 1;
                final bool isSelected =
                    _selectedYear == widget.initialMonth.year && monthNumber == _selectedMonth;
                final bool isCurrentMonth = _selectedYear == now.year && monthNumber == now.month;

                return InkWell(
                  onTap: () {
                    final DateTime picked = DateTime(_selectedYear, monthNumber);
                    Navigator.of(context).pop(picked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeAccent
                          : (isCurrentMonth
                                ? activeAccent.withValues(alpha: 0.12)
                                : (dark
                                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                                      : AmanahColorTokens.surfaceLight)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? activeAccent
                            : (isCurrentMonth
                                  ? activeAccent.withValues(alpha: 0.40)
                                  : (dark
                                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                                        : AmanahColorTokens.neutral200)),
                      ),
                    ),
                    child: Text(
                      _monthsShort[index],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected || isCurrentMonth
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? activeText
                            : (isCurrentMonth ? activeAccent : textColor),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 4. Quick Helper Note
            Text(
              'Laporan presensi akan mengekspor seluruh rekaman tanggal 1 sampai akhir bulan pilihan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: subtextColor, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
