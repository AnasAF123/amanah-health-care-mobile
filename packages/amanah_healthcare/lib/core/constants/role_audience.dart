/// Canonical Role Audience definitions matching database migration 0063.
/// Single Source of Truth (SSOT) across all mobile layers.
abstract final class RoleAudience {
  static const String internal = 'internal';
  static const String external = 'external';

  static const List<String> values = <String>[internal, external];

  static bool isInternal(String? audience) => audience == internal;
  static bool isExternal(String? audience) => audience == external;
}

/// Canonical Role Tier definitions matching database migration 0062.
abstract final class RoleTier {
  static const String macro = 'macro';
  static const String micro = 'micro';

  static const List<String> values = <String>[macro, micro];

  static bool isMacro(String? tier) => tier == macro;
  static bool isMicro(String? tier) => tier == micro;
}
