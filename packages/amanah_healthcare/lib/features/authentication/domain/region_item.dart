class RegionItem {
  const RegionItem({
    required this.id,
    required this.name,
    this.label,
    this.value,
    this.provinceId,
    this.regencyId,
    this.districtId,
  });

  factory RegionItem.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String? ?? '';
    final String name =
        json['name'] as String? ?? json['nama'] as String? ?? '';
    final String? label =
        json['label'] as String? ?? (name.isNotEmpty ? name : null);
    final String? value =
        json['value'] as String? ?? (id.isNotEmpty ? id : null);
    return RegionItem(
      id: id,
      name: name,
      label: label,
      value: value,
      provinceId:
          json['provinceId'] as String? ?? json['province_id'] as String?,
      regencyId: json['regencyId'] as String? ?? json['regency_id'] as String?,
      districtId:
          json['districtId'] as String? ?? json['district_id'] as String?,
    );
  }

  final String id;
  final String name;
  final String? label;
  final String? value;
  final String? provinceId;
  final String? regencyId;
  final String? districtId;

  String get displayName => label ?? name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => displayName;
}
