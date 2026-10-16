import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/constants/api_error_code.dart';
import 'package:amanah_healthcare/core/constants/api_prefix.dart';
import 'package:amanah_healthcare/core/constants/auth_schemes.dart';
import 'package:amanah_healthcare/core/constants/client_id.dart';
import 'package:amanah_healthcare/core/constants/http_header_names.dart';
import 'package:amanah_healthcare/core/constants/mime_types.dart';

void main() {
  group('Core Constants Layer', () {
    test('ApiPrefix defines non-ambiguous v1 and betterAuth prefixes', () {
      expect(ApiPrefix.v1, '/api/v1');
      expect(ApiPrefix.betterAuth, '/api');
    });

    test('ApiErrorCode maps known backend error codes', () {
      expect(ApiErrorCode.fromCode('NOT_AUTHORIZED'), ApiErrorCode.notAuthorized);
      expect(ApiErrorCode.fromCode('ACCOUNT_INACTIVE'), ApiErrorCode.accountInactive);
      expect(ApiErrorCode.fromCode('CLIENT_NOT_ALLOWED'), ApiErrorCode.clientNotAllowed);
      expect(ApiErrorCode.fromCode('INVALID_CREDENTIALS'), ApiErrorCode.invalidCredentials);
      expect(ApiErrorCode.fromCode('UNKNOWN_CODE'), isNull);
      expect(ApiErrorCode.fromCode(null), isNull);
    });

    test('ClientId provides internal mobile identifier', () {
      expect(ClientId.mobileInternal, 'mobile-internal');
    });

    test('AuthSchemes defines standard Bearer scheme', () {
      expect(AuthSchemes.bearer, 'Bearer');
    });

    test('HttpHeaderNames defines standard RFC header keys', () {
      expect(HttpHeaderNames.authorization, 'Authorization');
      expect(HttpHeaderNames.contentType, 'Content-Type');
      expect(HttpHeaderNames.accept, 'Accept');
      expect(HttpHeaderNames.xClientId, 'X-Client-Id');
    });

    test('MimeTypes defines common media type strings', () {
      expect(MimeTypes.applicationJson, 'application/json');
      expect(MimeTypes.multipartFormData, 'multipart/form-data');
      expect(MimeTypes.imageJpeg, 'image/jpeg');
      expect(MimeTypes.imagePng, 'image/png');
    });
  });
}
