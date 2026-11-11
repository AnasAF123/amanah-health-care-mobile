import 'package:amanah_healthcare/features/home/domain/entities/clinic_service_item.dart';

class ClinicCategoryItem {
  const ClinicCategoryItem({
    required this.id,
    required this.code,
    required this.name,
    required this.iconName,
    required this.displayOrder,
    required this.services,
    this.description,
    this.poliklinikId,
    this.poliklinikName,
  });

  final String id;
  final String code;
  final String name;
  final String iconName;
  final String? description;
  final int displayOrder;
  final String? poliklinikId;
  final String? poliklinikName;
  final List<ClinicServiceItem> services;
}
