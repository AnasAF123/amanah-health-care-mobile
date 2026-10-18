class EligibleSessionDto {
  const EligibleSessionDto({
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

  factory EligibleSessionDto.fromJson(Map<String, dynamic> json) {
    return EligibleSessionDto(
      sessionId: json['sessionId']?.toString() ?? '',
      sessionCode: json['sessionCode']?.toString() ?? '',
      sessionLabel: json['sessionLabel']?.toString() ?? '',
      startsAt: json['startsAt']?.toString() ?? '',
      endsAt: json['endsAt']?.toString() ?? '',
      workDate: json['workDate']?.toString() ?? '',
    );
  }
}
