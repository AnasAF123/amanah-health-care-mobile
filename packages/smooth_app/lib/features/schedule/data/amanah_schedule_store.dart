import 'package:flutter/material.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';

class AmanahScheduleStore extends ChangeNotifier {
  AmanahScheduleStore._() {
    _schedulesMap = Map<String, List<DoctorSchedule>>.from(_initialSchedulesMap);
    _daySettingsMap = Map<String, DayScheduleSetting>.from(_initialDaySettings);
  }

  static final AmanahScheduleStore instance = AmanahScheduleStore._();

  static final DateTime baseToday = DateTime(2026, 8, 26);

  late Map<String, List<DoctorSchedule>> _schedulesMap;
  late Map<String, DayScheduleSetting> _daySettingsMap;

  Map<String, List<DoctorSchedule>> get schedulesMap => _schedulesMap;
  Map<String, DayScheduleSetting> get daySettingsMap => _daySettingsMap;

  static String formatDateKey(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<DoctorSchedule> getSchedulesForDate(DateTime date) {
    final String key = formatDateKey(date);
    return _schedulesMap[key] ?? const <DoctorSchedule>[];
  }

  DayScheduleSetting getDaySettingForDate(DateTime date) {
    final String key = formatDateKey(date);
    return _daySettingsMap[key] ??
        DayScheduleSetting(
          targetQuota: 8,
          isCuti: date.weekday == DateTime.sunday,
        );
  }

  List<({BookedPatient patient, DoctorSchedule schedule})>
      getAllBookedPatientsForDate(DateTime date) {
    final List<DoctorSchedule> schedules = getSchedulesForDate(date);
    final List<({BookedPatient patient, DoctorSchedule schedule})> list =
        <({BookedPatient patient, DoctorSchedule schedule})>[];
    for (final DoctorSchedule sch in schedules) {
      for (final BookedPatient p in sch.bookedPatients) {
        list.add((patient: p, schedule: sch));
      }
    }
    return list;
  }

  int getCapacityPercentage(DateTime date) {
    final DayScheduleSetting setting = getDaySettingForDate(date);
    if (setting.isCuti || setting.targetQuota <= 0) {
      return 0;
    }
    final int bookedCount = getAllBookedPatientsForDate(date).length;
    return ((bookedCount / setting.targetQuota) * 100).round().clamp(0, 100);
  }

  void addSchedule(DateTime date, DoctorSchedule schedule) {
    final String key = formatDateKey(date);
    final List<DoctorSchedule> current =
        List<DoctorSchedule>.from(_schedulesMap[key] ?? <DoctorSchedule>[]);
    current.add(schedule);
    _schedulesMap[key] = current;
    notifyListeners();
  }

  void updateSchedule(DateTime date, DoctorSchedule schedule) {
    final String key = formatDateKey(date);
    final List<DoctorSchedule> current =
        List<DoctorSchedule>.from(_schedulesMap[key] ?? <DoctorSchedule>[]);
    final int index = current.indexWhere((DoctorSchedule s) => s.id == schedule.id);
    if (index >= 0) {
      current[index] = schedule;
      _schedulesMap[key] = current;
      notifyListeners();
    }
  }

  void deleteSchedule(DateTime date, String scheduleId) {
    final String key = formatDateKey(date);
    final List<DoctorSchedule> current =
        List<DoctorSchedule>.from(_schedulesMap[key] ?? <DoctorSchedule>[]);
    current.removeWhere((DoctorSchedule s) => s.id == scheduleId);
    _schedulesMap[key] = current;
    notifyListeners();
  }

  void setDayCuti(DateTime date, bool isCuti, {String? cutiReason}) {
    final String key = formatDateKey(date);
    final DayScheduleSetting current = getDaySettingForDate(date);
    _daySettingsMap[key] = current.copyWith(
      isCuti: isCuti,
      cutiReason: cutiReason ?? (isCuti ? 'Dokter Cuti Praktik' : null),
    );
    notifyListeners();
  }

  void reset() {
    _schedulesMap = Map<String, List<DoctorSchedule>>.from(_initialSchedulesMap);
    _daySettingsMap = Map<String, DayScheduleSetting>.from(_initialDaySettings);
    notifyListeners();
  }

  // 1:1 Initial Data from Web store
  static final Map<String, List<DoctorSchedule>> _initialSchedulesMap =
      <String, List<DoctorSchedule>>{
    '2026-08-26': <DoctorSchedule>[
      const DoctorSchedule(
        id: 'ses-1',
        title: 'Sesi Pagi',
        date: 'Rabu, 26 Agustus 2026',
        time: '07:00 - 11:00 WIB',
        startTime: '07:00',
        endTime: '11:00',
        sessionType: 'Pagi',
        poli: 'Poli Gigi & Mulut',
        room: 'Ruang 201',
        slotCount: '2',
        slotText: '2 Pasien Booking',
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
        bookedPatients: <BookedPatient>[
          BookedPatient(
            id: 'p-1',
            patientName: 'Steven Pratama',
            avatarUrl:
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
            patientAge: '28 Thn',
            patientRm: 'RM-2026-0412',
            patientComplaint:
                'Pembersihan karang gigi (scaling) & tambal gigi geraham belakang',
            queueNumber: '#01',
            timeSlot: '08:00 - 09:30 WIB',
            badge: 'Aktif',
            badgeVariant: AmanahBadgeVariant.success,
          ),
          BookedPatient(
            id: 'p-2',
            patientName: 'An. Kevin Sanjaya',
            avatarUrl:
                'https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?q=80&w=300&auto=format&fit=crop',
            patientAge: '7 Thn',
            patientRm: 'RM-2026-0523',
            patientGuardian: 'Bpk. Budi Sanjaya (Ayah)',
            patientComplaint: 'Cabut gigi susu goyang & aplikasi fluoride',
            queueNumber: '#02',
            timeSlot: '10:00 - 11:00 WIB',
            badge: 'Mendatang',
            badgeVariant: AmanahBadgeVariant.primary,
          ),
        ],
      ),
      const DoctorSchedule(
        id: 'ses-2',
        title: 'Sesi Siang',
        date: 'Rabu, 26 Agustus 2026',
        time: '13:00 - 17:00 WIB',
        startTime: '13:00',
        endTime: '17:00',
        sessionType: 'Siang',
        poli: 'Klinik Spesialis Konservasi',
        room: 'Ruang 204',
        slotCount: '1',
        slotText: '1 Pasien Booking',
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
        bookedPatients: <BookedPatient>[
          BookedPatient(
            id: 'p-3',
            patientName: 'Ibu Ratna Dewi',
            avatarUrl:
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=300&auto=format&fit=crop',
            patientAge: '42 Thn',
            patientRm: 'RM-2026-0789',
            patientComplaint:
                'Perawatan saluran akar lanjutan tahap 2 & persiapan crown',
            queueNumber: '#01',
            timeSlot: '13:30 - 15:00 WIB',
            badge: 'Mendatang',
            badgeVariant: AmanahBadgeVariant.primary,
          ),
        ],
      ),
      const DoctorSchedule(
        id: 'ses-3',
        title: 'Sesi Malam',
        date: 'Rabu, 26 Agustus 2026',
        time: '19:00 - 22:00 WIB',
        startTime: '19:00',
        endTime: '22:00',
        sessionType: 'Malam',
        poli: 'Klinik Eksekutif VIP',
        room: 'Suite VIP 01',
        slotCount: '1',
        slotText: '1 Pasien Booking',
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
        bookedPatients: <BookedPatient>[
          BookedPatient(
            id: 'p-4',
            patientName: 'Andi Budiman',
            avatarUrl:
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop',
            patientAge: '34 Thn',
            patientRm: 'RM-2026-0811',
            patientComplaint:
                'Pemeriksaan estetika veneer & konsultasi clear aligner',
            queueNumber: '#01',
            timeSlot: '19:30 - 21:00 WIB',
            badge: 'Mendatang',
            badgeVariant: AmanahBadgeVariant.primary,
          ),
        ],
      ),
    ],
    '2026-08-27': <DoctorSchedule>[
      const DoctorSchedule(
        id: 'ses-4',
        title: 'Sesi Pagi',
        date: 'Kamis, 27 Agustus 2026',
        time: '08:00 - 12:00 WIB',
        startTime: '08:00',
        endTime: '12:00',
        sessionType: 'Pagi',
        poli: 'Poli Gigi Umum',
        room: 'Ruang 201',
        slotCount: '1',
        slotText: '1 Pasien Booking',
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
        bookedPatients: <BookedPatient>[
          BookedPatient(
            id: 'p-5',
            patientName: 'Rafi Ahmad',
            avatarUrl:
                'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?q=80&w=300&auto=format&fit=crop',
            patientAge: '35 Thn',
            patientRm: 'RM-2026-0911',
            patientComplaint: 'Pemeriksaan rutin & scaling berkala',
            queueNumber: '#01',
            timeSlot: '09:00 - 10:30 WIB',
            badge: 'Mendatang',
            badgeVariant: AmanahBadgeVariant.primary,
          ),
        ],
      ),
      const DoctorSchedule(
        id: 'ses-5',
        title: 'Sesi Siang',
        date: 'Kamis, 27 Agustus 2026',
        time: '13:00 - 17:00 WIB',
        startTime: '13:00',
        endTime: '17:00',
        sessionType: 'Siang',
        poli: 'Spesialis Bedah Mulut',
        room: 'Ruang Tindakan 2',
        slotCount: '1',
        slotText: '1 Pasien Booking',
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
        bookedPatients: <BookedPatient>[
          BookedPatient(
            id: 'p-6',
            patientName: 'Bpk. Hendra Gunawan',
            avatarUrl:
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=300&auto=format&fit=crop',
            patientAge: '49 Thn',
            patientRm: 'RM-2026-1044',
            patientComplaint: 'Tindakan odontektomi gigi bungsu impaksi',
            queueNumber: '#01',
            timeSlot: '14:00 - 15:30 WIB',
            badge: 'Mendatang',
            badgeVariant: AmanahBadgeVariant.primary,
          ),
        ],
      ),
    ],
    '2026-08-28': <DoctorSchedule>[
      const DoctorSchedule(
        id: 'ses-6',
        title: 'Sesi Pagi',
        date: 'Jumat, 28 Agustus 2026',
        time: '08:00 - 11:30 WIB',
        startTime: '08:00',
        endTime: '11:30',
        sessionType: 'Pagi',
        poli: 'Telemedisin Gigi',
        room: 'Studio D-02',
        slotCount: '1',
        slotText: '1 Pasien Booking',
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
        bookedPatients: <BookedPatient>[
          BookedPatient(
            id: 'p-7',
            patientName: 'Nadia Saphira',
            avatarUrl:
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=300&auto=format&fit=crop',
            patientAge: '24 Thn',
            patientRm: 'RM-2026-1120',
            patientComplaint:
                'Konsultasi rencana kawat gigi / clear aligner estetika',
            queueNumber: '#01',
            timeSlot: '08:30 - 10:00 WIB',
            badge: 'Mendatang',
            badgeVariant: AmanahBadgeVariant.primary,
          ),
        ],
      ),
    ],
    '2026-08-29': <DoctorSchedule>[
      const DoctorSchedule(
        id: 'ses-7',
        title: 'Sesi Pagi',
        date: 'Sabtu, 29 Agustus 2026',
        time: '09:00 - 12:00 WIB',
        startTime: '09:00',
        endTime: '12:00',
        sessionType: 'Pagi',
        poli: 'Poli Eksekutif VIP',
        room: 'Suite VIP 02',
        slotCount: '1',
        slotText: '1 Pasien Booking',
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
        bookedPatients: <BookedPatient>[
          BookedPatient(
            id: 'p-8',
            patientName: 'drg. Maya Kusuma (VIP)',
            avatarUrl:
                'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=300&auto=format&fit=crop',
            patientAge: '31 Thn',
            patientRm: 'RM-2026-1205',
            patientComplaint:
                'Pemasangan bleaching / pemutihan gigi & fluoride polish',
            queueNumber: '#01',
            timeSlot: '09:00 - 11:00 WIB',
            badge: 'Mendatang',
            badgeVariant: AmanahBadgeVariant.primary,
          ),
        ],
      ),
    ],
    '2026-08-31': <DoctorSchedule>[
      const DoctorSchedule(
        id: 'ses-8',
        title: 'Sesi Pagi',
        date: 'Senin, 31 Agustus 2026',
        time: '08:30 - 12:00 WIB',
        startTime: '08:30',
        endTime: '12:00',
        sessionType: 'Pagi',
        poli: 'Poli Gigi & Mulut',
        room: 'Ruang 201',
        slotCount: '1',
        slotText: '1 Pasien Booking',
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
        bookedPatients: <BookedPatient>[
          BookedPatient(
            id: 'p-9',
            patientName: 'Farhan Maulana',
            avatarUrl:
                'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=300&auto=format&fit=crop',
            patientAge: '29 Thn',
            patientRm: 'RM-2026-1310',
            patientComplaint: 'Penambalan gigi berlubang & konsultasi',
            queueNumber: '#01',
            timeSlot: '08:30 - 10:00 WIB',
            badge: 'Mendatang',
            badgeVariant: AmanahBadgeVariant.primary,
          ),
        ],
      ),
    ],
  };

  static final Map<String, DayScheduleSetting> _initialDaySettings =
      <String, DayScheduleSetting>{
    '2026-08-26': const DayScheduleSetting(targetQuota: 8, isCuti: false),
    '2026-08-27': const DayScheduleSetting(targetQuota: 6, isCuti: false),
    '2026-08-28': const DayScheduleSetting(targetQuota: 6, isCuti: false),
    '2026-08-29': const DayScheduleSetting(targetQuota: 10, isCuti: false),
    '2026-08-30': const DayScheduleSetting(
      targetQuota: 0,
      isCuti: true,
      cutiReason: 'Cuti Akhir Pekan / Hari Libur Nasional',
    ),
    '2026-08-31': const DayScheduleSetting(targetQuota: 8, isCuti: false),
  };
}
