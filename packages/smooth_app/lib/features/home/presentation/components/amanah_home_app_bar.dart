import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';

/// Organism: DoctorProfileHeader App Bar matching DoctorProfileHeader.tsx (.web)
/// Renders doctor avatar, doctor name with drop shadow, greeting, and frosted unread notification bell.
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
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Doctor Profile Identity Group (Avatar + Name + Greeting)
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 19.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              height: 1.1,
                              shadows: <Shadow>[
                                Shadow(
                                  color: Color(0x33000000),
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            greeting,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xE6FFFFFF), // text-white/90
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13.0,
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
          const SizedBox(width: 12),

          // Notification Bell Button (Frosted Capsule: w-10 h-10, bg-white/10, border white/15)
          _NotificationButton(
            unreadNotifications: unreadNotifications,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}

/// Atom: Doctor Avatar with circular border and fallback hero asset
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
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/amanah/images/woman-signin-hero.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(
                color: const Color(0xFF0D66E9).withValues(alpha: 0.40),
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

/// Atom: Frosted Notification Bell Button
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.0,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                if (unreadNotifications > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
