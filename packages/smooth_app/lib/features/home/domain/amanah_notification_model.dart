import 'package:flutter/foundation.dart';
import 'package:smooth_app/features/home/domain/amanah_visual_role.dart';

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
  _initialNotifications = <AmanahNotificationItem>[
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
      visual: AmanahNotificationVisual.queueVitals,
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
      visual: AmanahNotificationVisual.clinicalCritical,
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
      visual: AmanahNotificationVisual.clinicalConsult,
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
      visual: AmanahNotificationVisual.shiftSchedule,
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
      visual: AmanahNotificationVisual.clinicalReport,
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
      visual: AmanahNotificationVisual.shiftReminder,
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
