import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';

const List<AttendanceRecord> kAttendanceRecords = <AttendanceRecord>[];

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
