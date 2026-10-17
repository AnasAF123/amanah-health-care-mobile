import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/network/api_client.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';
import 'package:amanah_healthcare/core/network/api_response.dart';
import 'package:amanah_healthcare/core/network/authorized_api_client.dart';
import 'package:amanah_healthcare/core/network/http_api_client.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_visual_role.dart';

enum AmanahNotificationCategory {
  all('all', 'Semua'),
  queue('queue', 'Antrean'),
  clinical('clinical', 'Klinis & Lab'),
  shift('shift', 'Shift & Poli');

  const AmanahNotificationCategory(this.id, this.label);

  final String id;
  final String label;
}

class AmanahNotificationItem {
  const AmanahNotificationItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.time,
    required this.timestamp,
    required this.category,
    required this.visual,
    this.isUnread = true,
    this.isUrgent = false,
    this.actionLabel,
  });

  final String id;
  final String title;
  final String desc;
  final String time;
  final String timestamp;
  final AmanahNotificationCategory category;
  final bool isUnread;
  final bool isUrgent;
  final String? actionLabel;
  final AmanahNotificationVisual visual;

  AmanahNotificationItem copyWith({
    String? id,
    String? title,
    String? desc,
    String? time,
    String? timestamp,
    AmanahNotificationCategory? category,
    bool? isUnread,
    bool? isUrgent,
    String? actionLabel,
    AmanahNotificationVisual? visual,
  }) {
    return AmanahNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      time: time ?? this.time,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isUnread: isUnread ?? this.isUnread,
      isUrgent: isUrgent ?? this.isUrgent,
      actionLabel: actionLabel ?? this.actionLabel,
      visual: visual ?? this.visual,
    );
  }
}

class AmanahNotificationStore extends ChangeNotifier {
  AmanahNotificationStore._() {
    _notifications = <AmanahNotificationItem>[];
    _apiClient = AuthorizedApiClient(
      innerClient: HttpApiClient(
        baseUrl: AmanahAuthEnvironment.authBaseUrl,
      ),
      tokenProvider: const AmanahAuthTokenStorage(),
    );
  }

  static final AmanahNotificationStore instance = AmanahNotificationStore._();

  late final ApiClient _apiClient;
  List<AmanahNotificationItem> _notifications = <AmanahNotificationItem>[];
  bool _isLoading = false;

  List<AmanahNotificationItem> get notifications =>
      List<AmanahNotificationItem>.unmodifiable(_notifications);

  bool get isLoading => _isLoading;

  int get unreadCount =>
      _notifications.where((AmanahNotificationItem n) => n.isUnread).length;

  int countForCategory(AmanahNotificationCategory category) {
    if (category == AmanahNotificationCategory.all) {
      return _notifications.length;
    }
    return _notifications
        .where((AmanahNotificationItem n) => n.category == category)
        .length;
  }

  List<AmanahNotificationItem> getFiltered(
    AmanahNotificationCategory category,
  ) {
    if (category == AmanahNotificationCategory.all) {
      return notifications;
    }
    return _notifications
        .where((AmanahNotificationItem n) => n.category == category)
        .toList();
  }

  static AmanahNotificationCategory _mapCategory(String? cat) {
    if (cat == null) return AmanahNotificationCategory.all;
    switch (cat.toLowerCase()) {
      case 'queue':
      case 'appointment':
        return AmanahNotificationCategory.queue;
      case 'clinical':
      case 'lab':
        return AmanahNotificationCategory.clinical;
      case 'shift':
      case 'schedule':
        return AmanahNotificationCategory.shift;
      default:
        return AmanahNotificationCategory.all;
    }
  }

  static AmanahNotificationVisual _mapVisual(String? cat, bool isUrgent) {
    if (isUrgent) return AmanahNotificationVisual.clinicalCritical;
    final String c = (cat ?? '').toLowerCase();
    if (c == 'queue' || c == 'appointment') return AmanahNotificationVisual.queueVitals;
    if (c == 'shift' || c == 'schedule') return AmanahNotificationVisual.shiftSchedule;
    return AmanahNotificationVisual.clinicalConsult;
  }

  static String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime dt = DateTime.parse(dateStr).toLocal();
      final String h = dt.hour.toString().padLeft(2, '0');
      final String m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  /// Fetches real notifications from backend SSOT.
  Future<void> fetchMyNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final ApiResponse<dynamic> res = await _apiClient.request(
        const ApiEndpoint(
          path: '/api/v1/notifications/me?limit=50',
          method: HttpMethod.get,
          requiresAuth: true,
        ),
      );

      dynamic rawData = res.data;
      if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
        rawData = rawData['data'];
      }

      if (rawData is List) {
        _notifications = rawData.whereType<Map<String, dynamic>>().map((item) {
          final String id = item['id']?.toString() ?? '';
          final String title = item['title']?.toString() ?? 'Pemberitahuan';
          final String desc =
              item['body']?.toString() ?? item['desc']?.toString() ?? '';
          final String createdAt = item['createdAt']?.toString() ?? '';
          final bool isRead = item['isRead'] as bool? ?? false;
          final bool isUrgent = item['isUrgent'] as bool? ?? false;
          final String categoryStr = item['category']?.toString() ?? '';

          return AmanahNotificationItem(
            id: id,
            title: title,
            desc: desc,
            time: _formatTime(createdAt),
            timestamp: createdAt,
            category: _mapCategory(categoryStr),
            isUnread: !isRead,
            isUrgent: isUrgent,
            visual: _mapVisual(categoryStr, isUrgent),
          );
        }).toList();
      }
    } catch (e) {
      AppLog.warning('[AmanahNotificationStore] Failed to fetch notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRead(String id) {
    bool updated = false;
    _notifications = _notifications.map((AmanahNotificationItem n) {
      if (n.id == id && n.isUnread) {
        updated = true;
        return n.copyWith(isUnread: false);
      }
      return n;
    }).toList();

    if (updated) {
      notifyListeners();
      // Sync with backend asynchronously
      unawaited(
        _apiClient.request(
          ApiEndpoint(
            path: '/api/v1/notifications/$id/read',
            method: HttpMethod.patch,
            requiresAuth: true,
          ),
        ).catchError((_) => const ApiResponse<dynamic>(statusCode: 500, data: null)),
      );
    }
  }

  void markAllAsRead() {
    final bool hasUnread = _notifications.any(
      (AmanahNotificationItem n) => n.isUnread,
    );
    if (!hasUnread) {
      return;
    }
    _notifications = _notifications
        .map((AmanahNotificationItem n) => n.copyWith(isUnread: false))
        .toList();
    notifyListeners();

    // Sync with backend asynchronously
    unawaited(
      _apiClient.request(
        const ApiEndpoint(
          path: '/api/v1/notifications/read-all',
          method: HttpMethod.patch,
          requiresAuth: true,
        ),
      ).catchError((_) => const ApiResponse<dynamic>(statusCode: 500, data: null)),
    );
  }

  void clearRead() {
    _notifications = _notifications
        .where((AmanahNotificationItem n) => n.isUnread)
        .toList();
    notifyListeners();
  }

  void addNotification(AmanahNotificationItem item) {
    _notifications = <AmanahNotificationItem>[item, ..._notifications];
    notifyListeners();
  }

  void clear() {
    _notifications = <AmanahNotificationItem>[];
    notifyListeners();
  }

  void reset() {
    _notifications = <AmanahNotificationItem>[];
    notifyListeners();
  }
}
