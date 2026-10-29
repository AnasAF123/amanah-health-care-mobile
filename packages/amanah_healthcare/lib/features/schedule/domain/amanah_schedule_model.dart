enum AmanahBadgeVariant { success, primary, warning, live, trend }

class BookedPatient {
  const BookedPatient({
    required this.id,
    this.appointmentId,
    this.patientId,
    required this.patientName,
    required this.patientRm,
    required this.patientAge,
    required this.patientComplaint,
    required this.queueNumber,
    required this.timeSlot,
    required this.badge,
    required this.badgeVariant,
    this.avatarUrl,
    this.patientGuardian,
    this.poliklinikName,
    this.etaRange,
    this.actualStartedAt,
    this.actualCompletedAt,
    this.consultationDurationFormatted,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.status,
  });

  final String id;
  final String? appointmentId;
  final String? patientId;
  final String patientName;
  final String patientRm;
  final String patientAge;
  final String patientComplaint;
  final String queueNumber;
  final String timeSlot;
  final String badge;
  final AmanahBadgeVariant badgeVariant;
  final String? avatarUrl;
  final String? patientGuardian;
  final String? poliklinikName;
  final String? etaRange;
  final String? actualStartedAt;
  final String? actualCompletedAt;
  final String? consultationDurationFormatted;
  final String? scheduledStartTime;
  final String? scheduledEndTime;
  final String? status;

  bool get isCompleted {
    final String s = (status ?? badge).toUpperCase();
    return s == 'COMPLETED' || s == 'SELESAI';
  }

  String get etaDisplay {
    if (etaRange != null && etaRange!.trim().isNotEmpty) {
      return etaRange!;
    }
    return timeSlot;
  }

  String get effectiveAppointmentId =>
      (appointmentId != null && appointmentId!.isNotEmpty) ? appointmentId! : id;

  String get effectivePatientId => (patientId != null && patientId!.isNotEmpty) ? patientId! : id;

  BookedPatient copyWith({
    String? id,
    String? appointmentId,
    String? patientId,
    String? patientName,
    String? patientRm,
    String? patientAge,
    String? patientComplaint,
    String? queueNumber,
    String? timeSlot,
    String? badge,
    AmanahBadgeVariant? badgeVariant,
    String? avatarUrl,
    String? patientGuardian,
    String? poliklinikName,
    String? etaRange,
    String? actualStartedAt,
    String? actualCompletedAt,
    String? consultationDurationFormatted,
    String? scheduledStartTime,
    String? scheduledEndTime,
    String? status,
  }) {
    return BookedPatient(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientRm: patientRm ?? this.patientRm,
      patientAge: patientAge ?? this.patientAge,
      patientComplaint: patientComplaint ?? this.patientComplaint,
      queueNumber: queueNumber ?? this.queueNumber,
      timeSlot: timeSlot ?? this.timeSlot,
      badge: badge ?? this.badge,
      badgeVariant: badgeVariant ?? this.badgeVariant,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      patientGuardian: patientGuardian ?? this.patientGuardian,
      poliklinikName: poliklinikName ?? this.poliklinikName,
      etaRange: etaRange ?? this.etaRange,
      actualStartedAt: actualStartedAt ?? this.actualStartedAt,
      actualCompletedAt: actualCompletedAt ?? this.actualCompletedAt,
      consultationDurationFormatted:
          consultationDurationFormatted ?? this.consultationDurationFormatted,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      status: status ?? this.status,
    );
  }
}

class DoctorSchedule {
  const DoctorSchedule({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    this.poli,
    this.room,
    required this.badge,
    required this.badgeVariant,
    this.startTime,
    this.endTime,
    this.sessionType = 'Pagi',
    this.bookedPatients = const <BookedPatient>[],
    this.isReplacement = false,
    this.replacedStaffName,
  });

  final String id;
  final String title;
  final String date;
  final String time;
  final String? poli;
  final String? room;
  final String badge;
  final AmanahBadgeVariant badgeVariant;
  final String? startTime;
  final String? endTime;
  final String sessionType; // 'Pagi', 'Siang', 'Malam', 'Dini Hari'
  final List<BookedPatient> bookedPatients;
  final bool isReplacement;
  final String? replacedStaffName;

  DoctorSchedule copyWith({
    String? id,
    String? title,
    String? date,
    String? time,
    String? poli,
    String? room,
    String? badge,
    AmanahBadgeVariant? badgeVariant,
    String? startTime,
    String? endTime,
    String? sessionType,
    List<BookedPatient>? bookedPatients,
    bool? isReplacement,
    String? replacedStaffName,
  }) {
    return DoctorSchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      poli: poli ?? this.poli,
      room: room ?? this.room,
      badge: badge ?? this.badge,
      badgeVariant: badgeVariant ?? this.badgeVariant,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sessionType: sessionType ?? this.sessionType,
      bookedPatients: bookedPatients ?? this.bookedPatients,
      isReplacement: isReplacement ?? this.isReplacement,
      replacedStaffName: replacedStaffName ?? this.replacedStaffName,
    );
  }
}

class DayScheduleSetting {
  const DayScheduleSetting({required this.isCuti, this.cutiReason});

  final bool isCuti;
  final String? cutiReason;

  DayScheduleSetting copyWith({bool? isCuti, String? cutiReason}) {
    return DayScheduleSetting(
      isCuti: isCuti ?? this.isCuti,
      cutiReason: cutiReason ?? this.cutiReason,
    );
  }
}
