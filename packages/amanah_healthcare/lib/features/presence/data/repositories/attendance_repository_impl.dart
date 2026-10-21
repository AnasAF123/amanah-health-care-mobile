import 'package:amanah_healthcare/core/time/functions/format_localized_time.dart';
import 'package:amanah_healthcare/features/presence/data/datasources/attendance_remote_data_source.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/repositories/attendance_repository.dart';
import 'package:amanah_healthcare/features/schedule/domain/helpers/clinical_session_resolver.dart';

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
    final AttendanceHistoryResult result = await getMyHistoryResult();
    return result.records;
  }

  @override
  Future<AttendanceHistoryResult> getMyHistoryResult() async {
    final dynamic rawData = await _remoteDataSource.getMyHistory();

    List<dynamic> list = <dynamic>[];
    AttendanceHistorySummary? summary;

    if (rawData is Map<String, dynamic>) {
      if (rawData['records'] is List) {
        list = rawData['records'] as List<dynamic>;
      }
      if (rawData['summary'] is Map<String, dynamic>) {
        final Map<String, dynamic> sumMap = rawData['summary'] as Map<String, dynamic>;
        final List<AttendanceStatusFacet> facets = <AttendanceStatusFacet>[];
        if (sumMap['facets'] is List) {
          for (final dynamic f in sumMap['facets']) {
            if (f is Map<String, dynamic>) {
              facets.add(
                AttendanceStatusFacet(
                  status: f['status']?.toString() ?? '',
                  label: f['label']?.toString() ?? '',
                  count: (f['count'] as num?)?.toInt() ?? 0,
                  colorHex: f['color']?.toString() ?? '#10B981',
                ),
              );
            }
          }
        }
        summary = AttendanceHistorySummary(
          totalWorkHours: (sumMap['totalWorkHours'] as num?)?.toDouble() ?? 0.0,
          totalDays: (sumMap['totalDays'] as num?)?.toInt() ?? 0,
          periodLabel: sumMap['periodLabel']?.toString() ?? 'Periode Ini',
          facets: facets,
        );
      }
    } else if (rawData is List) {
      list = rawData;
    }

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
      final DateTime? checkInAt = DateTime.tryParse(checkInStr)?.toLocal();
      final String timeFormatted = checkInAt != null
          ? '${formatLocalizedTime(checkInAt)} WIB'
          : '-';

      final String checkOutStr = item['checkOutAt']?.toString() ?? '';
      final DateTime? checkOutAt = DateTime.tryParse(checkOutStr)?.toLocal();

      final String rawDate = item['attendanceDate']?.toString() ?? '';
      final DateTime? parsedDate = DateTime.tryParse(rawDate) ?? checkInAt;
      final int dayNumber = parsedDate?.day ?? (checkInAt?.day ?? 1);
      final String dateFormatted = parsedDate != null
          ? '${parsedDate.day} ${_monthName(parsedDate.month)}'
          : rawDate;

      final String shiftRaw = item['shift']?.toString() ?? 'morning';
      final String shiftName = ClinicalSessionResolver.resolveShiftName(sessionShift: shiftRaw);
      final bool isReplacement = item['isReplacement'] == true;
      final String title = isReplacement ? 'Shift $shiftName (Pengganti)' : 'Shift $shiftName';

      final String? locationLabel = item['locationLabel']?.toString();
      final double? validatedHours = item['validatedDurationHours'] != null
          ? double.tryParse(item['validatedDurationHours'].toString())
          : null;
      final String? notes = item['notes']?.toString();

      records.add(
        AttendanceRecord(
          id: item['id']?.toString() ?? '',
          date: dateFormatted,
          dayNumber: dayNumber,
          time: timeFormatted,
          title: title,
          location: locationLabel ?? '',
          status: status,
          isLatest: i == 0,
          attendanceDate: parsedDate,
          checkInAt: checkInAt,
          checkOutAt: checkOutAt,
          validatedDurationHours: validatedHours,
          notes: notes,
        ),
      );
    }

    return AttendanceHistoryResult(records: records, summary: summary);
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
