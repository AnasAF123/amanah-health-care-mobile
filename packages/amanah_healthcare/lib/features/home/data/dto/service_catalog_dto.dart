import 'package:amanah_healthcare/features/home/domain/entities/clinic_category_item.dart';
import 'package:amanah_healthcare/features/home/domain/entities/clinic_service_item.dart';

class ServiceCatalogItemDto {
  const ServiceCatalogItemDto({
    required this.id,
    required this.code,
    required this.name,
    required this.prefix,
    required this.iconName,
    required this.displayOrder,
    required this.categoryId,
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

  factory ServiceCatalogItemDto.fromJson(Map<String, dynamic> json) {
    return ServiceCatalogItemDto(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      prefix: json['prefix']?.toString() ?? '',
      description: json['description']?.toString(),
      iconName: json['iconName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      specialtyCode: json['specialtyCode']?.toString(),
      intakeFormId: json['intakeFormId']?.toString(),
      intakeFormCode: json['intakeFormCode']?.toString(),
      intakeFormName: json['intakeFormName']?.toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      categoryId: json['categoryId']?.toString() ?? '',
      poliklinikId: json['poliklinikId']?.toString(),
      poliklinikName: json['poliklinikName']?.toString(),
      complaints: (json['complaints'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      isBookable: json['isBookable'] == true,
    );
  }

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
  final String? poliklinikId;
  final String? poliklinikName;
  final List<String> complaints;
  final bool isBookable;

  ClinicServiceItem toDomain(String categoryName) {
    return ClinicServiceItem(
      id: id,
      code: code,
      name: name,
      prefix: prefix,
      description: description,
      iconName: iconName,
      imageUrl: imageUrl,
      specialtyCode: specialtyCode,
      intakeFormId: intakeFormId,
      intakeFormCode: intakeFormCode,
      intakeFormName: intakeFormName,
      displayOrder: displayOrder,
      categoryId: categoryId,
      categoryName: categoryName,
      poliklinikId: poliklinikId,
      poliklinikName: poliklinikName,
      complaints: complaints,
      isBookable: isBookable,
    );
  }
}

class ServiceCategoryDto {
  const ServiceCategoryDto({
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

  factory ServiceCategoryDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawServices = json['services'] as List<dynamic>? ?? const <dynamic>[];
    return ServiceCategoryDto(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? '',
      description: json['description']?.toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      poliklinikId: json['poliklinikId']?.toString(),
      poliklinikName: json['poliklinikName']?.toString(),
      services: rawServices
          .whereType<Map<String, dynamic>>()
          .map(ServiceCatalogItemDto.fromJson)
          .toList(),
    );
  }

  final String id;
  final String code;
  final String name;
  final String iconName;
  final String? description;
  final int displayOrder;
  final String? poliklinikId;
  final String? poliklinikName;
  final List<ServiceCatalogItemDto> services;

  ClinicCategoryItem toDomain() {
    return ClinicCategoryItem(
      id: id,
      code: code,
      name: name,
      iconName: iconName,
      description: description,
      displayOrder: displayOrder,
      poliklinikId: poliklinikId,
      poliklinikName: poliklinikName,
      services: services.map((ServiceCatalogItemDto s) => s.toDomain(name)).toList(),
    );
  }
}

class ServiceCatalogResponseDto {
  const ServiceCatalogResponseDto({
    required this.success,
    required this.categories,
  });

  factory ServiceCatalogResponseDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawCategories =
        json['categories'] as List<dynamic>? ?? const <dynamic>[];
    return ServiceCatalogResponseDto(
      success: json['success'] == true,
      categories: rawCategories
          .whereType<Map<String, dynamic>>()
          .map(ServiceCategoryDto.fromJson)
          .toList(),
    );
  }

  final bool success;
  final List<ServiceCategoryDto> categories;
}
