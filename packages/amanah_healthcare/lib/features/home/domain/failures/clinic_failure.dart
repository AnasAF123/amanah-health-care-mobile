sealed class ClinicFailure implements Exception {
  const ClinicFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AmanahClinicException extends ClinicFailure {
  const AmanahClinicException(super.message, {super.code});
}

final class ClinicServerFailure extends AmanahClinicException {
  const ClinicServerFailure([
    super.message = 'Terjadi kendala pada server katalog layanan.',
    String? code,
  ]) : super(code: code);
}

final class ClinicNetworkFailure extends AmanahClinicException {
  const ClinicNetworkFailure([
    super.message = 'Koneksi internet bermasalah. Periksa jaringan Anda.',
  ]) : super(code: 'NETWORK_ERROR');
}

final class ClinicNotFoundFailure extends AmanahClinicException {
  const ClinicNotFoundFailure([
    super.message = 'Data layanan klinik tidak ditemukan.',
  ]) : super(code: 'NOT_FOUND');
}
