import 'package:dio/dio.dart';
import 'package:amanah_healthcare/core/constants/doctor_queue_endpoints.dart';
import 'package:amanah_healthcare/features/queue/data/models/doctor_queue_appointment_model.dart';

abstract class DoctorQueueRemoteDataSource {
  Future<List<DoctorQueueAppointmentModel>> getDailyQueue({
    required String poliklinikId,
    required String date,
    String? session,
    required String authToken,
  });

  Future<DoctorQueueAppointmentModel> callPatient(
    String appointmentId,
    String authToken,
  );

  Future<DoctorQueueAppointmentModel> respondPatient(
    String appointmentId,
    String authToken,
  );

  Future<DoctorQueueAppointmentModel> noShowPatient(
    String appointmentId,
    String authToken,
  );

  Future<DoctorQueueAppointmentModel> completeAppointment(
    String appointmentId,
    String authToken,
  );
}

class DoctorQueueRemoteDataSourceImpl implements DoctorQueueRemoteDataSource {
  final Dio dio;

  DoctorQueueRemoteDataSourceImpl({required this.dio});

  Options _authOptions(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  @override
  Future<List<DoctorQueueAppointmentModel>> getDailyQueue({
    required String poliklinikId,
    required String date,
    String? session,
    required String authToken,
  }) async {
    final queryParams = <String, dynamic>{
      DoctorQueueEndpoints.queryPoliklinikId: poliklinikId,
      DoctorQueueEndpoints.queryDate: date,
      if (session != null && session.isNotEmpty)
        DoctorQueueEndpoints.querySession: session,
    };

    final response = await dio.get(
      DoctorQueueEndpoints.dailyQueue,
      queryParameters: queryParams,
      options: _authOptions(authToken),
    );

    final rawList = response.data['data'] as List<dynamic>? ?? [];
    return rawList
        .map((item) =>
            DoctorQueueAppointmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DoctorQueueAppointmentModel> callPatient(
    String appointmentId,
    String authToken,
  ) async {
    final response = await dio.post(
      DoctorQueueEndpoints.call(appointmentId),
      options: _authOptions(authToken),
    );
    return DoctorQueueAppointmentModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<DoctorQueueAppointmentModel> respondPatient(
    String appointmentId,
    String authToken,
  ) async {
    final response = await dio.post(
      DoctorQueueEndpoints.respond(appointmentId),
      options: _authOptions(authToken),
    );
    return DoctorQueueAppointmentModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<DoctorQueueAppointmentModel> noShowPatient(
    String appointmentId,
    String authToken,
  ) async {
    final response = await dio.post(
      DoctorQueueEndpoints.noShow(appointmentId),
      options: _authOptions(authToken),
    );
    return DoctorQueueAppointmentModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<DoctorQueueAppointmentModel> completeAppointment(
    String appointmentId,
    String authToken,
  ) async {
    final response = await dio.patch(
      DoctorQueueEndpoints.complete(appointmentId),
      options: _authOptions(authToken),
    );
    return DoctorQueueAppointmentModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
