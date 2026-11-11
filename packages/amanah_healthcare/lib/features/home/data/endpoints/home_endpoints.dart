import 'package:amanah_healthcare/core/constants/api_prefix.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';

abstract final class HomeEndpoints {
  static const String pathServiceCatalog = '${ApiPrefix.v1}/clinics/services/catalog';

  static const ApiEndpoint serviceCatalogEndpoint = ApiEndpoint(
    path: pathServiceCatalog,
    method: HttpMethod.get,
    requiresAuth: false,
  );
}
