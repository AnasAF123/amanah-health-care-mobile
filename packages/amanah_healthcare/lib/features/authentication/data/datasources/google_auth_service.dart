import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:amanah_healthcare/core/config/amanah_auth_environment.dart';
import 'package:amanah_healthcare/features/authentication/domain/failures/auth_failure.dart';

/// Data source wrapper around the native Google Sign-In SDK.
/// Encapsulates platform interactions, account picker launching, and token retrieval.
class GoogleAuthService {
  const GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn;

  final GoogleSignIn? _googleSignIn;

  GoogleSignIn get _client =>
      _googleSignIn ??
      GoogleSignIn(
        serverClientId: AmanahAuthEnvironment.googleOAuthClientIdWeb,
        scopes: const <String>['email', 'profile'],
      );

  /// Clears the local Google SDK session so that the account chooser
  /// is prompted on the next login attempt.
  Future<void> signOut() async {
    try {
      await _client.signOut();
    } catch (_) {
      // Non-blocking cleanup
    }
  }

  /// Triggers the Google Account Chooser and retrieves the OAuth idToken.
  /// Returns `null` if the user cancels or dismisses the account picker.
  /// Throws [AuthFailure] if a platform or network error occurs.
  Future<String?> getIdToken() async {
    GoogleSignInAccount? account;
    try {
      account = await _client.signIn();
    } on PlatformException catch (e) {
      throw NetworkFailure(
        e.message ?? 'Gagal menghubungi layanan Google Play Services.',
      );
    } catch (_) {
      throw const NetworkFailure(
        'Koneksi ke layanan Google terputus. Silakan coba kembali.',
      );
    }

    if (account == null) {
      return null;
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    final String? idToken = auth.idToken;

    if (idToken == null || idToken.isEmpty) {
      await signOut();
      throw const ServerFailure(
        'Gagal memperoleh ID token dari akun Google yang dipilih.',
      );
    }

    return idToken;
  }
}
