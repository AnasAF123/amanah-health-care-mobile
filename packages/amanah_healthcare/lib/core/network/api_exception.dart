sealed class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

final class NetworkException extends ApiException {
  const NetworkException([
    super.message =
        'Koneksi internet bermasalah. Pastikan perangkat Anda terhubung ke jaringan.',
  ]) : super(code: 'NETWORK_ERROR');
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Sesi Anda telah kedaluwarsa. Silakan masuk kembali.',
    String? code,
  ]) : super(code: code, statusCode: 401);
}

final class ForbiddenException extends ApiException {
  const ForbiddenException(
    super.message, {
    super.code,
  }) : super(statusCode: 403);
}

final class NotFoundException extends ApiException {
  const NotFoundException(
    super.message, {
    super.code,
  }) : super(statusCode: 404);
}

final class ServerException extends ApiException {
  const ServerException([
    super.message = 'Terjadi kesalahan pada server.',
    String? code,
    int? statusCode,
  ]) : super(code: code, statusCode: statusCode);
}
