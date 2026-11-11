import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/features/home/data/dto/service_catalog_dto.dart';
import 'package:amanah_healthcare/features/home/data/endpoints/home_endpoints.dart';

abstract interface class HomeRemoteDataSource {
  Future<ServiceCatalogResponseDto> getServiceCatalog();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ??
            HttpApiClient(
              baseUrl: AmanahAuthEnvironment.authBaseUrl,
            );

  final ApiClient _apiClient;

  @override
  Future<ServiceCatalogResponseDto> getServiceCatalog() async {
    final ApiResponse<dynamic> res = await _apiClient.request(
      HomeEndpoints.serviceCatalogEndpoint,
    );
    final dynamic data = res.data;
    if (data is Map<String, dynamic>) {
      return ServiceCatalogResponseDto.fromJson(data);
    }
    return const ServiceCatalogResponseDto(
      success: false,
      categories: <ServiceCategoryDto>[],
    );
  }
}
