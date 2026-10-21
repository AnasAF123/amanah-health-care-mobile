export 'package:amanah_healthcare/features/authentication/domain/failures/auth_failure.dart';

class StaffOnboardingPoliOption {
  const StaffOnboardingPoliOption({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory StaffOnboardingPoliOption.fromJson(Map<String, dynamic> json) {
    return StaffOnboardingPoliOption(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? json['kodePoli'] as String? ?? '',
      name: json['name'] as String? ?? json['namaPoli'] as String? ?? '',
      description: json['description'] as String? ?? json['deskripsi'] as String?,
    );
  }

  final String id;
  final String code;
  final String name;
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffOnboardingPoliOption &&
          runtimeType == other.runtimeType &&
          (id.isNotEmpty ? id == other.id : code == other.code);

  @override
  int get hashCode => (id.isNotEmpty ? id : code).hashCode;
}
