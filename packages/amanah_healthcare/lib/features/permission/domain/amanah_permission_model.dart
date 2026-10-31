import 'package:amanah_healthcare/core/time/time.dart';

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
}

enum AmanahPermissionType {
  cutiTahunan,
  izinSakit,
  seminarSimposium,
  urusanKeluarga,
  tugasLuarRS,
  lainnya;

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
      case AmanahPermissionType.lainnya:
        return 'Lainnya';
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
    this.substituteStaffProfileId,
    this.substituteStaffName,
    String? substituteDoctor,
    this.reviewedAt,
    this.reviewerName,
    this.reviewerNotes,
    this.cancelledAt,
  }) : _substituteDoctor = substituteStaffName ?? substituteDoctor;

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
  final String? substituteStaffProfileId;
  final String? substituteStaffName;
  final String? _substituteDoctor;
  String? get substituteDoctor => substituteStaffName ?? _substituteDoctor;
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
    final DateTime? parsed = parseIsoDateString(dateStr);
    if (parsed == null) {
      return dateStr;
    }
    return formatLocalizedDate(parsed, style: 'human_short');
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
    String? substituteStaffProfileId,
    String? substituteStaffName,
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
      substituteStaffProfileId: substituteStaffProfileId ?? this.substituteStaffProfileId,
      substituteStaffName: substituteStaffName ?? substituteDoctor ?? this.substituteStaffName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
