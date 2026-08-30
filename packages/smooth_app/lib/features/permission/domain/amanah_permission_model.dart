import 'package:flutter/material.dart';

enum AmanahPermissionStatus {
  menunggu,
  disetujui,
  ditolak,
  dibatalkan;

  String get label {
    switch (this) {
      case AmanahPermissionStatus.menunggu:
        return 'Menunggu';
      case AmanahPermissionStatus.disetujui:
        return 'Disetujui';
      case AmanahPermissionStatus.ditolak:
        return 'Ditolak';
      case AmanahPermissionStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  static AmanahPermissionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return AmanahPermissionStatus.disetujui;
      case 'ditolak':
      case 'rejected':
        return AmanahPermissionStatus.ditolak;
      case 'dibatalkan':
      case 'cancelled':
        return AmanahPermissionStatus.dibatalkan;
      case 'menunggu':
      case 'pending':
      default:
        return AmanahPermissionStatus.menunggu;
    }
  }
}

enum AmanahPermissionType {
  cutiTahunan,
  izinSakit,
  seminarSimposium,
  urusanKeluarga,
  tugasLuarRS;

  String get label {
    switch (this) {
      case AmanahPermissionType.cutiTahunan:
        return 'Cuti Tahunan';
      case AmanahPermissionType.izinSakit:
        return 'Izin Sakit';
      case AmanahPermissionType.seminarSimposium:
        return 'Seminar / Simposium';
      case AmanahPermissionType.urusanKeluarga:
        return 'Urusan Keluarga';
      case AmanahPermissionType.tugasLuarRS:
        return 'Tugas Luar RS';
    }
  }

  Color get colorPrimary {
    switch (this) {
      case AmanahPermissionType.cutiTahunan:
        return const Color(0xFF2563EB);
      case AmanahPermissionType.izinSakit:
        return const Color(0xFFEF4444);
      case AmanahPermissionType.seminarSimposium:
        return const Color(0xFF8B5CF6);
      case AmanahPermissionType.urusanKeluarga:
        return const Color(0xFFF59E0B);
      case AmanahPermissionType.tugasLuarRS:
        return const Color(0xFF06B6D4);
    }
  }

  Color get colorLight {
    switch (this) {
      case AmanahPermissionType.cutiTahunan:
        return const Color(0xFF60A5FA);
      case AmanahPermissionType.izinSakit:
        return const Color(0xFFFCA5A5);
      case AmanahPermissionType.seminarSimposium:
        return const Color(0xFFC4B5FD);
      case AmanahPermissionType.urusanKeluarga:
        return const Color(0xFFFCD34D);
      case AmanahPermissionType.tugasLuarRS:
        return const Color(0xFF67E8F9);
    }
  }

  Color get colorDark {
    switch (this) {
      case AmanahPermissionType.cutiTahunan:
        return const Color(0xFF1D4ED8);
      case AmanahPermissionType.izinSakit:
        return const Color(0xFFDC2626);
      case AmanahPermissionType.seminarSimposium:
        return const Color(0xFF6D28D9);
      case AmanahPermissionType.urusanKeluarga:
        return const Color(0xFFD97706);
      case AmanahPermissionType.tugasLuarRS:
        return const Color(0xFF0891B2);
    }
  }

  static AmanahPermissionType fromString(String value) {
    switch (value) {
      case 'Izin Sakit':
        return AmanahPermissionType.izinSakit;
      case 'Seminar / Simposium':
        return AmanahPermissionType.seminarSimposium;
      case 'Urusan Keluarga':
        return AmanahPermissionType.urusanKeluarga;
      case 'Tugas Luar RS':
        return AmanahPermissionType.tugasLuarRS;
      case 'Cuti Tahunan':
      default:
        return AmanahPermissionType.cutiTahunan;
    }
  }
}

class AmanahPermissionRecord {
  const AmanahPermissionRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.userAvatarUrl,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.type,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.substituteDoctor,
    this.reviewedAt,
    this.reviewerName,
    this.reviewerNotes,
    this.cancelledAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String userAvatarUrl;
  final String startDate; // Format: 'YYYY-MM-DD'
  final String endDate; // Format: 'YYYY-MM-DD'
  final int durationDays;
  final AmanahPermissionType type;
  final String reason;
  final String? substituteDoctor;
  final AmanahPermissionStatus status;
  final String createdAt;
  final String? reviewedAt;
  final String? reviewerName;
  final String? reviewerNotes;
  final String? cancelledAt;

  String get formattedStartDate => formatDateIndo(startDate);
  String get formattedEndDate => formatDateIndo(endDate);
  String get formattedDateRange => '$formattedStartDate — $formattedEndDate';

  static String formatDateIndo(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      final List<String> monthNames = <String>[
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${monthNames[date.month]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  AmanahPermissionRecord copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? userAvatarUrl,
    String? startDate,
    String? endDate,
    int? durationDays,
    AmanahPermissionType? type,
    String? reason,
    String? substituteDoctor,
    AmanahPermissionStatus? status,
    String? createdAt,
    String? reviewedAt,
    String? reviewerName,
    String? reviewerNotes,
    String? cancelledAt,
  }) {
    return AmanahPermissionRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      substituteDoctor: substituteDoctor ?? this.substituteDoctor,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
