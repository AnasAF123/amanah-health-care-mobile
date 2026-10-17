import 'package:amanah_healthcare/core/network/api_endpoint.dart';

/// Centralized API Endpoints for the Clinical Queue module.
class QueueEndpoints {
  QueueEndpoints._();

  static const ApiEndpoint mySchedules = ApiEndpoint(
    path: '/api/v1/schedules/my-schedules',
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static ApiEndpoint sessionPatients(String sessionId, {String? status}) {
    final String query = status != null ? '?status=$status' : '';
    return ApiEndpoint(
      path: '/api/v1/schedules/sessions/$sessionId/patients$query',
      method: HttpMethod.get,
      requiresAuth: true,
    );
  }

  static ApiEndpoint callPatient(String appointmentId) => ApiEndpoint(
        path: '/api/v1/appointments/$appointmentId/call',
        method: HttpMethod.post,
        requiresAuth: true,
      );

  static ApiEndpoint startService(String appointmentId) => ApiEndpoint(
        path: '/api/v1/appointments/$appointmentId/start',
        method: HttpMethod.post,
        requiresAuth: true,
      );

  static ApiEndpoint completeService(String appointmentId) => ApiEndpoint(
        path: '/api/v1/appointments/$appointmentId/complete',
        method: HttpMethod.post,
        requiresAuth: true,
      );

  static ApiEndpoint cancelAppointment(String appointmentId) => ApiEndpoint(
        path: '/api/v1/appointments/$appointmentId/cancel',
        method: HttpMethod.post,
        requiresAuth: true,
      );

  static ApiEndpoint reportNoShow(String appointmentId) => ApiEndpoint(
        path: '/api/v1/appointments/$appointmentId/no-show',
        method: HttpMethod.post,
        requiresAuth: true,
      );

  static ApiEndpoint rescheduleAppointment(String appointmentId) => ApiEndpoint(
        path: '/api/v1/appointments/$appointmentId/reschedule',
        method: HttpMethod.post,
        requiresAuth: true,
      );

  static ApiEndpoint rescheduleOptions(String appointmentId) => ApiEndpoint(
        path: '/api/v1/appointments/$appointmentId/reschedule-options',
        method: HttpMethod.get,
        requiresAuth: true,
      );
}
