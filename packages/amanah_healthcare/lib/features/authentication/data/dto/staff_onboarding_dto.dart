class StaffOnboardingDto {
  const StaffOnboardingDto({
    required this.fullName,
    this.phoneNumber,
    this.staffCode,
    this.profession,
    this.poliklinikId,
    this.licenseNumber,
    this.birthPlace,
    this.birthDate,
    this.gender,
    this.nationalId,
    this.provinsi,
    this.provinsiId,
    this.kabupaten,
    this.kabupatenId,
    this.kecamatan,
    this.kecamatanId,
    this.kelurahan,
    this.kelurahanId,
    this.alamatDetail,
  });

  final String fullName;
  final String? phoneNumber;
  final String? staffCode;
  final String? profession;
  final String? poliklinikId;
  final String? licenseNumber;
  final String? birthPlace;
  final String? birthDate;
  final String? gender;
  final String? nationalId;
  final String? provinsi;
  final String? provinsiId;
  final String? kabupaten;
  final String? kabupatenId;
  final String? kecamatan;
  final String? kecamatanId;
  final String? kelurahan;
  final String? kelurahanId;
  final String? alamatDetail;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName.trim(),
      if (phoneNumber != null && phoneNumber!.trim().isNotEmpty)
        'phoneNumber': phoneNumber!.trim(),
      if (staffCode != null && staffCode!.trim().isNotEmpty)
        'staffCode': staffCode!.trim(),
      if (profession != null && profession!.trim().isNotEmpty)
        'profession': profession!.trim(),
      if (poliklinikId != null && poliklinikId!.trim().isNotEmpty)
        'poliklinikId': poliklinikId!.trim(),
      if (licenseNumber != null && licenseNumber!.trim().isNotEmpty)
        'licenseNumber': licenseNumber!.trim(),
      if (birthPlace != null && birthPlace!.trim().isNotEmpty)
        'birthPlace': birthPlace!.trim(),
      if (birthDate != null && birthDate!.trim().isNotEmpty)
        'birthDate': birthDate!.trim(),
      if (gender != null && gender!.trim().isNotEmpty)
        'gender': gender!.trim().toLowerCase(),
      if (nationalId != null && nationalId!.trim().isNotEmpty)
        'nationalId': nationalId!.trim(),
      if (provinsi != null && provinsi!.trim().isNotEmpty)
        'provinsi': provinsi!.trim(),
      if (provinsiId != null && provinsiId!.trim().isNotEmpty) ...<String, dynamic>{
        'provinsi_id': provinsiId!.trim(),
        'provinsiId': provinsiId!.trim(),
      },
      if (kabupaten != null && kabupaten!.trim().isNotEmpty)
        'kabupaten': kabupaten!.trim(),
      if (kabupatenId != null && kabupatenId!.trim().isNotEmpty) ...<String, dynamic>{
        'kabupaten_id': kabupatenId!.trim(),
        'kabupatenId': kabupatenId!.trim(),
      },
      if (kecamatan != null && kecamatan!.trim().isNotEmpty)
        'kecamatan': kecamatan!.trim(),
      if (kecamatanId != null && kecamatanId!.trim().isNotEmpty) ...<String, dynamic>{
        'kecamatan_id': kecamatanId!.trim(),
        'kecamatanId': kecamatanId!.trim(),
      },
      if (kelurahan != null && kelurahan!.trim().isNotEmpty)
        'kelurahan': kelurahan!.trim(),
      if (kelurahanId != null && kelurahanId!.trim().isNotEmpty) ...<String, dynamic>{
        'kelurahan_id': kelurahanId!.trim(),
        'kelurahanId': kelurahanId!.trim(),
      },
      if (alamatDetail != null && alamatDetail!.trim().isNotEmpty) ...<String, dynamic>{
        'alamat_detail': alamatDetail!.trim(),
        'alamatDetail': alamatDetail!.trim(),
        'line1': alamatDetail!.trim(),
      },
    };
  }
}
