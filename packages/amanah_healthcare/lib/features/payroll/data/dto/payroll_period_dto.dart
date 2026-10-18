class PayrollPeriodDto {
  const PayrollPeriodDto({
    required this.id,
    required this.periodName,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.totalPayout,
    this.notes,
  });

  final String id;
  final String periodName;
  final String periodStart;
  final String periodEnd;
  final String status;
  final double totalPayout;
  final String? notes;

  factory PayrollPeriodDto.fromJson(Map<String, dynamic> json) {
    return PayrollPeriodDto(
      id: json['id']?.toString() ?? '',
      periodName: json['periodName']?.toString() ?? '',
      periodStart: json['periodStart']?.toString() ?? '',
      periodEnd: json['periodEnd']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalPayout: (json['totalPayout'] is num)
          ? (json['totalPayout'] as num).toDouble()
          : double.tryParse(json['totalPayout']?.toString() ?? '0') ?? 0.0,
      notes: json['notes']?.toString(),
    );
  }
}
