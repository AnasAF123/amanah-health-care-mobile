abstract final class GenderConstants {
  static const String male = 'male';
  static const String female = 'female';

  static const String maleLabel = 'Laki-laki';
  static const String femaleLabel = 'Perempuan';

  static String toLabel(String? value) {
    if (value == null) return '-';
    final String normalized = value.trim().toLowerCase();
    if (normalized == female) return femaleLabel;
    if (normalized == male) return maleLabel;
    return value;
  }
}
