import 'package:smooth_app/features/presence/domain/amanah_presence_model.dart';

const List<AttendanceRecord> kAttendanceRecords = <AttendanceRecord>[
  AttendanceRecord(
    id: '101',
    date: '25 Ags 2026',
    dayNumber: 25,
    time: '07:30 WIB',
    title: 'Check-in',
    location: 'Poli Penyakit Dalam - Ruang 204',
    status: AttendanceStatus.hadir,
    isLatest: true,
  ),
  AttendanceRecord(
    id: '102',
    date: '24 Ags 2026',
    dayNumber: 24,
    time: '08:18 WIB',
    title: 'Terlambat',
    location: 'Poli Spesialis Anak',
    status: AttendanceStatus.telat,
    lateDuration: 'Terlambat 18 Menit',
  ),
  AttendanceRecord(
    id: '103',
    date: '23 Ags 2026',
    dayNumber: 23,
    time: '20:00 WIB',
    title: 'Missed',
    location: 'Gedung B - IGD Utama',
    status: AttendanceStatus.missed,
  ),
  AttendanceRecord(
    id: '104',
    date: '22 Ags 2026',
    dayNumber: 22,
    time: '08:00 WIB',
    title: 'Cuti',
    location: 'Izin Resmi RS (Approved)',
    status: AttendanceStatus.cuti,
    reason: 'Simposium Kedokteran Spesialis Penyakit Dalam Tahunan di Jakarta.',
  ),
  AttendanceRecord(
    id: '105',
    date: '20 Ags 2026',
    dayNumber: 20,
    time: '07:45 WIB',
    title: 'Check-in',
    location: 'Bangsal Cempaka Lt. 3',
    status: AttendanceStatus.hadir,
  ),
  AttendanceRecord(
    id: '106',
    date: '19 Ags 2026',
    dayNumber: 19,
    time: '08:10 WIB',
    title: 'Terlambat',
    location: 'Klinik Eksekutif Suite 01',
    status: AttendanceStatus.telat,
    lateDuration: 'Terlambat 10 Menit',
  ),
  AttendanceRecord(
    id: '107',
    date: '18 Ags 2026',
    dayNumber: 18,
    time: '08:00 WIB',
    title: 'Cuti',
    location: 'Disetujui HRD Medis',
    status: AttendanceStatus.cuti,
    reason: 'Cuti Tahunan Dokter Terjadwal Semester 2.',
  ),
];

const List<AttendanceFilterOption<String>> kUnitOptions = <AttendanceFilterOption<String>>[
  AttendanceFilterOption<String>(label: 'Semua Unit', value: 'all'),
  AttendanceFilterOption<String>(label: 'Poli Penyakit Dalam', value: 'Penyakit Dalam'),
  AttendanceFilterOption<String>(label: 'Poli Anak', value: 'Anak'),
  AttendanceFilterOption<String>(label: 'IGD', value: 'IGD'),
  AttendanceFilterOption<String>(label: 'Bangsal Cempaka', value: 'Cempaka'),
  AttendanceFilterOption<String>(label: 'Klinik Eksekutif', value: 'Eksekutif'),
];

const List<AttendanceFilterOption<AttendanceStatus?>> kStatusOptions = <AttendanceFilterOption<AttendanceStatus?>>[
  AttendanceFilterOption<AttendanceStatus?>(label: 'Semua Status', value: null),
  AttendanceFilterOption<AttendanceStatus?>(label: 'Hadir', value: AttendanceStatus.hadir),
  AttendanceFilterOption<AttendanceStatus?>(label: 'Telat', value: AttendanceStatus.telat),
  AttendanceFilterOption<AttendanceStatus?>(label: 'Missed', value: AttendanceStatus.missed),
  AttendanceFilterOption<AttendanceStatus?>(label: 'Cuti', value: AttendanceStatus.cuti),
];
