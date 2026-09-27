class DoctorQueueEndpoints {
  static const String dailyQueue = '/api/v1/appointments/queue/daily';
  static const String queryPoliklinikId = 'poliklinikId';
  static const String queryDate = 'date';
  static const String querySession = 'session';

  static String call(String appointmentId) => '/api/v1/appointments/$appointmentId/call';
  static String respond(String appointmentId) => '/api/v1/appointments/$appointmentId/respond';
  static String noShow(String appointmentId) => '/api/v1/appointments/$appointmentId/no-show';
  static String complete(String appointmentId) => '/api/v1/appointments/$appointmentId/complete';
}
