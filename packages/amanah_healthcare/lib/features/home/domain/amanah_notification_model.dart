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
  appointment('appointment', 'Janji Temu'),
  clinical('clinical', 'Klinis'),
  labResult('lab_result', 'Hasil Lab'),
  shift('shift', 'Shift & Roster'),
  pharmacy('pharmacy', 'Farmasi & Resep'),
  telemedicine('telemedicine', 'Telemedisin'),
  support('support', 'Bantuan & IT'),
  system('system', 'Sistem & Pengumuman'),
  promotion('promotion', 'Informasi & Edukasi');

  const AmanahNotificationCategory(this.id, this.label);

  final String id;
  final String label;

  static AmanahNotificationCategory fromString(String? raw) {
    if (raw == null || raw.isEmpty) return AmanahNotificationCategory.all;
    final String normalized = raw.toLowerCase().trim();
    for (final AmanahNotificationCategory cat in AmanahNotificationCategory.values) {
      if (cat.id == normalized) return cat;
    }
    return AmanahNotificationCategory.all;
  }
}

enum AmanahNotificationSourceType {
  attendance('attendance'),
  leave('leave'),
  replacement('replacement'),
  payroll('payroll'),
  queue('queue'),
  appointment('appointment'),
  clinical('clinical'),
  unknown('');

  const AmanahNotificationSourceType(this.value);

  final String value;

  static AmanahNotificationSourceType fromString(String? raw) {
    if (raw == null || raw.isEmpty) return AmanahNotificationSourceType.unknown;
    final String normalized = raw.toLowerCase().trim();
    for (final AmanahNotificationSourceType type in AmanahNotificationSourceType.values) {
      if (type.value == normalized) return type;
    }
    return AmanahNotificationSourceType.unknown;
  }

  bool get isShiftRelated =>
      this == attendance || this == leave || this == replacement || this == payroll;

  AmanahNotificationCategory get defaultCategory {
    switch (this) {
      case attendance:
      case leave:
      case replacement:
      case payroll:
        return AmanahNotificationCategory.shift;
      case queue:
      case appointment:
        return AmanahNotificationCategory.queue;
      case clinical:
        return AmanahNotificationCategory.clinical;
      case unknown:
        return AmanahNotificationCategory.all;
    }
  }

  AmanahNotificationVisual get defaultVisual {
    switch (this) {
      case attendance:
        return AmanahNotificationVisual.shiftReminder;
      case leave:
      case replacement:
      case payroll:
        return AmanahNotificationVisual.shiftSchedule;
      case queue:
      case appointment:
        return AmanahNotificationVisual.queueVitals;
      case clinical:
      case unknown:
        return AmanahNotificationVisual.clinicalConsult;
    }
  }
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
    this.audience = 'internal',
    this.targetRoleId,
    this.actionLabel,
    this.actionUrl,
    this.sourceType = AmanahNotificationSourceType.unknown,
    this.sourceId,
  });

  final String id;
  final String title;
  final String desc;
  final String time;
  final String timestamp;
  final AmanahNotificationCategory category;
  final bool isUnread;
  final bool isUrgent;
  final String audience;
  final String? targetRoleId;
  final String? actionLabel;
  final AmanahNotificationVisual visual;
  final String? actionUrl;
  final AmanahNotificationSourceType sourceType;
  final String? sourceId;

  AmanahNotificationItem copyWith({
    String? id,
    String? title,
    String? desc,
    String? time,
    String? timestamp,
    AmanahNotificationCategory? category,
    bool? isUnread,
    bool? isUrgent,
    String? audience,
    String? targetRoleId,
    String? actionLabel,
    AmanahNotificationVisual? visual,
    String? actionUrl,
    AmanahNotificationSourceType? sourceType,
    String? sourceId,
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
      audience: audience ?? this.audience,
      targetRoleId: targetRoleId ?? this.targetRoleId,
      actionLabel: actionLabel ?? this.actionLabel,
      visual: visual ?? this.visual,
      actionUrl: actionUrl ?? this.actionUrl,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
    );
  }
}

class AmanahNotificationStore extends ChangeNotifier {
  AmanahNotificationStore._() {
    _notifications = <AmanahNotificationItem>[];
    _apiClient = AuthorizedApiClient(
      innerClient: HttpApiClient(baseUrl: AmanahAuthEnvironment.authBaseUrl),
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

  int get unreadCount => _notifications.where((AmanahNotificationItem n) => n.isUnread).length;

  int countForCategory(AmanahNotificationCategory category) {
    if (category == AmanahNotificationCategory.all) {
      return _notifications.length;
    }
    return _notifications.where((AmanahNotificationItem n) => n.category == category).length;
  }

  List<AmanahNotificationItem> getFiltered(AmanahNotificationCategory category) {
    if (category == AmanahNotificationCategory.all) {
      return notifications;
    }
    return _notifications.where((AmanahNotificationItem n) => n.category == category).toList();
  }

  static AmanahNotificationCategory _mapCategory(
    String? cat, [
    AmanahNotificationSourceType sourceType = AmanahNotificationSourceType.unknown,
  ]) {
    if (sourceType.isShiftRelated) {
      return AmanahNotificationCategory.shift;
    }
    if (cat == null || cat.isEmpty) return AmanahNotificationCategory.all;
    final String c = cat.toLowerCase().trim();
    switch (c) {
      case 'queue':
        return AmanahNotificationCategory.queue;
      case 'appointment':
        return AmanahNotificationCategory.appointment;
      case 'clinical':
        return AmanahNotificationCategory.clinical;
      case 'lab_result':
      case 'lab':
        return AmanahNotificationCategory.labResult;
      case 'shift':
      case 'schedule':
      case 'attendance':
      case 'leave':
      case 'replacement':
      case 'payroll':
        return AmanahNotificationCategory.shift;
      case 'pharmacy':
        return AmanahNotificationCategory.pharmacy;
      case 'telemedicine':
        return AmanahNotificationCategory.telemedicine;
      case 'support':
        return AmanahNotificationCategory.support;
      case 'system':
        return AmanahNotificationCategory.system;
      case 'promotion':
        return AmanahNotificationCategory.promotion;
      default:
        return AmanahNotificationCategory.all;
    }
  }

  static AmanahNotificationVisual _mapVisual(
    String? cat,
    bool isUrgent, [
    AmanahNotificationSourceType sourceType = AmanahNotificationSourceType.unknown,
  ]) {
    if (isUrgent) return AmanahNotificationVisual.clinicalCritical;
    if (sourceType != AmanahNotificationSourceType.unknown) {
      return sourceType.defaultVisual;
    }

    final String c = (cat ?? '').toLowerCase().trim();
    switch (c) {
      case 'queue':
        return AmanahNotificationVisual.queueVitals;
      case 'appointment':
        return AmanahNotificationVisual.appointmentSchedule;
      case 'shift':
      case 'schedule':
      case 'payroll':
        return AmanahNotificationVisual.shiftSchedule;
      case 'lab_result':
      case 'clinical_report':
        return AmanahNotificationVisual.clinicalReport;
      case 'pharmacy':
        return AmanahNotificationVisual.pharmacyAlert;
      case 'support':
        return AmanahNotificationVisual.supportTicket;
      case 'system':
        return AmanahNotificationVisual.systemNotice;
      default:
        return AmanahNotificationVisual.clinicalConsult;
    }
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
          final String desc = item['body']?.toString() ?? item['desc']?.toString() ?? '';
          final String createdAt = item['createdAt']?.toString() ?? '';
          final bool isRead = item['isRead'] as bool? ?? false;
          final bool isUrgent = item['isUrgent'] as bool? ?? false;
          final String categoryStr = item['category']?.toString() ?? '';
          final String rawSourceType = item['sourceType']?.toString() ?? '';
          final AmanahNotificationSourceType sourceType = AmanahNotificationSourceType.fromString(
            rawSourceType,
          );
          final String sourceId = item['sourceId']?.toString() ?? '';
          final String audience = item['audience']?.toString() ?? 'internal';
          final String? targetRoleId = item['targetRoleId']?.toString();

          String? actionUrl = item['actionUrl']?.toString();
          String? actionLabel;
          final dynamic actionsList = item['actions'];
          if (actionsList is List && actionsList.isNotEmpty) {
            final dynamic firstAct = actionsList.first;
            if (firstAct is Map) {
              actionLabel = firstAct['label']?.toString();
              actionUrl ??= firstAct['url']?.toString();
            }
          }

          return AmanahNotificationItem(
            id: id,
            title: title,
            desc: desc,
            time: _formatTime(createdAt),
            timestamp: createdAt,
            category: _mapCategory(categoryStr, sourceType),
            isUnread: !isRead,
            isUrgent: isUrgent,
            audience: audience,
            targetRoleId: targetRoleId,
            visual: _mapVisual(categoryStr, isUrgent, sourceType),
            actionLabel: actionLabel,
            actionUrl: actionUrl,
            sourceType: sourceType,
            sourceId: sourceId.isNotEmpty ? sourceId : null,
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
        _apiClient
            .request(
              ApiEndpoint(
                path: '/api/v1/notifications/$id/read',
                method: HttpMethod.patch,
                requiresAuth: true,
              ),
            )
            .catchError((_) => const ApiResponse<dynamic>(statusCode: 500, data: null)),
      );
    }
  }

  void markAllAsRead() {
    final bool hasUnread = _notifications.any((AmanahNotificationItem n) => n.isUnread);
    if (!hasUnread) {
      return;
    }
    _notifications = _notifications
        .map((AmanahNotificationItem n) => n.copyWith(isUnread: false))
        .toList();
    notifyListeners();

    // Sync with backend asynchronously
    unawaited(
      _apiClient
          .request(
            const ApiEndpoint(
              path: '/api/v1/notifications/read-all',
              method: HttpMethod.patch,
              requiresAuth: true,
            ),
          )
          .catchError((_) => const ApiResponse<dynamic>(statusCode: 500, data: null)),
    );
  }

  void clearRead() {
    _notifications = _notifications.where((AmanahNotificationItem n) => n.isUnread).toList();
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
