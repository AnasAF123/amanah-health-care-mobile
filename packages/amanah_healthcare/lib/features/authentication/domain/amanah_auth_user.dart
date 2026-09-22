import 'package:amanah_healthcare/features/authentication/domain/user_avatar.dart';
export 'package:amanah_healthcare/features/authentication/domain/user_avatar.dart';
export 'package:amanah_healthcare/features/authentication/domain/staff_credential_model.dart';

enum AmanahUserRole { doctor, midwife, staff }

class AmanahStaffProfile {
  const AmanahStaffProfile({
    required this.id,
    required this.userId,
    this.practitionerId,
    this.poliklinikId,
    this.fullName,
    this.profession,
    this.idCardNumber,
    this.photoUrl,
    this.phoneNumber,
    this.isActive = true,
  });

  factory AmanahStaffProfile.fromJson(Map<String, dynamic> json) {
    return AmanahStaffProfile(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      practitionerId: json['practitionerId'] as String?,
      poliklinikId: json['poliklinikId'] as String?,
      fullName: json['fullName'] as String?,
      profession: json['profession'] as String?,
      idCardNumber: json['idCardNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final String userId;
  final String? practitionerId;
  final String? poliklinikId;
  final String? fullName;
  final String? profession;
  final String? idCardNumber;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isActive;
}

class AmanahAuthUser {
  const AmanahAuthUser({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatar = UserAvatar.empty,
    this.imageUrl,
    this.password = '',
    this.isEmailVerified = false,
    this.needsOnboarding = false,
    this.systemRole = 'PATIENT',
    this.staff,
  });

  factory AmanahAuthUser.fromJson(Map<String, dynamic> json) {
    final String roleStr = json['role'] is Map
        ? (json['role']['code'] as String? ?? '')
        : (json['role'] as String? ?? '');

    final String id = json['id'] as String? ?? '';
    final String fullName =
        json['fullName'] as String? ?? json['name'] as String? ?? '';
    final String? imageUrl =
        json['imageUrl'] as String? ?? json['image'] as String?;

    final UserAvatar resolvedAvatar = json['avatar'] != null
        ? UserAvatar.fromJson(json['avatar'] as Map<String, dynamic>)
        : (imageUrl != null && imageUrl.isNotEmpty
            ? UserAvatar(
                url: imageUrl,
                initials: UserAvatar.extractInitials(fullName),
                type: imageUrl.startsWith('http') ? 'oauth' : 'custom',
                hasCustomAvatar: true,
                directUrl: imageUrl,
              )
            : UserAvatar.fromFallback(userId: id, name: fullName));

    return AmanahAuthUser(
      id: id,
      role: parseRole(roleStr),
      fullName: fullName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String? ?? '',
      imageUrl: imageUrl,
      avatar: resolvedAvatar,
      password: json['password'] as String? ?? '',
      isEmailVerified: json['isEmailVerified'] as bool? ??
          json['emailVerified'] as bool? ??
          false,
      needsOnboarding:
          json['needsOnboarding'] as bool? ?? isPatientRole(roleStr),
      systemRole: json['systemRole'] as String? ?? 'PATIENT',
      staff: json['staff'] != null
          ? AmanahStaffProfile.fromJson(json['staff'] as Map<String, dynamic>)
          : null,
    );
  }

  factory AmanahAuthUser.fromBetterAuthJson(Map<String, dynamic> json) {
    final String roleStr = json['role'] is Map
        ? (json['role']['code'] as String? ?? '')
        : (json['role'] as String? ?? '');
    final AmanahUserRole mappedRole = parseRole(roleStr);
    final bool needsOnboarding =
        json['needsOnboarding'] as bool? ?? isPatientRole(roleStr);
    final String systemRole =
        json['systemRole'] as String? ?? (json['role'] as String? ?? 'PATIENT');
    final Map<String, dynamic>? staffJson =
        json['staff'] as Map<String, dynamic>?;

    final String id = json['id'] as String? ?? '';
    final String fullName =
        json['name'] as String? ?? json['fullName'] as String? ?? '';
    final String? imageUrl =
        json['imageUrl'] as String? ?? json['image'] as String?;

    final UserAvatar resolvedAvatar = json['avatar'] != null
        ? UserAvatar.fromJson(json['avatar'] as Map<String, dynamic>)
        : (imageUrl != null && imageUrl.isNotEmpty
            ? UserAvatar(
                url: imageUrl,
                initials: UserAvatar.extractInitials(fullName),
                type: imageUrl.startsWith('http') ? 'oauth' : 'custom',
                hasCustomAvatar: true,
                directUrl: imageUrl,
              )
            : UserAvatar.fromFallback(userId: id, name: fullName));

    return AmanahAuthUser(
      id: id,
      role: mappedRole,
      fullName: fullName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String? ?? '',
      imageUrl: imageUrl,
      avatar: resolvedAvatar,
      password: '',
      isEmailVerified: json['emailVerified'] as bool? ??
          json['isEmailVerified'] as bool? ??
          false,
      needsOnboarding: needsOnboarding,
      systemRole: systemRole,
      staff: staffJson != null ? AmanahStaffProfile.fromJson(staffJson) : null,
    );
  }

  final String id;
  final AmanahUserRole role;
  final String fullName;
  final String email;
  final String phone;
  final String? imageUrl;
  final UserAvatar avatar;
  final String password;
  final bool isEmailVerified;
  final bool needsOnboarding;
  final String systemRole;
  final AmanahStaffProfile? staff;

  String get roleLabel => switch (role) {
    AmanahUserRole.doctor => 'Dokter',
    AmanahUserRole.midwife => 'Bidan',
    AmanahUserRole.staff => 'Staff',
  };

  bool get isDoctor => role == AmanahUserRole.doctor;
  bool get isMidwife => role == AmanahUserRole.midwife;
  bool get isStaff => role == AmanahUserRole.staff;

  String get displayRole => switch (role) {
    AmanahUserRole.doctor => 'Dokter Spesialis',
    AmanahUserRole.midwife => 'Bidan Pelaksana',
    AmanahUserRole.staff => 'Staf Medis / Pegawai',
  };

  static AmanahUserRole parseRole(String? roleStr) {
    final String normalized =
        (roleStr ?? '').toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    if (normalized == 'staffdoctor' || normalized == 'doctor') {
      return AmanahUserRole.doctor;
    }
    if (normalized == 'staffmidwife' || normalized == 'midwife') {
      return AmanahUserRole.midwife;
    }
    return AmanahUserRole.staff;
  }

  static bool isPatientRole(String? roleStr) {
    final String normalized = (roleStr ?? '').toLowerCase();
    return normalized == 'patient';
  }

  AmanahAuthUser copyWith({
    String? id,
    AmanahUserRole? role,
    String? fullName,
    String? email,
    String? phone,
    String? imageUrl,
    UserAvatar? avatar,
    String? password,
    bool? isEmailVerified,
    bool? needsOnboarding,
    String? systemRole,
    AmanahStaffProfile? staff,
  }) {
    return AmanahAuthUser(
      id: id ?? this.id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      avatar: avatar ?? this.avatar,
      password: password ?? this.password,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
      systemRole: systemRole ?? this.systemRole,
      staff: staff ?? this.staff,
    );
  }
}
