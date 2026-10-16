/// API error codes returned by the backend authentication and clinical services.
enum ApiErrorCode {
  notAuthorized('NOT_AUTHORIZED'),
  accountInactive('ACCOUNT_INACTIVE'),
  clientNotAllowed('CLIENT_NOT_ALLOWED'),
  invalidCredentials('INVALID_CREDENTIALS');

  const ApiErrorCode(this.code);

  final String code;

  static ApiErrorCode? fromCode(String? code) {
    if (code == null) return null;
    for (final ApiErrorCode item in values) {
      if (item.code == code) return item;
    }
    return null;
  }
}
