import 'package:amanah_healthcare/core/time/functions/format_localized_date.dart';

class ReplacementItem {
  const ReplacementItem({
    required this.id,
    required this.leaveRequestId,
    required this.sessionId,
    required this.workDate,
    required this.originalStaffProfileId,
    this.originalPractitionerId,
    this.originalStaffName,
    this.originalStaffRole,
    this.originalStaffAvatarUrl,
    this.leaveReason,
    this.claimedByStaffProfileId,
    this.claimedByPractitionerId,
    this.claimedByName,
    this.claimedByRole,
    this.claimedByAvatarUrl,
    required this.status, // 'open' | 'claimed' | 'cancelled' | 'completed'
    this.claimedAt,
    required this.createdAt,
    this.sessionCode,
    this.sessionLabel,
    this.startTime,
    this.endTime,
  });

  final String id;
  final String leaveRequestId;
  final String sessionId;
  final String workDate;
  final String originalStaffProfileId;
  final String? originalPractitionerId;
  final String? originalStaffName;
  final String? originalStaffRole;
  final String? originalStaffAvatarUrl;
  final String? leaveReason;
  final String? claimedByStaffProfileId;
  final String? claimedByPractitionerId;
  final String? claimedByName;
  final String? claimedByRole;
  final String? claimedByAvatarUrl;
  final String status;
  final DateTime? claimedAt;
  final DateTime createdAt;
  final String? sessionCode;
  final String? sessionLabel;
  final String? startTime;
  final String? endTime;

  bool get isOpen => status == 'open';
  bool get isClaimed => status == 'claimed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get startTimeShort {
    if (startTime != null && startTime!.length >= 5) {
      return startTime!.substring(0, 5);
    }
    return '--:--';
  }

  String get endTimeShort {
    if (endTime != null && endTime!.length >= 5) {
      return endTime!.substring(0, 5);
    }
    return '--:--';
  }

  String statusBadgeText(String? currentStaffProfileId, String? currentUserName) {
    if (isOpen) {
      return 'Terbuka';
    }
    if (isClaimedByMe(currentStaffProfileId) ||
        (currentUserName != null &&
            currentUserName.isNotEmpty &&
            claimedByName == currentUserName)) {
      return 'Jadwal Anda';
    }
    return 'Diklaim';
  }

  String get formattedWorkDate {
    try {
      final DateTime dt = DateTime.parse(workDate);
      return formatLocalizedDate(dt, style: 'human_full');
    } catch (_) {
      return workDate;
    }
  }

  String get formattedTimeRange {
    if (startTime != null && endTime != null) {
      final String s =
          startTime!.length >= 5 ? startTime!.substring(0, 5) : startTime!;
      final String e =
          endTime!.length >= 5 ? endTime!.substring(0, 5) : endTime!;
      return '$s - $e WIB';
    }
    return 'Waktu dinas mengikuti roster';
  }

  bool isClaimedByMe(String? currentStaffProfileId) =>
      isClaimed &&
      currentStaffProfileId != null &&
      claimedByStaffProfileId == currentStaffProfileId;

  bool isClaimedByOther(String? currentStaffProfileId) =>
      isClaimed &&
      (currentStaffProfileId == null ||
          claimedByStaffProfileId != currentStaffProfileId);
}
