import 'package:amanah_healthcare/features/queue/domain/entities/queue_patient_card.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_session_info.dart';

class QueuePatientMapper {
  QueuePatientMapper._();

  static QueuePatientCard fromJson(
    Map<String, dynamic> json, {
    String? sessionRoom,
    String? sessionPoly,
    String? defaultDoctorName,
  }) {
    final Map<String, dynamic>? patientMap = json['patient'] is Map<String, dynamic>
        ? json['patient'] as Map<String, dynamic>
        : null;

    final String rawQueue = json['queueNumber']?.toString() ?? 'A01';
    final String cleanQueue = rawQueue.replaceAll('#', '').trim();
    final String queueNumber = '#$cleanQueue';

    final String patientName =
        patientMap?['fullName'] as String? ?? json['patientName'] as String? ?? '';

    final String complaint =
        json['chiefComplaint'] as String? ?? json['complaint'] as String? ?? '';

    final String poly = json['poliklinikName'] as String? ?? sessionPoly ?? '';

    final String room =
        json['clinicRoomName'] as String? ?? json['roomName'] as String? ?? sessionRoom ?? '';

    final String doctorName = json['doctorName'] as String? ?? defaultDoctorName ?? '';

    final String priority = (json['priority'] == 'urgent' || json['priority'] == 'high')
        ? 'Prioritas'
        : 'Reguler';

    final String timeSlot =
        json['etaRange'] as String? ?? json['timeSlot'] as String? ?? '08:00 - 08:30';

    int age = 30;
    final dynamic ageRaw = patientMap?['age'] ?? json['age'];
    if (ageRaw is int) {
      age = ageRaw;
    } else if (ageRaw is String) {
      final RegExp match = RegExp(r'\d+');
      final RegExpMatch? m = match.firstMatch(ageRaw);
      if (m != null) {
        age = int.tryParse(m.group(0) ?? '') ?? 30;
      }
    }

    final String genderRaw =
        patientMap?['gender'] as String? ?? json['gender'] as String? ?? 'male';
    final String gender = genderRaw.toLowerCase().startsWith('f') || genderRaw == 'p' ? 'P' : 'L';

    final String status = json['status'] as String? ?? 'waiting';

    final String patientRm =
        patientMap?['medicalRecordNumber'] as String? ??
        json['patientRm'] as String? ??
        'RM-2026-${cleanQueue.padLeft(4, '0')}';

    final String? guardian = patientMap?['guardianName'] as String? ?? json['guardian'] as String?;

    final List<String> allowedActions =
        (json['allowedActions'] as List<dynamic>?)?.map((dynamic e) => e.toString()).toList() ??
        const <String>[];

    final String aptId =
        json['appointmentId'] as String? ??
        (patientMap != null ? json['id'] as String? : null) ??
        json['id'] as String? ??
        '';
    final String pId = patientMap?['id'] as String? ?? json['patientId'] as String? ?? '';

    final String? patientAvatar =
        patientMap?['avatarUrl'] as String? ??
        patientMap?['patientAvatar'] as String? ??
        json['patientAvatar'] as String? ??
        json['avatarUrl'] as String?;

    return QueuePatientCard(
      id: aptId,
      appointmentId: aptId,
      patientId: pId.isNotEmpty ? pId : null,
      queueNumber: queueNumber,
      patientName: patientName,
      complaint: complaint,
      poly: poly,
      room: room,
      doctorName: doctorName,
      doctorImage: 'assets/amanah/avatar.png',
      priority: priority,
      timeSlot: timeSlot,
      age: age,
      gender: gender,
      status: status,
      patientRm: patientRm,
      guardian: guardian,
      avatarUrl: patientAvatar,
      allowedActions: allowedActions,
    );
  }

  static QueueSessionInfo sessionFromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? clinicRoom = json['clinicRoom'] is Map<String, dynamic>
        ? json['clinicRoom'] as Map<String, dynamic>
        : null;

    final String resolvedCode = json['sessionCode'] as String? ?? json['session']?.toString() ?? '';
    final String resolvedLabel =
        json['sessionLabel'] as String? ??
        json['title'] as String? ??
        (resolvedCode.isNotEmpty ? resolvedCode : 'Sesi Praktik');

    return QueueSessionInfo(
      sessionId: json['sessionId'] as String? ?? json['id'] as String? ?? '',
      sessionCode: resolvedCode,
      sessionLabel: resolvedLabel,
      scheduleDate: json['scheduleDate'] as String? ?? json['specificDate'] as String? ?? '',
      startTime: (json['startTime'] as String? ?? '08:00').sliceTime(),
      endTime: (json['endTime'] as String? ?? '12:00').sliceTime(),
      roomName: json['roomName'] as String? ?? clinicRoom?['name'] as String? ?? '',
      poliklinikName: json['poliklinikName'] as String? ?? '',
      bookedCount: json['bookedCount'] as int? ?? json['totalBookedPatients'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}

extension on String {
  String sliceTime() {
    if (length >= 5) return substring(0, 5);
    return this;
  }
}
