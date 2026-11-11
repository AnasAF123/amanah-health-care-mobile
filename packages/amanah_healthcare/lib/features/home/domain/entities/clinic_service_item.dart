class ClinicServiceItem {
  const ClinicServiceItem({
    required this.id,
    required this.code,
    required this.name,
    required this.prefix,
    required this.iconName,
    required this.displayOrder,
    required this.categoryId,
    required this.categoryName,
    required this.isBookable,
    this.description,
    this.imageUrl,
    this.specialtyCode,
    this.intakeFormId,
    this.intakeFormCode,
    this.intakeFormName,
    this.poliklinikId,
    this.poliklinikName,
    this.complaints = const <String>[],
  });

  final String id;
  final String code;
  final String name;
  final String prefix;
  final String? description;
  final String iconName;
  final String? imageUrl;
  final String? specialtyCode;
  final String? intakeFormId;
  final String? intakeFormCode;
  final String? intakeFormName;
  final int displayOrder;
  final String categoryId;
  final String categoryName;
  final String? poliklinikId;
  final String? poliklinikName;
  final List<String> complaints;
  final bool isBookable;
}
