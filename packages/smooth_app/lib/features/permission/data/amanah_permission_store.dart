import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smooth_app/features/permission/domain/amanah_permission_model.dart';

class AmanahPermissionStore extends ChangeNotifier {
  AmanahPermissionStore._() {
    _records = List<AmanahPermissionRecord>.from(_seedRecords);
  }

  static final AmanahPermissionStore instance = AmanahPermissionStore._();

  static final List<AmanahPermissionRecord> _seedRecords =
      <AmanahPermissionRecord>[
    const AmanahPermissionRecord(
      id: 'perm_001',
      userId: 'doc_001',
      userName: 'dr. Amelia Cantika',
      userRole: 'Dokter Spesialis Anak',
      userAvatarUrl: 'assets/amanah/auth/auth_background.png',
      startDate: '2026-09-02',
      endDate: '2026-09-04',
      durationDays: 3,
      type: AmanahPermissionType.seminarSimposium,
      reason:
          'Menghadiri Kongres Nasional Ilmu Kesehatan Anak (KONIKA) XIX di Bali sebagai pembicara panelis.',
      substituteDoctor: 'dr. Budi Santoso, Sp.A',
      status: AmanahPermissionStatus.menunggu,
      createdAt: '2026-08-30T08:30:00Z',
    ),
    const AmanahPermissionRecord(
      id: 'perm_002',
      userId: 'doc_001',
      userName: 'dr. Amelia Cantika',
      userRole: 'Dokter Spesialis Anak',
      userAvatarUrl: 'assets/amanah/auth/auth_background.png',
      startDate: '2026-09-15',
      endDate: '2026-09-16',
      durationDays: 2,
      type: AmanahPermissionType.urusanKeluarga,
      reason:
          'Keperluan mendesak keluarga di luar kota dan pendampingan wisuda keluarga inti.',
      substituteDoctor: 'dr. Ratna Sp.A',
      status: AmanahPermissionStatus.menunggu,
      createdAt: '2026-08-29T14:15:00Z',
    ),
    const AmanahPermissionRecord(
      id: 'perm_003',
      userId: 'doc_001',
      userName: 'dr. Amelia Cantika',
      userRole: 'Dokter Spesialis Anak',
      userAvatarUrl: 'assets/amanah/auth/auth_background.png',
      startDate: '2026-08-10',
      endDate: '2026-08-12',
      durationDays: 3,
      type: AmanahPermissionType.cutiTahunan,
      reason:
          'Pengambilan cuti tahunan terjadwal Semester 2 (Hak cuti dokter spesialis).',
      substituteDoctor: 'dr. Budi Santoso, Sp.A',
      status: AmanahPermissionStatus.disetujui,
      createdAt: '2026-08-01T09:00:00Z',
      reviewedAt: '2026-08-02T11:20:00Z',
      reviewerName: 'dr. H. Hendra, Sp.JP (Direktur Pelayanan Medis)',
      reviewerNotes:
          'Disetujui. Kuota dokter pengganti rawat jalan dan jaga bangsal aman.',
    ),
    const AmanahPermissionRecord(
      id: 'perm_004',
      userId: 'doc_001',
      userName: 'dr. Amelia Cantika',
      userRole: 'Dokter Spesialis Anak',
      userAvatarUrl: 'assets/amanah/auth/auth_background.png',
      startDate: '2026-07-20',
      endDate: '2026-07-21',
      durationDays: 2,
      type: AmanahPermissionType.tugasLuarRS,
      reason:
          'Bakti sosial pengobatan gratis dan edukasi stunting anak di Puskesmas Binaan.',
      substituteDoctor: 'dr. Kevin Pratama, Sp.A',
      status: AmanahPermissionStatus.disetujui,
      createdAt: '2026-07-10T10:00:00Z',
      reviewedAt: '2026-07-11T16:45:00Z',
      reviewerName: 'Bagian SDM & Komite Medik RS Amanah',
      reviewerNotes:
          'Surat tugas dinas luar telah diterbitkan nomor ST/2026/07/088.',
    ),
    const AmanahPermissionRecord(
      id: 'perm_005',
      userId: 'doc_001',
      userName: 'dr. Amelia Cantika',
      userRole: 'Dokter Spesialis Anak',
      userAvatarUrl: 'assets/amanah/auth/auth_background.png',
      startDate: '2026-06-18',
      endDate: '2026-06-19',
      durationDays: 2,
      type: AmanahPermissionType.cutiTahunan,
      reason: 'Pengajuan cuti tambahan libur cuti bersama.',
      substituteDoctor: '-',
      status: AmanahPermissionStatus.ditolak,
      createdAt: '2026-06-12T07:45:00Z',
      reviewedAt: '2026-06-13T09:10:00Z',
      reviewerName: 'dr. H. Hendra, Sp.JP (Direktur Pelayanan Medis)',
      reviewerNotes:
          'Mohon maaf tidak dapat disetujui karena jadwal operasi dan visit pasien poliklinik sedang padat.',
    ),
    const AmanahPermissionRecord(
      id: 'perm_006',
      userId: 'doc_001',
      userName: 'dr. Amelia Cantika',
      userRole: 'Dokter Spesialis Anak',
      userAvatarUrl: 'assets/amanah/auth/auth_background.png',
      startDate: '2026-05-05',
      endDate: '2026-05-06',
      durationDays: 2,
      type: AmanahPermissionType.izinSakit,
      reason: 'Demam dan radang tenggorokan akut, istirahat mandiri.',
      substituteDoctor: 'dr. Budi Santoso, Sp.A',
      status: AmanahPermissionStatus.dibatalkan,
      createdAt: '2026-05-04T19:00:00Z',
      cancelledAt: '2026-05-05T06:30:00Z',
    ),
  ];

  late List<AmanahPermissionRecord> _records;

  List<AmanahPermissionRecord> get records =>
      List<AmanahPermissionRecord>.unmodifiable(_records);

  int get pendingCount => _records
      .where((AmanahPermissionRecord r) =>
          r.status == AmanahPermissionStatus.menunggu)
      .length;

  int get approvedCount => _records
      .where((AmanahPermissionRecord r) =>
          r.status == AmanahPermissionStatus.disetujui)
      .length;

  List<AmanahPermissionRecord> getFiltered(AmanahPermissionStatus? filter) {
    if (filter == null) {
      return records;
    }
    return _records
        .where((AmanahPermissionRecord r) => r.status == filter)
        .toList();
  }

  AmanahPermissionRecord? getById(String id) {
    try {
      return _records.firstWhere((AmanahPermissionRecord r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  static int calculateDays(String startStr, String endStr) {
    try {
      final DateTime start = DateTime.parse(startStr);
      final DateTime end = DateTime.parse(endStr);
      final int diff = end.difference(start).inDays + 1;
      return diff > 0 ? diff : 1;
    } catch (_) {
      return 1;
    }
  }

  AmanahPermissionRecord createPermission({
    required String startDate,
    required String endDate,
    required AmanahPermissionType type,
    required String reason,
    String? substituteDoctor,
    int? durationDays,
    String doctorName = 'dr. Rayhan Pratama, Sp.A',
    String doctorRole = 'Dokter Spesialis Anak',
  }) {
    final int duration = durationDays ?? calculateDays(startDate, endDate);
    final String randomSuffix =
        (Random().nextInt(9000) + 1000).toString();
    final AmanahPermissionRecord newRecord = AmanahPermissionRecord(
      id: 'perm_${DateTime.now().millisecondsSinceEpoch}_$randomSuffix',
      userId: 'doc_001',
      userName: doctorName,
      userRole: doctorRole,
      userAvatarUrl: 'assets/amanah/auth/auth_background.png',
      startDate: startDate,
      endDate: endDate,
      durationDays: duration,
      type: type,
      reason: reason.trim(),
      substituteDoctor: substituteDoctor?.trim().isNotEmpty == true
          ? substituteDoctor!.trim()
          : null,
      status: AmanahPermissionStatus.menunggu,
      createdAt: DateTime.now().toIso8601String(),
    );

    _records = <AmanahPermissionRecord>[newRecord, ..._records];
    notifyListeners();
    return newRecord;
  }

  ({bool success, String message, AmanahPermissionRecord? record})
      updatePermission({
    required String id,
    String? startDate,
    String? endDate,
    AmanahPermissionType? type,
    String? reason,
    String? substituteDoctor,
    int? durationDays,
  }) {
    final int index =
        _records.indexWhere((AmanahPermissionRecord r) => r.id == id);
    if (index == -1) {
      return (
        success: false,
        message: 'Data perizinan tidak ditemukan.',
        record: null
      );
    }

    final AmanahPermissionRecord current = _records[index];
    if (current.status != AmanahPermissionStatus.menunggu) {
      return (
        success: false,
        message: current.status == AmanahPermissionStatus.disetujui
            ? 'Perizinan yang sudah disetujui tidak dapat diedit.'
            : 'Perizinan dengan status ini tidak dapat diedit.',
        record: null
      );
    }

    final String finalStart = startDate ?? current.startDate;
    final String finalEnd = endDate ?? current.endDate;
    final int finalDuration =
        durationDays ?? calculateDays(finalStart, finalEnd);

    final AmanahPermissionRecord updated = current.copyWith(
      startDate: finalStart,
      endDate: finalEnd,
      durationDays: finalDuration,
      type: type ?? current.type,
      reason: reason?.trim() ?? current.reason,
      substituteDoctor: substituteDoctor != null
          ? (substituteDoctor.trim().isNotEmpty
              ? substituteDoctor.trim()
              : null)
          : current.substituteDoctor,
    );

    final List<AmanahPermissionRecord> updatedList =
        List<AmanahPermissionRecord>.from(_records);
    updatedList[index] = updated;
    _records = updatedList;
    notifyListeners();

    return (
      success: true,
      message: 'Perizinan berhasil diperbarui.',
      record: updated
    );
  }

  ({bool success, String message, AmanahPermissionRecord? record})
      cancelPermission(String id) {
    final int index =
        _records.indexWhere((AmanahPermissionRecord r) => r.id == id);
    if (index == -1) {
      return (
        success: false,
        message: 'Data perizinan tidak ditemukan.',
        record: null
      );
    }

    final AmanahPermissionRecord current = _records[index];
    if (current.status == AmanahPermissionStatus.disetujui) {
      return (
        success: false,
        message:
            'Izin yang telah disetujui oleh Direksi/HRD tidak dapat dibatalkan melalui aplikasi.',
        record: null
      );
    }

    if (current.status == AmanahPermissionStatus.dibatalkan) {
      return (
        success: false,
        message: 'Izin ini sudah dibatalkan sebelumnya.',
        record: null
      );
    }

    if (current.status == AmanahPermissionStatus.ditolak) {
      return (
        success: false,
        message: 'Izin yang telah ditolak tidak dapat dibatalkan.',
        record: null
      );
    }

    final AmanahPermissionRecord updated = current.copyWith(
      status: AmanahPermissionStatus.dibatalkan,
      cancelledAt: DateTime.now().toIso8601String(),
    );

    final List<AmanahPermissionRecord> updatedList =
        List<AmanahPermissionRecord>.from(_records);
    updatedList[index] = updated;
    _records = updatedList;
    notifyListeners();

    return (
      success: true,
      message: 'Pengajuan perizinan berhasil dibatalkan.',
      record: updated
    );
  }

  void clear() {
    _records = <AmanahPermissionRecord>[];
    notifyListeners();
  }

  void reset() {
    _records = List<AmanahPermissionRecord>.from(_seedRecords);
    notifyListeners();
  }
}
