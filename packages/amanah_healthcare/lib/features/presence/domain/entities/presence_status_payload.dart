/// Categorical outcome types for the Presence Scanner flow.
enum PresenceStatusType {
  successCheckIn,
  successCheckOut,
  conflictAlreadyCheckedIn,
  conflictAlreadyCheckedOut,
  outOfSchedule,
  invalidOrExpiredToken,
  onOfficialLeave,
  genericError,
}

/// Domain entity representing the complete payload for presence flow feedback.
class PresenceStatusPayload {
  const PresenceStatusPayload({
    required this.type,
    required this.title,
    required this.message,
    required this.badgeLabel,
    this.timeFormatted,
    this.durationHours,
    this.actionLabel = 'Saya Mengerti',
  });

  final PresenceStatusType type;
  final String title;
  final String message;
  final String badgeLabel;
  final String? timeFormatted;
  final double? durationHours;
  final String actionLabel;

  bool get isSuccess =>
      type == PresenceStatusType.successCheckIn ||
      type == PresenceStatusType.successCheckOut;

  bool get isCheckOut =>
      type == PresenceStatusType.successCheckOut ||
      type == PresenceStatusType.conflictAlreadyCheckedOut;

  /// Creates a canonical payload from check-in/out result entity.
  factory PresenceStatusPayload.fromSuccess({
    required String timeFormatted,
    required bool isCheckOut,
    double? validatedDurationHours,
  }) {
    if (isCheckOut) {
      return PresenceStatusPayload(
        type: PresenceStatusType.successCheckOut,
        title: 'Presensi Pulang Berhasil',
        message: 'Presensi pulang dinas Anda telah berhasil diverifikasi dan tersimpan.',
        badgeLabel: 'BERHASIL PULANG',
        timeFormatted: timeFormatted,
        durationHours: validatedDurationHours,
        actionLabel: 'Selesai',
      );
    }
    return PresenceStatusPayload(
      type: PresenceStatusType.successCheckIn,
      title: 'Presensi Masuk Berhasil',
      message: 'Presensi masuk dinas Anda telah berhasil diverifikasi dan tersimpan.',
      badgeLabel: 'BERHASIL MASUK',
      timeFormatted: timeFormatted,
      durationHours: validatedDurationHours,
      actionLabel: 'Selesai',
    );
  }

  /// Maps an error message to a structured, typed presence payload.
  factory PresenceStatusPayload.fromError(String rawError) {
    final String str = rawError.toLowerCase();

    if (str.contains('sudah melakukan presensi masuk') || str.contains('masuk hari ini')) {
      return PresenceStatusPayload(
        type: PresenceStatusType.conflictAlreadyCheckedIn,
        title: 'Sudah Presensi Masuk',
        message: 'Anda sudah melakukan presensi masuk hari ini. Silakan gunakan mode Presensi Pulang jika dinas Anda telah selesai.',
        badgeLabel: 'SUDAH TERDATA',
        actionLabel: 'Saya Mengerti',
      );
    }

    if (str.contains('sudah tercatat sebelumnya') || str.contains('pulang hari ini')) {
      return PresenceStatusPayload(
        type: PresenceStatusType.conflictAlreadyCheckedOut,
        title: 'Sudah Presensi Pulang',
        message: 'Presensi pulang sudah tercatat sebelumnya untuk hari ini. Tidak ada sesi dinas aktif yang perlu ditutup.',
        badgeLabel: 'SUDAH SELESAI',
        actionLabel: 'Saya Mengerti',
      );
    }

    if (str.contains('jadwal dinas') || str.contains('roster') || str.contains('403')) {
      return PresenceStatusPayload(
        type: PresenceStatusType.outOfSchedule,
        title: 'Di Luar Jadwal Dinas',
        message: 'Anda tidak memiliki jadwal dinas aktif pada sesi waktu saat ini. Hubungi koordinator staf jika terdapat kekeliruan.',
        badgeLabel: 'DILUAR JADWAL',
        actionLabel: 'Saya Mengerti',
      );
    }

    if (str.contains('cuti') || str.contains('izin resmi')) {
      return PresenceStatusPayload(
        type: PresenceStatusType.onOfficialLeave,
        title: 'Status Izin / Cuti Aktif',
        message: 'Sistem mendeteksi izin resmi atau cuti dinas yang telah disetujui untuk hari ini.',
        badgeLabel: 'CUTI RESMI',
        actionLabel: 'Saya Mengerti',
      );
    }

    if (str.contains('token qr') || str.contains('kedaluwarsa') || str.contains('format qr') || str.contains('400')) {
      return PresenceStatusPayload(
        type: PresenceStatusType.invalidOrExpiredToken,
        title: 'Token QR Tidak Valid',
        message: 'Token QR tidak dikenali atau sudah kedaluwarsa. Silakan scan QR code dinamis terbaru di terminal kehadiran.',
        badgeLabel: 'KEDALUWARSA',
        actionLabel: 'Scan Ulang',
      );
    }

    return PresenceStatusPayload(
      type: PresenceStatusType.genericError,
      title: 'Gagal Memproses Presensi',
      message: rawError.replaceAll('Exception: ', '').replaceAll('FormatException: ', ''),
      badgeLabel: 'PERIKSA KEMBALI',
      actionLabel: 'Saya Mengerti',
    );
  }
}
