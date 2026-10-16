import 'package:amanah_healthcare/core/constants/client_id.dart';
import 'package:amanah_healthcare/core/constants/http_header_names.dart';
import 'package:amanah_healthcare/core/constants/mime_types.dart';

export 'package:amanah_healthcare/core/constants/api_error_code.dart';
export 'package:amanah_healthcare/core/constants/api_prefix.dart';
export 'package:amanah_healthcare/core/constants/auth_schemes.dart';
export 'package:amanah_healthcare/core/constants/client_id.dart';
export 'package:amanah_healthcare/core/constants/http_header_names.dart';
export 'package:amanah_healthcare/core/constants/mime_types.dart';

typedef AuthHeaderNames = HttpHeaderNames;
typedef AuthMimeTypes = MimeTypes;
typedef AuthClientIds = ClientId;

abstract final class AuthApiErrorCodes {
  static const String notAuthorized = 'NOT_AUTHORIZED';
  static const String accountInactive = 'ACCOUNT_INACTIVE';
  static const String clientNotAllowed = 'CLIENT_NOT_ALLOWED';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
}
