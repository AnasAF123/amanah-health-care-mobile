import 'package:flutter/material.dart';

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
    required this.colorPrimary,
    required this.colorLight,
    required this.colorDark,
    required this.icon,
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
  final Color colorPrimary;
  final Color colorLight;
  final Color colorDark;
  final IconData icon;

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
    Color? colorPrimary,
    Color? colorLight,
    Color? colorDark,
    IconData? icon,
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
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorLight: colorLight ?? this.colorLight,
      colorDark: colorDark ?? this.colorDark,
      icon: icon ?? this.icon,
    );
  }
}

class AmanahNotificationStore extends ChangeNotifier {
  AmanahNotificationStore._() {
    _notifications = List<AmanahNotificationItem>.from(_initialNotifications);
  }

  static final AmanahNotificationStore instance = AmanahNotificationStore._();

  static const List<AmanahNotificationItem> _initialNotifications =
      <AmanahNotificationItem>[
    AmanahNotificationItem(
      id: 'notif_1',
      title: 'Pasien Siap di Ruang Periksa',
      desc:
          'An. Kevin Sanjaya (No. Antrean A-04) telah selesai asesmen tanda vital oleh perawat.',
      time: 'Baru saja',
      timestamp: '07:45',
      category: AmanahNotificationCategory.queue,
      isUnread: true,
      isUrgent: false,
      colorPrimary: Color(0xFF2563EB),
      colorLight: Color(0xFF60A5FA),
      colorDark: Color(0xFF1D4ED8),
      icon: Icons.monitor_heart_outlined,
    ),
    AmanahNotificationItem(
      id: 'notif_2',
      title: 'Hasil Kritis Laboratorium Darah',
      desc:
          'Hb 7.2 g/dL & Trombosit 45.000 pada pasien Ny. Ratna Dewi (Kamar 204B) perlu verifikasi DPJP.',
      time: '12 mnt lalu',
      timestamp: '07:33',
      category: AmanahNotificationCategory.clinical,
      isUnread: true,
      isUrgent: true,
      colorPrimary: Color(0xFFEF4444),
      colorLight: Color(0xFFFCA5A5),
      colorDark: Color(0xFFDC2626),
      icon: Icons.error_outline_rounded,
    ),
    AmanahNotificationItem(
      id: 'notif_3',
      title: 'Konsultasi Antar Spesialis',
      desc:
          'dr. Budi Santoso, Sp.A meminta lembar rujukan kasus bronkiolitis anak ruang PICU.',
      time: '45 mnt lalu',
      timestamp: '07:00',
      category: AmanahNotificationCategory.clinical,
      isUnread: true,
      isUrgent: false,
      colorPrimary: Color(0xFF8B5CF6),
      colorLight: Color(0xFFC4B5FD),
      colorDark: Color(0xFF6D28D9),
      icon: Icons.chat_bubble_outline_rounded,
    ),
    AmanahNotificationItem(
      id: 'notif_4',
      title: 'Konfirmasi Jadwal Shift Sore',
      desc:
          'Poli Spesialis Anak Sesi 2 dimulai pukul 14:00 - 18:00 WIB (Kuota 15 pasien terisi).',
      time: '2 jam lalu',
      timestamp: '05:45',
      category: AmanahNotificationCategory.shift,
      isUnread: false,
      isUrgent: false,
      colorPrimary: Color(0xFFF59E0B),
      colorLight: Color(0xFFFCD34D),
      colorDark: Color(0xFFD97706),
      icon: Icons.calendar_today_outlined,
    ),
    AmanahNotificationItem(
      id: 'notif_5',
      title: 'Laporan Hasil Radiologi Toraks',
      desc:
          'Hasil foto Rontgen Thorax AP/Lat pasien By. Alif Pratama sudah dapat diakses via SIMRS.',
      time: '3 jam lalu',
      timestamp: '04:30',
      category: AmanahNotificationCategory.clinical,
      isUnread: false,
      isUrgent: false,
      colorPrimary: Color(0xFF06B6D4),
      colorLight: Color(0xFF67E8F9),
      colorDark: Color(0xFF0891B2),
      icon: Icons.description_outlined,
    ),
    AmanahNotificationItem(
      id: 'notif_6',
      title: 'Pengingat Batas Verifikasi Resep',
      desc:
          'Terdapat 3 resep elektronik pasien rawat jalan yang menunggu paraf digital Anda.',
      time: 'Kemarin',
      timestamp: '25 Ags',
      category: AmanahNotificationCategory.shift,
      isUnread: false,
      isUrgent: false,
      colorPrimary: Color(0xFF10B981),
      colorLight: Color(0xFF6EE7B7),
      colorDark: Color(0xFF059669),
      icon: Icons.access_time_rounded,
    ),
  ];

  late List<AmanahNotificationItem> _notifications;

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
      AmanahNotificationCategory category) {
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
    final bool hasUnread =
        _notifications.any((AmanahNotificationItem n) => n.isUnread);
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
