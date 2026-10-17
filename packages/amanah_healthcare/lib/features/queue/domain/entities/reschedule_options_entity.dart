/// Domain entity representing dynamic reschedule options from the backend.
class RescheduleShiftOption {
  const RescheduleShiftOption({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.shift,
    required this.sessionShift,
    required this.loadStatus,
    required this.isAvailable,
  });

  final String sessionId;
  final String startTime;
  final String endTime;
  final String shift;
  final String sessionShift;
  final String loadStatus;
  final bool isAvailable;

  factory RescheduleShiftOption.fromJson(Map<String, dynamic> json) {
    return RescheduleShiftOption(
      sessionId: json['sessionId']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '08:00',
      endTime: json['endTime']?.toString() ?? '12:00',
      shift: json['shift']?.toString() ?? 'Shift Pagi',
      sessionShift: json['sessionShift']?.toString() ?? 'morning',
      loadStatus: json['loadStatus']?.toString() ?? 'NORMAL',
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}

class RescheduleDateOption {
  const RescheduleDateOption({
    required this.date,
    required this.shifts,
  });

  final String date;
  final List<RescheduleShiftOption> shifts;

  factory RescheduleDateOption.fromJson(Map<String, dynamic> json) {
    final dynamic rawShifts = json['shifts'];
    final List<RescheduleShiftOption> shifts = <RescheduleShiftOption>[];
    if (rawShifts is List) {
      for (final dynamic item in rawShifts) {
        if (item is Map<String, dynamic>) {
          shifts.add(RescheduleShiftOption.fromJson(item));
        }
      }
    }
    return RescheduleDateOption(
      date: json['date']?.toString() ?? '',
      shifts: shifts,
    );
  }
}

class RescheduleOptionsEntity {
  const RescheduleOptionsEntity({
    required this.appointmentId,
    required this.currentDate,
    required this.patientName,
    required this.doctorName,
    required this.serviceName,
    required this.availableDates,
  });

  final String appointmentId;
  final String? currentDate;
  final String patientName;
  final String doctorName;
  final String serviceName;
  final List<RescheduleDateOption> availableDates;

  factory RescheduleOptionsEntity.fromJson(Map<String, dynamic> json) {
    final dynamic rawDates = json['availableDates'];
    final List<RescheduleDateOption> dates = <RescheduleDateOption>[];
    if (rawDates is List) {
      for (final dynamic item in rawDates) {
        if (item is Map<String, dynamic>) {
          dates.add(RescheduleDateOption.fromJson(item));
        }
      }
    }

    final dynamic patient = json['patient'];
    final String patientName =
        patient is Map ? patient['name']?.toString() ?? 'Pasien' : 'Pasien';

    final dynamic doctor = json['doctor'];
    final String doctorName =
        doctor is Map ? doctor['name']?.toString() ?? 'Dokter' : 'Dokter';

    final dynamic service = json['service'];
    final String serviceName =
        service is Map ? service['name']?.toString() ?? 'Layanan' : 'Layanan';

    return RescheduleOptionsEntity(
      appointmentId: json['appointmentId']?.toString() ?? '',
      currentDate: json['currentDate']?.toString(),
      patientName: patientName,
      doctorName: doctorName,
      serviceName: serviceName,
      availableDates: dates,
    );
  }
}
