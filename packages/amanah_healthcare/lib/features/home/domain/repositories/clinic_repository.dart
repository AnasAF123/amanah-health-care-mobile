import 'package:amanah_healthcare/features/home/domain/entities/clinic_category_item.dart';
import 'package:amanah_healthcare/features/home/domain/entities/clinic_service_item.dart';

abstract interface class ClinicRepository {
  Future<List<ClinicCategoryItem>> getServiceCatalog();
  Future<List<ClinicServiceItem>> getActiveServices();
}
