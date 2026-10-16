sealed class ScheduleFailure implements Exception {
  const ScheduleFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AmanahScheduleException extends ScheduleFailure {
  const AmanahScheduleException(super.message, {super.code});
}

final class ScheduleServerFailure extends AmanahScheduleException {
  const ScheduleServerFailure([
    super.message = 'Terjadi kendala pada server jadwal. Silakan coba beberapa saat lagi.',
    String? code,
  ]) : super(code: code);
}

final class ScheduleNetworkFailure extends AmanahScheduleException {
  const ScheduleNetworkFailure([
    super.message = 'Koneksi internet bermasalah. Periksa jaringan Anda.',
  ]) : super(code: 'NETWORK_ERROR');
}

final class ScheduleNotFoundFailure extends AmanahScheduleException {
  const ScheduleNotFoundFailure([
    super.message = 'Data jadwal atau sesi tidak ditemukan.',
  ]) : super(code: 'NOT_FOUND');
}

final class ScheduleUnauthorizedFailure extends AmanahScheduleException {
  const ScheduleUnauthorizedFailure([
    super.message = 'Sesi Anda telah kedaluwarsa atau Anda tidak memiliki akses.',
  ]) : super(code: 'UNAUTHORIZED');
}

final class ScheduleValidationFailure extends AmanahScheduleException {
  const ScheduleValidationFailure(
    super.message, {
    super.code = 'VALIDATION_ERROR',
  });
}
