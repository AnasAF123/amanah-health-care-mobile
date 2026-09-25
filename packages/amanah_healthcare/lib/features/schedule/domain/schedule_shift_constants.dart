/// Canonical 4-Shift 24-Hour Cycle Constants & SSOT Mapping
/// Aligned strictly with PostgreSQL database enums `staff_shift` and backend `schedule-shift.constants.ts`.
enum CanonicalShift {
  earlyMorning(
    code: 'early_morning',
    dtoSession: 'DINI_HARI',
    label: 'Dini Hari',
    defaultStartTime: '00:00',
    defaultEndTime: '06:00',
    startMinutes: 0,
    endMinutes: 360,
  ),
  morning(
    code: 'morning',
    dtoSession: 'PAGI',
    label: 'Pagi',
    defaultStartTime: '06:00',
    defaultEndTime: '12:00',
    startMinutes: 360,
    endMinutes: 720,
  ),
  afternoon(
    code: 'afternoon',
    dtoSession: 'SIANG',
    label: 'Siang',
    defaultStartTime: '12:00',
    defaultEndTime: '18:00',
    startMinutes: 720,
    endMinutes: 1080,
  ),
  night(
    code: 'night',
    dtoSession: 'MALAM',
    label: 'Malam',
    defaultStartTime: '18:00',
    defaultEndTime: '24:00',
    startMinutes: 1080,
    endMinutes: 1440,
  );

  const CanonicalShift({
    required this.code,
    required this.dtoSession,
    required this.label,
    required this.defaultStartTime,
    required this.defaultEndTime,
    required this.startMinutes,
    required this.endMinutes,
  });

  final String code;
  final String dtoSession;
  final String label;
  final String defaultStartTime;
  final String defaultEndTime;
  final int startMinutes;
  final int endMinutes;

  /// Resolves any raw session string (case-insensitive, Indonesian or English)
  /// to its canonical enum representation.
  static CanonicalShift? tryResolve(String? raw) {
    if (raw == null) return null;
    final String clean = raw.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    switch (clean) {
      case 'early_morning':
      case 'earlymorning':
      case 'dini_hari':
      case 'dinihari':
        return CanonicalShift.earlyMorning;
      case 'morning':
      case 'pagi':
        return CanonicalShift.morning;
      case 'afternoon':
      case 'siang':
        return CanonicalShift.afternoon;
      case 'night':
      case 'malam':
        return CanonicalShift.night;
      default:
        return null;
    }
  }

  /// Resolves or falls back to [morning]
  static CanonicalShift resolve(String? raw) {
    return tryResolve(raw) ?? CanonicalShift.morning;
  }
}

class ShiftTimingConstants {
  const ShiftTimingConstants._();

  static const int minutesPerDay = 1440;
  static const int standardConsultationMinutes = 30;
  static const String midnightTime = '00:00';
  static const String endOfDayTime = '24:00';
}

class ScheduleCanonicalStatus {
  const ScheduleCanonicalStatus._();

  static const String open = 'OPEN';
  static const String closed = 'CLOSED';
  static const String occupied = 'OCCUPIED';
  static const String available = 'AVAILABLE';
  static const String cuti = 'CUTI';
  static const String tutup = 'TUTUP';
  static const String terisi = 'TERISI';
  static const String buka = 'BUKA';
  static const String batal = 'BATAL';
}

class ScheduleFormConstants {
  const ScheduleFormConstants._();

  static const String selectTime = 'Pilih Jam';
  static const String emptyTime = '-';
  static const String selectRoom = 'Pilih Ruang Praktik';
  static const String selectPoli = 'Pilih Poliklinik';
  static const String statusBuka = 'Buka';
  static const String statusTutup = 'Tutup';
  static const String statusCuti = 'Cuti';
  static const String statusBatal = 'Dibatalkan';
  static const String badgeSudahSelesai = 'Sudah Selesai';
  static const String badgePenuh = 'Penuh';
  static const String badgeWaktuHabis = 'Waktu Habis';
  static const String badgeTersedia = 'tersedia';
  static const String badgeTerisi = 'Terisi';
  static const String badgeSelesai = 'Selesai';
  static const String labelTerisi = 'Terisi';
  static const String labelTersedia = 'Tersedia';
}

