import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';

class AmanahAuthRepository {
  const AmanahAuthRepository();

  Future<List<AmanahAuthUser>> loadUsers() async {
    return const <AmanahAuthUser>[];
  }

  Future<AmanahAuthUser?> signIn({
    required String identifier,
    required String password,
  }) async {
    final String normalizedIdentifier = identifier.trim().toLowerCase();
    final List<AmanahAuthUser> users = await loadUsers();

    for (final AmanahAuthUser user in users) {
      final bool identifierMatches =
          user.email.toLowerCase() == normalizedIdentifier ||
          user.phone == identifier.trim();
      if (identifierMatches && user.password == password) {
        return user;
      }
    }

    return null;
  }
}
