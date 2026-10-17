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

  String get effectiveAppointmentId =>
      (appointmentId != null && appointmentId!.isNotEmpty) ? appointmentId! : id;

  String get effectivePatientId =>
      (patientId != null && patientId!.isNotEmpty) ? patientId! : id;

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
    );
  }
}

class DayScheduleSetting {
  const DayScheduleSetting({
    required this.isCuti,
    this.cutiReason,
  });

  final bool isCuti;
  final String? cutiReason;

  DayScheduleSetting copyWith({
    bool? isCuti,
    String? cutiReason,
  }) {
    return DayScheduleSetting(
      isCuti: isCuti ?? this.isCuti,
      cutiReason: cutiReason ?? this.cutiReason,
    );
  }
}
