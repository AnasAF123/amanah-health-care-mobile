import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/queue/data/datasources/doctor_queue_remote_data_source.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/doctor_queue_appointment.dart';
import 'package:amanah_healthcare/features/queue/domain/repositories/doctor_queue_repository.dart';

class DoctorQueueRepositoryImpl implements DoctorQueueRepository {
  final DoctorQueueRemoteDataSource remoteDataSource;
  final AmanahAuthTokenStorage tokenStorage;

  DoctorQueueRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  Future<String> _getToken() async {
    final token = await tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Authentication token missing');
    }
    return token;
  }

  @override
  Future<List<DoctorQueueAppointment>> getDailyQueue({
    required String poliklinikId,
    required String date,
    String? session,
  }) async {
    final token = await _getToken();
    return await remoteDataSource.getDailyQueue(
      poliklinikId: poliklinikId,
      date: date,
      session: session,
      authToken: token,
    );
  }

  @override
  Future<DoctorQueueAppointment> callPatient(String appointmentId) async {
    final token = await _getToken();
    return await remoteDataSource.callPatient(appointmentId, token);
  }

  @override
  Future<DoctorQueueAppointment> respondPatient(String appointmentId) async {
    final token = await _getToken();
    return await remoteDataSource.respondPatient(appointmentId, token);
  }

  @override
  Future<DoctorQueueAppointment> noShowPatient(String appointmentId) async {
    final token = await _getToken();
    return await remoteDataSource.noShowPatient(appointmentId, token);
  }

  @override
  Future<DoctorQueueAppointment> completeAppointment(
      String appointmentId) async {
    final token = await _getToken();
    return await remoteDataSource.completeAppointment(appointmentId, token);
  }
}
