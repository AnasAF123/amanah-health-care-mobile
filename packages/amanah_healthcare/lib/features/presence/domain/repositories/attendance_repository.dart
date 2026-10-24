import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';

abstract interface class AttendanceRepository {
  Future<AttendanceCheckInResult> recordScan({
    required String qrToken,
    AttendanceMethod? method,
    String? shift,
    String? deviceInfo,
  });

  Future<AttendanceCheckInResult> recordCheckout({
    String? qrToken,
    AttendanceMethod? method,
    String? checkoutTicket,
    String? notes,
  });

  Future<List<AttendanceRecord>> getMyHistory();

  Future<AttendanceHistoryResult> getMyHistoryResult();
}
