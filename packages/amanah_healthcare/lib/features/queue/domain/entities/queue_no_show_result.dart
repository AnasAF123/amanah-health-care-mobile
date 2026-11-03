/// Entity representing the response from reporting an unresponding patient.
class QueueNoShowResult {
  const QueueNoShowResult({
    this.requeued = false,
    this.noShow = false,
    this.attemptNumber = 1,
    this.remainingAttempts = 0,
    this.status = '',
  });

  factory QueueNoShowResult.fromJson(Map<String, dynamic> json) {
    return QueueNoShowResult(
      requeued: json['requeued'] as bool? ?? false,
      noShow: json['noShow'] as bool? ?? false,
      attemptNumber: json['attemptNumber'] as int? ?? 1,
      remainingAttempts: json['remainingAttempts'] as int? ?? 0,
      status: json['status'] as String? ?? '',
    );
  }

  final bool requeued;
  final bool noShow;
  final int attemptNumber;
  final int remainingAttempts;
  final String status;
}
