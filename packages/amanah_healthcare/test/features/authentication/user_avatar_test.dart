import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/domain/user_avatar.dart';

void main() {
  group('UserAvatar Domain Model Tests', () {
    test('UserAvatar.fromJson deserializes contract format correctly', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'url': '/api/v1/users/usr-123/avatar',
        'initials': 'AS',
        'type': 'custom',
        'hasCustomAvatar': true,
        'directUrl': 'http://localhost:3001/api/v1/users/usr-123/avatar?v=1710000000',
      };

      final UserAvatar avatar = UserAvatar.fromJson(json);

      expect(avatar.url, '/api/v1/users/usr-123/avatar');
      expect(avatar.initials, 'AS');
      expect(avatar.type, 'custom');
      expect(avatar.hasCustomAvatar, isTrue);
      expect(avatar.directUrl, 'http://localhost:3001/api/v1/users/usr-123/avatar?v=1710000000');
      expect(avatar.isCustom, isTrue);
      expect(avatar.isOAuth, isFalse);
      expect(avatar.isInitials, isFalse);
      expect(avatar.displayUrl, 'http://localhost:3001/api/v1/users/usr-123/avatar?v=1710000000');
    });

    test('UserAvatar.toJson serializes model correctly', () {
      const UserAvatar avatar = UserAvatar(
        url: '/api/v1/users/usr-456/avatar',
        initials: 'DR',
        type: 'oauth',
        hasCustomAvatar: true,
        directUrl: 'https://lh3.googleusercontent.com/photo.jpg',
      );

      final Map<String, dynamic> json = avatar.toJson();

      expect(json['url'], '/api/v1/users/usr-456/avatar');
      expect(json['initials'], 'DR');
      expect(json['type'], 'oauth');
      expect(json['hasCustomAvatar'], isTrue);
      expect(json['directUrl'], 'https://lh3.googleusercontent.com/photo.jpg');
    });

    test('UserAvatar.fromFallback constructs initials fallback properly', () {
      final UserAvatar fallback = UserAvatar.fromFallback(
        userId: 'usr-999',
        name: 'dr. Ahmad Santoso, Sp.A',
      );

      expect(fallback.url, '/api/v1/users/usr-999/avatar');
      expect(fallback.initials, 'AS');
      expect(fallback.type, 'initials');
      expect(fallback.hasCustomAvatar, isFalse);
      expect(fallback.isInitials, isTrue);
      expect(fallback.displayUrl, '/api/v1/users/usr-999/avatar');
    });

    group('extractInitials title and suffix cleaning', () {
      test('strips medical doctor prefix dr. and specialization suffix Sp.A', () {
        expect(UserAvatar.extractInitials('dr. Ahmad Santoso, Sp.A'), 'AS');
      });

      test('strips dentist prefix drg. and master degree suffix M.Kes', () {
        expect(UserAvatar.extractInitials('drg. Siti Rahma, M.Kes'), 'SR');
      });

      test('strips midwife prefix Bdn. and diploma suffix S.Tr.Keb', () {
        expect(UserAvatar.extractInitials('Bdn. Dewi Sartika, S.Tr.Keb'), 'DS');
      });

      test('strips Professor and Doctor prefixes', () {
        expect(UserAvatar.extractInitials('Prof. Dr. Budi Santoso, Ph.D'), 'BS');
      });

      test('handles single word names by taking up to first 2 letters', () {
        expect(UserAvatar.extractInitials('Siti'), 'SI');
        expect(UserAvatar.extractInitials('A'), 'A');
      });

      test('falls back to AH on empty or whitespace strings', () {
        expect(UserAvatar.extractInitials(''), 'AH');
        expect(UserAvatar.extractInitials('   '), 'AH');
      });
    });

    test('copyWith produces updated instance without modifying original', () {
      const UserAvatar original = UserAvatar(
        url: '/avatar1',
        initials: 'AS',
        type: 'initials',
        hasCustomAvatar: false,
      );

      final UserAvatar copy = original.copyWith(
        url: '/avatar2',
        hasCustomAvatar: true,
        type: 'custom',
      );

      expect(original.url, '/avatar1');
      expect(original.hasCustomAvatar, isFalse);
      expect(copy.url, '/avatar2');
      expect(copy.hasCustomAvatar, isTrue);
      expect(copy.initials, 'AS');
      expect(copy.type, 'custom');
    });

    test('value equality and hashCode behave consistently', () {
      const UserAvatar a1 = UserAvatar(
        url: '/avatar',
        initials: 'AS',
        type: 'custom',
        hasCustomAvatar: true,
        directUrl: 'http://cdn/avatar.jpg',
      );
      const UserAvatar a2 = UserAvatar(
        url: '/avatar',
        initials: 'AS',
        type: 'custom',
        hasCustomAvatar: true,
        directUrl: 'http://cdn/avatar.jpg',
      );
      const UserAvatar a3 = UserAvatar(
        url: '/avatar',
        initials: 'AS',
        type: 'initials',
        hasCustomAvatar: false,
      );

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
      expect(a1, isNot(equals(a3)));
    });
  });
}
