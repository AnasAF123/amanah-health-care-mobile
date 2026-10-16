import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/network/client/amanah_http_client.dart';
import 'package:amanah_healthcare/core/network/client/observable_http_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/data/endpoints/auth_endpoints.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';

class RegionApiService {
  RegionApiService({
    String? baseUrl,
    http.Client? httpClient,
  })  : _customBaseUrl = baseUrl,
        _customClient = httpClient;

  final String? _customBaseUrl;
  final http.Client? _customClient;

  // In-memory cache for fast responsive navigation
  final Map<String, List<RegionItem>> _regencyCache = <String, List<RegionItem>>{};
  final Map<String, List<RegionItem>> _districtCache = <String, List<RegionItem>>{};
  final Map<String, List<RegionItem>> _villageCache = <String, List<RegionItem>>{};
  List<RegionItem>? _provinceCache;

  String get _baseUrl =>
      _customBaseUrl ?? AmanahAuthEnvironment.authBaseUrl;

  http.Client get _httpClient {
    final http.Client? custom = _customClient;
    if (custom != null) {
      return custom is ObservableHttpClient
          ? custom
          : ObservableHttpClient(innerClient: custom);
    }
    return AmanahHttpClient.instance;
  }

  /// Helper to decode standard backend response { success: true, data: [...] }
  List<RegionItem> _parseRegionList(http.Response response, String errorContext) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rawList = decoded is Map<String, dynamic> && decoded['data'] is List
          ? decoded['data'] as List<dynamic>
          : decoded is List
              ? decoded
              : const <dynamic>[];

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(RegionItem.fromJson)
          .where((RegionItem item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList();
    }

    // Zero-fallback: Fail fast so backend contract errors are transparently known
    throw AmanahAuthException(
      'Gagal memuat data $errorContext dari server (Status: ${response.statusCode}).',
    );
  }

  /// 1. Ambil daftar provinsi resmi Indonesia dari Kemendagri
  /// Endpoint: GET /api/v1/patients/reference/provinces
  Future<List<RegionItem>> getProvinces({bool forceRefresh = false}) async {
    if (!forceRefresh && _provinceCache != null && _provinceCache!.isNotEmpty) {
      return _provinceCache!;
    }

    final Uri uri =
        Uri.parse('$_baseUrl${AuthEndpoints.referenceProvinces}');
    final http.Response response = await _httpClient.get(
      uri,
      headers: const <String, String>{'Accept': 'application/json'},
    );

    final List<RegionItem> items = _parseRegionList(response, 'provinsi');
    _provinceCache = items;
    return items;
  }

  /// 2. Ambil daftar kabupaten/kota berdasarkan kode provinsi
  /// Endpoint: GET /api/v1/patients/reference/regencies?provinceId=:id
  Future<List<RegionItem>> getRegencies(String provinceId, {bool forceRefresh = false}) async {
    if (provinceId.isEmpty) return const <RegionItem>[];

    if (!forceRefresh && _regencyCache.containsKey(provinceId)) {
      return _regencyCache[provinceId]!;
    }

    final Uri uri = Uri.parse(
        '$_baseUrl${AuthEndpoints.referenceRegencies}?provinceId=$provinceId');
    final http.Response response = await _httpClient.get(
      uri,
      headers: const <String, String>{'Accept': 'application/json'},
    );

    final List<RegionItem> items = _parseRegionList(response, 'kabupaten/kota');
    _regencyCache[provinceId] = items;
    return items;
  }

  /// 3. Ambil daftar kecamatan berdasarkan kode kabupaten/kota
  /// Endpoint: GET /api/v1/patients/reference/districts?regencyId=:id
  Future<List<RegionItem>> getDistricts(String regencyId, {bool forceRefresh = false}) async {
    if (regencyId.isEmpty) return const <RegionItem>[];

    if (!forceRefresh && _districtCache.containsKey(regencyId)) {
      return _districtCache[regencyId]!;
    }

    final Uri uri = Uri.parse(
        '$_baseUrl${AuthEndpoints.referenceDistricts}?regencyId=$regencyId');
    final http.Response response = await _httpClient.get(
      uri,
      headers: const <String, String>{'Accept': 'application/json'},
    );

    final List<RegionItem> items = _parseRegionList(response, 'kecamatan');
    _districtCache[regencyId] = items;
    return items;
  }

  /// 4. Ambil daftar kelurahan/desa berdasarkan kode kecamatan
  /// Endpoint: GET /api/v1/patients/reference/villages?districtId=:id
  Future<List<RegionItem>> getVillages(String districtId, {bool forceRefresh = false}) async {
    if (districtId.isEmpty) return const <RegionItem>[];

    if (!forceRefresh && _villageCache.containsKey(districtId)) {
      return _villageCache[districtId]!;
    }

    final Uri uri = Uri.parse(
        '$_baseUrl${AuthEndpoints.referenceVillages}?districtId=$districtId');
    final http.Response response = await _httpClient.get(
      uri,
      headers: const <String, String>{'Accept': 'application/json'},
    );

    final List<RegionItem> items = _parseRegionList(response, 'kelurahan/desa');
    _villageCache[districtId] = items;
    return items;
  }

  /// Hapus cache jika data wilayah di-refresh
  void clearCache() {
    _provinceCache = null;
    _regencyCache.clear();
    _districtCache.clear();
    _villageCache.clear();
  }
}
