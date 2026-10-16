import 'package:amanah_healthcare/core/constants/api_prefix.dart';
import 'package:amanah_healthcare/core/network/api_endpoint.dart';

abstract final class ScheduleEndpoints {
  static const String pathMyRoster = '${ApiPrefix.v1}/schedules/my-roster';
  static const String pathCalendarSummary =
      '${ApiPrefix.v1}/schedules/calendar-summary';
  static const String pathBookedPatients =
      '${ApiPrefix.v1}/schedules/booked-patients';
  static const String pathMySchedules = '${ApiPrefix.v1}/schedules/my-schedules';

  static String pathSessionPatients(String sessionId) =>
      '${ApiPrefix.v1}/schedules/sessions/$sessionId/patients';

  static String pathDays(String date) =>
      '${ApiPrefix.v1}/schedules/days/$date';

  static const ApiEndpoint myRosterGetEndpoint = ApiEndpoint(
    path: pathMyRoster,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static const ApiEndpoint myRosterPutEndpoint = ApiEndpoint(
    path: pathMyRoster,
    method: HttpMethod.put,
    requiresAuth: true,
  );

  static const ApiEndpoint myRosterDeleteEndpoint = ApiEndpoint(
    path: pathMyRoster,
    method: HttpMethod.delete,
    requiresAuth: true,
  );

  static const ApiEndpoint calendarSummaryEndpoint = ApiEndpoint(
    path: pathCalendarSummary,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static const ApiEndpoint bookedPatientsEndpoint = ApiEndpoint(
    path: pathBookedPatients,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static const ApiEndpoint mySchedulesEndpoint = ApiEndpoint(
    path: pathMySchedules,
    method: HttpMethod.get,
    requiresAuth: true,
  );

  static ApiEndpoint sessionPatientsEndpoint(String sessionId) => ApiEndpoint(
        path: pathSessionPatients(sessionId),
        method: HttpMethod.get,
        requiresAuth: true,
      );

  static ApiEndpoint daysPatchEndpoint(String date) => ApiEndpoint(
        path: pathDays(date),
        method: HttpMethod.patch,
        requiresAuth: true,
      );
}
