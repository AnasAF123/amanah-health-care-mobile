enum AmanahUserRole { doctor, staff }

class AmanahAuthUser {
  const AmanahAuthUser({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  factory AmanahAuthUser.fromJson(Map<String, dynamic> json) {
    return AmanahAuthUser(
      id: json['id'] as String,
      role: switch (json['role'] as String) {
        'doctor' => AmanahUserRole.doctor,
        'staff' => AmanahUserRole.staff,
        _ => AmanahUserRole.staff,
      },
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
    );
  }

  final String id;
  final AmanahUserRole role;
  final String fullName;
  final String email;
  final String phone;
  final String password;

  String get roleLabel => switch (role) {
    AmanahUserRole.doctor => 'Dokter',
    AmanahUserRole.staff => 'Staff',
  };
}
