import 'package:amanah_healthcare/core/network/api_endpoint.dart';

/// Centralized API Endpoints for Patient Intake and Medical Records.
class IntakeEndpoints {
  IntakeEndpoints._();

  static ApiEndpoint intakeByAppointment(String appointmentId) => ApiEndpoint(
        path: '/api/v1/medical-records/intakes/by-appointment/$appointmentId',
        method: HttpMethod.get,
        requiresAuth: true,
      );
}
