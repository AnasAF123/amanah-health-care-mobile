import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

export 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart'
    show AmanahBadgeVariant;

enum AmanahQuickActionIcon { history, presence, schedule, search, idCard }

enum AmanahActivityIcon { users, stethoscope }

enum AmanahActivityGlow { blue, emerald }

class AmanahDoctorProfile {
  const AmanahDoctorProfile({
    required this.name,
    required this.role,
    required this.greeting,
    required this.unreadNotifications,
    this.sip = '',
    this.str = '',
    this.nik = '',
    this.kkiNumber = '',
    this.email = '',
    this.phone = '',
    this.hospital = '',
    this.department = '',
    this.avatarAsset = '',
  });

  final String name;
  final String role;
  final String greeting;
  final int unreadNotifications;
  final String sip;
  final String str;
  final String nik;
  final String kkiNumber;
  final String email;
  final String phone;
  final String hospital;
  final String department;
  final String avatarAsset;
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

  AmanahActivityMetric copyWith({
    String? id,
    String? title,
    String? count,
    String? unit,
    String? badgeText,
    AmanahBadgeVariant? badgeVariant,
    AmanahActivityIcon? icon,
    AmanahActivityGlow? glow,
  }) {
    return AmanahActivityMetric(
      id: id ?? this.id,
      title: title ?? this.title,
      count: count ?? this.count,
      unit: unit ?? this.unit,
      badgeText: badgeText ?? this.badgeText,
      badgeVariant: badgeVariant ?? this.badgeVariant,
      icon: icon ?? this.icon,
      glow: glow ?? this.glow,
    );
  }
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
    name: '',
    role: '',
    greeting: '',
    unreadNotifications: 0,
  ),
  schedules: <AmanahSchedule>[],
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
      id: 'pilih-antrean',
      label: 'Pilih Antrean',
      icon: AmanahQuickActionIcon.search,
    ),
    AmanahQuickAction(
      id: 'kartu-id',
      label: 'Kartu ID',
      icon: AmanahQuickActionIcon.idCard,
    ),
  ],
  activities: <AmanahActivityMetric>[],
);

IconData amanahQuickActionIconData(AmanahQuickActionIcon icon) {
  return switch (icon) {
    AmanahQuickActionIcon.history => Icons.history_rounded,
    AmanahQuickActionIcon.presence => Icons.check_box_outlined,
    AmanahQuickActionIcon.schedule => Icons.calendar_today_outlined,
    AmanahQuickActionIcon.search => Icons.groups_outlined,
    AmanahQuickActionIcon.idCard => Icons.contact_page_outlined,
  };
}

IconData amanahActivityIconData(AmanahActivityIcon icon) {
  return switch (icon) {
    AmanahActivityIcon.users => Icons.groups_2_outlined,
    AmanahActivityIcon.stethoscope => Icons.medical_services_outlined,
  };
}
