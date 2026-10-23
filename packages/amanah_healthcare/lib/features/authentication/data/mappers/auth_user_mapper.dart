import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';

abstract final class AuthUserMapper {
  static AmanahAuthUser fromJson(Map<String, dynamic> json) {
    final String roleStr = json['role'] is Map
        ? (json['role']['code'] as String? ?? '')
        : (json['role'] as String? ?? '');
    final AmanahUserRole mappedRole = AmanahAuthUser.parseRole(roleStr);
    final bool needsOnboarding = json['needsOnboarding'] as bool? ?? false;
    final String systemRole = json['systemRole'] as String? ?? roleStr;
    final Map<String, dynamic>? staffJson = json['staff'] as Map<String, dynamic>?;

    final String id = json['id'] as String? ?? '';
    final String fullName = json['name'] as String? ?? json['fullName'] as String? ?? '';
    final String? avatarUrl = json['avatarUrl'] as String? ?? json['avatar_url'] as String?;

    final UserAvatar resolvedAvatar = json['avatar'] != null
        ? UserAvatar.fromJson(json['avatar'] as Map<String, dynamic>)
        : (avatarUrl != null && avatarUrl.isNotEmpty
              ? UserAvatar(
                  url: avatarUrl,
                  initials: UserAvatar.extractInitials(fullName),
                  type: avatarUrl.startsWith('http') ? 'oauth' : 'custom',
                  hasCustomAvatar: true,
                  directUrl: avatarUrl,
                )
              : UserAvatar.fromFallback(userId: id, name: fullName));

    return AmanahAuthUser(
      id: id,
      role: mappedRole,
      fullName: fullName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String? ?? '',
      avatar: resolvedAvatar,
      password: '',
      isEmailVerified: json['emailVerified'] as bool? ?? json['isEmailVerified'] as bool? ?? false,
      needsOnboarding: needsOnboarding,
      systemRole: systemRole,
      staff: staffJson != null ? AmanahStaffProfile.fromJson(staffJson) : null,
    );
  }
}
