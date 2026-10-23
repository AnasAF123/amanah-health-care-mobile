import 'package:amanah_healthcare/features/authentication/domain/user_avatar.dart';
export 'package:amanah_healthcare/features/authentication/domain/user_avatar.dart';
export 'package:amanah_healthcare/features/authentication/domain/staff_credential_model.dart';

enum AmanahUserRole { doctor, midwife, staff }

class AmanahStaffAddress {
  const AmanahStaffAddress({
    this.provinceCode,
    this.provinceName,
    this.regencyCode,
    this.regencyName,
    this.districtCode,
    this.districtName,
    this.villageCode,
    this.villageName,
    this.line1,
    this.fullAddress,
  });

  static String? _normalize(dynamic val) {
    if (val == null) return null;
    final String s = val.toString().trim();
    if (s.isEmpty || s == '-') return null;
    return s;
  }

  factory AmanahStaffAddress.fromJson(Map<String, dynamic> json) {
    return AmanahStaffAddress(
      provinceCode: _normalize(
        json['provinceCode'] ?? json['province_code'] ?? json['provinsiId'] ?? json['provinsi_id'],
      ),
      provinceName: _normalize(json['provinceName'] ?? json['province_name'] ?? json['provinsi']),
      regencyCode: _normalize(
        json['regencyCode'] ?? json['regency_code'] ?? json['kabupatenId'] ?? json['kabupaten_id'],
      ),
      regencyName: _normalize(json['regencyName'] ?? json['regency_name'] ?? json['kabupaten']),
      districtCode: _normalize(
        json['districtCode'] ??
            json['district_code'] ??
            json['kecamatanId'] ??
            json['kecamatan_id'],
      ),
      districtName: _normalize(json['districtName'] ?? json['district_name'] ?? json['kecamatan']),
      villageCode: _normalize(
        json['villageCode'] ?? json['village_code'] ?? json['kelurahanId'] ?? json['kelurahan_id'],
      ),
      villageName: _normalize(json['villageName'] ?? json['village_name'] ?? json['kelurahan']),
      line1: _normalize(json['line1'] ?? json['alamatDetail'] ?? json['alamat_detail']),
      fullAddress: _normalize(
        json['fullAddress'] ??
            json['full_address'] ??
            (json['address'] is String ? json['address'] : null),
      ),
    );
  }

  final String? provinceCode;
  final String? provinceName;
  final String? regencyCode;
  final String? regencyName;
  final String? districtCode;
  final String? districtName;
  final String? villageCode;
  final String? villageName;
  final String? line1;
  final String? fullAddress;

  String get displayAddress {
    if (fullAddress != null && fullAddress!.trim().isNotEmpty) {
      return fullAddress!.trim();
    }
    final List<String> parts = <String?>[
      line1,
      villageName != null ? 'Kel. $villageName' : null,
      districtName != null ? 'Kec. $districtName' : null,
      regencyName,
      provinceName,
    ].where((String? s) => s != null && s.trim().isNotEmpty).map((String? s) => s!.trim()).toList();
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (provinceCode != null) 'provinceCode': provinceCode,
      if (provinceName != null) 'provinceName': provinceName,
      if (regencyCode != null) 'regencyCode': regencyCode,
      if (regencyName != null) 'regencyName': regencyName,
      if (districtCode != null) 'districtCode': districtCode,
      if (districtName != null) 'districtName': districtName,
      if (villageCode != null) 'villageCode': villageCode,
      if (villageName != null) 'villageName': villageName,
      if (line1 != null) 'line1': line1,
      if (fullAddress != null) 'fullAddress': fullAddress,
    };
  }
}

class AmanahStaffProfile {
  const AmanahStaffProfile({
    required this.id,
    required this.userId,
    this.practitionerId,
    this.poliklinikId,
    this.poliklinikName,
    this.fullName,
    this.profession,
    this.staffCode,
    this.nationalId,
    this.idCardNumber,
    this.licenseNumber,
    this.birthPlace,
    this.birthDate,
    this.gender,
    this.photoUrl,
    this.avatarUrl,
    this.phoneNumber,
    this.addressModel,
    String? address,
    this.isActive = true,
  }) : _rawAddress = address;

  factory AmanahStaffProfile.fromJson(Map<String, dynamic> json) {
    AmanahStaffAddress? parsedAddress;
    String? rawAddr;

    if (json['address'] is Map) {
      parsedAddress = AmanahStaffAddress.fromJson(json['address'] as Map<String, dynamic>);
      rawAddr = parsedAddress.displayAddress;
    } else {
      if (json.containsKey('provinsi') ||
          json.containsKey('provinsiId') ||
          json.containsKey('provinceCode') ||
          json.containsKey('provinceName') ||
          json.containsKey('line1') ||
          json.containsKey('alamatDetail')) {
        parsedAddress = AmanahStaffAddress.fromJson(json);
        rawAddr = parsedAddress.displayAddress;
      } else if (json['address'] is String) {
        rawAddr = json['address'] as String?;
        parsedAddress = AmanahStaffAddress(fullAddress: rawAddr);
      }
    }

    return AmanahStaffProfile(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      practitionerId: json['practitionerId'] as String?,
      poliklinikId: json['poliklinikId'] as String?,
      poliklinikName: json['poliklinikName'] as String? ?? json['poliklinik_name'] as String?,
      fullName: json['fullName'] as String?,
      profession: json['profession'] as String?,
      staffCode: json['staffCode'] as String? ?? json['staff_code'] as String?,
      nationalId: json['nationalId'] as String? ?? json['nik'] as String?,
      idCardNumber: json['idCardNumber'] as String?,
      licenseNumber:
          json['licenseNumber'] as String? ??
          json['sipNumber'] as String? ??
          json['sip'] as String?,
      birthPlace: AmanahStaffAddress._normalize(json['birthPlace']),
      birthDate: AmanahStaffAddress._normalize(json['birthDate']),
      gender: AmanahStaffAddress._normalize(json['gender']),
      photoUrl: json['photoUrl'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      addressModel: parsedAddress,
      address: rawAddr,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final String userId;
  final String? practitionerId;
  final String? poliklinikId;
  final String? poliklinikName;
  final String? fullName;
  final String? profession;
  final String? staffCode;
  final String? nationalId;
  final String? idCardNumber;
  final String? licenseNumber;
  final String? birthPlace;
  final String? birthDate;
  final String? gender;
  final String? photoUrl;
  final String? avatarUrl;
  final String? phoneNumber;
  final AmanahStaffAddress? addressModel;
  final String? _rawAddress;
  final bool isActive;

  String? get address => addressModel?.displayAddress ?? _rawAddress;
}

class AmanahAuthUser {
  const AmanahAuthUser({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatar = UserAvatar.empty,
    this.password = '',
    this.isEmailVerified = false,
    this.needsOnboarding = false,
    this.systemRole = '',
    this.staff,
  });

  factory AmanahAuthUser.fromJson(Map<String, dynamic> json) {
    final String roleStr = json['role'] is Map
        ? (json['role']['code'] as String? ?? '')
        : (json['role'] as String? ?? '');

    final String id = json['id'] as String? ?? '';
    final String fullName = json['fullName'] as String? ?? json['name'] as String? ?? '';
    final String? avatarUrl = json['avatarUrl'] as String? ?? json['avatar_url'] as String?;

    final UserAvatar resolvedAvatar = json['avatar'] != null
        ? UserAvatar.fromJson(json['avatar'] as Map<String, dynamic>)
        : (avatarUrl != null && avatarUrl.isNotEmpty
              ? UserAvatar(
                  url: avatarUrl,
                  initials: UserAvatar.extractInitials(fullName),
                  type: avatarUrl.startsWith('http') ? 'oauth' : 'custom',
                  hasCustomAvatar: true,
                  directUrl: avatarUrl,
                )
              : UserAvatar.fromFallback(userId: id, name: fullName));

    return AmanahAuthUser(
      id: id,
      role: parseRole(roleStr),
      fullName: fullName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String? ?? '',
      avatar: resolvedAvatar,
      password: json['password'] as String? ?? '',
      isEmailVerified: json['isEmailVerified'] as bool? ?? json['emailVerified'] as bool? ?? false,
      needsOnboarding: json['needsOnboarding'] as bool? ?? false,
      systemRole: json['systemRole'] as String? ?? roleStr,
      staff: json['staff'] != null
          ? AmanahStaffProfile.fromJson(json['staff'] as Map<String, dynamic>)
          : null,
    );
  }

  @Deprecated('Use AuthUserMapper.fromJson in data/mappers instead')
  factory AmanahAuthUser.fromBetterAuthJson(Map<String, dynamic> json) =>
      AmanahAuthUser.fromJson(json);

  final String id;
  final AmanahUserRole role;
  final String fullName;
  final String email;
  final String phone;
  final UserAvatar avatar;
  final String password;
  final bool isEmailVerified;
  final bool needsOnboarding;
  final String systemRole;
  final AmanahStaffProfile? staff;

  String? get avatarUrl =>
      staff?.avatarUrl ?? (avatar.displayUrl.isNotEmpty ? avatar.displayUrl : null);

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
    final String normalized = (roleStr ?? '').toLowerCase().replaceAll('_', '').replaceAll(' ', '');
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
      avatar: avatar ?? this.avatar,
      password: password ?? this.password,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
      systemRole: systemRole ?? this.systemRole,
      staff: staff ?? this.staff,
    );
  }
}
