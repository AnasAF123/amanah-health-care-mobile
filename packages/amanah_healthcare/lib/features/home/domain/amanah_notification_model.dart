import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/features/home/data/amanah_notification_repository.dart';
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

  factory AmanahNotificationItem.fromJson(Map<String, dynamic> json) {
    final String rawCat = (json['category'] as String? ?? 'all').toLowerCase();
    AmanahNotificationCategory category;
    if (rawCat.contains('queue') ||
        rawCat.contains('appointment') ||
        rawCat.contains('antrean')) {
      category = AmanahNotificationCategory.queue;
    } else if (rawCat.contains('clinical') ||
        rawCat.contains('lab') ||
        rawCat.contains('klinis')) {
      category = AmanahNotificationCategory.clinical;
    } else if (rawCat.contains('shift') ||
        rawCat.contains('schedule') ||
        rawCat.contains('poli')) {
      category = AmanahNotificationCategory.shift;
    } else {
      category = AmanahNotificationCategory.all;
    }

    final bool isUrgent = json['isUrgent'] as bool? ?? false;
    final bool isUnread = !(json['isRead'] as bool? ?? false);

    AmanahNotificationVisual visual;
    if (isUrgent) {
      visual = AmanahNotificationVisual.clinicalCritical;
    } else if (category == AmanahNotificationCategory.queue) {
      visual = AmanahNotificationVisual.queueVitals;
    } else if (category == AmanahNotificationCategory.shift) {
      visual = AmanahNotificationVisual.shiftSchedule;
    } else {
      visual = AmanahNotificationVisual.clinicalConsult;
    }

    final String createdAtStr = json['createdAt'] as String? ?? '';
    String timeStr = 'Baru saja';
    String timestampStr = 'Hari ini';
    if (createdAtStr.isNotEmpty) {
      final DateTime? parsed = DateTime.tryParse(createdAtStr);
      if (parsed != null) {
        timeStr =
            '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
        timestampStr =
            '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      }
    }

    return AmanahNotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Pemberitahuan',
      desc: json['body'] as String? ?? json['desc'] as String? ?? '',
      time: timeStr,
      timestamp: timestampStr,
      category: category,
      visual: visual,
      isUnread: isUnread,
      isUrgent: isUrgent,
      actionLabel: json['actionLabel'] as String?,
    );
  }

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
  AmanahNotificationStore._({AmanahNotificationRepository? repository})
      : _repository = repository ?? AmanahNotificationRepository() {
    _notifications = List<AmanahNotificationItem>.from(_initialNotifications);
  }

  static final AmanahNotificationStore instance = AmanahNotificationStore._();

  static const List<AmanahNotificationItem> _initialNotifications =
      <AmanahNotificationItem>[];

  final AmanahNotificationRepository _repository;
  late List<AmanahNotificationItem> _notifications;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  @visibleForTesting
  void seedForTesting(List<AmanahNotificationItem> items) {
    _notifications = List<AmanahNotificationItem>.from(items);
    notifyListeners();
  }

  List<AmanahNotificationItem> get notifications =>
      List<AmanahNotificationItem>.unmodifiable(_notifications);

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

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<AmanahNotificationItem> items =
          await _repository.fetchNotifications();
      if (items.isNotEmpty) {
        _notifications = items;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUnreadCount() async {
    final int count = await _repository.fetchUnreadCount();
    if (count == 0 && unreadCount > 0) {
      _notifications = _notifications
          .map((AmanahNotificationItem n) => n.copyWith(isUnread: false))
          .toList();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
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
      await _repository.markAsRead(id);
    }
  }

  Future<void> markAllAsRead() async {
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
    await _repository.markAllAsRead();
  }

  void clearRead() {
    _notifications = _notifications
        .where((AmanahNotificationItem n) => n.isUnread)
        .toList();
    notifyListeners();
  }

  void reset() {
    _notifications = List<AmanahNotificationItem>.from(_initialNotifications);
    notifyListeners();
  }
}
