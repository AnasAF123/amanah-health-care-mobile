import 'package:flutter/material.dart';

enum AmanahBadgeVariant { success, primary, live, trend }

enum AmanahQuickActionIcon { history, presence, schedule, search, idCard }

enum AmanahActivityIcon { users, stethoscope }

enum AmanahActivityGlow { blue, emerald }

class AmanahDoctorProfile {
  const AmanahDoctorProfile({
    required this.name,
    required this.role,
    required this.greeting,
    required this.unreadNotifications,
  });

  final String name;
  final String role;
  final String greeting;
  final int unreadNotifications;
}

class AmanahSchedule {
  const AmanahSchedule({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.poli,
    required this.room,
    required this.slotCount,
    required this.slotText,
    required this.badge,
    required this.badgeVariant,
  });

  final String id;
  final String title;
  final String date;
  final String time;
  final String poli;
  final String room;
  final String slotCount;
  final String slotText;
  final String badge;
  final AmanahBadgeVariant badgeVariant;
}

class AmanahQuickAction {
  const AmanahQuickAction({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final AmanahQuickActionIcon icon;
}

class AmanahActivityMetric {
  const AmanahActivityMetric({
    required this.id,
    required this.title,
    required this.count,
    required this.unit,
    required this.badgeText,
    required this.badgeVariant,
    required this.icon,
    required this.glow,
  });

  final String id;
  final String title;
  final String count;
  final String unit;
  final String badgeText;
  final AmanahBadgeVariant badgeVariant;
  final AmanahActivityIcon icon;
  final AmanahActivityGlow glow;
}

class AmanahHomeDashboardData {
  const AmanahHomeDashboardData({
    required this.profile,
    required this.schedules,
    required this.quickActions,
    required this.activities,
  });

  final AmanahDoctorProfile profile;
  final List<AmanahSchedule> schedules;
  final List<AmanahQuickAction> quickActions;
  final List<AmanahActivityMetric> activities;
}

const AmanahHomeDashboardData amanahHomeDashboardData = AmanahHomeDashboardData(
  profile: AmanahDoctorProfile(
    name: 'dr. Andika Perkasa',
    role: 'Dokter Spesialis Anak',
    greeting: 'Selamat Pagi',
    unreadNotifications: 3,
  ),
  schedules: <AmanahSchedule>[
    AmanahSchedule(
      id: 'sch_001',
      title: 'Jadwal Hari Ini',
      date: 'Selasa, 21 Mei 2026',
      time: '07:30 - 11:30',
      poli: 'Poli Anak',
      room: 'Room 102',
      slotCount: '16 / 30',
      slotText: 'Slot Tersedia',
      badge: 'Buka',
      badgeVariant: AmanahBadgeVariant.success,
    ),
    AmanahSchedule(
      id: 'sch_002',
      title: 'Jadwal Siang',
      date: 'Rabu, 22 Mei 2026',
      time: '13:00 - 16:00',
      poli: 'Poli Umum',
      room: 'Room 105',
      slotCount: '5 / 30',
      slotText: 'Slot Tersedia',
      badge: 'Aktif',
      badgeVariant: AmanahBadgeVariant.primary,
    ),
    AmanahSchedule(
      id: 'sch_003',
      title: 'Jadwal Esok',
      date: 'Kamis, 23 Mei 2026',
      time: '09:00 - 12:00',
      poli: 'Poli Gigi',
      room: 'Room 201',
      slotCount: '20 / 30',
      slotText: 'Slot Tersedia',
      badge: 'Buka',
      badgeVariant: AmanahBadgeVariant.success,
    ),
  ],
  quickActions: <AmanahQuickAction>[
    AmanahQuickAction(
      id: 'history',
      label: 'History',
      icon: AmanahQuickActionIcon.history,
    ),
    AmanahQuickAction(
      id: 'jadwal-saya',
      label: 'Jadwal Saya',
      icon: AmanahQuickActionIcon.schedule,
    ),
    AmanahQuickAction(
      id: 'cari-visit',
      label: 'Cari Visit',
      icon: AmanahQuickActionIcon.search,
    ),
    AmanahQuickAction(
      id: 'kartu-id',
      label: 'Kartu ID',
      icon: AmanahQuickActionIcon.idCard,
    ),
  ],
  activities: <AmanahActivityMetric>[
    AmanahActivityMetric(
      id: 'antrean-aktif',
      title: 'Antrean Aktif',
      count: '23',
      unit: 'Pasien',
      badgeText: 'Live',
      badgeVariant: AmanahBadgeVariant.live,
      icon: AmanahActivityIcon.users,
      glow: AmanahActivityGlow.blue,
    ),
    AmanahActivityMetric(
      id: 'total-selesai',
      title: 'Total Selesai',
      count: '45',
      unit: 'Pasien',
      badgeText: '+12%',
      badgeVariant: AmanahBadgeVariant.trend,
      icon: AmanahActivityIcon.stethoscope,
      glow: AmanahActivityGlow.emerald,
    ),
  ],
);

IconData amanahQuickActionIconData(AmanahQuickActionIcon icon) {
  return switch (icon) {
    AmanahQuickActionIcon.history => Icons.history_rounded,
    AmanahQuickActionIcon.presence => Icons.check_box_outlined,
    AmanahQuickActionIcon.schedule => Icons.calendar_today_outlined,
    AmanahQuickActionIcon.search => Icons.search_rounded,
    AmanahQuickActionIcon.idCard => Icons.contact_page_outlined,
  };
}

IconData amanahActivityIconData(AmanahActivityIcon icon) {
  return switch (icon) {
    AmanahActivityIcon.users => Icons.groups_2_outlined,
    AmanahActivityIcon.stethoscope => Icons.medical_services_outlined,
  };
}
