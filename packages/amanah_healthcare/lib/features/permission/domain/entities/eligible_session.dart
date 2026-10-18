class EligibleSession {
  const EligibleSession({
    required this.sessionId,
    required this.sessionCode,
    required this.sessionLabel,
    required this.startsAt,
    required this.endsAt,
    required this.workDate,
  });

  final String sessionId;
  final String sessionCode;
  final String sessionLabel;
  final String startsAt;
  final String endsAt;
  final String workDate;
}
