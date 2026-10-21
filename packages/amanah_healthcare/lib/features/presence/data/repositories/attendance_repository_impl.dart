import 'package:amanah_healthcare/features/presence/data/datasources/attendance_remote_data_source.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl({AttendanceRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AttendanceRemoteDataSourceImpl();

  final AttendanceRemoteDataSource _remoteDataSource;

  @override
  Future<AttendanceCheckInResult> recordScan({
    required String qrToken,
    String? shift,
    String? deviceInfo,
  }) async {
    final Map<String, dynamic> json = await _remoteDataSource.submitScan(
      qrToken: qrToken,
      shift: shift,
      deviceInfo: deviceInfo,
    );

    final String checkInStr = json['checkInAt']?.toString() ?? '';
    final DateTime checkInAt = DateTime.tryParse(checkInStr) ?? DateTime.now();

    final String hours = checkInAt.hour.toString().padLeft(2, '0');
    final String minutes = checkInAt.minute.toString().padLeft(2, '0');
    final String timeFormatted = '$hours:$minutes WIB';

    return AttendanceCheckInResult(
      id: json['id']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? '',
      shift: json['shift']?.toString() ?? 'morning',
      status: json['status']?.toString() ?? 'present',
      checkInAt: checkInAt,
      timeFormatted: timeFormatted,
      isReplacement: json['isReplacement'] == true,
      isEarlyDeparture: json['isEarlyDeparture'] == true,
      notes: json['notes']?.toString(),
      validatedDurationHours: json['validatedDurationHours'] != null
          ? double.tryParse(json['validatedDurationHours'].toString())
          : null,
    );
  }

  @override
  Future<AttendanceCheckInResult> recordCheckout({
    String? qrToken,
    String? checkoutTicket,
    String? notes,
  }) async {
    final Map<String, dynamic> json = await _remoteDataSource.submitCheckout(
      qrToken: qrToken,
      checkoutTicket: checkoutTicket,
      notes: notes,
    );

    final String checkInStr = json['checkInAt']?.toString() ?? '';
    final DateTime checkInAt = DateTime.tryParse(checkInStr) ?? DateTime.now();
    final String checkOutStr = json['checkOutAt']?.toString() ?? '';
    final DateTime? checkOutAt = DateTime.tryParse(checkOutStr);

    final DateTime refTime = checkOutAt ?? DateTime.now();
    final String hours = refTime.hour.toString().padLeft(2, '0');
    final String minutes = refTime.minute.toString().padLeft(2, '0');
    final String timeFormatted = '$hours:$minutes WIB';

    return AttendanceCheckInResult(
      id: json['id']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? '',
      shift: json['shift']?.toString() ?? 'morning',
      status: json['status']?.toString() ?? 'present',
      checkInAt: checkInAt,
      checkOutAt: checkOutAt,
      timeFormatted: timeFormatted,
      isReplacement: json['isReplacement'] == true,
      isEarlyDeparture: json['isEarlyDeparture'] == true,
      notes: json['notes']?.toString(),
      validatedDurationHours: json['validatedDurationHours'] != null
          ? double.tryParse(json['validatedDurationHours'].toString())
          : null,
    );
  }

  @override
  Future<List<AttendanceRecord>> getMyHistory() async {
    final List<dynamic> list = await _remoteDataSource.getMyHistory();

    final List<AttendanceRecord> records = <AttendanceRecord>[];
    for (int i = 0; i < list.length; i++) {
      final dynamic item = list[i];
      if (item is! Map<String, dynamic>) continue;

      final String statusStr = item['status']?.toString().toLowerCase() ?? '';
      final AttendanceStatus status = statusStr == 'late' || statusStr == 'telat'
          ? AttendanceStatus.telat
          : statusStr == 'leave' || statusStr == 'cuti'
          ? AttendanceStatus.cuti
          : statusStr == 'absent' || statusStr == 'missed'
          ? AttendanceStatus.missed
          : AttendanceStatus.hadir;

      final String checkInStr = item['checkInAt']?.toString() ?? '';
      final DateTime? checkInAt = DateTime.tryParse(checkInStr);
      final String timeFormatted = checkInAt != null
          ? '${checkInAt.hour.toString().padLeft(2, '0')}:${checkInAt.minute.toString().padLeft(2, '0')} WIB'
          : '-';

      final String checkOutStr = item['checkOutAt']?.toString() ?? '';
      final DateTime? checkOutAt = DateTime.tryParse(checkOutStr);

      final String rawDate = item['attendanceDate']?.toString() ?? '';
      final DateTime? parsedDate = DateTime.tryParse(rawDate) ?? checkInAt;
      final int dayNumber = parsedDate?.day ?? (checkInAt?.day ?? 1);
      final String dateFormatted = parsedDate != null
          ? '${parsedDate.day} ${_monthName(parsedDate.month)}'
          : rawDate;

      final String shiftStr = item['shift']?.toString() ?? 'Pagi';
      final bool isReplacement = item['isReplacement'] == true;

      records.add(
        AttendanceRecord(
          id: item['id']?.toString() ?? '',
          date: dateFormatted,
          dayNumber: dayNumber,
          time: timeFormatted,
          title: isReplacement ? 'Dinas Shift $shiftStr (Pengganti)' : 'Dinas Shift $shiftStr',
          location: item['locationLabel']?.toString() ?? 'Klinik Pratama Amanah',
          status: status,
          isLatest: i == 0,
          attendanceDate: parsedDate,
          checkInAt: checkInAt,
          checkOutAt: checkOutAt,
        ),
      );
    }

    return records;
  }

  static String _monthName(int month) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
