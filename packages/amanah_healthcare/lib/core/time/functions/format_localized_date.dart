import 'package:amanah_healthcare/core/time/functions/format_iso_date_string.dart';

const List<String> _idDays = <String>[
  '',
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const List<String> _idMonths = <String>[
  '',
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

const List<String> _idShortMonths = <String>[
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const List<String> _enDays = <String>[
  '',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _enMonths = <String>[
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _enShortMonths = <String>[
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a [date] into a human-readable localized string based on [style] and [locale].
///
/// Supported styles:
/// - `human_full`: "Kamis, 22 Oktober 2026"
/// - `human_medium`: "22 Oktober 2026"
/// - `human_short`: "22 Okt 2026"
/// - `day_and_short_month`: "Kamis, 22 Okt"
/// - `day_name`: "Kamis"
/// - `iso`: "2026-10-22"
String formatLocalizedDate(
  DateTime date, {
  String style = 'human_full',
  String locale = 'id-ID',
}) {
  final bool isEn = locale.toLowerCase().startsWith('en');
  final List<String> days = isEn ? _enDays : _idDays;
  final List<String> months = isEn ? _enMonths : _idMonths;
  final List<String> shortMonths = isEn ? _enShortMonths : _idShortMonths;

  final String dayName = days[date.weekday];
  final String monthName = months[date.month];
  final String shortMonth = shortMonths[date.month];

  switch (style) {
    case 'human_full':
      return '$dayName, ${date.day} $monthName ${date.year}';
    case 'human_medium':
      return '${date.day} $monthName ${date.year}';
    case 'human_short':
      return '${date.day} $shortMonth ${date.year}';
    case 'day_and_short_month':
      return '$dayName, ${date.day} $shortMonth';
    case 'day_name':
      return dayName;
    case 'month_name':
      return monthName;
    case 'iso':
      return formatIsoDateString(date);
    default:
      return '$dayName, ${date.day} $monthName ${date.year}';
  }
}
