import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';

/// Categorical outcome types for the Presence Scanner flow.
enum PresenceStatusType {
  successCheckIn,
  successCheckOut,
  conflictAlreadyCheckedIn,
  conflictAlreadyCheckedOut,
  notCheckedIn,
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
    this.timeFormatted,
    this.durationHours,
    this.actionLabel = 'Saya Mengerti',
  });

  final PresenceStatusType type;
  final String title;
  final String message;
  final String? timeFormatted;
  final double? durationHours;
  final String actionLabel;

  bool get isSuccess =>
      type == PresenceStatusType.successCheckIn || type == PresenceStatusType.successCheckOut;

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
        timeFormatted: timeFormatted,
        durationHours: validatedDurationHours,
        actionLabel: 'Selesai',
      );
    }
    return PresenceStatusPayload(
      type: PresenceStatusType.successCheckIn,
      title: 'Presensi Masuk Berhasil',
      message: 'Presensi masuk dinas Anda telah berhasil diverifikasi dan tersimpan.',
      timeFormatted: timeFormatted,
      durationHours: validatedDurationHours,
      actionLabel: 'Selesai',
    );
  }

  /// Maps an exception directly from the backend machine-readable contract.
  factory PresenceStatusPayload.fromException(Object error, {AttendanceMethod? method}) {
    if (error is ApiException) {
      switch (error.code) {
        case 'ATTENDANCE_NOT_FOUND':
          return const PresenceStatusPayload(
            type: PresenceStatusType.notCheckedIn,
            title: 'Belum Presensi Masuk',
            message:
                'Data presensi masuk untuk hari ini tidak ditemukan. Silakan lakukan presensi masuk terlebih dahulu sebelum presensi pulang.',
            actionLabel: 'Ubah ke Presensi Masuk',
          );

        case 'DUPLICATE_CHECK_IN':
          return const PresenceStatusPayload(
            type: PresenceStatusType.conflictAlreadyCheckedIn,
            title: 'Sudah Presensi Masuk',
            message:
                'Anda sudah melakukan presensi masuk hari ini. Silakan gunakan mode Presensi Pulang jika dinas Anda telah selesai.',
            actionLabel: 'Saya Mengerti',
          );

        case 'ALREADY_CHECKED_OUT':
          return const PresenceStatusPayload(
            type: PresenceStatusType.conflictAlreadyCheckedOut,
            title: 'Sudah Presensi Pulang',
            message:
                'Presensi pulang sudah tercatat sebelumnya untuk hari ini. Tidak ada sesi dinas aktif yang perlu ditutup.',
            actionLabel: 'Saya Mengerti',
          );

        case 'NO_ACTIVE_SESSION':
        case 'SESSION_EXPIRED':
        case 'STAFF_NOT_ROSTERED':
        case 'SESSION_MISMATCH':
          return PresenceStatusPayload(
            type: PresenceStatusType.outOfSchedule,
            title: error.code == 'SESSION_EXPIRED' ? 'Sesi Telah Berakhir' : 'Di Luar Jadwal Dinas',
            message: error.message.isNotEmpty
                ? error.message
                : 'Anda tidak memiliki jadwal dinas aktif pada sesi waktu saat ini. Hubungi koordinator staf jika terdapat kekeliruan.',
            actionLabel: 'Saya Mengerti',
          );

        case 'STAFF_ON_LEAVE':
          return const PresenceStatusPayload(
            type: PresenceStatusType.onOfficialLeave,
            title: 'Status Izin / Cuti Aktif',
            message:
                'Sistem mendeteksi izin resmi atau cuti dinas yang telah disetujui untuk hari ini.',
            actionLabel: 'Saya Mengerti',
          );

        case 'INVALID_MANUAL_CODE':
          return const PresenceStatusPayload(
            type: PresenceStatusType.invalidOrExpiredToken,
            title: 'Kode Presensi Tidak Valid',
            message:
                'Kode presensi tidak dikenali atau sudah kedaluwarsa. Silakan periksa kode 6-karakter terbaru pada terminal kehadiran.',
            actionLabel: 'Coba Lagi',
          );

        case 'INVALID_QR_TOKEN':
          if (method == AttendanceMethod.manualPin) {
            return const PresenceStatusPayload(
              type: PresenceStatusType.invalidOrExpiredToken,
              title: 'Kode Presensi Tidak Valid',
              message:
                  'Kode presensi tidak dikenali atau sudah kedaluwarsa. Silakan periksa kode 6-karakter terbaru pada terminal kehadiran.',
              actionLabel: 'Coba Lagi',
            );
          }
          return const PresenceStatusPayload(
            type: PresenceStatusType.invalidOrExpiredToken,
            title: 'Token QR Tidak Valid',
            message:
                'Token QR tidak dikenali atau sudah kedaluwarsa. Silakan scan QR code dinamis terbaru di terminal kehadiran.',
            actionLabel: 'Scan Ulang',
          );
      }

      // Secondary fallback based strictly on HTTP status code
      switch (error.statusCode) {
        case 404:
          return const PresenceStatusPayload(
            type: PresenceStatusType.notCheckedIn,
            title: 'Belum Presensi Masuk',
            message:
                'Data presensi masuk untuk hari ini tidak ditemukan. Silakan lakukan presensi masuk terlebih dahulu sebelum presensi pulang.',
            actionLabel: 'Ubah ke Presensi Masuk',
          );
        case 409:
          return PresenceStatusPayload(
            type: PresenceStatusType.conflictAlreadyCheckedOut,
            title: 'Konflik Presensi',
            message: error.message,
            actionLabel: 'Saya Mengerti',
          );
        case 403:
          return const PresenceStatusPayload(
            type: PresenceStatusType.outOfSchedule,
            title: 'Di Luar Jadwal Dinas',
            message: 'Anda tidak memiliki jadwal dinas aktif pada sesi waktu saat ini.',
            actionLabel: 'Saya Mengerti',
          );
      }
    }

    final String cleanMessage = error is ApiException
        ? error.message
        : error.toString().replaceAll('Exception: ', '').replaceAll('FormatException: ', '');

    return PresenceStatusPayload(
      type: PresenceStatusType.genericError,
      title: 'Gagal Memproses Presensi',
      message: cleanMessage.isNotEmpty
          ? cleanMessage
          : 'Terjadi kendala saat memproses presensi dinas.',
      actionLabel: 'Saya Mengerti',
    );
  }

  /// Backward-compatible bridge for legacy callers passing raw string error.
  factory PresenceStatusPayload.fromError(String rawError, {AttendanceMethod? method}) =>
      PresenceStatusPayload.fromException(rawError, method: method);
}
