/// Represents failure outcomes in clinical queue operations.
class QueueFailure implements Exception {
  const QueueFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'QueueFailure: $message (code: $code)';
}
