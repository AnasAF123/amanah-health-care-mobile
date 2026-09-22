enum CredentialType {
  sip,
  str,
  kki,
  npwp,
  nib,
  nationalId,
  other;

  String toApiValue() {
    switch (this) {
      case CredentialType.nationalId:
        return 'national_id';
      default:
        return name.toLowerCase();
    }
  }

  static CredentialType fromApiValue(String? val) {
    if (val == null) return CredentialType.other;
    switch (val.toLowerCase().trim()) {
      case 'sip':
        return CredentialType.sip;
      case 'str':
        return CredentialType.str;
      case 'kki':
        return CredentialType.kki;
      case 'npwp':
        return CredentialType.npwp;
      case 'nib':
        return CredentialType.nib;
      case 'national_id':
      case 'nationalid':
      case 'nik':
        return CredentialType.nationalId;
      default:
        return CredentialType.other;
    }
  }

  String get label {
    switch (this) {
      case CredentialType.sip:
        return 'SIP (Surat Izin Praktik)';
      case CredentialType.str:
        return 'STR (Surat Tanda Registrasi)';
      case CredentialType.kki:
        return 'Nomor KKI';
      case CredentialType.npwp:
        return 'NPWP';
      case CredentialType.nib:
        return 'Nomor NIB';
      case CredentialType.nationalId:
        return 'NIK';
      case CredentialType.other:
        return 'Kredensial Lainnya';
    }
  }

  String get shortLabel {
    switch (this) {
      case CredentialType.sip:
        return 'SIP';
      case CredentialType.str:
        return 'STR';
      case CredentialType.kki:
        return 'KKI';
      case CredentialType.npwp:
        return 'NPWP';
      case CredentialType.nib:
        return 'NIB';
      case CredentialType.nationalId:
        return 'NIK';
      case CredentialType.other:
        return 'LAIN';
    }
  }
}

class StaffCredentialModel {
  const StaffCredentialModel({
    required this.id,
    required this.staffProfileId,
    required this.credentialType,
    required this.credentialNumber,
    this.issuer,
    this.issuedAt,
    this.expiresAt,
    required this.status,
  });

  factory StaffCredentialModel.fromJson(Map<String, dynamic> json) {
    return StaffCredentialModel(
      id: json['id'] as String? ?? '',
      staffProfileId: json['staffProfileId'] as String? ?? '',
      credentialType: CredentialType.fromApiValue(
        json['credentialType'] as String? ?? 'other',
      ),
      credentialNumber: json['credentialNumber'] as String? ?? '',
      issuer: json['issuer'] as String?,
      issuedAt: json['issuedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      status: (json['status'] as String? ?? 'unverified').toLowerCase(),
    );
  }

  final String id;
  final String staffProfileId;
  final CredentialType credentialType;
  final String credentialNumber;
  final String? issuer;
  final String? issuedAt;
  final String? expiresAt;
  final String status;

  bool get isVerified => status.toLowerCase() == 'verified';

  String get statusDisplayLabel {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Terverifikasi';
      case 'expired':
        return 'Kedaluwarsa';
      case 'revoked':
        return 'Dicabut';
      default:
        return 'Menunggu Verifikasi';
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'staffProfileId': staffProfileId,
      'credentialType': credentialType.toApiValue(),
      'credentialNumber': credentialNumber,
      if (issuer != null) 'issuer': issuer,
      if (issuedAt != null) 'issuedAt': issuedAt,
      if (expiresAt != null) 'expiresAt': expiresAt,
      'status': status.toLowerCase(),
    };
  }

  StaffCredentialModel copyWith({
    String? id,
    String? staffProfileId,
    CredentialType? credentialType,
    String? credentialNumber,
    String? issuer,
    String? issuedAt,
    String? expiresAt,
    String? status,
  }) {
    return StaffCredentialModel(
      id: id ?? this.id,
      staffProfileId: staffProfileId ?? this.staffProfileId,
      credentialType: credentialType ?? this.credentialType,
      credentialNumber: credentialNumber ?? this.credentialNumber,
      issuer: issuer ?? this.issuer,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StaffCredentialModel &&
        other.id == id &&
        other.staffProfileId == staffProfileId &&
        other.credentialType == credentialType &&
        other.credentialNumber == credentialNumber &&
        other.issuer == issuer &&
        other.issuedAt == issuedAt &&
        other.expiresAt == expiresAt &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
    id,
    staffProfileId,
    credentialType,
    credentialNumber,
    issuer,
    issuedAt,
    expiresAt,
    status,
  );
}
