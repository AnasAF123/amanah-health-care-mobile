import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AmanahHomeAppBar extends StatelessWidget {
  const AmanahHomeAppBar({
    required this.user,
    required this.onNotificationTap,
    required this.onProfileTap,
    super.key,
    this.greeting = 'Selamat Pagi',
    this.unreadNotifications = 3,
  });

  final AmanahAuthUser user;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final String greeting;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: SMALL_SPACE, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  children: <Widget>[
                    const _DoctorAvatar(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            greeting,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.90),
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: MEDIUM_SPACE),
          _NotificationButton(
            unreadNotifications: unreadNotifications,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Foto profil dokter',
      image: true,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.40),
            width: 2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/amanah/auth/auth_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(
                color: const Color(0xFF0A44FF).withValues(alpha: 0.30),
                alignment: Alignment.center,
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.unreadNotifications,
    required this.onTap,
  });

  final int unreadNotifications;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Notifikasi',
      child: SizedBox(
        width: 44,
        height: 44,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Material(
              color: Colors.white.withValues(alpha: 0.10),
              shape: CircleBorder(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.30)),
              ),
              shadowColor: Colors.black.withValues(alpha: 0.12),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                    if (unreadNotifications > 0)
                      Positioned(
                        top: SMALL_SPACE,
                        right: SMALL_SPACE,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.60),
                              width: 2,
                            ),
                          ),
                          child: const SizedBox(width: 8, height: 8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
