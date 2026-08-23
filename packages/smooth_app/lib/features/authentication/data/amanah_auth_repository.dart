import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';

class AmanahAuthRepository {
  const AmanahAuthRepository({
    this.credentialsAssetPath = 'assets/amanah/auth/auth_credentials.json',
  });

  final String credentialsAssetPath;

  Future<List<AmanahAuthUser>> loadUsers() async {
    final String rawJson = await rootBundle.loadString(credentialsAssetPath);
    final Map<String, dynamic> data =
        jsonDecode(rawJson) as Map<String, dynamic>;
    final List<dynamic> users = data['users'] as List<dynamic>;

    return users
        .map(
          (dynamic item) =>
              AmanahAuthUser.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
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
