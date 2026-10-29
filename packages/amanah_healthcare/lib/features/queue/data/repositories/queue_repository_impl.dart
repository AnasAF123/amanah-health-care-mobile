import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/features/queue/data/datasources/queue_remote_data_source.dart';
import 'package:amanah_healthcare/features/queue/data/mappers/queue_patient_mapper.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_patient_card.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_session_info.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/reschedule_options_entity.dart';
import 'package:amanah_healthcare/features/queue/domain/failures/queue_failure.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/queue_repository.dart';

class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl({QueueRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? QueueRemoteDataSourceImpl();

  final QueueRemoteDataSource _remoteDataSource;

  @override
  Future<List<QueueSessionInfo>> getDoctorTodaySessions() async {
    try {
      final dynamic raw = await _remoteDataSource.getMySchedules();
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(QueuePatientMapper.sessionFromJson)
            .toList();
      }
      return <QueueSessionInfo>[];
    } on ApiException catch (e) {
      AppLog.error('[QueueRepository] Failed to get my schedules: ${e.message}');
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      AppLog.error('[QueueRepository] Unexpected error getting my schedules: $e');
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<List<QueuePatientCard>> getWaitingQueue(String sessionId, {String? date}) async {
    try {
      final dynamic raw = await _remoteDataSource.getSessionPatients(
        sessionId,
        status: 'waiting',
        date: date,
      );

      String? sessionRoom;
      String? sessionPoly;
      List<dynamic> patientList = <dynamic>[];

      if (raw is Map<String, dynamic>) {
        final dynamic clinicRoom = raw['clinicRoom'];
        if (clinicRoom is Map<String, dynamic>) {
          sessionRoom = clinicRoom['name'] as String?;
        }
        final dynamic rawPatients = raw['patients'];
        if (rawPatients is List) {
          patientList = rawPatients;
        }
      } else if (raw is List) {
        patientList = raw;
      }

      return patientList
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => QueuePatientMapper.fromJson(
              item,
              sessionRoom: sessionRoom,
              sessionPoly: sessionPoly,
            ),
          )
          .where(
            (card) =>
                card.status == 'waiting' ||
                card.status == 'checked_in' ||
                card.status == 'in_service',
          )
          .toList();
    } on ApiException catch (e) {
      AppLog.error('[QueueRepository] Failed to get session patients: ${e.message}');
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      AppLog.error('[QueueRepository] Unexpected error getting session queue: $e');
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<void> callPatient(String appointmentId, {String? notes}) async {
    try {
      await _remoteDataSource.callPatient(appointmentId, notes: notes);
    } on ApiException catch (e) {
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<void> startService(String appointmentId) async {
    try {
      await _remoteDataSource.startService(appointmentId);
    } on ApiException catch (e) {
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<void> completeService(String appointmentId) async {
    try {
      await _remoteDataSource.completeService(appointmentId);
    } on ApiException catch (e) {
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId, {String? reason}) async {
    try {
      await _remoteDataSource.cancelAppointment(appointmentId, reason: reason);
    } on ApiException catch (e) {
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<void> reportNoShow(String appointmentId, {String? notes}) async {
    try {
      await _remoteDataSource.reportNoShow(appointmentId, notes: notes);
    } on ApiException catch (e) {
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<void> rescheduleAppointment(
    String appointmentId, {
    required String targetDate,
    String? session,
    String? targetSessionId,
    String? reason,
  }) async {
    try {
      await _remoteDataSource.rescheduleAppointment(
        appointmentId,
        targetDate: targetDate,
        session: session,
        targetSessionId: targetSessionId,
        reason: reason,
      );
    } on ApiException catch (e) {
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<RescheduleOptionsEntity> getRescheduleOptions(String appointmentId) async {
    try {
      final dynamic raw = await _remoteDataSource.getRescheduleOptions(appointmentId);
      if (raw is Map<String, dynamic>) {
        return RescheduleOptionsEntity.fromJson(raw);
      }
      throw const QueueFailure('Format respons opsi reschedule tidak valid');
    } on ApiException catch (e) {
      AppLog.error('[QueueRepository] Failed to get reschedule options: ${e.message}');
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      AppLog.error('[QueueRepository] Unexpected error getting reschedule options: $e');
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<List<QueuePatientCard>> getCompletedQueue(String sessionId, {String? date}) async {
    try {
      final dynamic raw = await _remoteDataSource.getSessionPatients(
        sessionId,
        status: 'completed',
        date: date,
      );

      String? sessionRoom;
      String? sessionPoly;
      List<dynamic> patientList = <dynamic>[];

      if (raw is Map<String, dynamic>) {
        final dynamic clinicRoom = raw['clinicRoom'];
        if (clinicRoom is Map<String, dynamic>) {
          sessionRoom = clinicRoom['name'] as String?;
        }
        final dynamic rawPatients = raw['patients'];
        if (rawPatients is List) {
          patientList = rawPatients;
        }
      } else if (raw is List) {
        patientList = raw;
      }

      return patientList
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => QueuePatientMapper.fromJson(
              item,
              sessionRoom: sessionRoom,
              sessionPoly: sessionPoly,
            ),
          )
          .toList();
    } on ApiException catch (e) {
      AppLog.error('[QueueRepository] Failed to get completed patients: ${e.message}');
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      AppLog.error('[QueueRepository] Unexpected error getting completed queue: $e');
      throw QueueFailure(e.toString());
    }
  }

  @override
  Future<List<QueuePatientCard>> getDoctorProcessedQueue({String? date}) async {
    try {
      final dynamic raw = await _remoteDataSource.getDoctorProcessedQueue(date: date);

      List<dynamic> patientList = <dynamic>[];
      if (raw is List) {
        patientList = raw;
      } else if (raw is Map<String, dynamic> && raw['data'] is List) {
        patientList = raw['data'] as List<dynamic>;
      }

      return patientList
          .whereType<Map<String, dynamic>>()
          .map((item) => QueuePatientMapper.fromJson(item))
          .toList();
    } on ApiException catch (e) {
      AppLog.error('[QueueRepository] Failed to get doctor processed patients: ${e.message}');
      throw QueueFailure(e.message, code: e.code);
    } catch (e) {
      AppLog.error('[QueueRepository] Unexpected error getting doctor processed queue: $e');
      throw QueueFailure(e.toString());
    }
  }
}
