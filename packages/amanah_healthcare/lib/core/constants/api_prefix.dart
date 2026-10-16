/// API URL prefixes for the Amanah Healthcare backend services.
abstract final class ApiPrefix {
  /// Primary v1 API routes (NestJS controllers with version: '1')
  static const String v1 = '/api/v1';

  /// Active Better-Auth engine routes (NestJS controllers with VERSION_NEUTRAL)
  static const String betterAuth = '/api';
}
