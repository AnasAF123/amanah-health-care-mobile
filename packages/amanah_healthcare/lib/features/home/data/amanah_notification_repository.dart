import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:amanah_healthcare/core/network/client/amanah_http_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';

class AmanahNotificationRepository {
  AmanahNotificationRepository({
    AmanahAuthTokenStorage? tokenStorage,
    http.Client? httpClient,
  })  : _tokenStorage = tokenStorage ?? AmanahAuthTokenStorage(),
        _httpClient = httpClient ?? AmanahHttpClient.instance;

  final AmanahAuthTokenStorage _tokenStorage;
  final http.Client _httpClient;

  String get _baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  Future<Map<String, String>> _buildHeaders() async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final String? token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<int> fetchUnreadCount() async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/api/v1/notifications/unread-count');
      final http.Response response =
          await _httpClient.get(uri, headers: await _buildHeaders());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['unreadCount'] is int) {
          return decoded['unreadCount'] as int;
        }
      }
    } catch (_) {}
    return 0;
  }

  Future<List<AmanahNotificationItem>> fetchNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/api/v1/notifications/me').replace(
        queryParameters: <String, String>{
          'page': '$page',
          'limit': '$limit',
          if (unreadOnly) 'unreadOnly': 'true',
        },
      );
      final http.Response response =
          await _httpClient.get(uri, headers: await _buildHeaders());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        final dynamic data =
            decoded is Map<String, dynamic> && decoded['data'] != null
                ? decoded['data']
                : decoded;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(AmanahNotificationItem.fromJson)
              .toList();
        }
      }
    } catch (_) {}
    return <AmanahNotificationItem>[];
  }

  Future<bool> markAsRead(String id) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/api/v1/notifications/$id/read');
      final http.Response response =
          await _httpClient.patch(uri, headers: await _buildHeaders());
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/api/v1/notifications/read-all');
      final http.Response response =
          await _httpClient.patch(uri, headers: await _buildHeaders());
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
