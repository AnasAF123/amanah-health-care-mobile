import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/features/home/data/datasources/home_remote_data_source.dart';
import 'package:amanah_healthcare/features/home/data/dto/service_catalog_dto.dart';
import 'package:amanah_healthcare/features/home/domain/entities/clinic_category_item.dart';
import 'package:amanah_healthcare/features/home/domain/entities/clinic_service_item.dart';
import 'package:amanah_healthcare/features/home/domain/failures/clinic_failure.dart';
import 'package:amanah_healthcare/features/home/domain/repositories/clinic_repository.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  ClinicRepositoryImpl({
    HomeRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? HomeRemoteDataSourceImpl();

  final HomeRemoteDataSource _remoteDataSource;

  Never _handleError(Object error) {
    if (error is NetworkException) {
      throw ClinicNetworkFailure(error.message);
    }
    if (error is NotFoundException) {
      throw ClinicNotFoundFailure(error.message);
    }
    if (error is ServerException) {
      throw ClinicServerFailure(error.message, error.code);
    }
    if (error is AmanahClinicException) {
      throw error;
    }
    throw ClinicServerFailure(error.toString());
  }

  @override
  Future<List<ClinicCategoryItem>> getServiceCatalog() async {
    try {
      final ServiceCatalogResponseDto dto =
          await _remoteDataSource.getServiceCatalog();
      return dto.categories.map((ServiceCategoryDto c) => c.toDomain()).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<ClinicServiceItem>> getActiveServices() async {
    try {
      final ServiceCatalogResponseDto dto =
          await _remoteDataSource.getServiceCatalog();
      final List<ClinicServiceItem> allServices = <ClinicServiceItem>[];
      for (final ServiceCategoryDto cat in dto.categories) {
        for (final ServiceCatalogItemDto s in cat.services) {
          allServices.add(s.toDomain(cat.name));
        }
      }
      return allServices;
    } catch (e) {
      _handleError(e);
    }
  }
}
