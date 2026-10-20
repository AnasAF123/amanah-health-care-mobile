import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
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
    this.hospital = 'RS Amanah Sehat',
    this.department = 'Pelayanan Medis',
    this.avatarAsset = 'assets/amanah/id_card/images/woman-doctor-4.png',
    this.avatarUrl,
  });

  factory AmanahDoctorProfile.fromAuthUser(
    AmanahAuthUser user, {
    int unreadNotifications = 0,
    String? customGreeting,
  }) {
    final int hour = DateTime.now().hour;
    final String greeting = customGreeting ??
        (hour < 11
            ? 'Selamat Pagi'
            : hour < 15
                ? 'Selamat Siang'
                : hour < 18
                    ? 'Selamat Sore'
                    : 'Selamat Malam');

    final String doctorName = user.staff?.fullName?.trim().isNotEmpty == true
        ? user.staff!.fullName!
        : user.fullName.trim().isNotEmpty
            ? user.fullName
            : (user.isDoctor ? 'dr. Tenaga Medis' : 'Tenaga Medis');

    final String role = user.staff?.profession?.trim().isNotEmpty == true
        ? user.staff!.profession!
        : user.displayRole;

    final String sip = user.staff?.practitionerId?.trim().isNotEmpty == true
        ? user.staff!.practitionerId!
        : (user.staff?.idCardNumber?.trim().isNotEmpty == true
            ? user.staff!.idCardNumber!
            : 'ID-${user.id.isNotEmpty ? user.id.substring(0, user.id.length < 8 ? user.id.length : 8).toUpperCase() : "MEDIS"}');

    final String nik = user.staff?.idCardNumber ?? '';
    final String email = user.email;
    final String phone = user.staff?.phoneNumber ?? user.phone;
    final String? avatarUrl = user.avatar.directUrl ?? (user.avatar.url.isNotEmpty ? user.avatar.url : null);

    return AmanahDoctorProfile(
      name: doctorName,
      role: role,
      greeting: greeting,
      unreadNotifications: unreadNotifications,
      sip: sip,
      str: sip,
      nik: nik,
      kkiNumber: sip,
      email: email,
      phone: phone,
      hospital: 'RS Amanah Sehat',
      department: user.isDoctor
          ? 'Pelayanan Medis'
          : user.isMidwife
              ? 'Kebidanan & Kandungan'
              : 'Administrasi Medis',
      avatarAsset: 'assets/amanah/id_card/images/woman-doctor-4.png',
      avatarUrl: avatarUrl,
    );
  }

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
  final String? avatarUrl;
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

const List<AmanahQuickAction> kDefaultQuickActions = <AmanahQuickAction>[
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
];

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
