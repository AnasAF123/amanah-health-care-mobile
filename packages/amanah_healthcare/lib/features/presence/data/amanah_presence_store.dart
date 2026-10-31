import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';

const List<AttendanceRecord> kAttendanceRecords = <AttendanceRecord>[];

const List<AttendanceFilterOption<AttendanceStatus?>>
kStatusOptions = <AttendanceFilterOption<AttendanceStatus?>>[
  AttendanceFilterOption<AttendanceStatus?>(label: 'Semua Status', value: null),
  AttendanceFilterOption<AttendanceStatus?>(label: 'Hadir', value: AttendanceStatus.present),
  AttendanceFilterOption<AttendanceStatus?>(label: 'Terlambat', value: AttendanceStatus.late),
  AttendanceFilterOption<AttendanceStatus?>(label: 'Tidak Hadir', value: AttendanceStatus.missed),
  AttendanceFilterOption<AttendanceStatus?>(label: 'Cuti / Izin', value: AttendanceStatus.leave),
  AttendanceFilterOption<AttendanceStatus?>(label: 'Alpa', value: AttendanceStatus.absent),
];
