import 'dart:math';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';

class AmanahPermissionStore extends ChangeNotifier {
  AmanahPermissionStore._() {
    _records = <AmanahPermissionRecord>[];
  }

  static final AmanahPermissionStore instance = AmanahPermissionStore._();

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
    String doctorName = '',
    String doctorRole = '',
    String userId = '',
    String userAvatarUrl = '',
  }) {
    final int duration = durationDays ?? calculateDays(startDate, endDate);
    final String randomSuffix =
        (Random().nextInt(9000) + 1000).toString();
    final AmanahPermissionRecord newRecord = AmanahPermissionRecord(
      id: 'perm_${DateTime.now().millisecondsSinceEpoch}_$randomSuffix',
      userId: userId,
      userName: doctorName,
      userRole: doctorRole,
      userAvatarUrl: userAvatarUrl,
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
    _records = <AmanahPermissionRecord>[];
    notifyListeners();
  }
}
