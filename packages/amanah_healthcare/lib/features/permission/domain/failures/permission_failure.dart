sealed class PermissionFailure implements Exception {
  const PermissionFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AmanahPermissionException extends PermissionFailure {
  const AmanahPermissionException(super.message, {super.code});
}

final class PermissionServerFailure extends AmanahPermissionException {
  const PermissionServerFailure([
    super.message = 'Terjadi kendala pada server perizinan. Silakan coba beberapa saat lagi.',
    String? code,
  ]) : super(code: code);
}

final class PermissionNetworkFailure extends AmanahPermissionException {
  const PermissionNetworkFailure([
    super.message = 'Koneksi internet bermasalah. Periksa jaringan Anda.',
  ]) : super(code: 'NETWORK_ERROR');
}

final class PermissionNotFoundFailure extends AmanahPermissionException {
  const PermissionNotFoundFailure([
    super.message = 'Data permohonan izin tidak ditemukan.',
  ]) : super(code: 'NOT_FOUND');
}

final class PermissionUnauthorizedFailure extends AmanahPermissionException {
  const PermissionUnauthorizedFailure([
    super.message = 'Sesi Anda telah kedaluwarsa atau Anda tidak memiliki akses.',
  ]) : super(code: 'UNAUTHORIZED');
}

final class PermissionValidationFailure extends AmanahPermissionException {
  const PermissionValidationFailure(
    super.message, {
    super.code = 'VALIDATION_ERROR',
  });
}
