import 'package:amanah_healthcare/features/schedule/domain/booked_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/schedule_shift_constants.dart';

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
    this.scheduleDate,
    this.roomId,
    this.poliklinikId,
    this.serviceId,
    this.capacity = 8,
    this.availableSlots,
    this.bookedPatientCount = 0,
    this.isAvailable = true,
    this.isPast = false,
    this.notes,
    this.sessionShift = 'morning',
    this.version,
    this.staffId,
    this.practitionerId,
    this.doctorName,
    this.isRescheduleEligible = true,
    this.rescheduleIneligibilityReason,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    final String sessionShift = json['sessionShift'] as String? ??
        (json['nama_sesi'] != null
            ? (CanonicalShift.tryResolve(json['nama_sesi'] as String)?.code ??
                CanonicalShift.morning.code)
            : CanonicalShift.morning.code);
    final CanonicalShift canonicalShift =
        CanonicalShift.tryResolve(sessionShift) ??
        CanonicalShift.tryResolve(json['nama_sesi'] as String? ?? '') ??
        CanonicalShift.morning;
    final String sessionLabel = json['sessionLabel'] as String? ??
        json['nama_sesi'] as String? ??
        canonicalShift.label;
    final String sessionTypeTitle = 'Sesi $sessionLabel';

    final String? startTime =
        json['startTime'] as String? ?? json['jam_mulai'] as String?;
    final String? endTime =
        json['endTime'] as String? ?? json['jam_selesai'] as String?;
    final String? rawWaktu =
        json['timeRange'] as String? ?? json['waktu'] as String?;
    final String timeStr = rawWaktu != null
        ? (rawWaktu.endsWith('WIB') ? rawWaktu : '$rawWaktu WIB')
        : (startTime != null && endTime != null
            ? '$startTime - $endTime WIB'
            : '${canonicalShift.defaultStartTime} - ${canonicalShift.defaultEndTime} WIB');

    final String scheduleDate = json['scheduleDate'] as String? ??
        json['specificDate'] as String? ??
        json['date'] as String? ??
        '';

    final String? version = json['version'] as String?;
    final String rawStatus = (json['rawStatus'] as String? ??
            json['status'] as String? ??
            json['status_sesi'] as String? ??
            json['status_dokter'] as String? ??
            '')
        .toUpperCase();
    final bool isAvailable = json['isAvailable'] as bool? ??
        (rawStatus != ScheduleCanonicalStatus.closed &&
            rawStatus != ScheduleCanonicalStatus.tutup);

    final int capacity = json['capacity'] as int? ??
        json['kuota_pasien'] as int? ??
        json['kapasitas_per_hari'] as int? ??
        8;

    final List<dynamic>? bookedPatientsRaw =
        json['bookedPatients'] as List<dynamic>?;
    final List<BookedPatient> bookedPatients = bookedPatientsRaw != null
        ? bookedPatientsRaw
            .whereType<Map<String, dynamic>>()
            .map(BookedPatient.fromJson)
            .toList()
        : <BookedPatient>[];

    final int bookedPatientCount = json['bookedPatientCount'] as int? ??
        json['pasien_terdaftar'] as int? ??
        bookedPatients.where((BookedPatient p) => !p.isCancelled).length;

    final int availableSlots = json['availableSlots'] as int? ??
        json['slot_tersedia'] as int? ??
        (capacity - bookedPatientCount).clamp(0, capacity);

    final String? backendBadge = json['statusBadge'] as String?;
    final String? backendVariant = json['badgeVariant'] as String?;
    final bool isPast = json['isPast'] as bool? ?? false;

    final String badge;
    final AmanahBadgeVariant badgeVariant;
    if (backendBadge != null && backendBadge.isNotEmpty) {
      badge = backendBadge;
      if (backendVariant == 'warning') {
        badgeVariant = AmanahBadgeVariant.warning;
      } else if (backendVariant == 'primary') {
        badgeVariant = AmanahBadgeVariant.primary;
      } else {
        badgeVariant = AmanahBadgeVariant.success;
      }
    } else if (isPast) {
      badge = ScheduleFormConstants.badgeSelesai;
      badgeVariant = AmanahBadgeVariant.warning;
    } else if (!isAvailable ||
        rawStatus == ScheduleCanonicalStatus.closed ||
        rawStatus == ScheduleCanonicalStatus.tutup) {
      badge = ScheduleFormConstants.statusTutup;
      badgeVariant = AmanahBadgeVariant.warning;
    } else if (availableSlots == 0 ||
        rawStatus == ScheduleCanonicalStatus.occupied ||
        rawStatus == ScheduleCanonicalStatus.terisi) {
      badge = ScheduleFormConstants.badgePenuh;
      badgeVariant = AmanahBadgeVariant.primary;
    } else if (bookedPatientCount > 0) {
      badge = ScheduleFormConstants.badgeTerisi;
      badgeVariant = AmanahBadgeVariant.primary;
    } else {
      badge = ScheduleFormConstants.statusBuka;
      badgeVariant = AmanahBadgeVariant.success;
    }

    final String? staffId =
        json['staffId'] as String? ?? json['staff_id'] as String?;
    final String? practitionerId = json['practitionerId'] as String? ??
        json['practitioner_id'] as String? ??
        json['doctorId'] as String? ??
        json['doctor_id'] as String?;
    final String? doctorName = json['doctorName'] as String? ??
        json['doctor_name'] as String? ??
        json['nama_dokter'] as String?;
    final bool isRescheduleEligible =
        json['isRescheduleEligible'] as bool? ??
            json['is_reschedule_eligible'] as bool? ??
            true;
    final String? rescheduleIneligibilityReason =
        json['rescheduleIneligibilityReason'] as String? ??
            json['reschedule_ineligibility_reason'] as String?;

    final String poli = json['poliklinikName'] as String? ??
        json['spesialisasi'] as String? ??
        json['poli'] as String? ??
        '';

    final String room = json['roomName'] as String? ??
        json['ruang'] as String? ??
        json['ruang_praktik'] as String? ??
        '';

    return DoctorSchedule(
      id: json['id'] as String? ?? '',
      title: sessionTypeTitle,
      date: scheduleDate,
      time: timeStr,
      poli: poli,
      room: room,
      slotCount: bookedPatientCount.toString(),
      slotText: '$bookedPatientCount Pasien Booking',
      badge: badge,
      badgeVariant: badgeVariant,
      startTime: startTime,
      endTime: endTime,
      sessionType: sessionLabel,
      bookedPatients: bookedPatients,
      scheduleDate: scheduleDate,
      roomId: json['roomId'] as String?,
      poliklinikId: json['poliklinikId'] as String?,
      serviceId: json['serviceId'] as String?,
      capacity: capacity,
      availableSlots: availableSlots,
      bookedPatientCount: bookedPatientCount,
      isAvailable: isAvailable,
      isPast: isPast,
      notes: json['notes'] as String?,
      sessionShift: sessionShift,
      version: version,
      staffId: staffId,
      practitionerId: practitionerId,
      doctorName: doctorName,
      isRescheduleEligible: isRescheduleEligible,
      rescheduleIneligibilityReason: rescheduleIneligibilityReason,
    );
  }

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
  final String sessionType;
  final List<BookedPatient> bookedPatients;
  final String? scheduleDate;
  final String? roomId;
  final String? poliklinikId;
  final String? serviceId;
  final int capacity;
  final int? availableSlots;
  final int bookedPatientCount;
  final bool isAvailable;
  final bool isPast;
  final String? notes;
  final String sessionShift;
  final String? version;
  final String? staffId;
  final String? practitionerId;
  final String? doctorName;
  final bool isRescheduleEligible;
  final String? rescheduleIneligibilityReason;

  String get doctorId => (practitionerId != null && practitionerId!.isNotEmpty)
      ? practitionerId!
      : (staffId ?? '');
  String get sessionId => id;

  String get canonicalStatus => (badge == ScheduleFormConstants.statusTutup || !isAvailable)
      ? ScheduleCanonicalStatus.closed
      : (badge == ScheduleFormConstants.badgeTerisi ||
              badge == ScheduleFormConstants.badgePenuh ||
              bookedPatientCount > 0
          ? ScheduleCanonicalStatus.occupied
          : ScheduleCanonicalStatus.open);

  String get mutationStatus =>
      (badge == ScheduleFormConstants.statusTutup || !isAvailable)
          ? ScheduleCanonicalStatus.closed
          : ScheduleCanonicalStatus.open;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'scheduleDate': scheduleDate ?? date,
      'session': sessionType.toUpperCase(),
      'sessionLabel': sessionType,
      'sessionShift': sessionShift,
      'startTime': startTime,
      'endTime': endTime,
      'timeRange': time,
      'poliklinikId': poliklinikId,
      'poliklinikName': poli,
      'roomId': roomId,
      'roomName': room,
      'serviceId': serviceId,
      'capacity': capacity,
      'availableSlots': availableSlots,
      'bookedPatientCount': bookedPatientCount,
      'isAvailable': isAvailable,
      'isPast': isPast,
      'status': canonicalStatus,
      'status_sesi': mutationStatus,
      'badge': badge,
      'notes': notes,
      'version': version,
      'staffId': staffId,
      'practitionerId': practitionerId,
      'doctorName': doctorName,
      'isRescheduleEligible': isRescheduleEligible,
      'rescheduleIneligibilityReason': rescheduleIneligibilityReason,
      'bookedPatients': bookedPatients.map((BookedPatient p) => p.toJson()).toList(),
    };
  }

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
    String? scheduleDate,
    String? roomId,
    String? poliklinikId,
    String? serviceId,
    int? capacity,
    int? availableSlots,
    int? bookedPatientCount,
    bool? isAvailable,
    bool? isPast,
    String? notes,
    String? sessionShift,
    String? version,
    String? staffId,
    String? practitionerId,
    String? doctorName,
    bool? isRescheduleEligible,
    String? rescheduleIneligibilityReason,
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
      scheduleDate: scheduleDate ?? this.scheduleDate,
      roomId: roomId ?? this.roomId,
      poliklinikId: poliklinikId ?? this.poliklinikId,
      serviceId: serviceId ?? this.serviceId,
      capacity: capacity ?? this.capacity,
      availableSlots: availableSlots ?? this.availableSlots,
      bookedPatientCount: bookedPatientCount ?? this.bookedPatientCount,
      isAvailable: isAvailable ?? this.isAvailable,
      isPast: isPast ?? this.isPast,
      notes: notes ?? this.notes,
      sessionShift: sessionShift ?? this.sessionShift,
      version: version ?? this.version,
      staffId: staffId ?? this.staffId,
      practitionerId: practitionerId ?? this.practitionerId,
      doctorName: doctorName ?? this.doctorName,
      isRescheduleEligible: isRescheduleEligible ?? this.isRescheduleEligible,
      rescheduleIneligibilityReason:
          rescheduleIneligibilityReason ?? this.rescheduleIneligibilityReason,
    );
  }
}
