/// Domain exception for schedule operations.
class AmanahScheduleException implements Exception {
  const AmanahScheduleException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Conflict exception thrown on HTTP 409/422 Conflict and Unprocessable responses.
class AmanahScheduleConflictException extends AmanahScheduleException {
  const AmanahScheduleConflictException({
    required String message,
    required String code,
    this.conflictingDoctor,
    this.conflictingRoom,
    this.conflictingTimeRange,
    this.activeBookingCount,
  }) : super(message, code: code);

  final String? conflictingDoctor;
  final String? conflictingRoom;
  final String? conflictingTimeRange;
  final int? activeBookingCount;

  static const String scheduleHasActiveBookings = 'SCHEDULE_HAS_ACTIVE_BOOKINGS';
  static const String roomAlreadyOccupied = 'ROOM_ALREADY_OCCUPIED';
  static const String practitionerAlreadyScheduled = 'PRACTITIONER_ALREADY_SCHEDULED';
  static const String invalidTimeRange = 'INVALID_TIME_RANGE';
  static const String startOutsideBoundary = 'START_OUTSIDE_BOUNDARY';
  static const String invalidStartPrecision = 'INVALID_START_PRECISION';
  static const String durationLeavesNoCapacity = 'DURATION_LEAVES_NO_CAPACITY';
  static const String dateClosed = 'DATE_CLOSED';
  static const String scheduleModifiedConcurrently = 'SCHEDULE_MODIFIED_CONCURRENTLY';

  bool get hasActiveBookings => code == scheduleHasActiveBookings;
  bool get isRoomOccupied => code == roomAlreadyOccupied;
  bool get isPractitionerConflict => code == practitionerAlreadyScheduled;
  bool get isInvalidTimeRange => code == invalidTimeRange;
  bool get isStartOutsideBoundary => code == startOutsideBoundary;
  bool get isInvalidStartPrecision => code == invalidStartPrecision;
  bool get isDurationLeavesNoCapacity => code == durationLeavesNoCapacity;
  bool get isDateClosed => code == dateClosed;
  bool get isConcurrentModification => code == scheduleModifiedConcurrently;

  /// Returns user-facing Indonesian message based on canonical domain error codes.
  static String userMessageForCode(String code, {String? defaultMessage}) {
    switch (code) {
      case startOutsideBoundary:
        return 'Jam mulai berada di luar batas waktu shift yang dipilih.';
      case invalidStartPrecision:
        return 'Jam mulai tidak sesuai presisi menit yang diizinkan.';
      case durationLeavesNoCapacity:
        return 'Waktu mulai terlalu dekat dengan akhir shift sehingga tidak ada kuota konsultasi.';
      case dateClosed:
        return 'Tidak dapat membuat jadwal karena Anda tercatat sedang cuti pada tanggal ini.';
      case practitionerAlreadyScheduled:
        return 'Anda sudah memiliki jadwal lain yang bertabrakan pada rentang waktu ini.';
      case roomAlreadyOccupied:
        return 'Ruangan tersebut sudah digunakan oleh dokter lain pada jam ini.';
      case scheduleHasActiveBookings:
        return 'Jadwal tidak dapat dihapus atau diubah karena sudah ada pasien terdaftar. Silakan batalkan atau pindahkan pasien terlebih dahulu.';
      case scheduleModifiedConcurrently:
        return 'Jadwal telah diubah oleh pengguna lain. Silakan muat ulang halaman.';
      default:
        return defaultMessage ?? 'Terjadi kendala penjadwalan pada sistem.';
    }
  }
}
