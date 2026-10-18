sealed class PayrollFailure implements Exception {
  const PayrollFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AmanahPayrollException extends PayrollFailure {
  const AmanahPayrollException(super.message, {super.code});
}

final class PayrollServerFailure extends AmanahPayrollException {
  const PayrollServerFailure([
    super.message = 'Terjadi kendala pada server kalkulasi gaji. Silakan coba lagi.',
    String? code,
  ]) : super(code: code);
}

final class PayrollNetworkFailure extends AmanahPayrollException {
  const PayrollNetworkFailure([
    super.message = 'Koneksi internet bermasalah. Periksa jaringan Anda.',
  ]) : super(code: 'NETWORK_ERROR');
}

final class PayrollNotFoundFailure extends AmanahPayrollException {
  const PayrollNotFoundFailure([
    super.message = 'Data slip gaji periode ini belum tersedia.',
  ]) : super(code: 'NOT_FOUND');
}
