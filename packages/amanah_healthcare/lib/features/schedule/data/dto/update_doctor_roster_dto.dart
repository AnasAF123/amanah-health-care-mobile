class UpdateDoctorRosterAssignmentDto {
  const UpdateDoctorRosterAssignmentDto({
    required this.dow,
    required this.sessionId,
    required this.isActive,
    this.preferredRoomId,
  });

  final int dow;
  final String sessionId;
  final bool isActive;
  final String? preferredRoomId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dow': dow,
      'sessionId': sessionId,
      'isActive': isActive,
      'preferredRoomId': preferredRoomId,
    };
  }
}

class UpdateDoctorRosterDto {
  const UpdateDoctorRosterDto({
    required this.assignments,
    this.reason,
  });

  final List<UpdateDoctorRosterAssignmentDto> assignments;
  final String? reason;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'assignments': assignments.map((a) => a.toJson()).toList(),
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
    };
  }
}
