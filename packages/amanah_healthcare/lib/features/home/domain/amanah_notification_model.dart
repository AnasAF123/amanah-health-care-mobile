import 'package:flutter/foundation.dart';
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
    _notifications = List<AmanahNotificationItem>.from(_initialNotifications);
  }

  static final AmanahNotificationStore instance = AmanahNotificationStore._();

  static const List<AmanahNotificationItem>
  _initialNotifications = <AmanahNotificationItem>[];

  late List<AmanahNotificationItem> _notifications;

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
