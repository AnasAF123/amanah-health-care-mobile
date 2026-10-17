/// Represents failure outcomes when retrieving clinical intake records.
class IntakeFailure implements Exception {
  const IntakeFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'IntakeFailure: $message (code: $code)';
}

/// Specialized failure when no intake submission is found for the appointment (HTTP 404).
class IntakeNotFoundFailure extends IntakeFailure {
  const IntakeNotFoundFailure([
    super.message = 'Formulir belum tersedia untuk kunjungan ini',
    String? code = 'INTAKE_NOT_FOUND',
  ]) : super(code: code);
}

