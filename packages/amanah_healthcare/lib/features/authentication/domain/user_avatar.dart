class UserAvatar {
  const UserAvatar({
    required this.url,
    required this.initials,
    required this.type,
    required this.hasCustomAvatar,
    this.directUrl,
  });

  static const UserAvatar empty = UserAvatar(
    url: '',
    initials: 'AH',
    type: 'initials',
    hasCustomAvatar: false,
  );

  final String url;
  final String initials;
  final String type; // 'custom' | 'oauth' | 'initials'
  final bool hasCustomAvatar;
  final String? directUrl;

  bool get isCustom => type == 'custom';
  bool get isOAuth => type == 'oauth';
  bool get isInitials => type == 'initials';

  /// Primary display URL preferring cache-busted directUrl if present
  String get displayUrl => directUrl != null && directUrl!.isNotEmpty ? directUrl! : url;

  factory UserAvatar.fromJson(Map<String, dynamic> json) {
    return UserAvatar(
      url: json['url'] as String? ?? '',
      initials: json['initials'] as String? ?? 'AH',
      type: json['type'] as String? ?? 'initials',
      hasCustomAvatar: json['hasCustomAvatar'] as bool? ?? false,
      directUrl: json['directUrl'] as String?,
    );
  }

  factory UserAvatar.fromFallback({
    required String userId,
    required String name,
  }) {
    final String cleanInitials = extractInitials(name);
    return UserAvatar(
      url: '/api/v1/users/$userId/avatar',
      initials: cleanInitials,
      type: 'initials',
      hasCustomAvatar: false,
    );
  }

  factory UserAvatar.custom({
    required String url,
    required String initials,
    String? directUrl,
  }) {
    return UserAvatar(
      url: url,
      initials: initials,
      type: 'custom',
      hasCustomAvatar: true,
      directUrl: directUrl,
    );
  }

  static String extractInitials(String name) {
    if (name.trim().isEmpty) return 'AH';
    
    // Clean clinical prefixes (dr., drg., Bdn., Prof.) and academic titles
    String cleaned = name
        .replaceAll(RegExp(r'\b(dr\.|drg\.|Bdn\.|Prof\.)\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r',\s*(Sp\.[A-Z]+|M\.Kes|S\.Tr\.Keb|MPH|Ph\.D).*', caseSensitive: false), '')
        .trim();

    final List<String> parts = cleaned.split(RegExp(r'\s+')).where((String s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'AH';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'initials': initials,
      'type': type,
      'hasCustomAvatar': hasCustomAvatar,
      if (directUrl != null) 'directUrl': directUrl,
    };
  }

  UserAvatar copyWith({
    String? url,
    String? initials,
    String? type,
    bool? hasCustomAvatar,
    String? directUrl,
  }) {
    return UserAvatar(
      url: url ?? this.url,
      initials: initials ?? this.initials,
      type: type ?? this.type,
      hasCustomAvatar: hasCustomAvatar ?? this.hasCustomAvatar,
      directUrl: directUrl ?? this.directUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAvatar &&
        other.url == url &&
        other.initials == initials &&
        other.type == type &&
        other.hasCustomAvatar == hasCustomAvatar &&
        other.directUrl == directUrl;
  }

  @override
  int get hashCode => Object.hash(url, initials, type, hasCustomAvatar, directUrl);

  @override
  String toString() {
    return 'UserAvatar(url: $url, initials: $initials, type: $type, hasCustomAvatar: $hasCustomAvatar, directUrl: $directUrl)';
  }
}
