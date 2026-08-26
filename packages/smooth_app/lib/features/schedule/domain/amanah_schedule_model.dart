import 'package:flutter/material.dart';

enum AmanahBadgeVariant {
  success,
  primary,
  warning,
  live,
  trend;

  Color get color {
    switch (this) {
      case AmanahBadgeVariant.success:
        return const Color(0xFF10B981);
      case AmanahBadgeVariant.primary:
        return const Color(0xFF0A44FF);
      case AmanahBadgeVariant.warning:
        return const Color(0xFFF59E0B);
      case AmanahBadgeVariant.live:
        return const Color(0xFF38BDF8);
      case AmanahBadgeVariant.trend:
        return const Color(0xFF8B5CF6);
    }
  }
}

class BookedPatient {
  const BookedPatient({
    required this.id,
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

  BookedPatient copyWith({
    String? id,
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
    required this.poli,
    required this.room,
    required this.slotCount,
    required this.slotText,
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
  final String poli;
  final String room;
  final String slotCount;
  final String slotText;
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
    String? slotCount,
    String? slotText,
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
      slotCount: slotCount ?? this.slotCount,
      slotText: slotText ?? this.slotText,
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
    required this.targetQuota,
    required this.isCuti,
    this.cutiReason,
  });

  final int targetQuota;
  final bool isCuti;
  final String? cutiReason;

  DayScheduleSetting copyWith({
    int? targetQuota,
    bool? isCuti,
    String? cutiReason,
  }) {
    return DayScheduleSetting(
      targetQuota: targetQuota ?? this.targetQuota,
      isCuti: isCuti ?? this.isCuti,
      cutiReason: cutiReason ?? this.cutiReason,
    );
  }
}
