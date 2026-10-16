sealed class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AmanahAuthException extends AuthFailure {
  const AmanahAuthException(super.message, {super.code});
}

class AmanahAuthPatientRestrictedException extends AmanahAuthException {
  const AmanahAuthPatientRestrictedException([
    super.message =
        'Akun Anda terdaftar sebagai pasien. Aplikasi ini khusus staf medis klinik.',
  ]) : super(code: 'PATIENT_RESTRICTED');
}

final class InvalidCredentialsFailure extends AmanahAuthException {
  const InvalidCredentialsFailure([
    super.message =
        'Kombinasi email atau kata sandi salah. Silakan periksa kembali.',
  ]) : super(code: 'INVALID_CREDENTIALS');
}

final class PatientRestrictedFailure
    extends AmanahAuthPatientRestrictedException {
  const PatientRestrictedFailure([super.message]);
}

final class AccountInactiveFailure extends AmanahAuthException {
  const AccountInactiveFailure([
    super.message =
        'Akun staf Anda telah dinonaktifkan oleh administrator klinik.',
  ]) : super(code: 'ACCOUNT_INACTIVE');
}

final class NotAuthorizedFailure extends AmanahAuthException {
  const NotAuthorizedFailure([
    super.message =
        'Akun ini tidak memiliki undangan aktif sebagai staf/dokter klinik.',
  ]) : super(code: 'NOT_AUTHORIZED');
}

final class ServerFailure extends AmanahAuthException {
  const ServerFailure([
    super.message =
        'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.',
    String? code,
  ]) : super(code: code);
}

final class NetworkFailure extends AmanahAuthException {
  const NetworkFailure([
    super.message =
        'Koneksi internet bermasalah. Pastikan perangkat Anda terhubung ke jaringan.',
  ]) : super(code: 'NETWORK_ERROR');
}
